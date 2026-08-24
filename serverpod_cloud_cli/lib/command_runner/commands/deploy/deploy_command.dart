import 'dart:io' show File;

import 'package:config/config.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/deploy.dart';
import 'package:serverpod_cloud_cli/constants.dart';

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

class DeployOutputOption extends FileOption {
  const DeployOutputOption({super.group})
    : super(
        argName: 'output',
        argAbbrev: 'o',
        helpText:
            'Save the deployment zip file to the specified path. Must end with .zip',
        customValidator: _zipExtValidator,
      );

  static void _zipExtValidator(final File value) {
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
  projectId(ProjectIdOption(asFirstArg: true)),
  concurrency(DeployConcurrencyOption()),
  wetRun(DeployWetRunOption()),
  showFiles(DeployShowFilesOption()),
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
  String get usageExamples => '''\n
Examples

  Deploy your project to the cloud

    \$ scloud deploy

  Preview the file tree that will be uploaded
  
    \$ scloud deploy --show-files
  
  The output shows files that will be included in the deployment, as well as files that are ignored (marked with "(ignored)").
  
  This is useful for verifying that your .gitignore and .scloudignore files are working as expected. You can combine it with --wet-run to preview the file tree without actually deploying:

    \$ scloud deploy --wet-run --show-files

  Save the deployment zip file locally

    \$ scloud deploy --output deployment.zip --wet-run

  Save the deployment zip and still upload it (unless --wet-run is set)

    \$ scloud deploy --output deployment.zip

''';

  CloudDeployCommand({required super.logger})
    : super(options: DeployCommandOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<DeployCommandOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(DeployCommandOption.projectId);
    final concurrency = commandConfig.value(DeployCommandOption.concurrency);
    final wetRun = commandConfig.value(DeployCommandOption.wetRun);
    final showFiles = commandConfig.value(DeployCommandOption.showFiles);
    final outputPath = commandConfig.optionalValue(DeployCommandOption.output);
    final wait = commandConfig.value(DeployCommandOption.wait);
    final dartVersionOverride = commandConfig.optionalValue(
      DeployCommandOption.dartVersion,
    );
    final skipDartPubGet = commandConfig.value(
      DeployCommandOption.skipDartPubGet,
    );

    final projectDirectory = runner.verifiedProjectDirectory();
    logger.debug('Project directory is: ${projectDirectory.path}');
    final configFilePath =
        globalConfiguration.projectConfigFile?.path ??
        p.join(
          projectDirectory.path,
          ProjectConfigFileConstants.defaultFileName,
        );

    await Deploy.deploy(
      runner.serviceProvider.cloudApiClient,
      runner.serviceProvider.fileUploaderFactory,
      logger: logger,
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
