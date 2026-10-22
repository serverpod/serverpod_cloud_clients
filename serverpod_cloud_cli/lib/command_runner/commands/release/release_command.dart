import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/prepare_project_files.dart'
    show TenantProject;
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/util/flutter_platform.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;

import 'release_app.dart';

class ReleaseAppDirOption extends DirOption {
  const ReleaseAppDirOption({super.group})
    : super(
        argName: 'app-dir',
        helpText:
            'The path to the Serverpod Flutter app directory. '
            "Defaults to the Flutter app in the server's workspace.",
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
            'Only the code of these platforms is uploaded. '
            'Defaults to the whole app. '
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

enum ReleaseAppCommandOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption(asFirstArg: true, excludeSettings: true)),
  appDir(ReleaseAppDirOption()),
  platforms(ReleasePlatformsOption());

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
      'Upload the Serverpod Flutter app to the cloud. '
      'The app is zipped in a workspace with its workspace dependencies.';

  @override
  String get usageExamples =>
      '''\n
Examples

  Release the Flutter app of your project

    \$ $baseCommand release app

  Release only the Android and iOS code of the app

    \$ $baseCommand release app --platforms android,ios

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

    final appDirectory =
        appDir ??
        TenantProject.findAppDirectory(runner.verifiedProjectDirectory());
    logger.debug('App directory is: ${appDirectory.path}');

    await ReleaseApp.release(
      runner.serviceProvider.cloudApiClient,
      runner.serviceProvider.fileUploaderFactory,
      logger: logger,
      projectId: projectId,
      appDirectory: appDirectory,
      platforms: platforms?.toSet(),
    );
  }
}
