import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/project_zipper/project_zipper.dart';
import 'package:serverpod_cloud_cli/project_zipper/project_zipper_exceptions.dart';
import 'package:serverpod_cloud_cli/util/configuration.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';

enum DeployCommandOption implements OptionDefinition {
  projectId(
    ConfigOption(
      argName: 'project-id',
      argAbbrev: 'i',
      argPos: 0,
      helpText:
          'The ID of the project. Can also be specified as the first argument.',
      mandatory: true,
      envName: 'SERVERPOD_CLOUD_PROJECT_ID',
    ),
  ),
  projectDir(
    ConfigOption(
      argName: 'project-dir',
      argAbbrev: 'p',
      helpText: 'The path to the directory of the project to deploy.',
      hide: true,
      defaultFrom: _getCurrentPath,
      envName: 'SERVERPOD_CLOUD_PROJECT_DIR',
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
  );

  const DeployCommandOption(this.option);

  @override
  final ConfigOption option;
}

String _getCurrentPath() {
  return Directory.current.path;
}

class CloudDeployCommand extends CloudCliCommand<DeployCommandOption> {
  @override
  String get description => 'Deploy a Serverpod project to the cloud.';

  @override
  String get name => 'deploy';

  CloudDeployCommand({required super.logger})
      : super(options: DeployCommandOption.values);

  @override
  Future<void> runWithConfig(
      final Configuration<DeployCommandOption> commandConfig) async {
    final projectId = commandConfig.value(DeployCommandOption.projectId);
    final projectDirectory =
        Directory(commandConfig.value(DeployCommandOption.projectDir));
    final concurrency =
        int.tryParse(commandConfig.value(DeployCommandOption.concurrency));

    if (concurrency == null) {
      logger.error(
          'Failed to parse --concurrency option, value must be an integer.');
      throw ExitException();
    }

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    final String uploadDescription;
    try {
      uploadDescription = await apiCloudClient.deploy.createUploadDescription(
        projectId,
      );
    } catch (e) {
      logger.error('Failed to fetch upload description: $e');
      throw ExitException();
    }

    final List<int> projectZip;
    try {
      projectZip = await ProjectZipper.zipProject(
        projectDirectory: projectDirectory,
        logger: logger,
        fileReadPoolSize: concurrency,
      );
    } on ProjectZipperExceptions catch (e) {
      switch (e) {
        case ProjectDirectoryDoesNotExistException():
          logger.error(
            'Project directory does not exist: ${e.path}',
          );
          break;
        case EmptyProjectException():
          logger.error(
            'No files to upload. Make sure you are selecting the correct project directory and check that `.gitignore` and `.scloudignore` does not filter out all project files.',
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
              'Unknown error occurred while zipping project, please try again.');
          break;
      }
      throw ExitException();
    }

    final success = await logger.progress('Uploading project...', () async {
      return await GoogleCloudStorageUploader(uploadDescription).upload(
        Stream.fromIterable([projectZip]),
        projectZip.length,
      );
    });

    if (!success) {
      logger.error('Failed to upload project, please try again.');
      throw ExitException();
    }

    logger.info('Project uploaded successfully! 🚀');
  }
}
