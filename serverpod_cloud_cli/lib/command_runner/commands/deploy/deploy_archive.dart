import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/status/status_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/dio_failure.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/file_uploader_factory.dart';
import 'package:serverpod_cloud_cli/project_zipper/project_zipper.dart';
import 'package:serverpod_cloud_cli/project_zipper/project_zipper_exceptions.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_shared/serverpod_cloud_shared.dart'
    show ByteSizeFormatter, UploadProgressCallback;

import 'prepare_project_files.dart';

abstract class DeployArchive {
  /// Zips the files selected by [projectFilePreparer], leaving out its
  /// excluded paths and filtering the `pubspec.yaml` and `pubspec.lock`
  /// files on the way. [concurrency] is the number of files processed at
  /// once.
  ///
  /// Throws [ErrorExitException] if the project could not be zipped.
  static Future<List<int>> zip({
    required CommandLogger logger,
    required ProjectFilePreparer projectFilePreparer,
    int concurrency = ProjectZipper.defaultFileReadPoolSize,
    required bool showFiles,
    String subject = 'project',
  }) async {
    late final List<int> projectZip;
    final isZipped = await logger.progress(
      'Zipping $subject',
      successMessage: 'Zipping successful.',
      padRight: StatusCommands.progressMessagePadLength,
      newParagraph: true,
      () async {
        try {
          projectZip = await ProjectZipper.zipProject(
            logger: logger,
            rootDirectory: projectFilePreparer.rootDirectory,
            beneath: projectFilePreparer.includedSubPaths,
            fileReadPoolSize: concurrency,
            showFiles: showFiles,
            excludeFile: projectFilePreparer.excludedSubPaths.isEmpty
                ? null
                : projectFilePreparer.isExcluded,
            fileContentModifier: (relativePath, contentReader) async {
              final pathSegments = p.split(relativePath);
              if (pathSegments.contains('.scloud')) return null;
              if (pathSegments.last == 'pubspec.yaml') {
                final content = await contentReader();
                return projectFilePreparer.filterPubspecYaml(content);
              }
              if (pathSegments.last == 'pubspec.lock') {
                final content = await contentReader();
                return projectFilePreparer.filterPubspecLock(content);
              }
              return null;
            },
          );
          return true;
        } on ProjectZipperExceptions catch (e) {
          switch (e) {
            case ProjectDirectoryDoesNotExistException():
              logger.error('Project directory does not exist: ${e.path}');
              break;
            case EmptyProjectException():
              logger.error(
                'No files to upload.',
                hint:
                    'Ensure that the correct project directory is selected (either through the --project-dir flag or the current directory) and check '
                    'that `.gitignore` and `.scloudignore` does not filter out all project files.',
              );
              break;
            case DirectorySymLinkException():
              logger.error(
                'Serverpod Cloud does not support directory symlinks: `${e.path}`',
              );
              break;
            case NonResolvingSymlinkException():
              logger.error(
                'Serverpod Cloud does not support non-resolving symlinks: `${e.path}` => `${e.target}`',
              );
              break;
            case NullZipException():
              logger.error(
                'Unknown error occurred while zipping $subject, please try again.',
              );
              break;
          }
          return false;
        }
      },
    );

    if (!isZipped) throw ErrorExitException('Failed to zip $subject.');
    return projectZip;
  }

  /// Writes [projectZip] to [outputPath].
  ///
  /// Throws [FailureException] if the file could not be written.
  static Future<void> writeZipFile({
    required CommandLogger logger,
    required String outputPath,
    required List<int> projectZip,
  }) async {
    await logger.progress(
      'Writing zip file to $outputPath',
      padRight: StatusCommands.progressMessagePadLength,
      () async {
        try {
          final file = File(outputPath);
          await file.writeAsBytes(projectZip);
          return true;
        } on Exception catch (e, stackTrace) {
          throw FailureException.nested(
            e,
            stackTrace,
            'Failed to write zip file to $outputPath',
          );
        }
      },
    );
  }

  /// Uploads [projectZip] to the destination in [uploadDescription] while
  /// showing the progress.
  ///
  /// Throws [ErrorExitException] if the upload did not succeed.
  static Future<void> upload({
    required CommandLogger logger,
    required FileUploaderFactory fileUploaderFactory,
    required String uploadDescription,
    required List<int> projectZip,
    String subject = 'project',
  }) async {
    final total = projectZip.length;
    final events = StreamController<_UploadProgress>();
    var lastPercent = -1;

    void onProgress(final int sent, final int _) {
      final percent = total == 0 ? 100 : sent * 100 ~/ total;
      if (percent == lastPercent) return;
      lastPercent = percent;
      events.add(_UploadProgress.sending(subject, sent, total));
    }

    unawaited(
      _runUpload(
        fileUploaderFactory,
        uploadDescription,
        projectZip,
        events,
        onProgress,
      ),
    );

    final _UploadProgress result;
    try {
      result = await logger.progressStream(
        'Uploading $subject...',
        events.stream,
        toMessage: (final p) => p.message,
        isSuccess: (final p) => p.succeeded,
        padRight: StatusCommands.progressMessagePadLength,
      );
    } on DioException catch (e) {
      throw failureFromDioException(e, action: 'upload the $subject');
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(
        e,
        stackTrace,
        'Failed to upload $subject.',
      );
    }

    if (!result.succeeded) {
      logger.error('Failed to upload $subject, please try again.');
      throw ErrorExitException('Failed to upload $subject.');
    }
  }

  static Future<void> _runUpload(
    FileUploaderFactory fileUploaderFactory,
    String uploadDescription,
    List<int> projectZip,
    StreamController<_UploadProgress> events,
    UploadProgressCallback onProgress,
  ) async {
    try {
      final fileUploader = fileUploaderFactory(uploadDescription);
      final success = await fileUploader.upload(
        Stream.value(projectZip),
        projectZip.length,
        onProgress: onProgress,
      );
      events.add(_UploadProgress.finished(success));
    } on Exception catch (e, stackTrace) {
      events.addError(e, stackTrace);
    } finally {
      await events.close();
    }
  }
}

/// One update of the upload spinner.
class _UploadProgress {
  final String message;
  final bool succeeded;

  const _UploadProgress._(this.message, {required this.succeeded});

  factory _UploadProgress.sending(
    final String subject,
    final int sent,
    final int total,
  ) {
    return _UploadProgress._(
      'Uploading $subject ${ByteSizeFormatter.format(sent)} '
      'of ${ByteSizeFormatter.format(total)}...',
      succeeded: false,
    );
  }

  factory _UploadProgress.finished(final bool success) {
    return _UploadProgress._(
      success ? 'Upload successful.' : 'Upload failed.',
      succeeded: success,
    );
  }
}
