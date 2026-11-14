import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/constants.dart'
    show ProjectConfigFileConstants;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract final class FlutterSdkSelector {
  static final _releaseVersion = RegExp(r'^\d{1,4}\.\d{1,4}\.\d{1,4}$');

  /// The source of a version read from the Flutter SDK installed on this
  /// machine, as messages name it.
  static const localSource = 'local Flutter SDK';

  /// Selects the Flutter release version to build an app with, such as
  /// `3.38.4`.
  ///
  /// The requested version is the first of [commandLineVersion],
  /// [pubspecVersionConstraint], [scloudVersion] and [localVersion] that
  /// holds a value. The rest are ignored.
  ///
  /// [localVersion] is the version of the Flutter SDK installed on this
  /// machine, which the app is built with locally.
  ///
  /// [scloudVersion] comes from the project configuration file
  /// [scloudFileName], which messages name as its source.
  ///
  /// A value is a Flutter release version.
  ///
  /// [pubspecVersionConstraint] is a request only when it pins a single
  /// version, such as `3.38.4`. A range or a caret constraint requests no
  /// version, but the selected version must satisfy its lower bound, as
  /// the app itself needs it. A constraint that cannot be parsed is ignored.
  ///
  /// [lockVersionConstraint] is not a request: the selected version must
  /// satisfy its lower bound, since the app's packages need it. Its upper
  /// bound is not enforced, as the Flutter SDK enforces only the lower
  /// bound of a Flutter constraint.
  ///
  /// Returns null when no version is requested.
  ///
  /// Throws [FailureException] if the requested value is not a release
  /// version, such as a local Flutter SDK on the beta channel, if
  /// [lockVersionConstraint] cannot be parsed, or if the
  /// selected version is below [lockVersionConstraint] or
  /// [pubspecVersionConstraint].
  static String? selectFlutterVersion({
    String? commandLineVersion,
    String? scloudVersion,
    String scloudFileName = ProjectConfigFileConstants.defaultFileName,
    String? pubspecVersionConstraint,
    String? localVersion,
    String? lockVersionConstraint,
  }) {
    return selectFlutterVersionWithSource(
      commandLineVersion: commandLineVersion,
      scloudVersion: scloudVersion,
      scloudFileName: scloudFileName,
      pubspecVersionConstraint: pubspecVersionConstraint,
      localVersion: localVersion,
      lockVersionConstraint: lockVersionConstraint,
    )?.version;
  }

  /// Selects the Flutter release version to build an app with, as
  /// [selectFlutterVersion] does, together with the source it was
  /// requested in, such as `scloud.yaml`.
  ///
  /// Returns null when no version is requested.
  ///
  /// Throws [FailureException] in the cases [selectFlutterVersion] does.
  static ({String version, String source})? selectFlutterVersionWithSource({
    String? commandLineVersion,
    String? scloudVersion,
    String scloudFileName = ProjectConfigFileConstants.defaultFileName,
    String? pubspecVersionConstraint,
    String? localVersion,
    String? lockVersionConstraint,
  }) {
    final requested = _firstRequested([
      (commandLineVersion, '--flutter-version flag'),
      (_singleVersion(pubspecVersionConstraint), 'pubspec.yaml'),
      (scloudVersion, scloudFileName),
      (localVersion, localSource),
    ]);
    if (requested == null) {
      return null;
    }

    final (value, source) = requested;
    final selected = _normalize(value);
    if (selected == null) {
      throw FailureException(
        error: 'Unsupported Flutter version "$value" (from $source).',
        hint:
            'Use a Flutter release version such as 3.38.4 with '
            '--flutter-version, or pin one in environment.flutter of the '
            "app's pubspec.yaml.",
      );
    }

    final minVersion = _lowerBound(lockVersionConstraint);
    if (minVersion != null && !minVersion.allows(Version.parse(selected))) {
      throw FailureException(
        error:
            'The Flutter version $selected (from $source) is below the '
            'Flutter SDK constraint "${lockVersionConstraint?.trim()}" '
            "of the app's packages (from pubspec.lock).",
        hint:
            'Request Flutter ${_firstReleaseFrom(minVersion)} or later, or '
            'change the Flutter SDK constraints of the app.',
      );
    }

    final pubspecMinVersion = _pubspecLowerBound(pubspecVersionConstraint);
    if (pubspecMinVersion != null &&
        !pubspecMinVersion.allows(Version.parse(selected))) {
      throw FailureException(
        error:
            'The Flutter version $selected (from $source) is below the '
            'Flutter SDK constraint "${pubspecVersionConstraint?.trim()}" '
            'of the app (from pubspec.yaml).',
        hint:
            'Request Flutter ${_firstReleaseFrom(pubspecMinVersion)} or '
            "later, or change environment.flutter in the app's pubspec.yaml.",
      );
    }
    return (version: selected, source: source);
  }

  /// The first source that holds a value, or null if none do.
  static (String, String)? _firstRequested(List<(String?, String)> sources) {
    for (final (value, source) in sources) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return (trimmed, source);
      }
    }
    return null;
  }

  /// [constraint] when it pins a single version, or else null.
  static String? _singleVersion(String? constraint) {
    final trimmed = constraint?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    try {
      return VersionConstraint.parse(trimmed) is Version ? trimmed : null;
    } on FormatException {
      return null;
    }
  }

  /// [value] when it is a release version, or else null.
  static String? _normalize(String value) {
    return _releaseVersion.hasMatch(value) ? value : null;
  }

  /// The versions at or above the lower bound of the pubspec [constraint],
  /// or null if it holds no value, no lower bound, or cannot be parsed.
  static VersionRange? _pubspecLowerBound(String? constraint) {
    try {
      return _lowerBound(constraint);
    } on FailureException {
      return null;
    }
  }

  /// The versions at or above the lower bound of [constraint], or null if
  /// [constraint] holds no value or no lower bound.
  ///
  /// Throws [FailureException] if [constraint] cannot be parsed.
  static VersionRange? _lowerBound(String? constraint) {
    final trimmed = constraint?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    final VersionConstraint parsed;
    try {
      parsed = VersionConstraint.parse(trimmed);
    } on FormatException {
      throw FailureException(
        error: 'Invalid Flutter SDK constraint "$trimmed" (from pubspec.lock).',
        hint: 'Run "flutter pub get" in the app directory.',
      );
    }

    if (parsed is! VersionRange) {
      return null;
    }
    final min = parsed.min;
    if (min == null) {
      return null;
    }
    return VersionRange(min: min, includeMin: parsed.includeMin);
  }

  /// The first release version that [range] allows, such as `3.18.0` for a
  /// range from `3.18.0-18.0.pre.54`.
  static Version _firstReleaseFrom(VersionRange range) {
    final min = range.min;
    if (min == null) {
      return Version.none;
    }
    final release = Version(min.major, min.minor, min.patch);
    if (range.allows(release)) {
      return release;
    }
    return min.nextPatch;
  }
}
