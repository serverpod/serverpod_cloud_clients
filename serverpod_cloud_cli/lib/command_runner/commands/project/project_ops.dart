import 'package:collection/collection.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/dart_version_util.dart';
import 'package:serverpod_cloud_cli/util/project_files_writer.dart';

class CreatedPlan {
  final UuidValue subscriptionId;
  final String planDisplayName;

  const CreatedPlan({
    required this.subscriptionId,
    required this.planDisplayName,
  });
}

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

  /// Resolves or procures the subscription the new project will be created under.
  static Future<CreatedPlan> createPlan(
    Client cloudApiClient, {
    required PlanProfile? plan,
  }) async {
    if (plan == null) {
      late final List<SubscriptionInfo> subscriptions;
      try {
        subscriptions = await cloudApiClient.plans.listSubscriptions();
      } on Exception catch (e, s) {
        throw FailureException.nested(e, s, 'Request to list plans failed');
      }
      if (subscriptions.isNotEmpty) {
        final legacySubscription = subscriptions
            .where(
              (s) =>
                  _legacyPlanNames.contains(s.planProductId.split(':').first),
            )
            .firstOrNull;
        if (legacySubscription != null) {
          return CreatedPlan(
            subscriptionId: legacySubscription.subscriptionId,
            planDisplayName: legacySubscription.planDisplayName,
          );
        }
      }
    }

    final planProductName = plan?.name ?? defaultPlan;
    try {
      final subscriptionId = await cloudApiClient.plans.procurePlan(
        planProductName: planProductName,
      );
      return CreatedPlan(
        subscriptionId: subscriptionId,
        planDisplayName: planProductName,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Request to procure a plan failed');
    }
  }

  /// Registers a new tenant project under [subscriptionId].
  static Future<Map<String, Object?>> createProject(
    Client cloudApiClient, {
    required String projectId,
    required UuidValue subscriptionId,
    required PlanProfile? plan,
  }) async {
    try {
      await cloudApiClient.projects.createProject(
        cloudProjectId: projectId,
        projectProductName: plan?.projectProductName,
        underSubscriptionId: subscriptionId,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Request to create a new project failed',
      );
    }

    return {'projectId': projectId};
  }

  /// Requests database creation for an existing project.
  static Future<Map<String, Object?>> createDatabase(
    Client cloudApiClient, {
    required String projectId,
  }) async {
    try {
      await cloudApiClient.database.enableDatabase(cloudCapsuleId: projectId);
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Request to create a database for the new project failed',
      );
    }

    return {'projectId': projectId};
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

  static Future<Map<String, Object?>> linkProject(
    Client cloudApiClient, {
    required String projectId,
    required String projectDirectory,
    required String configFilePath,
    String? dartVersionOverride,
    List<String> preDeployScripts = const [],
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

    ProjectFilesWriter.writeFiles(
      projectId: projectId,
      preDeployScripts: preDeployScripts,
      configFilePath: configFilePath,
      projectDirectory: projectDirectory,
      dartSdk: safeDartSdk,
    );
    return {'projectId': projectId};
  }
}
