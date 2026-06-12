import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:ground_control_client/ground_control_client.dart'
    show
        Client,
        DartSdkUnsupportedConstraintException,
        InvalidValueException,
        ServerpodClientException;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/file_uploader_factory.dart';
import 'package:serverpod_cloud_cli/commands/deploy/script_runner.dart';
import 'package:serverpod_cloud_cli/commands/status/status.dart';
import 'package:serverpod_cloud_cli/project_zipper/project_zipper.dart';
import 'package:serverpod_cloud_cli/project_zipper/project_zipper_exceptions.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/dart_version_util.dart'
    show ProjectDartVersionHint;
import 'package:serverpod_cloud_cli/util/deploy_multi_instance_serverpod_warning.dart';
import 'package:serverpod_cloud_cli/util/git_metadata.dart';
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
    final bool skipTailingStatus = false,
    final String? outputPath,
    final String? dartVersionOverride,
    final IOSink? stdout,
    final IOSink? stderr,
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
        stdout: stdout,
        stderr: stderr,
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

    await warnIfLegacyServerpodWithMultipleInstances(
      cloudApiClient: cloudApiClient,
      projectId: projectId,
      logger: logger,
      serverpodVersionConstraint: pubspecValidator.serverpodVersion,
    );

    final gitMetadata = await readGitMetadata(projectDir, logger: logger);
    if (gitMetadata != null && gitMetadata.hasUncommittedChanges) {
      logger.warning(
        'You have uncommitted changes in your git repository.',
        hint:
            'These changes are included in the deployment, but the deploy '
            'is recorded against the last commit. Commit your changes for '
            'an accurate deployment history.',
        newParagraph: true,
      );
      logger.line(' ');
    }

    final Directory rootDirectory;
    final Iterable<String> includedSubPaths;
    final bool isWorkspace = pubspecValidator.isWorkspaceResolved();
    if (isWorkspace) {
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

    // TODO: Workaround — for workspace projects we skip uploading any
    // pubspec.lock because the workspace root's lockfile is not guaranteed
    // to match the bespoke `scloud_ws_pubspec.yaml` we generate (which only
    // references a subset of the original workspace members). Remove this
    // exclusion once we resolve a lockfile against our custom workspace root.
    final bool Function(String)? excludeFile = isWorkspace
        ? (final String relativePath) =>
              p.basename(relativePath) == 'pubspec.lock'
        : null;

    late final List<int> projectZip;
    final isZipped = await logger.progress(
      'Zipping project',
      successMessage: 'Zipping successful.',
      padRight: StatusCommands.progressMessagePadLength,
      () async {
        try {
          projectZip = await ProjectZipper.zipProject(
            logger: logger,
            rootDirectory: rootDirectory,
            beneath: includedSubPaths,
            fileReadPoolSize: concurrency,
            showFiles: showFiles,
            excludeFile: excludeFile,
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

    if (outputPath != null) {
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

    if (dryRun) {
      await logger.progress(
        'Dry run, skipping upload',
        successMessage: 'Dry run, skipping upload.',
        padRight: StatusCommands.progressMessagePadLength,
        () async {
          return true;
        },
      );

      if (config != null && config.scripts.postDeploy.isNotEmpty) {
        await ScriptRunner.runScripts(
          config.scripts.postDeploy,
          projectDir,
          logger,
          scriptType: 'post-deploy',
        );
      }
      return;
    }

    final uploadDescription = await _createUploadDescription(
      logger,
      cloudApiClient,
      projectId,
      pubspecValidator.serverpodVersion,
      dartVersionHint,
      gitMetadata,
    );

    await _uploadProject(
      logger,
      fileUploaderFactory,
      uploadDescription,
      projectZip,
    );

    if (config != null && config.scripts.postDeploy.isNotEmpty) {
      await ScriptRunner.runScripts(
        config.scripts.postDeploy,
        projectDir,
        logger,
        scriptType: 'post-deploy',
      );
    }

    if (skipTailingStatus) {
      logger.terminalCommand(
        'scloud deployment show',
        message: 'To view the deployment status, run this command:',
        newParagraph: true,
      );
      return;
    }

    final attemptId = resolveUploadIdFromUploadDescription(uploadDescription);
    if (attemptId == null) {
      throw FailureException(
        error: 'Failed to get deployment status.',
        hint:
            'Run this command to see recent deployments: '
            'scloud deployment list',
      );
    }

    await StatusCommands.tailDeploymentStatus(
      cloudApiClient,
      logger: logger,
      cloudCapsuleId: projectId,
      attemptId: attemptId,
      skipUploadStage: true,
    );
  }

  static Future<String> _createUploadDescription(
    final CommandLogger logger,
    final Client cloudApiClient,
    final String projectId,
    final String? serverpodVersion,
    final String? dartVersionHint,
    final GitMetadata? gitMetadata,
  ) async {
    try {
      final uploadDescription = await cloudApiClient.deploy
          .createUploadDescription(
            projectId,
            serverpodVersion: serverpodVersion,
            dartVersion: dartVersionHint,
            commitHash: gitMetadata?.commitHash,
            commitMessage: gitMetadata?.commitMessage,
            branch: gitMetadata?.branch,
          );
      final resolvedTag = resolveDartImageTagFromUploadDescription(
        uploadDescription,
      );
      if (resolvedTag != null) {
        logger.debug('Using Dart SDK $resolvedTag.');
      }
      return uploadDescription;
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
  }

  static Future<void> _uploadProject(
    final CommandLogger logger,
    final FileUploaderFactory fileUploaderFactory,
    final String uploadDescription,
    final List<int> projectZip,
  ) async {
    final success = await logger.progress(
      'Uploading project',
      padRight: StatusCommands.progressMessagePadLength,
      successMessage: 'Upload successful.',
      () async {
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
      },
    );

    if (!success) {
      throw ErrorExitException('Failed to upload project.');
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
