import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/tool_versions_reader.dart';

abstract final class DartVersionResolver {
  /// Resolves the Dart SDK version to use for building a project.
  ///
  /// Resolution order (first non-null wins):
  /// 1. [cliOverride] – from `--dart-version` flag
  /// 2. [scloudDartVersion] – from `scloud.yaml` `dartVersion`
  /// 3. `.tool-versions` dart entry in [rootDirectory]
  /// 4. Pubspec fallback: lowest version from [pubspecSdkConstraint] that
  ///    satisfies [VersionConstants.supportedSdkConstraint]
  ///
  /// The resolved version is validated against [VersionConstants.supportedSdkConstraint].
  /// Throws [FailureException] if the resolved version is outside the supported range.
  static String resolve({
    required final Directory rootDirectory,
    required final VersionConstraint? pubspecSdkConstraint,
    final String? cliOverride,
    final String? scloudDartVersion,
  }) {
    final resolved =
        cliOverride ??
        scloudDartVersion ??
        ToolVersionsReader.readDartVersion(rootDirectory) ??
        _resolveFromPubspec(pubspecSdkConstraint);

    _validateVersion(resolved);
    return resolved;
  }

  static String _resolveFromPubspec(
    final VersionConstraint? sdkConstraint,
  ) {
    if (sdkConstraint == null) {
      return VersionConstants.minSupportedSdkVersion;
    }

    final supported = VersionConstraint.parse(
      VersionConstants.supportedSdkConstraint,
    );
    final intersection = supported.intersect(sdkConstraint);

    if (intersection.isEmpty) {
      return VersionConstants.minSupportedSdkVersion;
    }

    final min = _extractMin(intersection);
    if (min == null) {
      return VersionConstants.minSupportedSdkVersion;
    }
    return min.toString();
  }

  static Version? _extractMin(final VersionConstraint constraint) {
    if (constraint is Version) {
      return constraint;
    }
    if (constraint is VersionRange) {
      final min = constraint.min;
      if (min == null) return null;
      if (constraint.includeMin) return min;
      return Version(min.major, min.minor, min.patch + 1);
    }
    if (constraint is VersionUnion) {
      final first = constraint.ranges.first;
      return _extractMin(first);
    }
    return null;
  }

  static void _validateVersion(final String version) {
    final Version parsed;
    try {
      parsed = Version.parse(version);
    } catch (_) {
      throw FailureException(
        error: 'Invalid Dart SDK version: "$version".',
        hint: 'Use a version like "3.9.0" or "3.10.1".',
      );
    }

    final supported = VersionConstraint.parse(
      VersionConstants.supportedSdkConstraint,
    );
    if (!supported.allows(parsed)) {
      throw FailureException(
        error:
            'Dart SDK version "$version" is outside the supported range '
            '(${VersionConstants.supportedSdkConstraint}).',
        hint:
            'Use a Dart SDK version within the supported range. '
            'Run `scloud deploy --help` for more information.',
      );
    }
  }
}
