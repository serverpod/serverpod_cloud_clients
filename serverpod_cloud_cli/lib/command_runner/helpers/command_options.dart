import 'dart:io';

import 'package:serverpod_cloud_cli/util/configuration.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config.dart';

abstract final class CommandConfigConstants {
  static const listOptionAbbrev = 'l';

  static const projectIdArgName = 'project';
  static const projectIdHelpText =
      'The ID of the project. Can be omitted if the project is linked. \n'
      'See `scloud project link --help` for more information.';
}

class ProjectIdOption extends ConfigOption {
  const ProjectIdOption({
    super.argPos,
    super.helpText = CommandConfigConstants.projectIdHelpText,
    super.envName = 'SERVERPOD_CLOUD_PROJECT_ID',
  }) : super(
          argName: CommandConfigConstants.projectIdArgName,
          argAbbrev: 'p',
          defaultFrom: _tryGetProjectIdFromConfig,
          valueRequired: true,
        );
}

String? _tryGetProjectIdFromConfig() {
  try {
    return ScloudConfig.getProjectIdFromConfig(Directory.current.path);
  } catch (_) {
    return null;
  }
}

class ProjectDirOption extends ConfigOption {
  const ProjectDirOption({required final String helpText})
      : super(
          argName: 'project-dir',
          argAbbrev: 'd',
          helpText: helpText,
          defaultFrom: _getCurrentPath,
          envName: 'SERVERPOD_CLOUD_PROJECT_DIR',
        );
}

class NameOption extends ConfigOption {
  const NameOption({
    required String super.helpText,
    required int super.argPos,
  }) : super(
          mandatory: true,
          argName: 'name',
        );
}

class ValueOption extends ConfigOption {
  const ValueOption({
    required final String helpText,
    required final int argPos,
  }) : super(
          argName: 'value',
          helpText: helpText,
          mandatory: true,
          argPos: argPos,
        );
}

String _getCurrentPath() {
  if (Platform.environment.containsKey('GENERATING_DOCS')) {
    return "<current directory>";
  }

  return Directory.current.path;
}
