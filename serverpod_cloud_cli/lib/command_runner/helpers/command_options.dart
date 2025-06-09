import 'package:cli_tools/config.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config.dart';

abstract final class CommandConfigConstants {
  static const listOptionAbbrev = 'l';
}

class ProjectIdOption extends StringOption {
  static const _projectIdArgName = 'project';
  static const _projectIdArgAbbrev = 'p';

  static const _helpText = 'The ID of the project.';
  static const _helpTextFirstArg = 'The ID of the project. '
      'Can be passed as the first argument.';

  /// Project ID option that can be passed as command line argument
  /// (and if asFirstArg is true, also as the first positional argument),
  /// env variable, and scloud config file.
  const ProjectIdOption({
    final bool asFirstArg = false,
  }) : super(
          argName: _projectIdArgName,
          argAbbrev: _projectIdArgAbbrev,
          argPos: asFirstArg ? 0 : null,
          envName: 'SERVERPOD_CLOUD_PROJECT_ID',
          configKey: '$scloudConfigDomainPrefix:/project/projectId',
          mandatory: true,
          helpText: '${asFirstArg ? _helpTextFirstArg : _helpText}'
              '\nCan be omitted for existing projects that are linked. '
              'See `scloud project link --help`.',
        );

  /// Used for commands that require explicit command line argument for the
  /// project ID, i.e. not from env variable or scloud config file.
  /// (And if asFirstArg is true, also as the first positional argument.)
  const ProjectIdOption.argsOnly({
    final bool asFirstArg = false,
  }) : super(
          argName: _projectIdArgName,
          argAbbrev: _projectIdArgAbbrev,
          argPos: asFirstArg ? 0 : null,
          mandatory: true,
          helpText: asFirstArg ? _helpTextFirstArg : _helpText,
        );

  /// Used for commands that interactively ask for the project ID but
  /// allow it to be specified as a command line argument
  /// (and if asFirstArg is true, also as the first positional argument).
  /// Does not accept value from env variable or scloud config file.
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
          argName: 'name',
          mandatory: true,
        );
}

const _valueGroup = MutuallyExclusive(
  'Value',
  mode: MutuallyExclusiveMode.mandatory,
);

class ValueOption extends StringOption {
  const ValueOption({
    required String super.helpText,
    required int super.argPos,
  }) : super(
          argName: 'value',
          group: _valueGroup,
        );
}

class ValueFileOption extends FileOption {
  const ValueFileOption({
    required String super.helpText,
  }) : super(
          argName: 'from-file',
          group: _valueGroup,
          mode: PathExistMode.mustExist,
        );
}
