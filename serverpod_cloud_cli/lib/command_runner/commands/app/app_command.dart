import 'dart:io';

import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client.dart'
    show AppPlatform, UuidValue;
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

import 'app_publish.dart';
import 'app_ops.dart';
import 'app_show.dart';
import 'app_ui.dart';

class AppPublishDirOption extends DirOption {
  const AppPublishDirOption({super.group})
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

class AppPublishPlatformsOption extends MultiOption<FlutterPlatform> {
  /// The platforms an app can be published for.
  static const supportedPlatforms = [
    FlutterPlatform.android,
    FlutterPlatform.ios,
  ];

  const AppPublishPlatformsOption({super.group})
    : super(
        multiParser: const MultiParser(EnumParser(supportedPlatforms)),
        allowedValues: supportedPlatforms,
        argName: 'platforms',
        valueHelp: 'android,ios',
        helpText:
            'The platforms to publish, separated by commas. '
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
        'Publishing for ${unsupported.join(', ')} is not supported yet. '
            'Supported platforms: '
            '${supportedPlatforms.map((platform) => platform.name).join(', ')}.',
        '',
      );
    }
  }
}

class AppPublishFlutterVersionOption extends StringOption {
  const AppPublishFlutterVersionOption({super.group})
    : super(
        argName: 'flutter-version',
        valueHelp: 'version',
        helpText:
            'The Flutter release version to build the app with. '
            'Defaults to project.flutterSdk in scloud.yaml, '
            'or else to the version in a .tool-versions file, '
            "or else to the single version the app's pubspec.yaml requires, "
            'or else to the latest stable release.',
        envName: 'SERVERPOD_CLOUD_APP_FLUTTER_VERSION',
      );
}

class AppPublishAwaitOption extends FlagOption {
  const AppPublishAwaitOption({super.group})
    : super(
        argName: 'await',
        defaultsTo: true,
        helpText:
            'Await the builds to finish while showing their progress, and '
            'their build logs on an interactive terminal.',
      );
}

class AppUploadIdOption extends StringOption {
  const AppUploadIdOption({super.group})
    : super(
        argName: 'upload-id',
        argPos: 0,
        mandatory: true,
        helpText:
            'The id of the app upload, as printed by app publish or app list. '
            'Can be passed as the first argument.',
        customValidator: _uploadIdValidator,
      );

  static void _uploadIdValidator(String value) {
    try {
      UuidValue.withValidation(value);
    } on FormatException {
      throw FormatException('Invalid upload id: $value');
    }
  }
}

class AppLogPlatformOption extends EnumOption<AppPlatform> {
  const AppLogPlatformOption({super.group})
    : super(
        enumParser: const EnumParser(AppPlatform.values),
        argName: 'platform',
        allowedValues: AppPlatform.values,
        helpText:
            'The platform of the build to stream the log of. '
            'Defaults to the only platform of the upload.',
      );
}

enum AppPublishCommandOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption(asFirstArg: true, excludeSettings: true)),
  appDir(AppPublishDirOption()),
  platforms(AppPublishPlatformsOption()),
  flutterVersion(AppPublishFlutterVersionOption()),
  wait(AppPublishAwaitOption());

  const AppPublishCommandOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

enum AppShowCommandOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption(excludeSettings: true)),
  uploadId(AppUploadIdOption());

  const AppShowCommandOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AppListPlatformsOption extends MultiOption<AppPlatform> {
  const AppListPlatformsOption()
    : super(
        multiParser: const MultiParser(EnumParser(AppPlatform.values)),
        allowedValues: AppPlatform.values,
        argName: 'platforms',
        valueHelp: 'android,ios',
        helpText:
            'The platforms to list the builds of, separated by commas. '
            'Lists one row per build instead of one row per publish.',
      );
}

enum AppListCommandOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption(asFirstArg: true, excludeSettings: true)),
  platforms(AppListPlatformsOption()),
  limit(
    IntOption(
      argName: 'limit',
      helpText: 'The maximum number of rows to list.',
      defaultsTo: 10,
      min: 1,
    ),
  ),
  utc(UtcOption());

  const AppListCommandOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

enum AppStatusCommandOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption(asFirstArg: true, excludeSettings: true)),
  utc(UtcOption());

  const AppStatusCommandOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

enum AppLogCommandOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption(excludeSettings: true)),
  uploadId(AppUploadIdOption()),
  platform(AppLogPlatformOption());

  const AppLogCommandOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudAppCommand extends CloudCliCommand {
  @override
  final name = 'app';

  @override
  final description = 'Publish and follow the apps of a Serverpod project.';

  @override
  String get category => CommandCategories.control;

  /// Hidden until a published app can be built and hosted.
  @override
  bool get hidden => true;

  CloudAppCommand({required super.logger}) {
    addSubcommand(CloudAppPublishCommand(logger: logger));
    addSubcommand(CloudAppShowCommand(logger: logger));
    addSubcommand(CloudAppListCommand(logger: logger));
    addSubcommand(CloudAppStatusCommand(logger: logger));
    addSubcommand(CloudAppLogCommand(logger: logger));
  }
}

class CloudAppPublishCommand extends CloudCliCommand<AppPublishCommandOption> {
  @override
  final name = 'publish';

  @override
  final description =
      'Upload the Flutter app to be built and published. '
      'An app in a Dart workspace is uploaded with its workspace dependencies.';

  @override
  String get usageExamples =>
      '''\n
Examples

  Publish the Flutter app of your project

    \$ $baseCommand app publish

  Publish only the Android app

    \$ $baseCommand app publish --platforms android

  Publish the app built with a specific Flutter version

    \$ $baseCommand app publish --flutter-version 3.38.4

  Publish the app without waiting for its builds to finish

    \$ $baseCommand app publish --no-await

  Publish a Flutter app in a specific directory

    \$ $baseCommand app publish --app-dir my_project_flutter

''';

  CloudAppPublishCommand({required super.logger})
    : super(options: AppPublishCommandOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<AppPublishCommandOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(AppPublishCommandOption.projectId);
    final appDir = commandConfig.optionalValue(AppPublishCommandOption.appDir);
    final platforms = commandConfig.optionalValue(
      AppPublishCommandOption.platforms,
    );
    final flutterVersion = commandConfig.optionalValue(
      AppPublishCommandOption.flutterVersion,
    );
    final awaitBuilds = commandConfig.value(AppPublishCommandOption.wait);

    final configFile = globalConfiguration.projectConfigFile;
    final config = configFile == null
        ? null
        : ScloudConfigIO.readFromFile(configFile.path);

    final appDirectory =
        appDir ?? _configuredOrWorkspaceAppDirectory(configFile, config);
    logger.debug('App directory is: ${appDirectory.path}');

    await AppPublish.publish(
      runner.serviceProvider.cloudApiClient,
      runner.serviceProvider.fileUploaderFactory,
      logger: logger,
      baseCommand: baseCommand,
      projectId: projectId,
      appDirectory: appDirectory,
      defaultPlatforms: AppPublishPlatformsOption.supportedPlatforms,
      platforms: platforms?.toSet(),
      configuredAppIdentifiers: config?.appIdentifiers ?? const {},
      flutterVersionOverride: flutterVersion,
      configuredFlutterVersion: config?.flutterSdk,
      configFileName: configFile == null
          ? ProjectConfigFileConstants.defaultFileName
          : p.basename(configFile.path),
      awaitBuilds: awaitBuilds,
    );
  }

  /// Returns the app directory set by project.appDir in [config], read from
  /// [configFile] and resolved from that file's directory, or else the
  /// Flutter app found in the server's workspace or near the server
  /// directory.
  ///
  /// Throws [FailureException] if the configured directory does not exist.
  Directory _configuredOrWorkspaceAppDirectory(
    File? configFile,
    ScloudConfig? config,
  ) {
    final projectDirectory = runner.verifiedProjectDirectory();
    final configuredAppDir = config?.appDir;
    if (configFile == null || configuredAppDir == null) {
      return TenantProject.findAppDirectory(projectDirectory);
    }
    final configFilePath = configFile.path;

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

class CloudAppShowCommand extends CloudCliCommand<AppShowCommandOption> {
  @override
  final name = 'show';

  @override
  final description =
      'Show the builds of an app upload. '
      'Follows their progress until they end.';

  @override
  String get usageExamples =>
      '''\n
Examples

  Show the builds of an app upload by the upload id that app publish or app list printed

    \$ $baseCommand app show 3f2b0c4e-1d5a-4b8e-9c7f-2a6d8e1b4c90

''';

  CloudAppShowCommand({required super.logger})
    : super(options: AppShowCommandOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<AppShowCommandOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(AppShowCommandOption.projectId);
    final uploadId = commandConfig.value(AppShowCommandOption.uploadId);

    await AppShow.show(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: projectId,
      uploadId: UuidValue.withValidation(uploadId),
    );
  }
}

class CloudAppListCommand extends CloudCliCommand<AppListCommandOption> {
  @override
  final name = 'list';

  @override
  final description = 'List recent app publishes, newest first.';

  @override
  String get usageExamples =>
      '''\n
Examples

  List the 10 most recent publishes

    \$ $baseCommand app list

  List the 20 most recent iOS builds

    \$ $baseCommand app list --platforms ios --limit 20

  List the most recent builds of each platform

    \$ $baseCommand app list --platforms ios,android

''';

  CloudAppListCommand({required super.logger})
    : super(options: AppListCommandOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<AppListCommandOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(AppListCommandOption.projectId);
    final platforms = commandConfig.optionalValue(
      AppListCommandOption.platforms,
    );
    final limit = commandConfig.value(AppListCommandOption.limit);
    final inUtc = commandConfig.value(AppListCommandOption.utc);
    final cloudApiClient = runner.serviceProvider.cloudApiClient;

    if (platforms == null || platforms.isEmpty) {
      await renderCommand(
        output,
        operation: () => AppOperations.listUploads(
          cloudApiClient,
          projectId: projectId,
          limit: limit,
        ),
        textOutputUi: AppUploadListTextUi(utc: inUtc),
      );
      return;
    }

    final selectedPlatforms = AppPlatform.values
        .where(platforms.contains)
        .toList();
    await renderCommand(
      output,
      operation: () => AppOperations.listBuilds(
        cloudApiClient,
        projectId: projectId,
        platforms: selectedPlatforms,
        limit: limit,
      ),
      textOutputUi: AppBuildListTextUi(
        utc: inUtc,
        platforms: selectedPlatforms,
      ),
      jsonOutputUi: const AppBuildListStructuredUi(),
      yamlOutputUi: const AppBuildListStructuredUi(),
    );
  }
}

class CloudAppStatusCommand extends CloudCliCommand<AppStatusCommandOption> {
  @override
  final name = 'status';

  @override
  final description =
      'Show the latest build of each platform with a connected store.';

  @override
  String get usageExamples =>
      '''\n
Examples

  Show the latest build of each connected platform

    \$ $baseCommand app status

''';

  CloudAppStatusCommand({required super.logger})
    : super(options: AppStatusCommandOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<AppStatusCommandOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(AppStatusCommandOption.projectId);
    final inUtc = commandConfig.value(AppStatusCommandOption.utc);

    await renderCommand(
      output,
      operation: () => AppOperations.getStatus(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
      ),
      textOutputUi: AppStatusTextUi(
        utc: inUtc,
        baseCommand: baseCommand,
        projectId: projectId,
      ),
    );
  }
}

class CloudAppLogCommand extends CloudCliCommand<AppLogCommandOption> {
  @override
  final name = 'log';

  @override
  final description =
      'Stream the build log of an app upload for one platform. '
      'The log of a step shows when the step ends.';

  @override
  String get usageExamples =>
      '''\n
Examples

  Stream the iOS build log of an app upload by the upload id that app publish or app list printed

    \$ $baseCommand app log 3f2b0c4e-1d5a-4b8e-9c7f-2a6d8e1b4c90 --platform ios

''';

  CloudAppLogCommand({required super.logger})
    : super(options: AppLogCommandOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<AppLogCommandOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(AppLogCommandOption.projectId);
    final uploadId = commandConfig.value(AppLogCommandOption.uploadId);
    final platform = commandConfig.optionalValue(AppLogCommandOption.platform);

    await renderCommand(
      output,
      operation: () => AppOperations.followBuildLog(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
        uploadId: UuidValue.withValidation(uploadId),
        platform: platform,
      ),
      textOutputUi: const AppLogTextUi(),
    );
  }
}
