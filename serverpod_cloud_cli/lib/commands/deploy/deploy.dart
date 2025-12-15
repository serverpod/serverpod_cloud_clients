import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/file_uploader_factory.dart';
import 'package:serverpod_cloud_cli/project_zipper/project_zipper_exceptions.dart';
import 'package:serverpod_cloud_cli/project_zipper/project_zipper.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';
import 'package:serverpod_cloud_cli/util/scloudignore.dart' show ScloudIgnore;

import 'prepare_workspace.dart';

abstract class Deploy {
  static Future<void> deploy(
    final Client cloudApiClient,
    final FileUploaderFactory fileUploaderFactory, {
    required final CommandLogger logger,
    required final String projectId,
    required final String projectDir,
    required final int concurrency,
    required final bool dryRun,
    required final bool showFiles,
  }) async {
    logger.init('Deploying Serverpod Cloud project "$projectId".');

    final projectDirectory = Directory(projectDir);

    final pubspecValidator = TenantProjectPubspec.fromProjectDir(
      projectDirectory,
    );

    final issues = pubspecValidator.projectDependencyIssues();
    if (issues.isNotEmpty) {
      throw FailureException(errors: issues);
    }

    final Directory rootDirectory;
    final Iterable<String> includedSubPaths;
    if (pubspecValidator.isWorkspaceResolved()) {
      (rootDirectory, includedSubPaths) =
          WorkspaceProject.prepareWorkspacePaths(projectDirectory);

      logger.list(
        title: 'Including workspace packages',
        includedSubPaths.where(
          (final path) => path != ScloudIgnore.scloudDirName,
        ),
        level: LogLevel.debug,
      );
    } else {
      rootDirectory = projectDirectory;
      includedSubPaths = const ['.'];
    }

    late final List<int> projectZip;
    final isZipped = await logger.progress(
      'Zipping project...',
      newParagraph: true,
      () async {
        try {
          projectZip = await ProjectZipper.zipProject(
            logger: logger,
            rootDirectory: rootDirectory,
            beneath: includedSubPaths,
            fileReadPoolSize: concurrency,
            showFiles: showFiles,
            fileContentModifier: (final relativePath, final contentReader) async {
              final isPubspec =
                  relativePath.endsWith('pubspec.yaml') &&
                  !relativePath.contains('.scloud/');
              if (isPubspec) {
                final content = await contentReader();
                return WorkspaceProject.stripDevDependenciesFromPubspecContent(
                  content,
                );
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
                'Unknown error occurred while zipping project, please try again.',
              );
              break;
          }
          return false;
        }
      },
    );

    if (!isZipped) throw ErrorExitException('Failed to zip project.');

    if (dryRun) {
      await logger.progress('Dry run, skipping upload.', () async {
        return true;
      });
      return;
    }

    final success = await logger.progress('Uploading project...', () async {
      late final String uploadDescription;
      try {
        uploadDescription = await cloudApiClient.deploy.createUploadDescription(
          projectId,
        );
      } on Exception catch (e, stackTrace) {
        throw FailureException.nested(
          e,
          stackTrace,
          'Failed to fetch upload description',
        );
      }

      try {
        final fileUploader = fileUploaderFactory(uploadDescription);
        final ret = await fileUploader.upload(
          Stream.fromIterable([projectZip]),
          projectZip.length,
        );
        if (!ret) {
          logger.error('Failed to upload project, please try again.');
        }
        return ret;
      } on DioException catch (e) {
        throw FailureException(
          error: 'Failed to upload project: ${_uploadDioExceptionFormatter(e)}',
        );
      } on Exception catch (e, stackTrace) {
        throw FailureException.nested(
          e,
          stackTrace,
          'Failed to upload project',
        );
      }
    });

    if (!success) {
      throw ErrorExitException('Failed to upload project.');
    }
  }

  static String _uploadDioExceptionFormatter(final DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection Timeout. Please check your internet connection and try again.';
      case DioExceptionType.sendTimeout:
        return 'Send Timeout. Please check your internet connection and try again.';
      case DioExceptionType.receiveTimeout:
        return 'Receive Timeout. Please check your internet connection and try again.';
      case DioExceptionType.connectionError:
        return 'Connection Error. Please check your internet connection and try again.';
      default:
        return e.toString();
    }
  }
}
