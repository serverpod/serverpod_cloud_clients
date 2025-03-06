// Source: https://github.com/dart-lang/pub/blob/e9ad2bc/lib/src/package.dart

// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This code has been modified from the original version.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/project_zipper/project_zipper.dart';
import 'package:serverpod_cloud_cli/project_zipper/project_zipper_exceptions.dart';
import 'package:serverpod_cloud_cli/util/ignore.dart';

abstract final class ProjectFiles {
  /// Collects all files in the project directory that are not ignored by any
  /// ignore rules files in the project directory.
  ///
  /// The ignore rules are determined by the presence of
  /// [ProjectZipper.recognizedIgnoreRuleFiles] files.
  static (Set<String> collectedFiles, Set<String> ignoredFiles) collectFiles({
    required final Directory projectDirectory,
    required final CommandLogger logger,
  }) {
    final root = p.toUri(p.normalize(projectDirectory.path)).path;
    const beneath = '.';
    final (collectedFiles, ignoredFiles) = Ignore.listFiles(
      beneath: beneath,
      listDir: (final dir) {
        final contents = Directory(_resolve(from: root, path: dir))
            .listSync(recursive: true);
        return contents.map((final entity) {
          final path = entity.path;
          if (_linkExists(path)) {
            final target = Link(path).targetSync();
            if (_dirExists(path)) {
              throw DirectorySymLinkException(path);
            }
            if (!_fileExists(entity.path)) {
              throw NonResolvingSymlinkException(path, target);
            }
          }
          final relative = p.relative(entity.path, from: root);
          if (Platform.isWindows) {
            return p.posix.joinAll(p.split(relative));
          }
          return relative;
        });
      },
      ignoreForDir: (final dir) {
        final ignoreRuleFiles = ProjectZipper.recognizedIgnoreRuleFiles.map(
          (final fileName) => _resolve(from: root, path: '$dir/$fileName'),
        );

        final rules = [
          ...ProjectZipper.defaultIgnoreRules,
          ...ignoreRuleFiles.map((final filePath) {
            if (!_fileExists(filePath)) return null;

            return _readTextFile(filePath);
          }).nonNulls,
        ];

        if (rules.isEmpty) return null;

        return Ignore(
          rules,
          onInvalidPattern: (final pattern, final exception) {
            logger.warning(
              'Ignoring invalid pattern in ignore file: $pattern. Remove it to avoid this warning.',
            );
          },
          // Ignore case on macOS and Windows, because `git clone` and
          // `git init` will set `core.ignoreCase = true` in the local
          // local `.git/config` file for the repository.
          //
          // So on Windows and macOS most users will have case-insensitive
          // behavior with `.gitignore`, hence, it seems reasonable to do
          // the same when we interpret `.gitignore` and `.scloudignore`.
          //
          // There are cases where a user may have case-sensitive behavior
          // with `.gitignore` on Windows and macOS:
          //
          //  (A) The user has manually overwritten the repository
          //      configuration setting `core.ignoreCase = false`.
          //
          //  (B) The git-clone or git-init command that create the
          //      repository did not deem `core.ignoreCase = true` to be
          //      appropriate. Documentation for [git-config]][1] implies
          //      this might depend on whether or not the filesystem is
          //      case sensitive:
          //      > If true, this option enables various workarounds to
          //      > enable Git to work better on filesystems that are not
          //      > case sensitive, like FAT.
          //      > ...
          //      > The default is false, except git-clone[1] or
          //      > git-init[1] will probe and set core.ignoreCase true
          //      > if appropriate when the repository is created.
          //
          // In either case, it seems likely that users on Windows and
          // macOS will prefer case-insensitive matching. We specifically
          // know that some tooling will generate `.PDB` files instead of
          // `.pdb`, see: [#3003][2]
          //
          // [1]: https://git-scm.com/docs/git-config/2.14.6#Documentation/git-config.txt-coreignoreCase
          // [2]: https://github.com/dart-lang/pub/issues/3003
          ignoreCase: Platform.isMacOS || Platform.isWindows,
        );
      },
      isDir: (final dir) => _dirExists(_resolve(from: root, path: dir)),
    );

    final collected = collectedFiles
        .map((final file) => _resolve(from: beneath, path: file))
        .toSet();

    final ignored = ignoredFiles
        .map((final file) => _resolve(from: beneath, path: file))
        .toSet();

    return (collected, ignored);
  }

  static String resolvePath({
    required final Directory fromDir,
    required final String path,
  }) {
    final root = p.toUri(p.normalize(fromDir.path)).path;
    return _resolve(from: root, path: path);
  }

  static String _resolve({
    required final String from,
    required final String path,
  }) {
    if (Platform.isWindows) {
      return p.joinAll([from, ...p.posix.split(path)]);
    }
    return p.join(from, path);
  }

  static bool _linkExists(final String link) => Link(link).existsSync();
  static bool _dirExists(final String dir) => Directory(dir).existsSync();
  static bool _fileExists(final String file) => File(file).existsSync();
  static String _readTextFile(final String path) =>
      File(path).readAsStringSync();
}
