import 'package:collection/collection.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/status/status_ops.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/shared/user_interaction/user_confirmations.dart';
import 'package:serverpod_cloud_cli/util/dart_version_util.dart';
import 'package:serverpod_cloud_cli/util/project_files_writer.dart';

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
    Client cloudApiClient, {
    required CommandLogger logger,
    required PlanProfile? plan,
  }) async {
    final planNames = await cloudApiClient.plans.listProcuredPlanNames();

    if (plan == null &&
        planNames.any((name) => _legacyPlanNames.contains(name))) {
      return;
    }

    final planProductName = plan?.name ?? defaultPlan;

    await cloudApiClient.plans.checkPlanAvailability(
      planProductName: planProductName,
    );
  }

  /// Subcommand to create a new tenant project.
  static Future<void> createProject(
    Client cloudApiClient, {
    required CommandLogger logger,
    required String projectId,
    required PlanProfile? plan,
    required bool enableDb,
    bool skipConfirmation = false,
    bool suppressCommandMessages = false,
  }) async {
    if (!skipConfirmation) {
      await UserConfirmations.confirmNewProjectCostAcceptance(logger);
    }

    UuidValue? subscriptionId;
    if (plan == null) {
      // If no plan is specified and user has a legacy plan, use that.
      final subscriptions = await cloudApiClient.plans.listSubscriptions();
      if (subscriptions.isNotEmpty) {
        final legacySubscription = subscriptions
            .where(
              (s) =>
                  _legacyPlanNames.contains(s.planProductId.split(':').first),
            )
            .firstOrNull;
        if (legacySubscription != null) {
          if (!suppressCommandMessages) {
            logger.init('Creating Serverpod Cloud project "$projectId".');
            logger.info('On plan: ${legacySubscription.planDisplayName}');
          }
          subscriptionId = legacySubscription.subscriptionId;
        }
      }
    }

    if (subscriptionId == null) {
      final planProductName = plan?.name ?? defaultPlan;
      subscriptionId = await cloudApiClient.plans.procurePlan(
        planProductName: planProductName,
      );
      if (!suppressCommandMessages) {
        logger.init('Creating Serverpod Cloud project "$projectId".');
        logger.info('On plan: $planProductName');
      }
    }

    try {
      await logger.progress(
        'Registering Serverpod Cloud project',
        successMessage: 'Project registration successful.',
        padRight: StatusCommands.progressMessagePadLength,
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
      await logger.progress(
        'Requesting database creation',
        successMessage: 'Database creation request sent.',
        padRight: StatusCommands.progressMessagePadLength,
        () async {
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
        },
      );
    }

    if (!suppressCommandMessages) {
      logger.success('Serverpod Cloud project created.', newParagraph: true);
    }
  }

  static Future<Map<String, Object?>> deleteProject(
    final Client cloudApiClient, {
    required final String projectId,
  }) async {
    try {
      await cloudApiClient.projects.deleteProject(cloudProjectId: projectId);
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Request to delete the project failed',
      );
    }

    return {'projectId': projectId};
  }

  static Future<List<ProjectInfo>> listProjectsOperation(
    Client cloudApiClient, {
    bool showArchived = false,
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
        : projects.where((p) => p.project.archivedAt == null);

    return activeProjects.sortedBy((p) => p.project.createdAt).toList();
  }

  static Future<String?> linkProject(
    Client cloudApiClient, {
    required CommandLogger logger,
    required String projectId,
    required String projectDirectory,
    required String configFilePath,
    String? dartVersionOverride,
    List<String> preDeployScripts = const [],
    bool suppressCommandMessages = false,
  }) async {
    final safeDartSdk = ProjectDartVersionHint.normalizeBareMajorMinorOverride(
      dartVersionOverride,
    );
    if (safeDartSdk != null) {
      ensureValidVersionConstraint(
        safeDartSdk,
        sourceDescription: '(from --dart-version flag)',
      );
    }

    await logger.progress(
      'Writing cloud configuration files',
      successMessage: 'Configuration files written.',
      padRight: StatusCommands.progressMessagePadLength,
      () async {
        ProjectFilesWriter.writeFiles(
          projectId: projectId,
          preDeployScripts: preDeployScripts,
          configFilePath: configFilePath,
          projectDirectory: projectDirectory,
          dartSdk: safeDartSdk,
        );
        return true;
      },
    );

    if (!suppressCommandMessages) {
      logger.success('Linked Serverpod Cloud project.', newParagraph: true);
    }

    return safeDartSdk;
  }
}
