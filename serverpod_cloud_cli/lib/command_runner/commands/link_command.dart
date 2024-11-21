import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/util/configuration.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';

enum LinkCommandOption implements OptionDefinition {
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
      helpText: 'The path to the directory of the project to Link.',
      hide: true,
      defaultFrom: _getCurrentPath,
      envName: 'SERVERPOD_CLOUD_PROJECT_DIR',
    ),
  );

  const LinkCommandOption(this.option);

  @override
  final ConfigOption option;
}

String _getCurrentPath() {
  return Directory.current.path;
}

class CloudLinkCommand extends CloudCliCommand<LinkCommandOption> {
  @override
  String get description =>
      'Link your local project to an existing Serverpod Cloud project.';

  @override
  String get name => 'link';

  CloudLinkCommand({required super.logger})
      : super(options: LinkCommandOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<LinkCommandOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(LinkCommandOption.projectId);
    final projectDirectory =
        Directory(commandConfig.value(LinkCommandOption.projectDir));

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    final ProjectConfig projectConfig;
    try {
      projectConfig = await apiCloudClient.projects.fetchProjectConfig(
        cloudProjectId: projectId,
      );
    } catch (e) {
      logger.error('Failed to fetch project config: $e');
      throw ExitException();
    }

    try {
      ScloudConfig.writeToFile(projectConfig, projectDirectory);
    } catch (e) {
      logger
          .error('Failed to write to ${ConfigFileConstants.fileName} file: $e');
      throw ExitException();
    }

    logger.info('Successfully linked project!');
  }
}
