import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:cli_tools/cli_tools.dart';
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
  static String stripRoot(final String rootPath, final String fullPath) {
    return p.relative(p.normalize(fullPath), from: rootPath);
  }

  /// Zips a project directory.
  /// Returns a list of bytes representing the zipped project.
  ///
  /// The [projectDirectory] is the directory to zip.
  /// The [logger] is used to log debug information and warnings.
  /// The [fileReadPoolSize] is the number of files that are processed concurrently.
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
    required final Directory projectDirectory,
    required final CommandLogger logger,
    final int fileReadPoolSize = 5,
  }) async {
    final projectPath = projectDirectory.path;

    if (!projectDirectory.existsSync()) {
      throw ProjectDirectoryDoesNotExistException(projectPath);
    }

    final (filesToUpload, filesIgnored) = ProjectFiles.collectFiles(
      projectDirectory: projectDirectory,
      logger: logger,
    );

    logger.debug('Found ${filesToUpload.length} files to upload.');
    if (logger.logLevel == LogLevel.debug) {
      FileTreePrinter.writeFileTree(
        filePaths: filesToUpload
            .map((final file) => stripRoot(projectPath, file))
            .toSet(),
        ignoredPaths: filesIgnored
            .map((final file) => stripRoot(projectPath, file))
            .toSet(),
        write: logger.raw,
      );
    }

    final archive = Archive();
    final fileReadPool = Pool(fileReadPoolSize);

    Future<void> addFileToArchive(final String path) async {
      final file = File(path);
      if (!file.existsSync()) return;

      await fileReadPool.withResource(() async {
        final length = await file.length();
        final bytes = await file.readAsBytes();

        archive.addFile(
          ArchiveFile(stripRoot(projectPath, path), length, bytes),
        );
      });
    }

    await Future.wait(filesToUpload.map(addFileToArchive));

    if (archive.isEmpty) {
      throw const EmptyProjectException();
    }

    final encoded = ZipEncoder().encode(archive);
    logger.debug(
      'Encoded ${archive.length} files to ${_formatFileSize(encoded?.length ?? 0)}.',
    );

    if (encoded == null) {
      // This should never happen.
      // If we end up here, it's a bug in the archive package.
      throw const NullZipException();
    }

    return encoded;
  }

  static String _formatFileSize(final int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static const List<String> defaultIgnoreRules = [
    '.**',
  ];

  static const List<String> recognizedIgnoreRuleFiles = [
    '.gitignore',
    ScloudIgnore.fileName,
  ];
}
