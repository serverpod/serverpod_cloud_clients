import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ground_control_client/ground_control_client.dart'
    show
        Client,
        DartSdkUnsupportedConstraintException,
        InvalidValueException,
        ServerpodClientException;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/file_uploader_factory.dart';
import 'package:serverpod_cloud_cli/commands/deploy/script_runner.dart';
import 'package:serverpod_cloud_cli/project_zipper/project_zipper.dart';
import 'package:serverpod_cloud_cli/project_zipper/project_zipper_exceptions.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/dart_version_util.dart'
    show ProjectDartVersionHint;
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart'
    show TenantProjectPubspec;
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config_io.dart';
import 'package:serverpod_cloud_cli/util/scloudignore.dart' show ScloudIgnore;
import 'package:serverpod_cloud_cli/util/tool_versions_io.dart';
import 'package:serverpod_cloud_cli/util/upload_description_metadata.dart';

import 'prepare_workspace.dart';

abstract class Deploy {
  static Future<void> deploy(
    final Client cloudApiClient,
    final FileUploaderFactory fileUploaderFactory, {
    required final CommandLogger logger,
    required final String projectId,
    required final String projectDir,
    required final String projectConfigFilePath,
    required final int concurrency,
    required final bool dryRun,
    required final bool showFiles,
    final String? outputPath,
    final String? dartVersionOverride,
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

    final config = ScloudConfigIO.readFromFile(projectConfigFilePath);

    if (config != null && config.scripts.preDeploy.isNotEmpty) {
      await ScriptRunner.runScripts(
        config.scripts.preDeploy,
        projectDir,
        logger,
        scriptType: 'pre-deploy',
      );
    }

    final dartVersionHint = ProjectDartVersionHint.resolveDartVersionForDeploy(
      override: dartVersionOverride,
      configDartSdk: config?.dartSdk,
      lazyVersionSources: [
        () {
          final roots = <Directory>[projectDirectory];
          if (pubspecValidator.isWorkspaceResolved()) {
            final (workspaceRoot, _) = WorkspaceProject.findWorkspaceRoot(
              projectDirectory,
            );
            roots.add(workspaceRoot);
          }
          return ToolVersionsIO.readDartVersionFromToolVersions(roots);
        },
        pubspecValidator.environmentSdkConstraint,
      ],
    );

    late final String uploadDescription;

    if (!dryRun) {
      final serverpodVersion = pubspecValidator.serverpodVersion;

      await logger.progress('Retrieving upload description...', () async {
        try {
          uploadDescription = await cloudApiClient.deploy
              .createUploadDescription(
                projectId,
                serverpodVersion: serverpodVersion,
                dartVersion: dartVersionHint,
              );
          final resolvedTag = resolvedDartImageTagFromUploadDescription(
            uploadDescription,
          );
          if (resolvedTag != null) {
            logger.debug('Using Dart SDK $resolvedTag.');
          }
          return true;
        } on DartSdkUnsupportedConstraintException catch (e) {
          throw FailureException(
            error: e.message,
            hint: 'Please update the constraint and try again.',
          );
        } on InvalidValueException catch (e) {
          throw FailureException(error: e.message);
        } on ServerpodClientException catch (e) {
          if (e.message.toLowerCase().contains('connection timed out')) {
            throw FailureException(
              error:
                  'Connection timed out. Please check your internet connection and try again.',
              hint: 'Try increasing the timeout with the --timeout option.',
              reason: e.toString(),
            );
          }
          throw FailureException.nested(
            e,
            null,
            'Failed to fetch upload description.',
          );
        } on Exception catch (e, stackTrace) {
          throw FailureException.nested(
            e,
            stackTrace,
            'Failed to fetch upload description.',
          );
        }
      }, newParagraph: true);
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
    final isZipped = await logger.progress('Zipping project...', () async {
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
    });

    if (!isZipped) throw ErrorExitException('Failed to zip project.');

    if (outputPath != null) {
      await logger.progress('Writing zip file to $outputPath...', () async {
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
      });
    }

    if (dryRun) {
      await logger.progress('Dry run, skipping upload.', () async {
        return true;
      });
    } else {
      final success = await logger.progress('Uploading project...', () async {
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
          _uploadDioException(e);
        } on Exception catch (e, stackTrace) {
          throw FailureException.nested(
            e,
            stackTrace,
            'Failed to upload project.',
          );
        }
      });

      if (!success) {
        throw ErrorExitException('Failed to upload project.');
      }

      logger.success(
        'Project uploaded successfully!',
        trailingRocket: true,
        newParagraph: true,
      );
    }

    if (config != null && config.scripts.postDeploy.isNotEmpty) {
      await ScriptRunner.runScripts(
        config.scripts.postDeploy,
        projectDir,
        logger,
        scriptType: 'post-deploy',
      );
    }
  }

  static Never _uploadDioException(final DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        throw FailureException(
          error:
              'Connection Timeout. Please check your internet connection and try again.',
          hint: 'Try increasing the timeout with the --timeout option.',
        );
      case DioExceptionType.sendTimeout:
        throw FailureException(
          error:
              'Send Timeout. Please check your internet connection and try again.',
          hint: 'Try increasing the timeout with the --timeout option.',
        );
      case DioExceptionType.receiveTimeout:
        throw FailureException(
          error:
              'Receive Timeout. Please check your internet connection and try again.',
          hint: 'Try increasing the timeout with the --timeout option.',
        );
      case DioExceptionType.connectionError:
        throw FailureException(
          error:
              'Connection Error. Please check your internet connection and try again.',
          hint: 'Try increasing the timeout with the --timeout option.',
        );
      default:
        throw FailureException(
          error: 'Failed to upload project.',
          nestedException: e,
        );
    }
  }
}
