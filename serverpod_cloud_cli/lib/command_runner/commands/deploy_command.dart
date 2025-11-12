import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/commands/deploy/deploy.dart';

import 'categories.dart';

enum DeployCommandOption<V> implements OptionDefinition<V> {
  projectId(
    ProjectIdOption(
      asFirstArg: true,
    ),
  ),
  concurrency(
    IntOption(
      argName: 'concurrency',
      argAbbrev: 'c',
      helpText:
          'Number of concurrent files processed when zipping the project.',
      defaultsTo: 5,
      min: 1,
    ),
  ),
  dryRun(
    FlagOption(
      argName: 'dry-run',
      helpText: 'Do not actually deploy, just print the deployment steps.',
      defaultsTo: false,
      negatable: false,
    ),
  ),
  showFiles(
    FlagOption(
      argName: 'show-files',
      helpText: 'Display the file tree that will be uploaded.',
      defaultsTo: false,
      negatable: false,
    ),
  );

  const DeployCommandOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudDeployCommand extends CloudCliCommand<DeployCommandOption> {
  @override
  String get description => 'Deploy a Serverpod project to the cloud.';

  @override
  String get name => 'deploy';

  @override
  String get category => CommandCategories.control;

  @override
  String get usageExamples => '''\n
Examples

  Deploy your project to the cloud

    \$ scloud deploy

  Preview the file tree that will be uploaded
  
    \$ scloud deploy --show-files
  
  The output shows files that will be included in the deployment, as well as files that are ignored (marked with "(ignored)").
  
  This is useful for verifying that your .gitignore and .scloudignore files are working as expected. You can combine it with --dry-run to preview the file tree without actually deploying:
  
    \$ scloud deploy --dry-run --show-files

''';

  CloudDeployCommand({required super.logger})
      : super(options: DeployCommandOption.values);

  @override
  Future<void> runWithConfig(
      final Configuration<DeployCommandOption> commandConfig) async {
    final projectId = commandConfig.value(DeployCommandOption.projectId);
    final concurrency = commandConfig.value(DeployCommandOption.concurrency);
    final dryRun = commandConfig.value(DeployCommandOption.dryRun);
    final showFiles = commandConfig.value(DeployCommandOption.showFiles);

    final projectDirectory = runner.verifiedProjectDirectory();
    logger.debug('Using project directory `${projectDirectory.path}`');

    await Deploy.deploy(
      runner.serviceProvider.cloudApiClient,
      runner.serviceProvider.fileUploaderFactory,
      logger: logger,
      projectId: projectId,
      projectDir: projectDirectory.path,
      concurrency: concurrency,
      dryRun: dryRun,
      showFiles: showFiles,
    );
  }
}
