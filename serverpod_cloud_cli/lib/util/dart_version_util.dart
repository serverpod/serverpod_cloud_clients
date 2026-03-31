import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

const _dartSdkDocsUrl =
    'https://docs.serverpod.cloud/guides/deployment/dart-sdk-versions';

/// Validates that [version] is a valid Dart SDK version within the supported range.
///
/// Throws [FailureException] if [version] is malformed or outside
/// [VersionConstants.supportedSdkConstraint].
void validateDartVersion(final String version) {
  final Version parsed;
  try {
    parsed = Version.parse(version);
  } catch (_) {
    throw FailureException(
      error: 'Invalid Dart SDK version: "$version".',
      hint: 'Use a valid version. See: $_dartSdkDocsUrl',
    );
  }

  final constraint = VersionConstraint.parse(
    VersionConstants.supportedSdkConstraint,
  );
  if (!constraint.allows(parsed)) {
    throw FailureException(
      error:
          'Dart SDK version "$version" is outside the supported range '
          '(${VersionConstants.supportedSdkConstraint}).',
      hint: 'See: $_dartSdkDocsUrl',
    );
  }
}
