import 'package:serverpod_cloud_cli/util/config/config.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config.dart';

abstract final class CommandConfigConstants {
  static const listOptionAbbrev = 'l';
}

class ProjectIdOption extends StringOption {
  static const _projectIdArgName = 'project';
  static const _projectIdArgAbbrev = 'p';

  static const _helpText = 'The ID of the project. \n'
      'Can be omitted for existing projects that are linked. '
      'See `scloud project link --help`.';
  static const _helpTextFirstArg = 'The ID of the project. '
      'Can be passed as the first argument.\n'
      'Can be omitted for existing projects that are linked. '
      'See `scloud project link --help`.';

  const ProjectIdOption({
    final bool asFirstArg = false,
  }) : super(
          argName: _projectIdArgName,
          argAbbrev: _projectIdArgAbbrev,
          argPos: asFirstArg ? 0 : null,
          envName: 'SERVERPOD_CLOUD_PROJECT_ID',
          configKey: '$scloudConfigDomainPrefix:/project/projectId',
          mandatory: true,
          helpText: asFirstArg ? _helpTextFirstArg : _helpText,
        );

  /// Used for commands that require explicit command line argument for the project ID.
  const ProjectIdOption.argsOnly({
    final bool asFirstArg = false,
  }) : super(
          argName: _projectIdArgName,
          argAbbrev: _projectIdArgAbbrev,
          argPos: asFirstArg ? 0 : null,
          mandatory: true,
          helpText: asFirstArg ? _helpTextFirstArg : _helpText,
        );

  /// Used for commands that interactively ask for the project ID.
  const ProjectIdOption.nonMandatory({
    final bool asFirstArg = false,
  }) : super(
          argName: _projectIdArgName,
          argAbbrev: _projectIdArgAbbrev,
          argPos: asFirstArg ? 0 : null,
          helpText: asFirstArg ? _helpTextFirstArg : _helpText,
        );
}

class NameOption extends StringOption {
  const NameOption({
    required String super.helpText,
    required int super.argPos,
  }) : super(
          mandatory: true,
          argName: 'name',
        );
}

class ValueOption extends StringOption {
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
