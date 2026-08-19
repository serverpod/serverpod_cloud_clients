import 'package:ground_control_client/ground_control_client.dart' show Client;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

/// The Dart SDK version policy of Serverpod Cloud,
/// as fetched from the server for client-side validation.
final class SupportedDartSdkPolicy {
  /// The supported Dart SDK version range.
  final VersionConstraint supportedRange;

  /// The supported Dart SDK minor versions, ordered lowest to highest.
  final List<String> supportedVersions;

  /// URL of the documentation page describing the Dart SDK version support.
  final Uri documentationUrl;

  SupportedDartSdkPolicy({
    required this.supportedRange,
    required this.supportedVersions,
    required this.documentationUrl,
  });

  /// Lines listing the supported versions and the documentation page,
  /// for inclusion in validation error messages.
  String get availabilityDescription =>
      'Available Dart SDK versions: ${supportedVersions.join(', ')}.\n'
      'See: $documentationUrl';
}

/// Fetches the Dart SDK version policy from Serverpod Cloud.
///
/// Returns null if the policy cannot be fetched or is invalid, such as on a
/// network error or a server that does not serve the policy endpoint. The
/// caller should then skip policy-based validation - the server enforces
/// the policy when the deployment is created.
Future<SupportedDartSdkPolicy?> fetchSupportedDartSdkPolicy(
  final Client cloudApiClient, {
  required final CommandLogger logger,
}) async {
  try {
    final policy = await cloudApiClient.platform.getDartSdkVersionPolicy();
    final min = Version.parse(policy.minVersionInclusive);
    final max = Version.parse(policy.maxVersionExclusive);
    if (min >= max) {
      logger.debug(
        'Skipping Dart SDK version validation: invalid policy range $min..$max',
      );
      return null;
    }
    return SupportedDartSdkPolicy(
      supportedRange: VersionRange(min: min, includeMin: true, max: max),
      supportedVersions: [
        for (final version in policy.supportedVersions) version.version,
      ],
      documentationUrl: policy.documentationUrl,
    );
  } on Exception catch (e) {
    logger.debug('Skipping Dart SDK version validation: $e');
    return null;
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

/// Optional `dartVersion` for deploy.
/// It only checks constraint syntax.
/// The GC server will resolve it to a supported dart image tag.
final class ProjectDartVersionHint {
  const ProjectDartVersionHint._();

  static final RegExp _bareMajorMinorOverride = RegExp(r'^\d+\.\d+$');

  static String? resolveDartVersionForDeploy({
    required final String? override,
    required final String? configDartSdk,
    required final Iterable<String? Function()> lazyVersionSources,
  }) {
    final fromOverride = _nonBlank(normalizeBareMajorMinorOverride(override));
    if (fromOverride != null) {
      ensureValidVersionConstraint(
        fromOverride,
        sourceDescription: '(from --dart-version flag)',
      );
      return fromOverride;
    }
    final fromConfig = _nonBlank(configDartSdk);
    if (fromConfig != null) {
      ensureValidVersionConstraint(
        fromConfig,
        sourceDescription: '(from scloud.yaml)',
      );
      return fromConfig;
    }
    for (final source in lazyVersionSources) {
      final candidate = _nonBlank(source());
      if (candidate != null) {
        ensureValidVersionConstraint(candidate);
        return candidate;
      }
    }
    return null;
  }

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

  static String? _nonBlank(final String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
