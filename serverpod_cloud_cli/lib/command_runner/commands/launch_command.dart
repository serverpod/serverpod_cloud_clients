import 'dart:io' show Directory;

import 'package:config/config.dart';
import 'package:path/path.dart' as p;
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
  tui(
    FlagOption(
      argName: 'tui',
      defaultsTo: false,
      helpText: 'Flag to enable interactive terminal UI.',
      hide: true,
    ),
  ),
  dryRun(
    FlagOption(
      argName: 'dry-run',
      helpText:
          'Do not create the project, write cloud configuration files, '
          'or deploy. Runs the pre-deploy scripts and builds the deployment '
          'archive. For workspace projects the generated (gitignored) '
          '.scloud directory is still written, since the archive is built '
          'from it.',
      defaultsTo: false,
      negatable: false,
    ),
  ),

  // Deploy-specific options
  concurrency(DeployConcurrencyOption(group: _deployGroup)),
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
    final consoleServer = globalConfiguration.consoleServer;
    final openBrowser = globalConfiguration.browser;

    final projectId = commandConfig.optionalValue(LaunchOption.projectId);
    final preDeployScripts = commandConfig.value(LaunchOption.preDeployScripts);
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
    final relativeProjectDir = p.relative(projectDirectory.path, from: '.');

    if (projectConfigFile != null) {
      if (projectId == null) {
        throw FailureException(
          error:
              'The configuration file $projectConfigFile lacks a project ID.',
        );
      }
      final config = ScloudConfigIO.readFromFile(projectConfigFile.path);
      if (commandConfig.valueSourceType(LaunchOption.projectId) !=
              ValueSourceType.config &&
          config?.projectId != projectId) {
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

      // Unambiguous scloud.<ext> file found, perform a deploy
      logger.debug('Project directory is: $relativeProjectDir');
      await Deploy.deploy(
        runner.serviceProvider.cloudApiClient,
        runner.serviceProvider.fileUploaderFactory,
        logger: logger,
        projectId: projectId,
        projectDir: relativeProjectDir,
        config: config,
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
      projectDirectory: Directory(relativeProjectDir),
      projectId: projectId,
      includePreDeployScripts: preDeployScripts,
      performDeploy: deploy,
      dartVersionOverride: dartVersionOverride,
      tui: tui,
      consoleServer: consoleServer,
      openBrowser: openBrowser,
      deployConcurrency: concurrency,
      dryRun: dryRun,
      deployShowFiles: showFiles,
      deployOutputPath: outputPath?.path,
      deploySkipTailingStatus: !wait,
    );
  }
}
