import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/util/cli_authentication_key_manager.dart';
import 'package:serverpod_cloud_cli/project_zipper/project_zipper.dart';
import 'package:serverpod_cloud_cli/project_zipper/project_zipper_exceptions.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';

class CloudDeployCommand extends CloudCliCommand {
  @override
  String get description => 'Deploy a Serverpod project to the cloud.';

  @override
  String get name => 'deploy';

  CloudDeployCommand({required super.logger}) {
    argParser.addOption(
      'concurrency',
      abbr: 'c',
      help: 'Number of concurrent files processed when zipping the project.',
      valueHelp: '5',
      defaultsTo: '5',
    );

    argParser.addOption(
      'project-id',
      abbr: 'i',
      help: 'The project ID to deploy to.',
      mandatory: true,
    );

    argParser.addOption(
      'auth-dir',
      abbr: 'd',
      help:
          'Used to override directory path where the serverpod cloud authentication file is stored.',
      defaultsTo: ResourceManager.localStorageDirectory.path,
    );

    // Developer options and flags
    argParser.addOption(
      'project-dir',
      abbr: 'p',
      help: 'The path to the directory of the project to deploy.',
      hide: true,
      defaultsTo: Directory.current.path,
    );

    argParser.addOption(
      'server',
      abbr: 's',
      help: 'The URL to the Serverpod cloud api server.',
      hide: true,
      defaultsTo: HostConstants.serverpodCloudApi,
    );
  }

  @override
  Future<void> run() async {
    final concurrency = int.tryParse(argResults!['concurrency'] as String);
    final localStoragePath = argResults!['auth-dir'] as String;
    final serverAddress = argResults!['server'] as String;
    final projectId = argResults!['project-id'] as String;
    final projectDirectory = Directory(argResults!['project-dir'] as String);

    if (concurrency == null) {
      logger.error(
          'Failed to parse --concurrency option, value must be an integer.');
      throw ExitException();
    }

    final cloudClient = Client(
      serverAddress,
      authenticationKeyManager: CliAuthenticationKeyManager(
        logger: logger,
        localStoragePath: localStoragePath,
      ),
    );

    final String uploadDescription;
    try {
      uploadDescription = await cloudClient.deploy.createUploadDescription(
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
