import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

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
