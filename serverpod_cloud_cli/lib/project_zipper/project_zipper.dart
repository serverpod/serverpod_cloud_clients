import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:cli_tools/cli_tools.dart';
import 'package:pool/pool.dart';
import 'package:serverpod_cloud_cli/project_zipper/helpers/project_files.dart';
import 'package:serverpod_cloud_cli/project_zipper/project_zipper_exceptions.dart';

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
    required final Logger logger,
    final int fileReadPoolSize = 5,
  }) async {
    if (!projectDirectory.existsSync()) {
      throw ProjectDirectoryDoesNotExistException(projectDirectory.path);
    }

    final filesToUpload = ProjectFiles.collectFiles(
      projectDirectory: projectDirectory,
      logger: logger,
    );

    logger.debug('Found ${filesToUpload.length} files to upload.');
    if (logger.logLevel == LogLevel.debug) {
      for (final file in filesToUpload) {
        logger.debug(file, type: TextLogType.bullet);
      }
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
          ArchiveFile(
            path.replaceFirst('${projectDirectory.path}/', ''),
            length,
            bytes,
          ),
        );
      });
    }

    await Future.wait(filesToUpload.map(addFileToArchive));

    if (archive.isEmpty) {
      throw const EmptyProjectException();
    }

    final encoded = ZipEncoder().encode(archive);
    logger
        .debug('Encoded ${archive.length} files to ${encoded?.length} bytes.');

    if (encoded == null) {
      // This should never happen.
      // If we end up here, it's a bug in the archive package.
      throw const NullZipException();
    }

    return encoded;
  }

  static const List<String> defaultIgnoreRules = [
    '.*',
  ];

  static const List<String> recognizedIgnoreRuleFiles = [
    '.gitignore',
    '.scloudignore',
  ];
}
