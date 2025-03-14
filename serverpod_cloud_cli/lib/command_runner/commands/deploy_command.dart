import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/commands/deploy/deploy.dart';
import 'package:serverpod_cloud_cli/util/config/configuration.dart';

import 'categories.dart';

enum DeployCommandOption implements OptionDefinition {
  projectId(
    ProjectIdOption(
      asFirstArg: true,
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

    await Deploy.deploy(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: projectId,
      projectDir: projectDirectory.path,
      concurrency: concurrency,
      dryRun: dryRun,
    );
  }
}
