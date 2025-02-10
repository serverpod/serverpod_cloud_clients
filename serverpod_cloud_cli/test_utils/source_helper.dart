import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

/// Gets the version from the specified pubspec.yaml,
/// or from the pubspec.yaml for the current process if no path is specified.
///
/// Getting the pubspec for the current process works only if running from source.
///
/// Returns null if not running from source or if pubspec.yaml is not found.
/// Throws [FormatException] if pubspec.yaml is found but it has no version field.
Version? getPubSpecVersion({
  final String? pubSpecPath,
}) {
  final String path;
  if (pubSpecPath != null) {
    path = pubSpecPath;
  } else {
    final packagePath = sourcePackagePath();
    if (packagePath == null) return null;
    path = p.join(packagePath, 'pubspec.yaml');
  }

  final pubspecFile = File(path);
  if (!pubspecFile.existsSync()) {
    return null;
  }

  final pubspec = Pubspec.parse(pubspecFile.readAsStringSync());
  final pubspecVersion = pubspec.version;
  if (pubspecVersion == null) {
    throw FormatException('Version not specified in $pubspecFile');
  }
  return pubspecVersion;
}

/// Returns the path to the package this process is running from
/// (assumed to be serverpod_cloud_cli by default),
/// or null if not running from source.
String? sourcePackagePath({
  final String packageName = 'serverpod_cloud_cli',
}) {
  final scriptPackagePath = _pathOfSegment(
    packageName,
    Platform.script.path,
  );
  if (scriptPackagePath != null) {
    return scriptPackagePath;
  }

  final cdPackagePath = _pathOfSegment(
    packageName,
    Directory.current.path,
  );
  if (cdPackagePath != null) {
    return cdPackagePath;
  }

  return null;
}

/// Returns the full path for the path segment within a path,
/// i.e. the first part of the path up to and including the segment.
/// Returns null if the segment is not found in the path.
String? _pathOfSegment(
  final String pathSegment,
  final String path,
) {
  final index = path.indexOf(pathSegment);
  if (index >= 0) {
    final absPackagePath = path.substring(0, index + pathSegment.length);
    return absPackagePath;
  }
  return null;
}
