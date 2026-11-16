import 'dart:io';

import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client.dart'
    show AppPlatform, UuidValue;
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart'
    show CloudCliCommandRunner;
import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/prepare_project_files.dart'
    show TenantProject;
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/constants.dart'
    show ProjectConfigFileConstants;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart'
    show ErrorExitException, FailureException;
import 'package:serverpod_cloud_cli/util/dart_defines.dart';
import 'package:serverpod_cloud_cli/util/flutter_app_identifier.dart'
    show appIdentifierName, appIdentifierProblem;
import 'package:serverpod_cloud_cli/util/flutter_platform.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config.dart';

import 'app_doctor_check.dart';
import 'app_publish.dart';
import 'app_setup.dart';
import 'app_setup_guide.dart';
import 'app_ops.dart';
import 'app_show.dart';
import 'app_ui.dart';
import 'app_upload_controls_ui.dart';

class AppPublishDirOption extends DirOption {
  const AppPublishDirOption({super.group})
    : super(
        argName: 'app-dir',
        helpText:
            'The path to the Flutter app directory. '
            'Defaults to project.app.dir in scloud.yaml, the current Flutter app, '
            "or the Flutter app in the server's workspace "
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

  /// The help text of the option of `app publish`.
  static const publishHelpText =
      'The platforms to publish, separated by commas. '
      'The code of the other platforms is left out of the upload. '
      'Defaults to the supported platforms the app has code for '
      'and that are set up. '
      'Supported platforms: android, ios.';

  /// The help text of the option of `app doctor`.
  static const doctorHelpText =
      'The platforms to check, separated by commas. '
      'Defaults to the supported platforms the app has code for. '
      'Supported platforms: android, ios.';

  /// The help text of the option of `app setup`.
  static const setupHelpText =
      'The platforms to set up, separated by commas. '
      'Defaults to the supported platforms the app has code for. '
      'Supported platforms: android, ios.';

  const AppPublishPlatformsOption({
    super.group,
    super.helpText = publishHelpText,
  }) : super(
         multiParser: const MultiParser(_AppPlatformParser(supportedPlatforms)),
         argName: 'platforms',
         valueHelp: 'android,ios',
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
  /// The help text of the option of `app publish`.
  static const publishHelpText =
      'The Flutter release version to build the app with. '
      "Defaults to the single version the app's pubspec.yaml requires, "
      'or else to project.app.flutterSdk in scloud.yaml, '
      'or else to the version of the local Flutter SDK, '
      'or else to the latest stable release.';

  /// The help text of the option of `app doctor`.
  static const doctorHelpText =
      'The Flutter release version to check the app against, as '
      '"app publish --flutter-version" would build it. '
      "Defaults to the single version the app's pubspec.yaml requires, "
      'or else to project.app.flutterSdk in scloud.yaml, '
      'or else to the version of the local Flutter SDK. '
      'Without any of them, the build uses the latest stable release.';

  const AppPublishFlutterVersionOption({
    super.group,
    super.helpText = publishHelpText,
  }) : super(
         argName: 'flutter-version',
         valueHelp: 'version',
         envName: 'SERVERPOD_CLOUD_APP_FLUTTER_VERSION',
       );
}

class AppPublishDartDefineOption extends MultiOption<String> {
  const AppPublishDartDefineOption()
    : super(
        multiParser: const MultiParser(StringParser(), separator: null),
        argName: 'dart-define',
        valueHelp: 'key=value',
        helpText:
            'A dart define to build the app with, as KEY=VALUE. '
            'Can be repeated. Replaces the value of the same key from a '
            'dart defines file. SERVER_URL is always set by Serverpod Cloud.',
        customValidator: _validateDartDefines,
      );

  static void _validateDartDefines(List<String> defines) {
    for (final define in defines) {
      try {
        DartDefines.parseDefine(define);
      } on FormatException catch (e) {
        throw UsageException(e.message, '');
      }
    }
  }
}

class AppPublishDartDefineFromFileOption extends MultiOption<String> {
  const AppPublishDartDefineFromFileOption()
    : super(
        multiParser: const MultiParser(StringParser(), separator: null),
        argName: 'dart-define-from-file',
        valueHelp: 'path',
        helpText:
            'A file in JSON or .env format with dart defines to build the app '
            'with. Can be repeated; a later file replaces the values of an '
            'earlier one. Defaults to project.app.dartDefineFromFile in '
            'scloud.yaml.',
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

class AppPublishOutputOption extends FileOption {
  const AppPublishOutputOption()
    : super(
        argName: 'output',
        argAbbrev: 'o',
        helpText: 'Save the app archive to a path ending in .zip.',
        customValidator: _validateZipPath,
      );

  static void _validateZipPath(File file) {
    if (!file.path.endsWith('.zip')) {
      throw UsageException('The path must end with .zip.', '');
    }
  }
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
        enumParser: const _AppPlatformParser(AppPlatform.values),
        argName: 'platform',
        valueHelp: 'android|ios',
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
  dartDefine(AppPublishDartDefineOption()),
  dartDefineFromFile(AppPublishDartDefineFromFileOption()),
  wait(AppPublishAwaitOption()),
  showFiles(
    FlagOption(
      argName: 'show-files',
      helpText: 'Display the file tree that will be uploaded.',
      defaultsTo: false,
      negatable: false,
    ),
  ),
  wetRun(
    FlagOption(
      argName: 'wet-run',
      argAliases: ['dry-run'],
      helpText: 'Prepare the app archive without uploading or starting builds.',
      defaultsTo: false,
      negatable: false,
    ),
  ),
  output(AppPublishOutputOption());

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
        multiParser: const MultiParser(_AppPlatformParser(AppPlatform.values)),
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

enum AppUploadCommandOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption(excludeSettings: true)),
  uploadId(AppUploadIdOption());

  const AppUploadCommandOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

enum AppLogCommandOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption(excludeSettings: true)),
  uploadId(AppUploadIdOption()),
  platform(AppLogPlatformOption()),
  watch(
    FlagOption(
      argName: 'watch',
      helpText:
          'Wait for new step logs until the build ends. '
          'Use --no-watch to print the available logs and exit.',
      defaultsTo: true,
      negatable: true,
    ),
  );

  const AppLogCommandOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

enum AppDoctorCommandOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption(excludeSettings: true)),
  appDir(AppPublishDirOption()),
  platforms(
    AppPublishPlatformsOption(
      helpText: AppPublishPlatformsOption.doctorHelpText,
    ),
  ),
  flutterVersion(
    AppPublishFlutterVersionOption(
      helpText: AppPublishFlutterVersionOption.doctorHelpText,
    ),
  );

  const AppDoctorCommandOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class AppSetupIdentifierOption extends StringOption {
  const AppSetupIdentifierOption.android()
    : super(
        argName: 'android-package-name',
        valueHelp: 'name',
        envName: 'SERVERPOD_CLOUD_APP_ANDROID_PACKAGE_NAME',
        helpText:
            'The Android package name to publish the app with. Replaces the '
            'one the app declares, without a prompt.',
        customValidator: _validateAndroidPackageName,
      );

  const AppSetupIdentifierOption.ios()
    : super(
        argName: 'ios-bundle-id',
        valueHelp: 'id',
        envName: 'SERVERPOD_CLOUD_APP_IOS_BUNDLE_ID',
        helpText:
            'The iOS bundle ID to publish the app with. Replaces the one the '
            'app declares, without a prompt.',
        customValidator: _validateIosBundleId,
      );

  static void _validateAndroidPackageName(String value) =>
      _validate(FlutterPlatform.android, value);

  static void _validateIosBundleId(String value) =>
      _validate(FlutterPlatform.ios, value);

  static void _validate(FlutterPlatform platform, String value) {
    final problem = appIdentifierProblem(platform, value.trim());
    if (problem != null) {
      throw UsageException(
        'The ${appIdentifierName(platform)} "$value" $problem.',
        '',
      );
    }
  }
}

enum AppSetupCommandOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption(excludeSettings: true)),
  appDir(AppPublishDirOption()),
  platforms(
    AppPublishPlatformsOption(
      helpText: AppPublishPlatformsOption.setupHelpText,
    ),
  ),
  androidPackageName(AppSetupIdentifierOption.android()),
  iosBundleId(AppSetupIdentifierOption.ios());

  const AppSetupCommandOption(this.option);

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
    addSubcommand(CloudAppSetupCommand(logger: logger));
    addSubcommand(CloudAppDoctorCommand(logger: logger));
    addSubcommand(CloudAppPublishCommand(logger: logger));
    addSubcommand(CloudAppShowCommand(logger: logger));
    addSubcommand(CloudAppListCommand(logger: logger));
    addSubcommand(CloudAppStatusCommand(logger: logger));
    addSubcommand(CloudAppLogCommand(logger: logger));
    addSubcommand(CloudAppCancelCommand(logger: logger));
    addSubcommand(CloudAppArtifactsCommand(logger: logger));
  }
}

class CloudAppSetupCommand extends CloudCliCommand<AppSetupCommandOption> {
  @override
  final name = 'setup';

  @override
  final description =
      'Set up the Flutter app to be published. For each platform, checks the '
      'app identifier and asks for a new one when the app uses the Flutter '
      'default, unless --android-package-name or --ios-bundle-id sets it, '
      'then records it on Serverpod Cloud. For Android, also checks the '
      'release signing. Exits with an error status when a check fails.';

  @override
  bool get warnIfBillingOverdue => false;

  @override
  String get usageExamples =>
      '''\n
Examples

  Set up the Flutter app of your project

    \$ $baseCommand app setup

  Set up only the Android app

    \$ $baseCommand app setup --platforms android

  Set up the app without prompts, as in CI or for an agent

    \$ $baseCommand app setup --non-interactive --android-package-name com.acme.app --ios-bundle-id com.acme.app

  Set up a Flutter app in a specific directory

    \$ $baseCommand app setup --app-dir my_project_flutter

''';

  CloudAppSetupCommand({required super.logger})
    : super(options: AppSetupCommandOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<AppSetupCommandOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(AppSetupCommandOption.projectId);
    final appDir = commandConfig.optionalValue(AppSetupCommandOption.appDir);
    final platforms = commandConfig.optionalValue(
      AppSetupCommandOption.platforms,
    );
    final androidPackageName = commandConfig.optionalValue(
      AppSetupCommandOption.androidPackageName,
    );
    final iosBundleId = commandConfig.optionalValue(
      AppSetupCommandOption.iosBundleId,
    );

    final configFile = globalConfiguration.projectConfigFile;
    final config = configFile == null
        ? null
        : ScloudConfigIO.readFromFile(configFile.path);

    final context = await renderCommand(
      output,
      operation: () async {
        final appDirectory =
            appDir ??
            _configuredOrWorkspaceAppDirectory(runner, configFile, config);
        logger.debug('App directory is: ${appDirectory.path}');
        return AppSetupGuide.setUp(
          runner.serviceProvider.cloudApiClient,
          appDirectory: appDirectory,
          defaultPlatforms: AppPublishPlatformsOption.supportedPlatforms,
          platforms: platforms?.toSet(),
          requestedAppIdentifiers: {
            FlutterPlatform.android: ?androidPackageName?.trim(),
            FlutterPlatform.ios: ?iosBundleId?.trim(),
          },
          configuredAppIdentifiers: config?.appIdentifiers ?? const {},
          canPrompt: !output.format.isStructured,
          configFileName: _configFileName(configFile),
          projectId: projectId,
          logger: logger,
        );
      },
      textOutputUi: const AppDoctorTextUi(
        passedMessage: 'The app is set up for publishing.',
      ),
    );

    final failed = context
        .get<List<AppDoctorCheck>>()
        .where((check) => check.status == AppDoctorCheckStatus.failed)
        .length;
    if (failed > 0) {
      throw ErrorExitException('$failed app setup checks failed.');
    }
  }
}

class CloudAppDoctorCommand extends CloudCliCommand<AppDoctorCommandOption> {
  @override
  final name = 'doctor';

  @override
  final description =
      'Check whether the Flutter app is set up to be published: its Flutter '
      'version, the setup of each platform in the console, app identifiers, '
      'Android release signing, iOS export compliance, and app icons. Exits '
      'with an error status when a check fails.';

  @override
  bool get warnIfBillingOverdue => false;

  @override
  String get usageExamples =>
      '''\n
Examples

  Check the Flutter app of your project

    \$ $baseCommand app doctor

  Check only the iOS setup

    \$ $baseCommand app doctor --platforms ios

  Check the app as it would be built with a specific Flutter version

    \$ $baseCommand app doctor --flutter-version 3.50.0

  Check a Flutter app in a specific directory

    \$ $baseCommand app doctor --app-dir my_project_flutter

''';

  CloudAppDoctorCommand({required super.logger})
    : super(options: AppDoctorCommandOption.values);

  @override
  Future<void> runWithOutput(
    final Configuration<AppDoctorCommandOption> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(AppDoctorCommandOption.projectId);
    final appDir = commandConfig.optionalValue(AppDoctorCommandOption.appDir);
    final platforms = commandConfig.optionalValue(
      AppDoctorCommandOption.platforms,
    );
    final flutterVersion = commandConfig.optionalValue(
      AppDoctorCommandOption.flutterVersion,
    );

    final configFile = globalConfiguration.projectConfigFile;
    final config = configFile == null
        ? null
        : ScloudConfigIO.readFromFile(configFile.path);

    final context = await renderCommand(
      output,
      operation: () async {
        final appDirectory =
            appDir ??
            _configuredOrWorkspaceAppDirectory(runner, configFile, config);
        logger.debug('App directory is: ${appDirectory.path}');
        final publishingSetup = await AppOperations.getPublishingSetup(
          runner.serviceProvider.cloudApiClient,
          projectId: projectId,
        );
        return AppSetup.check(
          appDirectory,
          defaultPlatforms: AppPublishPlatformsOption.supportedPlatforms,
          platforms: platforms?.toSet(),
          configuredAppIdentifiers: config?.appIdentifiers ?? const {},
          configFileName: _configFileName(configFile),
          projectId: projectId,
          publishingSetup: publishingSetup,
          flutterVersionOverride: flutterVersion,
          configuredFlutterVersion: config?.flutterSdk,
          readLocalFlutterVersion:
              runner.serviceProvider.localFlutterVersionReader,
          logger: logger,
        );
      },
      textOutputUi: const AppDoctorTextUi(),
    );

    final failed = context
        .get<List<AppDoctorCheck>>()
        .where((check) => check.status == AppDoctorCheckStatus.failed)
        .length;
    if (failed > 0) {
      throw ErrorExitException('$failed app doctor checks failed.');
    }
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

    \$ $baseCommand app publish --flutter-version 3.50.0

  Publish the app built with dart defines

    \$ $baseCommand app publish --dart-define-from-file .env --dart-define FLAVOR=production

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
    final dartDefines =
        commandConfig.optionalValue(AppPublishCommandOption.dartDefine) ??
        const <String>[];
    final dartDefineFiles = commandConfig.optionalValue(
      AppPublishCommandOption.dartDefineFromFile,
    );

    final configFile = globalConfiguration.projectConfigFile;
    final config = configFile == null
        ? null
        : ScloudConfigIO.readFromFile(configFile.path);

    final appDirectory =
        appDir ??
        _configuredOrWorkspaceAppDirectory(runner, configFile, config);
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
      readLocalFlutterVersion: runner.serviceProvider.localFlutterVersionReader,
      dartDefineFiles: _dartDefineFiles(dartDefineFiles, configFile, config),
      dartDefines: dartDefines,
      configFileName: _configFileName(configFile),
      awaitBuilds: awaitBuilds,
      showFiles: commandConfig.value(AppPublishCommandOption.showFiles),
      wetRun: commandConfig.value(AppPublishCommandOption.wetRun),
      outputPath: commandConfig
          .optionalValue(AppPublishCommandOption.output)
          ?.path,
    );
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
      baseCommand: baseCommand,
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
      'Show the build log of an app upload for one platform. '
      'By default, watch for step logs until the build ends. '
      'Use --no-watch to print the available logs and exit.';

  @override
  String get usageExamples =>
      '''\n
Examples

  Stream the iOS build log of an app upload by the upload id that app publish or app list printed

    \$ $baseCommand app log 3f2b0c4e-1d5a-4b8e-9c7f-2a6d8e1b4c90 --platform ios

  Print the logs currently available and exit

    \$ $baseCommand app log 3f2b0c4e-1d5a-4b8e-9c7f-2a6d8e1b4c90 --platform ios --no-watch

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
    final watch = commandConfig.value(AppLogCommandOption.watch);

    await renderCommand(
      output,
      operation: () => AppOperations.followBuildLog(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
        uploadId: UuidValue.withValidation(uploadId),
        platform: platform,
        watch: watch,
        baseCommand: baseCommand,
      ),
      textOutputUi: AppLogTextUi(watch: watch),
    );
  }
}

class CloudAppCancelCommand extends CloudCliCommand<AppUploadCommandOption> {
  @override
  final name = 'cancel';

  @override
  final description =
      'Request cancellation of the active builds of an app upload.';

  CloudAppCancelCommand({required super.logger})
    : super(options: AppUploadCommandOption.values);

  @override
  Future<void> runWithOutput(
    Configuration<AppUploadCommandOption> commandConfig,
    CommandOutput output,
  ) async {
    await renderCommand(
      output,
      operation: () => AppOperations.cancelUpload(
        runner.serviceProvider.cloudApiClient,
        projectId: commandConfig.value(AppUploadCommandOption.projectId),
        uploadId: UuidValue.withValidation(
          commandConfig.value(AppUploadCommandOption.uploadId),
        ),
      ),
      textOutputUi: const AppCancelTextUi(),
    );
  }
}

class CloudAppArtifactsCommand extends CloudCliCommand<AppUploadCommandOption> {
  @override
  final name = 'artifacts';

  @override
  final description =
      'Show download links for the files built from an app upload. Links expire in ten minutes.';

  CloudAppArtifactsCommand({required super.logger})
    : super(options: AppUploadCommandOption.values);

  @override
  Future<void> runWithOutput(
    Configuration<AppUploadCommandOption> commandConfig,
    CommandOutput output,
  ) async {
    await renderCommand(
      output,
      operation: () => AppOperations.getArtifacts(
        runner.serviceProvider.cloudApiClient,
        projectId: commandConfig.value(AppUploadCommandOption.projectId),
        uploadId: UuidValue.withValidation(
          commandConfig.value(AppUploadCommandOption.uploadId),
        ),
      ),
      textOutputUi: const AppArtifactsTextUi(),
    );
  }
}

/// Returns the app directory set by project.app.dir in [config], read from
/// [configFile] and resolved from that file's directory, or else the
/// Flutter app in the current directory, in the server's workspace, or near
/// the server directory of [runner].
///
/// Throws [FailureException] if the configured directory does not exist.
Directory _configuredOrWorkspaceAppDirectory(
  CloudCliCommandRunner runner,
  File? configFile,
  ScloudConfig? config,
) {
  final configuredAppDir = config?.appDir;
  if (configFile == null || configuredAppDir == null) {
    final currentDirectory = Directory.current;
    if (runner.globalConfiguration.projectDir == null &&
        File(p.join(currentDirectory.path, 'pubspec.yaml')).existsSync() &&
        TenantProjectPubspec.fromProjectDir(currentDirectory).isFlutterApp()) {
      return currentDirectory;
    }
    return TenantProject.findAppDirectory(runner.verifiedProjectDirectory());
  }
  final configFilePath = configFile.path;

  final appDirectory = Directory(
    p.normalize(p.join(p.dirname(configFilePath), configuredAppDir)),
  );
  if (!appDirectory.existsSync()) {
    throw FailureException(
      error:
          'The app directory ${appDirectory.path} set by project.app.dir '
          'in $configFilePath does not exist.',
    );
  }
  return appDirectory;
}

/// The files to read the dart defines of an app build from: [requested],
/// the paths given on the command line, or else the paths of
/// project.app.dartDefineFromFile in [config], relative to the directory of
/// [configFile].
List<File> _dartDefineFiles(
  List<String>? requested,
  File? configFile,
  ScloudConfig? config,
) {
  if (requested != null && requested.isNotEmpty) {
    return [for (final path in requested) File(path)];
  }
  if (configFile == null || config == null) {
    return const [];
  }
  return [
    for (final path in config.dartDefineFromFile)
      File(p.normalize(p.join(p.dirname(configFile.path), path))),
  ];
}

/// The name of the project configuration file [configFile], or of the
/// default one when there is none.
String _configFileName(File? configFile) => configFile == null
    ? ProjectConfigFileConstants.defaultFileName
    : p.basename(configFile.path);

/// Parses supported app platform names without case sensitivity.
class _AppPlatformParser<E extends Enum> extends EnumParser<E> {
  const _AppPlatformParser(super.enumValues);

  @override
  E parse(String value) {
    final normalized = value.trim().toLowerCase();
    for (final platform in enumValues) {
      if (platform.name.toLowerCase() == normalized) return platform;
    }
    final supported = enumValues.map((platform) => platform.name).toList()
      ..sort();
    throw UsageException(
      'Invalid platform "$value". '
          'Supported platforms: ${supported.join(', ')}.',
      '',
    );
  }
}
