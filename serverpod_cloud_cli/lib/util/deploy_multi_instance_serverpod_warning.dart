import 'package:ground_control_client/ground_control_client.dart'
    show Client, ComputeInfo;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/constants.dart' show VersionConstants;

/// True when the pubspec's Serverpod constraint does not allow any
/// [VersionConstants.serverpodMultiInstanceSafeMinVersion] or newer release.
bool serverpodConstraintPrecludesMultiInstanceSafeRelease(
  final String? serverpodVersionConstraint,
) {
  if (serverpodVersionConstraint == null) {
    return false;
  }
  try {
    final projectConstraint = VersionConstraint.parse(
      serverpodVersionConstraint,
    );
    final fromSafe = VersionConstraint.parse(
      '>=${VersionConstants.serverpodMultiInstanceSafeMinVersion}',
    );
    return !projectConstraint.allowsAny(fromSafe);
  } on FormatException {
    return false;
  }
}

/// True when compute is configured for more than one running instance
/// at minimum or maximum scale.
bool computeUsesMoreThanOneInstance(final ComputeInfo compute) =>
    compute.minInstances > 1 || compute.maxInstances > 1;

/// When the project cannot resolve to Serverpod
/// [VersionConstants.serverpodMultiInstanceSafeMinVersion]+ and the capsule
/// is scaled beyond a single instance, logs a warning. Failures reading
/// compute are ignored (debug log only).
Future<void> warnIfLegacyServerpodWithMultipleInstances({
  required final Client cloudApiClient,
  required final String projectId,
  required final CommandLogger logger,
  required final String? serverpodVersionConstraint,
}) async {
  if (!serverpodConstraintPrecludesMultiInstanceSafeRelease(
    serverpodVersionConstraint,
  )) {
    return;
  }
  try {
    final compute = await cloudApiClient.compute.readCompute(
      cloudCapsuleId: projectId,
    );
    if (!computeUsesMoreThanOneInstance(compute)) {
      return;
    }
    logger.warning(
      'Multiple server instances are enabled, but your Serverpod constraint does not allow it. '
      'Upgrade to Serverpod ${VersionConstants.serverpodMultiInstanceSafeMinVersion} '
      'or later to reduce the risk of disruption during scaling and deployment.',
      newParagraph: true,
    );
  } on Exception catch (e) {
    logger.debug(
      'Could not read compute configuration for legacy Serverpod scaling '
      'warning: $e',
    );
  }
}
