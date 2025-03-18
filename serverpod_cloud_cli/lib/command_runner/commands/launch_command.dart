import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/commands/launch/launch.dart';
import 'package:serverpod_cloud_cli/util/config/config.dart';

enum LaunchOption implements OptionDefinition {
  projectId(ProjectIdOption.nonMandatory()),
  enableDb(ConfigOption(
    argName: 'enable-db',
    isFlag: true,
    helpText: 'Flag to enable the database for the project.',
  )),
  deploy(ConfigOption(
    argName: 'deploy',
    isFlag: true,
    helpText: 'Flag to immediately deploy the project.',
  ));

  const LaunchOption(this.option);

  @override
  final ConfigOption option;
}

class CloudLaunchCommand extends CloudCliCommand<LaunchOption> {
  @override
  final name = 'launch';

  @override
  final description = 'Guided launch of a new Serverpod Cloud project.';

  @override
  String get category => CommandCategories.control;

  @override
  CloudLaunchCommand({required super.logger})
      : super(options: LaunchOption.values);

  @override
  Future<void> runWithConfig(final Configuration commandConfig) async {
    final specifiedProjectDir = globalConfiguration.projectDir;
    final foundProjectDir =
        specifiedProjectDir == null ? runner.selectProjectDirectory() : null;

    final projectId = commandConfig.valueOrNull(LaunchOption.projectId);
    final enableDb = commandConfig.flagOrNull(LaunchOption.enableDb);
    final deploy = commandConfig.flagOrNull(LaunchOption.deploy);

    await Launch.launch(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      specifiedProjectDir: specifiedProjectDir,
      foundProjectDir: foundProjectDir,
      projectId: projectId,
      enableDb: enableDb,
      performDeploy: deploy,
    );
  }
}
