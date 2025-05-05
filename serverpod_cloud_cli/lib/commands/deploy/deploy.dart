import 'dart:io';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/file_uploader_factory.dart';
import 'package:serverpod_cloud_cli/shared/helpers/common_exceptions_handler.dart';
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
  }) async {
    final projectDirectory = Directory(projectDir);

    final pubspecValidator = TenantProjectPubspec.fromProjectDir(
      projectDirectory,
      logger: logger,
    );

    final issues = pubspecValidator.projectDependencyIssues();
    if (issues.isNotEmpty) {
      for (final issue in issues) {
        logger.error(issue);
      }
      throw ErrorExitException(issues.first);
    }

    final Directory rootDirectory;
    final Iterable<String> includedSubPaths;
    if (pubspecValidator.isWorkspaceResolved()) {
      try {
        (rootDirectory, includedSubPaths) =
            WorkspaceProject.prepareWorkspacePaths(
          projectDirectory,
        );
      } on WorkspaceException catch (e, s) {
        e.errors?.forEach(logger.error);
        throw ErrorExitException(e.errors?.first, e, s);
      }

      logger.list(
        title: 'Including workspace packages',
        includedSubPaths.where(
          (final path) => path != ScloudIgnore.scloudDirName,
        ),
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
        );
        return true;
      } on ProjectZipperExceptions catch (e) {
        switch (e) {
          case ProjectDirectoryDoesNotExistException():
            logger.error(
              'Project directory does not exist: ${e.path}',
            );
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

    if (dryRun) {
      logger.info('Dry run, skipping upload.');
      return;
    }

    final success = await logger.progress('Uploading project...', () async {
      late final String uploadDescription;
      await handleCommonClientExceptions(logger, () async {
        uploadDescription = await cloudApiClient.deploy.createUploadDescription(
          projectId,
        );
      }, (final e) {
        logger.error('Failed to fetch upload description', exception: e);
        throw ErrorExitException('Failed to fetch upload description', e);
      });

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
      } on Exception catch (e, stackTrace) {
        logger.error('Failed to upload project', exception: e);
        throw ErrorExitException('Failed to upload project', e, stackTrace);
      }
    });

    if (!success) {
      throw ErrorExitException('Failed to upload project.');
    }

    const tenantHost = 'serverpod.space';

    logger.success(
      'Project uploaded successfully!',
      trailingRocket: true,
      followUp: '\nWhen the server has started, you can access it at:\n'
          'Web:      https://$projectId.$tenantHost/\n'
          'API:      https://$projectId.api.$tenantHost/\n'
          'Insights: https://$projectId.insights.$tenantHost/\n\n'
          'See the `scloud domain` command to set up a custom domain.',
    );
  }
}
