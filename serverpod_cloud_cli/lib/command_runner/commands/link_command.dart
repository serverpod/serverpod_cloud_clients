import 'dart:io';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/common_exceptions_handler.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/configuration.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config.dart';
import 'package:serverpod_cloud_cli/util/serverpod_server_folder_detection.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';

enum LinkCommandOption implements OptionDefinition {
  projectId(
    ProjectIdOption(),
  ),
  projectDir(
    ProjectDirOption(
      helpText: 'The path to the directory of the project to link.',
    ),
  );

  const LinkCommandOption(this.option);

  @override
  final ConfigOption option;
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

    if (!isServerpodServerDirectory(projectDirectory.path)) {
      logProjectDirIsNotAServerpodServerDirectory(logger);
      throw ErrorExitException();
    }

    late final ProjectConfig projectConfig;
    await handleCommonClientExceptions(logger, () async {
      projectConfig = await apiCloudClient.projects.fetchProjectConfig(
        cloudProjectId: projectId,
      );
    }, (final e) {
      logger.error('Failed to fetch project config: $e');
      throw ErrorExitException();
    });

    try {
      ScloudConfig.writeToFile(projectConfig, projectDirectory);
    } catch (e) {
      logger
          .error('Failed to write to ${ConfigFileConstants.fileName} file: $e');
      throw ErrorExitException();
    }

    logger.success('Successfully linked project!');
  }
}
