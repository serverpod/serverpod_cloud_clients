import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pubspec_parse/pubspec_parse.dart';

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
/// A directory is considered a candidate if it directly contains a file named
/// `<fileBaseName>.<ext>` (for one of the [supportedExtensions]) for which
/// [fileContentCondition], if provided, returns true. By choosing the file name
/// and content condition the same algorithm can find a Serverpod server
/// directory both with and without an `scloud.yaml` file.
///
/// If [startingDirectory] is not provided or it returns null,
/// the current directory is used as starting directory.
///
/// Starting from the starting directory, the search proceeds as follows:
/// Traverse the directory tree [searchLevelsUp] levels up, one at a time:
///   1. If the directory is a candidate, it is used.
///   2. If the directory is a Dart workspace root, search its workspace packages.
///      If exactly one candidate is found it is used, otherwise the search ends.
///   3. Search [searchLevelsDown] levels down. If exactly one candidate is found
///      it is used.
///   4. If the directory is a git repository root, or the filesystem root,
///      stop the search.
///
/// If multiple candidate files are found at any single step then an
/// [AmbiguousSearchException] is thrown.
///
/// If a single matching file is found then its absolute path is returned,
/// otherwise null.
FileFinder<T> scloudFileFinder<T>({
  required final String fileBaseName,
  required final List<String> supportedExtensions,
  final String? Function(T arg)? startingDirectory,
  final int searchLevelsUp = 2,
  final int searchLevelsDown = 3,
  final FileContentCondition? fileContentCondition,
}) {
  final filenames = supportedExtensions
      .map((final ext) => '$fileBaseName.$ext')
      .toList();

  return (final T arg) {
    final startDir = p.absolute(
      p.normalize(startingDirectory?.call(arg) ?? Directory.current.path),
    );
    final finder = _StatefulFileFinder();
    return finder._findProjectFile(
      startDir,
      filenames,
      searchLevelsUp: searchLevelsUp,
      searchLevelsDown: searchLevelsDown,
      fileContentCondition: fileContentCondition,
    );
  };
}

class _StatefulFileFinder {
  final Set<String> _searchedTrees = {};

  String? _findProjectFile(
    final String startDir,
    final List<String> filenames, {
    required final int searchLevelsUp,
    required final int searchLevelsDown,
    final FileContentCondition? fileContentCondition,
  }) {
    // Traverse the directory tree [searchLevelsUp] levels up.
    var current = startDir;
    for (var i = 0; i <= searchLevelsUp; i++) {
      // 1. The directory is a candidate.
      final inDirectory = _findUnambiguousFile(
        _findFile(current, filenames, fileContentCondition),
      );
      if (inDirectory != null) {
        return inDirectory;
      }

      // 2. The directory is a Dart workspace root.
      if (_isDartWorkspaceRoot(current)) {
        return _findUnambiguousFile(
          _findFileInWorkspace(current, filenames, fileContentCondition),
        );
      }

      // 3. Search directory tree [searchLevelsDown] levels down.
      final downFromStart = _findUnambiguousFile(
        _findFileInTree(
          current,
          filenames,
          searchLevelsDown,
          fileContentCondition,
        ),
      );
      if (downFromStart != null) {
        return downFromStart;
      }

      if (_isGitRepoRoot(current)) {
        // The directory is a git repository root, stop the search.
        break;
      }
      final parent = p.dirname(current);
      final grandParent = p.dirname(parent);
      if (grandParent == parent) {
        // The directory is the root or one level below it, stop the search.
        break;
      }
      current = parent;
    }
    return null;
  }

  /// Returns true if [dir] contains a `pubspec.yaml` with a `workspace` field,
  /// i.e. it is the root of a Dart workspace.
  static bool _isDartWorkspaceRoot(final String dir) {
    return _parseWorkspacePubspec(dir)?.workspace != null;
  }

  /// Returns true if [dir] contains a `.git` directory or file,
  /// i.e. it is the root of a git repository (or worktree/submodule).
  static bool _isGitRepoRoot(final String dir) {
    final gitPath = p.join(dir, '.git');
    return Directory(gitPath).existsSync() || File(gitPath).existsSync();
  }

  /// Returns the single match if exactly one is found, null if none is found,
  /// or throws [AmbiguousSearchException] if multiple are found.
  static String? _findUnambiguousFile(final List<String> foundFiles) {
    if (foundFiles.length > 1) {
      throw AmbiguousSearchException(foundFiles);
    }
    return foundFiles.singleOrNull;
  }

  /// Searches the packages of the Dart workspace rooted at [workspaceRoot]
  /// for candidate files.
  List<String> _findFileInWorkspace(
    final String workspaceRoot,
    final List<String> filenames,
    final FileContentCondition? fileContentCondition,
  ) {
    final packagePaths = _parseWorkspacePubspec(workspaceRoot)?.workspace ?? [];
    final foundFiles = <String>[];
    for (final packagePath in packagePaths) {
      final packageDir = p.normalize(p.join(workspaceRoot, packagePath));
      foundFiles.addAll(_findFile(packageDir, filenames, fileContentCondition));
    }
    return foundFiles;
  }

  static Pubspec? _parseWorkspacePubspec(final String dir) {
    final pubspecFile = File(p.join(dir, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      return null;
    }
    try {
      return Pubspec.parse(pubspecFile.readAsStringSync());
    } on Exception catch (_) {
      return null;
    }
  }

  /// Searches for matching files in a directory tree.
  List<String> _findFileInTree(
    final String dir,
    final List<String> filenames,
    final int subDirLevels,
    final FileContentCondition? fileContentCondition,
  ) {
    if (_searchedTrees.contains(dir)) {
      return [];
    }
    _searchedTrees.add(dir);

    final foundFiles = _findFile(dir, filenames, fileContentCondition);

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
          _findFileInTree(
            subDir.path,
            filenames,
            subDirLevels - 1,
            fileContentCondition,
          ),
        );
      }
    }
    return foundFiles;
  }

  /// Searches for matching files in a specific directory.
  List<String> _findFile(
    final String dir,
    final List<String> filenames,
    final FileContentCondition? fileContentCondition,
  ) {
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
    return foundFiles;
  }
}
