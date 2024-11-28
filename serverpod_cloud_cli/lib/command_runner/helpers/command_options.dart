import 'dart:io';

import 'package:serverpod_cloud_cli/util/configuration.dart';

abstract final class CommandConfigConstants {
  static const listOptionAbbrev = 'l';

  static const projectIdArgName = 'project-id';
  static const projectIdHelpText = 'The ID of the project.';
}

class ProjectIdOption extends ConfigOption {
  const ProjectIdOption({
    super.argPos,
    super.helpText = CommandConfigConstants.projectIdHelpText,
    super.envName = 'SERVERPOD_CLOUD_PROJECT_ID',
  }) : super(
          argName: CommandConfigConstants.projectIdArgName,
          argAbbrev: 'i',
          mandatory: true,
        );
}

class ProjectDirOption extends ConfigOption {
  const ProjectDirOption({required final String helpText})
      : super(
          argName: 'project-dir',
          argAbbrev: 'd',
          helpText: helpText,
          defaultFrom: _getCurrentPath,
          envName: 'SERVERPOD_CLOUD_PROJECT_DIR',
          hide: true,
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
  return Directory.current.path;
}
