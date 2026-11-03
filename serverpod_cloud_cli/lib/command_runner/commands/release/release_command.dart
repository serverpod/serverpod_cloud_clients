import 'dart:io';

import 'package:config/config.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/prepare_project_files.dart'
    show TenantProject;
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/constants.dart'
    show ProjectConfigFileConstants;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart'
    show FailureException;
import 'package:serverpod_cloud_cli/util/flutter_platform.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config.dart';

import 'release_app.dart';

class ReleaseAppDirOption extends DirOption {
  const ReleaseAppDirOption({super.group})
    : super(
        argName: 'app-dir',
        helpText:
            'The path to the Flutter app directory. '
            'Defaults to project.appDir in scloud.yaml, '
            "or else to the Flutter app in the server's workspace "
            'or near the server directory.',
        mode: PathExistMode.mustExist,
      );
}

class ReleasePlatformsOption extends MultiOption<FlutterPlatform> {
  /// The platforms an app can be released for.
  static const supportedPlatforms = [
    FlutterPlatform.android,
    FlutterPlatform.ios,
  ];

  const ReleasePlatformsOption({super.group})
    : super(
        multiParser: const MultiParser(EnumParser(FlutterPlatform.values)),
        argName: 'platforms',
        valueHelp: 'android,ios',
        helpText:
            'The platforms to release, separated by commas. '
            'The code of the other platforms is left out of the upload. '
            'Defaults to the supported platforms the app has code for. '
            'Supported platforms: android, ios.',
        customValidator: _supportedPlatformsValidator,
      );

  static void _supportedPlatformsValidator(List<FlutterPlatform> platforms) {
    final unsupported = platforms
        .where((platform) => !supportedPlatforms.contains(platform))
        .map((platform) => platform.name)
        .toSet();
    if (unsupported.isNotEmpty) {
      throw UsageException(
        'Releasing for ${unsupported.join(', ')} is not supported yet. '
            'Supported platforms: '
            '${supportedPlatforms.map((platform) => platform.name).join(', ')}.',
        '',
      );
    }
  }
}

class ReleaseAwaitOption extends FlagOption {
  const ReleaseAwaitOption({super.group})
    : super(
        argName: 'await',
        defaultsTo: false,
        negatable: false,
        helpText: 'Await the builds to finish while showing their progress.',
      );
}

enum ReleaseAppCommandOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption(asFirstArg: true, excludeSettings: true)),
  appDir(ReleaseAppDirOption()),
  platforms(ReleasePlatformsOption()),
  wait(ReleaseAwaitOption());

  const ReleaseAppCommandOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudReleaseCommand extends CloudCliCommand {
  @override
  final name = 'release';

  @override
  final description = 'Release the apps of a Serverpod project.';

  @override
  String get category => CommandCategories.control;

  /// Hidden until a released app can be built and hosted.
  @override
  bool get hidden => true;

  CloudReleaseCommand({required super.logger}) {
    addSubcommand(CloudReleaseAppCommand(logger: logger));
  }
}

class CloudReleaseAppCommand extends CloudCliCommand<ReleaseAppCommandOption> {
  @override
  final name = 'app';

  @override
  final description =
      'Upload the Flutter app to be built for release. '
      'An app in a Dart workspace is uploaded with its workspace dependencies.';

  @override
  String get usageExamples =>
      '''\n
Examples

  Release the Flutter app of your project

    \$ $baseCommand release app

  Release only the Android app

    \$ $baseCommand release app --platforms android

  Release the app and wait for its builds to finish

    \$ $baseCommand release app --await

  Release a Flutter app in a specific directory

    \$ $baseCommand release app --app-dir my_project_flutter

''';

  CloudReleaseAppCommand({required super.logger})
    : super(options: ReleaseAppCommandOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<ReleaseAppCommandOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(ReleaseAppCommandOption.projectId);
    final appDir = commandConfig.optionalValue(ReleaseAppCommandOption.appDir);
    final platforms = commandConfig.optionalValue(
      ReleaseAppCommandOption.platforms,
    );
    final awaitBuilds = commandConfig.value(ReleaseAppCommandOption.wait);

    final appDirectory = appDir ?? _configuredOrWorkspaceAppDirectory();
    logger.debug('App directory is: ${appDirectory.path}');

    await ReleaseApp.release(
      runner.serviceProvider.cloudApiClient,
      runner.serviceProvider.fileUploaderFactory,
      logger: logger,
      projectId: projectId,
      appDirectory: appDirectory,
      defaultPlatforms: ReleasePlatformsOption.supportedPlatforms,
      platforms: platforms?.toSet(),
      awaitBuilds: awaitBuilds,
    );
  }

  /// Returns the app directory set by project.appDir in the scloud.yaml
  /// file, resolved from the directory of that file, or else the Flutter
  /// app found in the server's workspace or near the server directory.
  ///
  /// Throws [FailureException] if the configured directory does not exist.
  Directory _configuredOrWorkspaceAppDirectory() {
    final projectDirectory = runner.verifiedProjectDirectory();
    final configFilePath =
        globalConfiguration.projectConfigFile?.path ??
        p.join(
          projectDirectory.path,
          ProjectConfigFileConstants.defaultFileName,
        );

    final configuredAppDir = ScloudConfigIO.readFromFile(
      configFilePath,
    )?.appDir;
    if (configuredAppDir == null) {
      return TenantProject.findAppDirectory(projectDirectory);
    }

    final appDirectory = Directory(
      p.normalize(p.join(p.dirname(configFilePath), configuredAppDir)),
    );
    if (!appDirectory.existsSync()) {
      throw FailureException(
        error:
            'The app directory ${appDirectory.path} set by project.appDir '
            'in $configFilePath does not exist.',
      );
    }
    return appDirectory;
  }
}
