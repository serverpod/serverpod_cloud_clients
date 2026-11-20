import 'dart:io' show File;

import 'package:config/command.dart' show CommandContext;
import 'package:config/config.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart'
    show GlobalConfigurationOptions;
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/deploy.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/cloud_cli_usage_exception.dart';

import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';

class DeployConcurrencyOption extends IntOption {
  const DeployConcurrencyOption({super.group})
    : super(
        argName: 'concurrency',
        argAbbrev: 'c',
        helpText:
            'Number of concurrent files processed when zipping the project.',
        defaultsTo: 5,
        min: 1,
      );
}

class DeployWetRunOption extends FlagOption {
  const DeployWetRunOption({super.group})
    : super(
        argName: 'wet-run',
        argAliases: const ['dry-run'],
        helpText:
            'Perform every step except the deployment, '
            'leaving the hosted application untouched. '
            'Local files may still be modified.',
        defaultsTo: false,
        negatable: false,
      );
}

class DeployShowFilesOption extends FlagOption {
  const DeployShowFilesOption({super.group})
    : super(
        argName: 'show-files',
        helpText: 'Display the file tree that will be uploaded.',
        defaultsTo: false,
        negatable: false,
      );
}

class DeployRestartOption extends FlagOption {
  const DeployRestartOption({super.group})
    : super(
        argName: 'restart',
        argAliases: const ['redeploy'],
        helpText:
            'Restart the currently running build with the latest variables and '
            'secrets. Skips zipping and uploading the project.',
        defaultsTo: false,
        negatable: false,
      );
}

class DeployOutputOption extends FileOption {
  const DeployOutputOption({super.group})
    : super(
        argName: 'output',
        argAbbrev: 'o',
        helpText:
            'Save the deployment zip file to the specified path. Must end with .zip',
        customValidator: _zipExtValidator,
      );

  static void _zipExtValidator(File value) {
    if (!value.path.endsWith('.zip')) {
      throw UsageException('The path must end with .zip', '');
    }
  }
}

class AwaitOption extends FlagOption {
  const AwaitOption({super.group})
    : super(
        argName: 'await',
        defaultsTo: true,
        helpText:
            'Await the deployment to finish while showing status progression.',
      );
}

enum DeployCommandOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption(asFirstArg: true, excludeSettings: true)),
  concurrency(DeployConcurrencyOption()),
  wetRun(DeployWetRunOption()),
  showFiles(DeployShowFilesOption()),
  restart(DeployRestartOption()),
  output(DeployOutputOption()),
  wait(AwaitOption()),
  dartVersion(DartSdkVersionOption()),

  // developer options:
  skipDartPubGet(
    FlagOption(
      argName: 'skip-dart-pub-get',
      helpText: 'Skip running "dart pub get" before deploying.',
      defaultsTo: false,
      negatable: false,
      hide: true,
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
  String get usageExamples =>
      '''\n
Examples

  Deploy your project to the cloud

    \$ $baseCommand deploy

  Preview the file tree that will be uploaded
  
    \$ $baseCommand deploy --show-files
  
  The output shows files that will be included in the deployment, as well as files that are ignored (marked with "(ignored)").
  
  This is useful for verifying that your .gitignore and .scloudignore files are working as expected. You can combine it with --wet-run to preview the file tree without actually deploying:

    \$ $baseCommand deploy --wet-run --show-files

  Save the deployment zip file locally

    \$ $baseCommand deploy --output deployment.zip --wet-run

  Save the deployment zip and still upload it (unless --wet-run is set)

    \$ $baseCommand deploy --output deployment.zip

  Restart the currently running build with the latest variables and secrets

    \$ $baseCommand deploy --restart

''';

  CloudDeployCommand({required super.logger})
    : super(options: DeployCommandOption.values);

  @override
  Future<void> runWithOutput(
    final CommandContext<DeployCommandOption, void> context,
    final CommandOutput output,
  ) async {
    final projectId = context.config.value(DeployCommandOption.projectId);
    final concurrency = context.config.value(DeployCommandOption.concurrency);
    final wetRun = context.config.value(DeployCommandOption.wetRun);
    final showFiles = context.config.value(DeployCommandOption.showFiles);
    final restart = context.config.value(DeployCommandOption.restart);
    final outputPath = context.config.optionalValue(DeployCommandOption.output);
    final wait = context.config.value(DeployCommandOption.wait);
    final dartVersionOverride = context.config.optionalValue(
      DeployCommandOption.dartVersion,
    );
    final skipDartPubGet = context.config.value(
      DeployCommandOption.skipDartPubGet,
    );

    if (restart) {
      if (wetRun ||
          showFiles ||
          outputPath != null ||
          dartVersionOverride != null) {
        throw CloudCliUsageException(
          'The --restart option cannot be combined with '
          '--wet-run, --show-files, --output, or --dart-version.',
        );
      }

      await Deploy.restart(
        context.serviceProvider.cloudApiClient,
        logger: logger,
        baseCommand: baseCommand,
        projectId: projectId,
      );
      return;
    }

    final projectDirectory = runner.verifiedProjectDirectory(context);
    logger.debug('Project directory is: ${projectDirectory.path}');
    final configFilePath =
        context.globalConfiguration.projectConfigFile?.path ??
        p.join(
          projectDirectory.path,
          ProjectConfigFileConstants.defaultFileName,
        );

    await Deploy.deploy(
      context.serviceProvider.cloudApiClient,
      context.serviceProvider.fileUploaderFactory,
      logger: logger,
      baseCommand: baseCommand,
      projectId: projectId,
      projectDir: projectDirectory.path,
      projectConfigFilePath: configFilePath,
      concurrency: concurrency,
      wetRun: wetRun,
      showFiles: showFiles,
      skipDartPubGet: skipDartPubGet,
      skipTailingStatus: !wait,
      outputPath: outputPath?.path,
      dartVersionOverride: dartVersionOverride,
    );
  }
}
