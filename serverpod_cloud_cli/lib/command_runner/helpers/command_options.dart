import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config.dart';

import 'email_validator.dart';

abstract final class CommandConfigConstants {
  static const listOptionAbbrev = 'l';
}

class ProjectIdOption extends StringOption {
  static const _projectIdArgName = 'project';
  static const _projectIdArgAbbrev = 'p';

  static const _helpText = 'The ID of the project.';
  static const _helpTextFirstArg =
      'The ID of the project. '
      'Can be passed as the first argument.';

  /// Project ID option that can be passed as command line argument
  /// (and if asFirstArg is true, also as the first positional argument),
  /// env variable, and scloud config file.
  const ProjectIdOption({final bool asFirstArg = false})
    : super(
        argName: _projectIdArgName,
        argAbbrev: _projectIdArgAbbrev,
        argPos: asFirstArg ? 0 : null,
        envName: 'SERVERPOD_CLOUD_PROJECT_ID',
        configKey: '$scloudConfigDomainPrefix:/project/projectId',
        mandatory: true,
        helpText:
            '${asFirstArg ? _helpTextFirstArg : _helpText}'
            '\nCan be omitted for existing projects that are linked. '
            'See `scloud project link --help`.',
      );

  /// Used for commands that require explicit command line argument for the
  /// project ID, i.e. not from env variable or scloud config file.
  /// (And if asFirstArg is true, also as the first positional argument.)
  const ProjectIdOption.argsOnly({final bool asFirstArg = false})
    : super(
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
  const ProjectIdOption.nonMandatory({final bool asFirstArg = false})
    : super(
        argName: _projectIdArgName,
        argAbbrev: _projectIdArgAbbrev,
        argPos: asFirstArg ? 0 : null,
        helpText: asFirstArg ? _helpTextFirstArg : _helpText,
      );
}

class NameOption extends StringOption {
  const NameOption({required String super.helpText, required int super.argPos})
    : super(argName: 'name', mandatory: true);
}

const _valueGroup = MutuallyExclusive(
  'Value',
  mode: MutuallyExclusiveMode.mandatory,
);

class ValueOption extends StringOption {
  const ValueOption({required String super.helpText, required int super.argPos})
    : super(argName: 'value', group: _valueGroup);
}

class ValueFileOption extends FileOption {
  const ValueFileOption({required String super.helpText})
    : super(
        argName: 'from-file',
        group: _valueGroup,
        mode: PathExistMode.mustExist,
      );
}

class UtcOption extends FlagOption {
  const UtcOption()
    : super(
        argName: 'utc',
        argAbbrev: 'u',
        helpText: 'Display timestamps in UTC timezone instead of local.',
        negatable: true,
        defaultsTo: false,
        envName: 'SERVERPOD_CLOUD_DISPLAY_UTC',
      );
}

class UserEmailOption extends StringOption {
  const UserEmailOption({super.argPos, super.mandatory})
    : super(
        argName: 'user',
        argAbbrev: 'u',
        customValidator: emailValidator,
        // a bit convoluted due to Dart's const requirements:
        helpText:
            'The user email address.'
            '${argPos == 0
                ? ' Can be passed as the first argument.'
                : argPos == 1
                ? ' Can be passed as the second argument.'
                : ''}',
      );
}

class DateTimeOrDurationParser extends ValueParser<DateTime> {
  const DateTimeOrDurationParser();

  @override
  DateTime parse(final String value) {
    final result = _parseDateTimeOrDuration(value);
    if (result == null) {
      throw FormatException(
        'Invalid value: expected ISO date string (e.g., "2024-01-15T10:30:00Z") '
        'or duration string (e.g., "5m", "3h", "1d"). Value was: "$value"',
      );
    }
    return result;
  }

  DateTime? _parseDateTimeOrDuration(final String value) {
    try {
      return const DateTimeParser().parse(value);
    } on FormatException {
      final duration = _tryParseDuration(value);
      if (duration != null) {
        return DateTime.now().subtract(duration);
      }
      return null;
    }
  }

  Duration? _tryParseDuration(final String value) {
    try {
      return const DurationParser().parse(value);
    } on FormatException {
      return null;
    }
  }
}

class DateTimeOrDurationOption extends ComparableValueOption<DateTime> {
  const DateTimeOrDurationOption({
    super.argName,
    super.argAliases,
    super.argAbbrev,
    super.argPos,
    super.envName,
    super.configKey,
    super.fromCustom,
    super.fromDefault,
    super.defaultsTo,
    super.helpText,
    super.valueHelp = 'YYYY-MM-DDtHH:MM:SSz or duration[us|ms|s|m|h|d]',
    super.allowedHelp,
    super.group,
    super.allowedValues,
    super.customValidator,
    super.mandatory,
    super.hide,
    super.min,
    super.max,
  }) : super(valueParser: const DateTimeOrDurationParser());
}
