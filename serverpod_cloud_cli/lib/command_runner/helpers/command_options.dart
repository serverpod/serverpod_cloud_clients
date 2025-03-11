import 'package:serverpod_cloud_cli/util/config/config.dart';
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
  }) : super(
          argName: CommandConfigConstants.projectIdArgName,
          argAbbrev: 'p',
          envName: 'SERVERPOD_CLOUD_PROJECT_ID',
          configKey: '$scloudConfigDomainPrefix:/project/projectId',
          mandatory: true,
        );

  /// Used for commands that require explicit command line argument for the project ID.
  const ProjectIdOption.argsOnly({
    super.argPos,
    super.helpText = CommandConfigConstants.projectIdHelpText,
  }) : super(
          argName: CommandConfigConstants.projectIdArgName,
          argAbbrev: 'p',
          mandatory: true,
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
