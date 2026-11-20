import 'dart:io' show Directory;

import 'package:config/command.dart' show CommandContext;
import 'package:config/config.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart'
    show GlobalConfigurationOptions;
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;
import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/deploy_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/deploy.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/launch/launch.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart'
    show FailureException, UserAbortException;
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config_io.dart';

enum LaunchOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption.nonMandatory(excludeSettings: true)),
  preDeployScripts(
    FlagOption(
      argName: 'pre-deploy-scripts',
      helpText: 'Set up pre-deploy scripts.',
      defaultsTo: true,
    ),
  ),
  deploy(
    FlagOption(
      argName: 'deploy',
      helpText: 'Automatically deploy the project after setup.',
      defaultsTo: true,
      hide: true, // intended for development and testing only
    ),
  ),
  dartVersion(DartSdkVersionOption()),
  utc(UtcOption()),

  // Deploy-specific options
  concurrency(DeployConcurrencyOption(group: _deployGroup)),
  wetRun(
    FlagOption(
      argName: 'wet-run',
      argAliases: ['dry-run'],
      helpText:
          'Perform every step except the deployment, '
          'leaving the hosted application untouched. '
          'Local files and the cloud project setup may still be modified.',
      defaultsTo: false,
      negatable: false,
      group: _deployGroup,
    ),
  ),
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

  CloudLaunchCommand({required super.logger})
    : super(options: LaunchOption.values);

  @override
  bool get interactiveOnly => true;

  @override
  String get nonInteractiveHint =>
      'Use `$baseCommand project create` and `$baseCommand deploy` '
      'in a non-interactive environment.';

  @override
  Future<void> runWithOutput(
    final CommandContext<LaunchOption, void> context,
    final CommandOutput output,
  ) async {
    final projectConfigFile = context.globalConfiguration.projectConfigFile;
    final consoleServer = context.globalConfiguration.consoleServer;
    final openBrowser = context.globalConfiguration.browser;

    final projectId = context.config.optionalValue(LaunchOption.projectId);
    final preDeployScripts = context.config.value(
      LaunchOption.preDeployScripts,
    );
    final deploy = context.config.value(LaunchOption.deploy);
    final dartVersionOverride = context.config.optionalValue(
      LaunchOption.dartVersion,
    );
    final inUtc = context.config.value(LaunchOption.utc);

    // Deploy-specific options
    final concurrency = context.config.value(LaunchOption.concurrency);
    final wetRun = context.config.value(LaunchOption.wetRun);
    final showFiles = context.config.value(LaunchOption.showFiles);
    final outputPath = context.config.optionalValue(LaunchOption.output);
    final wait = context.config.value(LaunchOption.wait);

    final projectDirectory = runner.verifiedProjectDirectory(context);
    final relativeProjectDir = p.relative(projectDirectory.path, from: '.');

    if (projectConfigFile != null) {
      if (projectId == null) {
        throw FailureException(
          error:
              'The configuration file $projectConfigFile lacks a project ID.',
        );
      }
      if (context.config.valueSourceType(LaunchOption.projectId) !=
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
      logger.debug('Project directory is: $relativeProjectDir');
      await Deploy.deploy(
        context.serviceProvider.cloudApiClient,
        context.serviceProvider.fileUploaderFactory,
        logger: logger,
        baseCommand: baseCommand,
        projectId: projectId,
        projectDir: relativeProjectDir,
        projectConfigFilePath: projectConfigFile.path,
        concurrency: concurrency,
        wetRun: wetRun,
        showFiles: showFiles,
        skipTailingStatus: !wait,
        outputPath: outputPath?.path,
        dartVersionOverride: dartVersionOverride,
      );

      return;
    }

    await Launch.launch(
      context.serviceProvider.cloudApiClient,
      context.serviceProvider.fileUploaderFactory,
      logger: logger,
      baseCommand: baseCommand,
      projectDirectory: Directory(relativeProjectDir),
      projectId: projectId,
      includePreDeployScripts: preDeployScripts,
      performDeploy: deploy,
      dartVersionOverride: dartVersionOverride,
      inUtc: inUtc,
      consoleServer: consoleServer,
      openBrowser: openBrowser,
      deployConcurrency: concurrency,
      wetRun: wetRun,
      deployShowFiles: showFiles,
      deployOutputPath: outputPath?.path,
      deploySkipTailingStatus: !wait,
    );
  }
}
