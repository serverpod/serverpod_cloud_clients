import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:pool/pool.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/project_zipper/helpers/project_files.dart';
import 'package:serverpod_cloud_cli/project_zipper/project_zipper_exceptions.dart';
import 'package:serverpod_cloud_cli/util/printers/file_tree_printer.dart';
import 'package:serverpod_cloud_cli/util/scloudignore.dart';
import 'package:path/path.dart' as p;

/// [ProjectZipper] is a class that zips a project directory.
/// It is used to prepare a project for deployment to the cloud.
///
/// Files included in the zip are all non-ignored files in the project directory.
/// The zip is created in memory and returned as a list of bytes.
///
/// Files that are ignored are determined by the presence of a `.gitignore`
/// or `.scloudignore` file in the project directory.
///
/// The [zipProject] method is the main entry point for this class.
abstract final class ProjectZipper {
  static String stripRoot(String rootPath, String fullPath) {
    return p.relative(p.normalize(fullPath), from: rootPath);
  }

  /// Converts a platform-native relative path to a zip archive entry name.
  /// Entry names are always posix (`/`) separated, per the zip specification.
  static String toArchiveEntryName(
    String relativePath, {
    p.Context? pathContext,
  }) {
    final context = pathContext ?? p.context;
    return p.posix.joinAll(context.split(relativePath));
  }

  /// Zips a project directory.
  /// Returns a list of bytes representing the zipped project.
  /// Archive entry names are always posix (`/`) separated, regardless of
  /// platform.
  ///
  /// The [logger] is used to log debug information and warnings.
  /// The [rootDirectory] is the directory under which contents will be zipped.
  /// The [beneath] is the list of relative paths under [rootDirectory] that will be included,
  /// all by default.
  /// The [fileReadPoolSize] is the number of files that are processed concurrently.
  /// The [fileContentModifier] is an optional callback that can modify file content before
  /// it is added to the archive. It receives the relative path and a content reader function.
  /// The callback should return the modified content as a string, or null if no modification
  /// is needed (in which case the file will be added as binary). The content reader is only
  /// called when the modifier decides it needs to read the file content.
  /// The [excludeFile] is an optional predicate that, when returning true for a file's
  /// relative path, causes that file to be skipped from the archive entirely.
  ///
  /// All exceptions thrown by this method are subclasses of [ProjectZipperExceptions].
  /// Throws [ProjectDirectoryDoesNotExistException] if the project directory
  /// does not exist.
  /// Throws [EmptyProjectException] if the project directory is empty.
  /// Throws [DirectorySymLinkException] if the project directory contains a
  /// directory symlink.
  /// Throws [NonResolvingSymlinkException] if the project directory contains
  /// a non-resolving symlink.
  static Future<List<int>> zipProject({
    required CommandLogger logger,
    required Directory rootDirectory,
    Iterable<String> beneath = const ['.'],
    int fileReadPoolSize = 5,
    bool showFiles = false,
    Future<String?> Function(
      String relativePath,
      Future<String> Function() contentReader,
    )?
    fileContentModifier,
    bool Function(String relativePath)? excludeFile,
  }) async {
    final projectPath = rootDirectory.path;

    if (!rootDirectory.existsSync()) {
      throw ProjectDirectoryDoesNotExistException(projectPath);
    }

    final filesToUpload = <String>{};
    final filesIgnored = <String>{};
    for (final b in beneath) {
      final (included, ignored) = ProjectFiles.collectFiles(
        logger: logger,
        rootDirectory: rootDirectory,
        beneath: b,
      );
      filesToUpload.addAll(included);
      filesIgnored.addAll(ignored);
    }

    if (excludeFile != null) {
      filesToUpload.removeWhere(
        (path) => excludeFile(stripRoot(projectPath, path)),
      );
    }

    logger.debug('Found ${filesToUpload.length} files to upload.');
    if (showFiles) {
      FileTreePrinter.writeFileTree(
        filePaths: filesToUpload
            .map((file) => stripRoot(projectPath, file))
            .toSet(),
        ignoredPaths: filesIgnored
            .map((file) => stripRoot(projectPath, file))
            .toSet(),
        write: logger.raw,
      );
    }

    final archive = Archive();
    final fileReadPool = Pool(fileReadPoolSize);

    Future<void> addFileToArchive(String path) async {
      final file = File(path);
      if (!file.existsSync()) return;

      await fileReadPool.withResource(() async {
        final relativePath = stripRoot(projectPath, path);

        List<int> bytes;
        if (fileContentModifier != null) {
          final modifiedContent = await fileContentModifier(
            relativePath,
            () => file.readAsString(),
          );
          if (modifiedContent != null) {
            bytes = utf8.encode(modifiedContent);
          } else {
            bytes = await file.readAsBytes();
          }
        } else {
          bytes = await file.readAsBytes();
        }

        archive.addFile(
          ArchiveFile(toArchiveEntryName(relativePath), bytes.length, bytes),
        );
      });
    }

    await Future.wait(filesToUpload.map(addFileToArchive));

    if (archive.isEmpty) {
      throw const EmptyProjectException();
    }

    final encoded = ZipEncoder().encode(archive);
    logger.debug(
      'Encoded ${archive.length} files to ${_formatFileSize(encoded.length)}.',
    );

    return encoded;
  }

  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static const List<String> defaultIgnoreRules = ['.**'];

  static const List<String> recognizedIgnoreRuleFiles = [
    '.gitignore',
    ScloudIgnore.fileName,
  ];
}
