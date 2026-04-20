import 'dart:io';

import 'package:collection/collection.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/shared/user_interaction/user_confirmations.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';
import 'package:serverpod_cloud_cli/util/project_files_writer.dart';
import 'package:serverpod_cloud_cli/util/dart_version_util.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart'
    show resolveProjectDartSdkVersion;

enum PlanProfile {
  starter('starter', 'starter', 'starter-project'),
  growth('growth', 'growth', 'growth-project');

  const PlanProfile(this.name, this.planProductName, this.projectProductName);

  final String name;
  final String planProductName;
  final String projectProductName;
}

abstract class ProjectCommands {
  static const defaultPlan = 'starter';

  static const _legacyPlanNames = [
    'early-access',
    'closed-beta',
    'internal-test-runs',
    'internal-payment-testing',
  ];

  /// Subcommand to check if the user is subscribed to a given plan,
  /// and if not whether the plan can be procured.
  ///
  /// Throws [ProcurementDeniedException] if there is no subscription and the
  /// plan cannot be procured.
  static Future<void> checkPlanAvailability(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final PlanProfile? plan,
  }) async {
    final planNames = await cloudApiClient.plans.listProcuredPlanNames();

    if (plan == null &&
        planNames.any((final name) => _legacyPlanNames.contains(name))) {
      return;
    }

    final planProductName = plan?.name ?? defaultPlan;

    await cloudApiClient.plans.checkPlanAvailability(
      planProductName: planProductName,
    );
  }

  /// Subcommand to create a new tenant project.
  static Future<void> createProject(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
    required final PlanProfile? plan,
    required final bool enableDb,
    required final String projectDir,
    required final String configFilePath,
    final bool skipConfirmation = false,
  }) async {
    if (!skipConfirmation) {
      await UserConfirmations.confirmNewProjectCostAcceptance(logger);
    }

    String? subscriptionId;
    if (plan == null) {
      // If no plan is specified and user has a legacy plan, use that.
      final subscriptions = await cloudApiClient.plans.listSubscriptions();
      if (subscriptions.isNotEmpty) {
        final legacySubscription = subscriptions
            .where(
              (final s) =>
                  _legacyPlanNames.contains(s.planProductId.split(':').first),
            )
            .firstOrNull;
        if (legacySubscription != null) {
          logger.init('Creating Serverpod Cloud project "$projectId".');
          logger.info('On plan: ${legacySubscription.planDisplayName}');
          subscriptionId = legacySubscription.subscriptionId;
        }
      }
    }

    if (subscriptionId == null) {
      final planProductName = plan?.name ?? defaultPlan;
      subscriptionId = await cloudApiClient.plans.procurePlan(
        planProductName: planProductName,
      );
      logger.init('Creating Serverpod Cloud project "$projectId".');
      logger.info('On plan: $planProductName');
    }

    try {
      await logger.progress(
        'Registering Serverpod Cloud project.',
        newParagraph: true,
        () async {
          await cloudApiClient.projects.createProject(
            cloudProjectId: projectId,
            projectProductName: plan?.projectProductName,
            underSubscriptionId: subscriptionId,
          );
          return true;
        },
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Request to create a new project failed',
      );
    }

    if (enableDb) {
      await logger.progress('Requesting database creation.', () async {
        try {
          await cloudApiClient.database.enableDatabase(
            cloudCapsuleId: projectId,
          );
          return true;
        } on Exception catch (e, s) {
          throw FailureException.nested(
            e,
            s,
            'Request to create a database for the new project failed',
          );
        }
      });
    }

    logger.success('Serverpod Cloud project created.', newParagraph: true);
  }

  static Future<void> deleteProject(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
  }) async {
    final shouldDelete = await logger.confirm(
      'Are you sure you want to delete the project "$projectId"?',
      defaultValue: false,
    );

    if (!shouldDelete) {
      throw UserAbortException();
    }

    try {
      await cloudApiClient.projects.deleteProject(cloudProjectId: projectId);
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Request to delete the project failed',
      );
    }

    logger.success('Deleted the project "$projectId".', newParagraph: true);
  }

  static Future<void> listProjects(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    final bool showArchived = false,
  }) async {
    late List<ProjectInfo> projects;
    try {
      projects = await cloudApiClient.projects.listProjectsInfo(
        includeLatestDeployAttemptTime: true,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Request to list projects failed');
    }

    final activeProjects = showArchived
        ? projects
        : projects.where((final p) => p.project.archivedAt == null);

    if (activeProjects.isEmpty) {
      logger.info('No projects available.');
      return;
    }

    final tablePrinter = TablePrinter();
    tablePrinter.addHeaders([
      'Project Id',
      'Created At',
      'Last Deploy Attempt',
      if (showArchived) 'Deleted At',
    ]);
    for (final project in activeProjects.sortedBy(
      (final p) => p.project.createdAt,
    )) {
      tablePrinter.addRow([
        project.project.cloudProjectId,
        project.project.createdAt.toString().substring(0, 19),
        project.latestDeployAttemptTime?.timestamp?.toString().substring(0, 19),
        if (showArchived)
          project.project.archivedAt?.toString().substring(0, 19),
      ]);
    }
    tablePrinter.writeLines(logger.line);
  }

  static Future<void> linkProject(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
    required final String projectDirectory,
    required final String configFilePath,
    final String? dartVersionOverride,
  }) async {
    final resolvedDartSdk =
        dartVersionOverride ??
        resolveProjectDartSdkVersion(Directory(projectDirectory));
    validateDartVersion(resolvedDartSdk);

    await logger.progress(
      'Writing cloud project configuration files.',
      () async {
        ProjectFilesWriter.writeFiles(
          projectId: projectId,
          preDeployScripts: [],
          configFilePath: configFilePath,
          projectDirectory: projectDirectory,
          dartSdk: resolvedDartSdk,
        );
        return true;
      },
    );

    logger.success('Linked Serverpod Cloud project.', newParagraph: true);
  }

  static Future<void> inviteUser(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
    required final String email,
    required final List<String> assignRoleNames,
  }) async {
    try {
      await cloudApiClient.projects.inviteUser(
        cloudProjectId: projectId,
        email: email,
        assignRoleNames: assignRoleNames,
      );
    } on NotFoundException catch (e) {
      throw FailureException(error: e.message);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to invite user to project');
    }

    logger.success(
      'User invited to the project with roles: ${assignRoleNames.join(', ')}.',
      newParagraph: true,
    );
  }

  static Future<void> revokeUser(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
    required final String email,
    final List<String> unassignRoleNames = const [],
    final bool unassignAllRoles = false,
  }) async {
    final List<String> actuallyUnassigned;
    try {
      actuallyUnassigned = await cloudApiClient.projects.revokeUser(
        cloudProjectId: projectId,
        email: email,
        unassignRoleNames: unassignRoleNames,
        unassignAllRoles: unassignAllRoles,
      );
    } on NotFoundException catch (e) {
      throw FailureException(error: e.message);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to revoke user from project');
    }

    if (actuallyUnassigned.isEmpty) {
      logger.info(
        unassignAllRoles
            ? 'The user has no access roles to revoke on the project.'
            : 'The user does not have any of the specified project roles.',
      );
    } else {
      logger.success(
        unassignAllRoles
            ? 'Revoked all access roles of the user from the project: ${actuallyUnassigned.join(', ')}'
            : 'Revoked access roles of the user from the project: ${actuallyUnassigned.join(', ')}',
        newParagraph: true,
      );
    }
  }
}
