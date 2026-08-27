import 'package:ground_control_client/ground_control_client.dart' show Client;
import 'package:pub_semver/pub_semver.dart' show VersionConstraint;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

/// Hint for failures that the project cannot do anything about.
const platformFaultHint =
    'This is a problem with Serverpod Cloud, not with your project. '
    'Please try again later.';

/// Fetches the Dart SDK minor versions supported by Serverpod Cloud,
/// such as `['3.11', '3.12', '3.13']`, ordered lowest to highest.
///
/// Throws [FailureException] if they cannot be fetched, such as on a network
/// error or a server that does not serve the policy endpoint.
/// A deployment cannot select a Dart SDK version without them.
Future<List<String>> fetchSupportedDartSdkVersions(
  final Client cloudApiClient,
) async {
  try {
    final policy = await cloudApiClient.platform.getDartSdkVersionPolicy();
    return [for (final version in policy.supportedVersions) version.version];
  } on Exception catch (e, stackTrace) {
    throw FailureException(
      error:
          'Could not fetch the Dart SDK versions supported by Serverpod Cloud.',
      hint: platformFaultHint,
      reason: e.toString(),
      nestedException: e,
      nestedStackTrace: stackTrace,
    );
  }
}

/// Throws [FailureException] if [value] is not a parseable [VersionConstraint].
void ensureValidVersionConstraint(
  final String value, {
  final String? sourceDescription,
}) {
  final trimmed = value.trim();
  try {
    VersionConstraint.parse(trimmed);
  } on FormatException {
    throw FailureException(
      error:
          'Invalid Dart SDK version constraint: "$trimmed"${sourceDescription != null ? ' $sourceDescription' : ''}.',
      hint:
          'Use a valid pub-style constraint such as ^3.10.0, >=3.9.0 <4.0.0, or 3.9.2.',
    );
  }
}

/// Normalization of Dart SDK version strings written to project files.
final class ProjectDartVersionHint {
  const ProjectDartVersionHint._();

  static final RegExp _bareMajorMinorOverride = RegExp(r'^\d+\.\d+$');

  static String? normalizeBareMajorMinorOverride(final String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    if (_bareMajorMinorOverride.hasMatch(trimmed)) {
      return '$trimmed.0';
    }
    return trimmed;
  }
}
