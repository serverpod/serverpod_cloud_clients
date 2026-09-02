import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/dart_version_util.dart'
    show ensureValidVersionConstraint, platformFaultHint;

typedef _SourcedConstraint = ({
  String value,
  String source,
  VersionConstraint constraint,
});

abstract final class DartSdkSelector {
  /// Selects the Dart SDK minor version to build a deployment with,
  /// such as `3.13`.
  ///
  /// [supportedSdkMinorVersions] are the minor versions Serverpod Cloud supports,
  /// such as `['3.11', '3.12', '3.13']`.
  ///
  /// The requested version is the first of [commandLineVersion],
  /// [scloudVersion], [toolVersionsVersion] and [pubspecVersionConstraint]
  /// that holds a value. The rest are ignored.
  /// [lockVersionConstraint] is not a request: whichever version is selected must
  /// satisfy it too, since a build resolves against the lockfile.
  ///
  /// Every value is a version or a pub-style constraint, such as `3.13`,
  /// `3.13.2` or `>=3.11.0 <4.0.0`. A supported version satisfies a value when
  /// its minor line overlaps it, which is how a version maps to a build image.
  ///
  /// Returns the highest version of [supportedSdkMinorVersions] that satisfies both
  /// the requested version and [lockVersionConstraint].
  ///
  /// Throws [FailureException] if a value cannot be parsed, if
  /// [supportedSdkMinorVersions] is empty, or if no supported version satisfies both.
  static String selectDartSdkVersion({
    required List<String> supportedSdkMinorVersions,
    String? commandLineVersion,
    String? scloudVersion,
    String? toolVersionsVersion,
    String? pubspecVersionConstraint,
    String? lockVersionConstraint,
  }) {
    final constraints = [
      ?_firstConstraint([
        (commandLineVersion, '--dart-version flag'),
        (scloudVersion, 'scloud.yaml'),
        (toolVersionsVersion, '.tool-versions'),
        (pubspecVersionConstraint, 'pubspec.yaml'),
      ]),
      ?_constraint(lockVersionConstraint, 'pubspec.lock'),
    ];

    final minorVersions = _minorVersionsOf(supportedSdkMinorVersions);

    for (final minorVersion in minorVersions.reversed) {
      final minorLine = VersionRange(
        min: minorVersion,
        includeMin: true,
        max: Version(minorVersion.major, minorVersion.minor + 1, 0),
      );
      final satisfiesAll = constraints.every(
        (constraint) => constraint.constraint.allowsAny(minorLine),
      );
      if (satisfiesAll) {
        return '${minorVersion.major}.${minorVersion.minor}';
      }
    }

    throw FailureException(
      error:
          'No Dart SDK version supported by Serverpod Cloud satisfies the '
          'Dart SDK version constraints of the project:\n'
          '${constraints.map((c) => '  ${c.value} (from ${c.source})').join('\n')}\n'
          'Available Dart SDK versions: ${supportedSdkMinorVersions.join(', ')}.',
      hint:
          'Change the requested Dart SDK version, or the Dart SDK constraints '
          'of the project, so that they agree.',
    );
  }

  /// The constraint of the first source that holds a value, or null if none do.
  static _SourcedConstraint? _firstConstraint(List<(String?, String)> sources) {
    for (final (value, source) in sources) {
      final constraint = _constraint(value, source);
      if (constraint != null) {
        return constraint;
      }
    }
    return null;
  }

  /// The constraint [value] expresses, or null if [value] holds no value.
  ///
  /// A bare minor version such as `3.13` means the version `3.13.0`, which the
  /// minor line of `3.13` contains.
  ///
  /// Throws [FailureException] if [value] cannot be parsed.
  static _SourcedConstraint? _constraint(String? value, String source) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    final bareMinorVersion = RegExp(r'^\d+\.\d+$');

    final normalized = bareMinorVersion.hasMatch(trimmed)
        ? '$trimmed.0'
        : trimmed;
    ensureValidVersionConstraint(
      normalized,
      sourceDescription: '(from $source)',
    );

    return (
      value: trimmed,
      source: source,
      constraint: VersionConstraint.parse(normalized),
    );
  }

  /// The start version of every minor line in [minorVersions], such as `3.13.0`
  /// for `3.13`, ordered lowest to highest. Unparseable versions are left out.
  ///
  /// Throws [FailureException] if that leaves no versions to select from.
  static List<Version> _minorVersionsOf(List<String> minorVersions) {
    final versions = <Version>[
      for (final minorVersion in minorVersions)
        if (_minorVersionOf(minorVersion) case final Version version) version,
    ]..sort();

    if (versions.isEmpty) {
      throw FailureException(
        error: 'Serverpod Cloud reported no supported Dart SDK versions.',
        hint: platformFaultHint,
      );
    }
    return versions;
  }

  static Version? _minorVersionOf(String minorVersion) {
    final parts = minorVersion.trim().split('.');
    if (parts.length < 2) {
      return null;
    }
    final major = int.tryParse(parts[0]);
    final minor = int.tryParse(parts[1]);
    if (major == null || minor == null) {
      return null;
    }
    return Version(major, minor, 0);
  }
}
