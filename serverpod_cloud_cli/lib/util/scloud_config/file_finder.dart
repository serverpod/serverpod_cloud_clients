import 'dart:io';

import 'package:path/path.dart' as p;

typedef FileFinder<T> = String? Function(T arg);

typedef FileContentCondition = bool Function(String filePath);

class AmbiguousSearchException implements Exception {
  final List<String> matches;

  AmbiguousSearchException(this.matches);

  String get message =>
      'Ambiguous search, multiple candidates found: ${matches.join(', ')}';

  @override
  String toString() => message;
}

/// Returns a [FileFinder] function that implements the algorithm
/// for finding scloud project files.
///
/// If [startingDirectory] is not provided or it returns null,
/// the current directory is used as starting directory.
///
/// If [fileContentCondition] is provided, it is called with the path of
/// each file found. If it returns false, the file is not considered a match.
///
/// The file is searched for in this order:
/// 1. The starting directory and N levels down.
/// 2. If there is a pubspec.yaml file in the starting directory,
///    go one level up and search again with depth 1.
///
/// If multiple matching files are found then an
/// [AmbiguousSearchException] is thrown.
///
/// If a single matching file is found then its absolute path is returned,
/// otherwise null.
FileFinder<T> scloudFileFinder<T>({
  required final String fileBaseName,
  required final List<String> supportedExtensions,
  final String? Function(T arg)? startingDirectory,
  final int searchLevelsDown = 2,
  final FileContentCondition? fileContentCondition,
}) {
  final filenames = supportedExtensions
      .map((final ext) => '$fileBaseName.$ext')
      .toList();

  return (final T arg) {
    // search in current directory and N levels down
    // If several are found, throw StateError
    final startDir = p.absolute(
      p.normalize(startingDirectory?.call(arg) ?? Directory.current.path),
    );
    final foundFile = _findUnambiguousFile(
      startDir,
      filenames,
      subDirLevels: searchLevelsDown,
      fileContentCondition: fileContentCondition,
    );
    if (foundFile != null) {
      return foundFile;
    }

    // if there is a pubspec.yaml file in the current directory,
    // and the current directory is not a root directory,
    // go one level up and search again with depth 1,
    // this covers the case where the current directory is client/ or flutter/
    final pubspecFile = File(p.join(startDir, 'pubspec.yaml'));
    if (pubspecFile.existsSync() && startDir != p.rootPrefix(startDir)) {
      final upDir = Directory(p.normalize(p.join(startDir, '..')));
      final foundFile = _findUnambiguousFile(
        upDir.path,
        filenames,
        subDirLevels: 1,
        fileContentCondition: fileContentCondition,
      );
      if (foundFile != null) {
        return foundFile;
      }
    }

    return null;
  };
}

String? _findUnambiguousFile(
  final String dir,
  final List<String> filenames, {
  final int subDirLevels = 0,
  final FileContentCondition? fileContentCondition,
}) {
  final foundFiles = _findFile(
    dir,
    filenames,
    subDirLevels: subDirLevels,
    fileContentCondition: fileContentCondition,
  );
  if (foundFiles.length > 1) {
    throw AmbiguousSearchException(foundFiles);
  }
  return foundFiles.firstOrNull;
}

List<String> _findFile(
  final String dir,
  final List<String> filenames, {
  final int subDirLevels = 0,
  final FileContentCondition? fileContentCondition,
}) {
  final foundFiles = <String>[];
  for (final filename in filenames) {
    final file = File(p.join(dir, filename));
    try {
      if (file.existsSync()) {
        if (fileContentCondition?.call(file.path) ?? true) {
          foundFiles.add(file.path);
        }
      }
    } on FileSystemException catch (_) {
      // skip files that cannot be accessed
    }
  }

  if (subDirLevels > 0) {
    final List<FileSystemEntity> subEntities;
    try {
      subEntities = Directory(dir).listSync(followLinks: false);
    } on FileSystemException catch (_) {
      // skip directories that cannot be accessed
      return foundFiles;
    }

    for (final subDir in subEntities.whereType<Directory>()) {
      foundFiles.addAll(
        _findFile(
          subDir.path,
          filenames,
          subDirLevels: subDirLevels - 1,
          fileContentCondition: fileContentCondition,
        ),
      );
    }
  }
  return foundFiles;
}
