import 'package:cli_tools/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/commands/launch/launch.dart';

enum LaunchOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption.nonMandatory()),
  enableDb(FlagOption(
    argName: 'enable-db',
    helpText: 'Flag to enable the database for the project.',
  )),
  deploy(FlagOption(
    argName: 'deploy',
    helpText: 'Flag to immediately deploy the project.',
  ));

  const LaunchOption(this.option);

  @override
  final ConfigOptionBase<V> option;
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

    final projectId = commandConfig.optionalValue(LaunchOption.projectId);
    final enableDb = commandConfig.optionalValue(LaunchOption.enableDb);
    final deploy = commandConfig.optionalValue(LaunchOption.deploy);

    await Launch.launch(
      runner.serviceProvider.cloudApiClient,
      runner.serviceProvider.fileUploaderFactory,
      logger: logger,
      specifiedProjectDir: specifiedProjectDir?.path,
      foundProjectDir: foundProjectDir,
      projectId: projectId,
      enableDb: enableDb,
      performDeploy: deploy,
    );
  }
}
