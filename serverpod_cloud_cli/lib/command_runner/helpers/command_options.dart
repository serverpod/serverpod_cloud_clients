import 'dart:io';

import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/util/output/output_format.dart';
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
  const ProjectIdOption({bool asFirstArg = false, bool excludeSettings = false})
    : this._(
        asFirstArg: asFirstArg,
        excludeSettings: excludeSettings,
        mandatory: true,
        helpText:
            '${asFirstArg ? _helpTextFirstArg : _helpText}'
            '\nCan be omitted for existing projects that are linked'
            ' (see the "project link" command)'
            '${excludeSettings ? '.' : ' or if a global project context is set'
                      ' (see the "context set" command).'}',
      );

  /// If [asFirstArg] is true, the project ID can be also passed as the first positional argument.
  /// If [excludeSettings] is true, the user's context setting will not affect this value.
  const ProjectIdOption._({
    bool asFirstArg = false,
    bool excludeSettings = false,
    super.mandatory,
    super.helpText,
    super.group,
  }) : super(
         argName: _projectIdArgName,
         argAbbrev: _projectIdArgAbbrev,
         argPos: asFirstArg ? 0 : null,
         envName: 'SERVERPOD_CLOUD_PROJECT_ID',
         configKeys: excludeSettings
             ? const ['$scloudConfigDomainPrefix:/project/projectId']
             : const [
                 '$scloudConfigDomainPrefix:/project/projectId',
                 '$settingsConfigDomainPrefix:/project_context',
               ],
       );

  /// Used for commands that require explicit command line argument for the
  /// project ID, i.e. not from env variable or config files.
  /// (And if asFirstArg is true, also as the first positional argument.)
  const ProjectIdOption.argsOnly({bool asFirstArg = false})
    : super(
        argName: _projectIdArgName,
        argAbbrev: _projectIdArgAbbrev,
        argPos: asFirstArg ? 0 : null,
        mandatory: true,
        helpText: asFirstArg ? _helpTextFirstArg : _helpText,
      );

  /// Used for commands that interactively ask for the project ID if not already
  /// specified.
  ///
  /// If [asFirstArg] is true, the project ID can be also passed as the first positional argument.
  /// If [excludeSettings] is true, the user's context setting will not affect this value.
  const ProjectIdOption.nonMandatory({
    bool asFirstArg = false,
    bool excludeSettings = false,
    OptionGroup? group,
  }) : this._(
         asFirstArg: asFirstArg,
         excludeSettings: excludeSettings,
         mandatory: false,
         helpText: asFirstArg ? _helpTextFirstArg : _helpText,
         group: group,
       );
}

class FormatOption extends EnumOption<OutputFormat> {
  const FormatOption()
    : super(
        argName: 'format',
        envName: 'SERVERPOD_CLOUD_FORMAT',
        enumParser: const EnumParser(OutputFormat.values),
        defaultsTo: OutputFormat.text,
        helpText: 'Selects the command output format.',
      );
}

class NameOption extends StringOption {
  const NameOption({required String super.helpText, required int super.argPos})
    : super(argName: 'name', mandatory: true);
}

/// Mandatory, mutually exclusive [OptionGroup] for [ValueOption] and
/// [ValueFileOption].
const valueOptionGroup = MutuallyExclusive(
  'Value',
  mode: MutuallyExclusiveMode.mandatory,
);

/// Command-line value given directly as a positional or named argument.
///
/// Belongs to [valueOptionGroup] together with [ValueFileOption]: exactly one
/// of them must be provided.
class ValueOption extends StringOption {
  const ValueOption({required String super.helpText, required int super.argPos})
    : super(argName: 'value', group: valueOptionGroup);
}

/// Command-line value read from a file.
///
/// Belongs to [valueOptionGroup] together with [ValueOption]: exactly one of
/// them must be provided.
class ValueFileOption extends FileOption {
  const ValueFileOption({required String super.helpText})
    : super(
        argName: 'from-file',
        group: valueOptionGroup,
        mode: PathExistMode.mustExist,
      );
}

/// Resolution of the mutually exclusive [ValueOption] and [ValueFileOption]
/// pair to the single value they denote.
extension ValueOptionResolution on Configuration {
  /// The value of the [value] option if it is set, otherwise the full contents
  /// of the file given by the [valueFile] option, decoded as UTF-8.
  ///
  /// [value] and [valueFile] are expected to belong to [valueOptionGroup], as
  /// [ValueOption] and [ValueFileOption] do: configuration resolution then
  /// fails with a [UsageException] if neither or both of them are set, before
  /// `runWithConfig` is reached.
  ///
  /// Throws a [StateError] if neither option is set, which therefore signals a
  /// programming error rather than bad user input.
  String valueOrFileContent({
    required OptionDefinition<String> value,
    required OptionDefinition<File> valueFile,
  }) {
    final providedValue = optionalValue(value);
    if (providedValue != null) {
      return providedValue;
    }

    final providedFile = optionalValue(valueFile);
    if (providedFile != null) {
      return providedFile.readAsStringSync();
    }

    throw StateError('Expected one of the value options to be set.');
  }
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

class DartSdkVersionOption extends StringOption {
  const DartSdkVersionOption()
    : super(
        argName: 'dart-version',
        helpText:
            'Overrides the Dart SDK version to use for building the project.',
        envName: 'SERVERPOD_CLOUD_DEPLOY_DART_VERSION',
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
  DateTime parse(String value) {
    final result = _parseDateTimeOrDuration(value);
    if (result == null) {
      throw FormatException(
        'Invalid value: expected ISO date string (e.g., "2024-01-15T10:30:00Z") '
        'or duration string (e.g., "5m", "3h", "1d"). Value was: "$value"',
      );
    }
    return result;
  }

  DateTime? _parseDateTimeOrDuration(String value) {
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

  Duration? _tryParseDuration(String value) {
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
