import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/common_exceptions_handler.dart';
import 'package:serverpod_cloud_cli/project_zipper/project_zipper.dart';
import 'package:serverpod_cloud_cli/project_zipper/project_zipper_exceptions.dart';
import 'package:serverpod_cloud_cli/util/config/configuration.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';
import 'package:ground_control_client/ground_control_client.dart';

import 'categories.dart';

enum DeployCommandOption implements OptionDefinition {
  projectId(
    ProjectIdOption(
      argPos: 0,
      helpText:
          '${CommandConfigConstants.projectIdHelpText} Can be passed as the first argument.',
    ),
  ),
  concurrency(
    ConfigOption(
      argName: 'concurrency',
      argAbbrev: 'c',
      helpText:
          'Number of concurrent files processed when zipping the project.',
      defaultsTo: '5',
      valueHelp: '5',
    ),
  ),
  dryRun(
    ConfigOption(
      argName: 'dry-run',
      helpText: 'Do not actually deploy, just print the deployment steps.',
      isFlag: true,
      defaultsTo: 'false',
    ),
  );

  const DeployCommandOption(this.option);

  @override
  final ConfigOption option;
}

class CloudDeployCommand extends CloudCliCommand<DeployCommandOption> {
  @override
  String get description => 'Deploy a Serverpod project to the cloud.';

  @override
  String get name => 'deploy';

  @override
  String get category => CommandCategories.control;

  CloudDeployCommand({required super.logger})
      : super(options: DeployCommandOption.values);

  @override
  Future<void> runWithConfig(
      final Configuration<DeployCommandOption> commandConfig) async {
    final projectId = commandConfig.value(DeployCommandOption.projectId);
    final concurrency =
        int.tryParse(commandConfig.value(DeployCommandOption.concurrency));
    final dryRun = commandConfig.flag(DeployCommandOption.dryRun);

    if (concurrency == null) {
      logger.error(
          'Failed to parse --concurrency option, value must be an integer.');
      throw ErrorExitException();
    }

    final projectDirectory = runner.verifiedProjectDirectory();

    final pubspecValidator = TenantProjectPubspec.fromProjectDir(
      projectDirectory,
      logger: logger,
    );

    final issues = pubspecValidator.projectDependencyIssues();
    if (issues.isNotEmpty) {
      for (final issue in issues) {
        logger.error(issue);
      }
      throw ErrorExitException();
    }

    late final List<int> projectZip;
    final isZipped = await logger.progress('Zipping project...', () async {
      try {
        projectZip = await ProjectZipper.zipProject(
          projectDirectory: projectDirectory,
          logger: logger,
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

    if (!isZipped) throw ErrorExitException();

    if (dryRun) {
      logger.info('Dry run, skipping upload.');
      return;
    }

    final success = await logger.progress('Uploading project...', () async {
      final apiCloudClient = runner.serviceProvider.cloudApiClient;

      late final String uploadDescription;
      await handleCommonClientExceptions(logger, () async {
        uploadDescription = await apiCloudClient.deploy.createUploadDescription(
          projectId,
        );
      }, (final e) {
        logger.error('Failed to fetch upload description: $e');
        throw ErrorExitException();
      });

      try {
        final ret = await GoogleCloudStorageUploader(uploadDescription).upload(
          Stream.fromIterable([projectZip]),
          projectZip.length,
        );
        if (!ret) {
          logger.error('Failed to upload project, please try again.');
        }
        return ret;
      } catch (e) {
        logger.error(
          'Failed to upload project: $e',
        );
        return false;
      }
    });

    if (!success) {
      throw ErrorExitException();
    }

    logger.success(
      'Project uploaded successfully!',
      trailingRocket: true,
    );
  }
}
