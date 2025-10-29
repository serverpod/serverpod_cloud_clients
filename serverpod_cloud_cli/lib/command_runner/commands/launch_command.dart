import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';
import 'package:serverpod_cloud_cli/commands/launch/launch.dart';

enum LaunchOption<V> implements OptionDefinition<V> {
  projectId(StringOption(
    argName: 'project',
    helpText: 'The ID of an existing project to use.',
    group: _projectGroup,
  )),
  newProjectId(StringOption(
    argName: 'new-project',
    helpText: 'The ID of a new project to create.',
    group: _projectGroup,
  )),
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

  static const _projectGroup =
      MutuallyExclusive('Project', mode: MutuallyExclusiveMode.noDefaults);
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

    final existingProjectId =
        commandConfig.optionalValue(LaunchOption.projectId);
    final newProjectId = commandConfig.optionalValue(LaunchOption.newProjectId);
    final enableDb = commandConfig.optionalValue(LaunchOption.enableDb);
    final deploy = commandConfig.optionalValue(LaunchOption.deploy);

    await Launch.launch(
      runner.serviceProvider.cloudApiClient,
      runner.serviceProvider.fileUploaderFactory,
      logger: logger,
      specifiedProjectDir: specifiedProjectDir?.path,
      foundProjectDir: foundProjectDir,
      newProjectId: newProjectId,
      existingProjectId: existingProjectId,
      enableDb: enableDb,
      performDeploy: deploy,
    );
  }
}
