import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/commands/deploy/deploy.dart';
import 'package:serverpod_cloud_cli/commands/launch/launch.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart'
    show FailureException, UserAbortException;
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config_io.dart';

enum LaunchOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption.nonMandatory()),
  plan(PlanOption()),
  deploy(
    FlagOption(
      argName: 'deploy',
      helpText: 'Automatically deploy the project after setup.',
      defaultsTo: true,
      hide: true, // intended for development and testing only
    ),
  ),
  dartVersion(DartSdkVersionOption()),
  tui(
    FlagOption(
      argName: 'tui',
      defaultsTo: false,
      helpText: 'Flag to enable interactive terminal UI.',
      hide: true,
    ),
  ),

  // Deploy-specific options
  concurrency(DeployConcurrencyOption(group: _deployGroup)),
  dryRun(DeployDryRunOption(group: _deployGroup)),
  showFiles(DeployShowFilesOption(group: _deployGroup)),
  output(DeployOutputOption(group: _deployGroup)),
  wait(AwaitOption(group: _deployGroup));

  const LaunchOption(this.option);

  @override
  final ConfigOptionBase<V> option;

  static const _deployGroup = OptionGroup('Deployment options');
}

class CloudLaunchCommand extends CloudCliCommand<LaunchOption> {
  @override
  final name = 'launch';

  @override
  final description = '''
Common command to launch and deploy Serverpod Cloud projects.

If there already is a Serverpod Cloud project near the current directory
it will redeploy the project (upload, build, and rollout in the cloud).

Otherwise it will guide you through setting up a new Serverpod Cloud project.
''';

  @override
  String get category => CommandCategories.gettingStarted;

  @override
  CloudLaunchCommand({required super.logger})
    : super(options: LaunchOption.values);

  @override
  Future<void> runWithConfig(final Configuration commandConfig) async {
    final projectConfigFile = globalConfiguration.projectConfigFile;

    final projectId = commandConfig.optionalValue(LaunchOption.projectId);
    final plan = commandConfig.optionalValue(LaunchOption.plan);
    final deploy = commandConfig.value(LaunchOption.deploy);
    final dartVersionOverride = commandConfig.optionalValue(
      LaunchOption.dartVersion,
    );
    final tui = commandConfig.value(LaunchOption.tui);

    // Deploy-specific options
    final concurrency = commandConfig.value(LaunchOption.concurrency);
    final dryRun = commandConfig.value(LaunchOption.dryRun);
    final showFiles = commandConfig.value(LaunchOption.showFiles);
    final outputPath = commandConfig.optionalValue(LaunchOption.output);
    final wait = commandConfig.value(LaunchOption.wait);

    final projectDirectory = runner.verifiedProjectDirectory();

    if (projectConfigFile != null) {
      if (projectId == null) {
        throw FailureException(
          error:
              'The configuration file $projectConfigFile lacks a project ID.',
        );
      }
      if (commandConfig.valueSourceType(LaunchOption.projectId) !=
          ValueSourceType.config) {
        final config = ScloudConfigIO.readFromFile(projectConfigFile.path);
        if (config?.projectId != projectId) {
          final confirm = await logger.confirm(
            'The specified project ID "$projectId" does not match the scloud config file "${config?.projectId}".'
            '\nContinue with deployment to "$projectId"?',
            defaultValue: false,
          );
          if (!confirm) {
            logger.info('Deployment cancelled.');
            throw UserAbortException();
          }
        }
      }

      // Unambiguous scloud.<ext> file found, perform a deploy
      logger.debug('Project directory is: ${projectDirectory.path}');
      await Deploy.deploy(
        runner.serviceProvider.cloudApiClient,
        runner.serviceProvider.fileUploaderFactory,
        logger: logger,
        projectId: projectId,
        projectDir: projectDirectory.path,
        projectConfigFilePath: projectConfigFile.path,
        concurrency: concurrency,
        dryRun: dryRun,
        showFiles: showFiles,
        skipTailingStatus: !wait,
        outputPath: outputPath?.path,
        dartVersionOverride: dartVersionOverride,
      );

      return;
    }

    await Launch.launch(
      runner.serviceProvider.cloudApiClient,
      runner.serviceProvider.fileUploaderFactory,
      logger: logger,
      projectDirectory: projectDirectory,
      projectId: projectId,
      plan: plan,
      performDeploy: deploy,
      dartVersionOverride: dartVersionOverride,
      tui: tui,
      deployConcurrency: concurrency,
      deployDryRun: dryRun,
      deployShowFiles: showFiles,
      deployOutputPath: outputPath?.path,
      deploySkipTailingStatus: !wait,
    );
  }
}
