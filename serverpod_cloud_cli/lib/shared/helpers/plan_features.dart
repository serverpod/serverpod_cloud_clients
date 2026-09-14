import 'package:ground_control_client/ground_control_client.dart'
    show ProcurementDeniedException, ProcurementDeniedReason;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/shared/helpers/console_urls.dart';

/// A feature that the Starter plan does not include.
enum PlanFeature {
  databaseBackups('Database backups are available on the Growth plan.'),
  customDomains('Custom domains are available on the Growth plan.'),
  userInvites('Inviting users to a project is available on the Growth plan.'),
  additionalStorages('Additional storages are available on the Growth plan.');

  const PlanFeature(this.availability);

  /// States the plan that includes the feature.
  final String availability;

  /// The hint that tells the user how to get the feature for [projectId].
  String upgradeHint(final String projectId) =>
      '$availability\nTo upgrade, visit: ${getProjectPlanUrl(projectId)}';
}

/// Maps a [ProcurementDeniedException] to the failure shown to the user.
///
/// A denial because the plan of [projectId] does not include [feature] becomes
/// a failure with the server message and the plan upgrade hint. Any other
/// denial becomes a nested failure with [failureMessage].
FailureException planFeatureDeniedFailure(
  final ProcurementDeniedException e,
  final StackTrace s, {
  required final PlanFeature feature,
  required final String projectId,
  required final String failureMessage,
}) {
  if (e.reason != ProcurementDeniedReason.productNotAvailable) {
    return FailureException.nested(e, s, failureMessage);
  }

  return FailureException(
    error: e.message,
    hint: feature.upgradeHint(projectId),
  );
}
