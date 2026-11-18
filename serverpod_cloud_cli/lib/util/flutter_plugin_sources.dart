import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// The file in which `flutter pub get` lists the plugins of a Flutter app
/// with the local paths of their packages, relative to the app.
const flutterPluginsDependenciesPath = '.flutter-plugins-dependencies';

/// A plugin of a Flutter app for one platform.
typedef FlutterPlugin = ({String name, String path});

/// Reads the plugins for [platform], such as `ios` or `android`, of the
/// Flutter app in [appDirectory] from `.flutter-plugins-dependencies`. The
/// list holds the plugins in the pub cache, path and git dependencies, and
/// plugins in the app's own repository alike, each with the local path of
/// its package.
///
/// Returns null when the file is missing or cannot be read or parsed.
List<FlutterPlugin>? readFlutterPlugins(
  Directory appDirectory,
  String platform,
) {
  final file = File(p.join(appDirectory.path, flutterPluginsDependenciesPath));
  if (!file.existsSync()) return null;
  final Object? document;
  try {
    document = jsonDecode(file.readAsStringSync());
  } on FileSystemException {
    return null;
  } on FormatException {
    return null;
  }
  if (document is! Map || document['plugins'] is! Map) return null;
  final plugins = (document['plugins'] as Map)[platform];
  return [
    if (plugins is List)
      for (final plugin in plugins)
        if (plugin case {'name': final String name, 'path': final String path})
          (name: name, path: path),
  ];
}

/// Reads the source files with one of [extensions] under [directories],
/// without following links, and returns the code of each without its `//`
/// and `/* */` comments. Missing directories and files that cannot be read
/// are skipped.
Iterable<String> readSourceCode(
  Iterable<Directory> directories, {
  required Set<String> extensions,
}) sync* {
  for (final directory in directories) {
    if (!directory.existsSync()) continue;
    final List<FileSystemEntity> entities;
    try {
      entities = directory.listSync(recursive: true, followLinks: false);
    } on FileSystemException {
      continue;
    }
    for (final file in entities.whereType<File>()) {
      if (!extensions.contains(p.extension(file.path))) continue;
      try {
        yield file.readAsStringSync().replaceAll(_codeComment, '');
      } on FileSystemException {
        continue;
      } on FormatException {
        continue;
      }
    }
  }
}

/// A `//` or `/* */` comment of Swift or Objective-C.
final _codeComment = RegExp(r'/\*[\s\S]*?\*/|//[^\n]*');
