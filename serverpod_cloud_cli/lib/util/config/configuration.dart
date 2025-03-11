import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';

/// Common interface to enable same treatment for [ConfigOption] and option enums.
abstract class OptionDefinition {
  ConfigOption get option;
}

/// Defines a configuration option that can be set from configuration sources -
/// through command line arguments and / or environment variables.
///
/// Named command line arguments take precedence over positional arguments.
/// Command line arguments take precedence over environment variables.
///
/// If multiple positional arguments are defined, follow these restrictions to prevent ambiguity:
///  - all but the last one must be mandatory
///  - all but the last one must have no non-argument configuration sources
///
/// If an argument is defined as both named and positional, and the named argument is provided,
/// the positional index is still consumed so that subsequent positional arguments
/// still get the correct value.
/// Note that this means that an option can't be provided both named and positional at the same time.
///
/// If [mandatory] is true, the option must be provided in the configuration sources,
/// i.e. be explicitly set.
/// This cannot be used together with [defaultsTo] or [fromDefault].
///
/// If no value is provided from the configuration sources, the [fromDefault] callback is used
/// if available, otherwise the [defaultsTo] value is used.
/// [fromDefault] must return the same value if called multiple times.
class ConfigOption<T extends OptionDefinition> implements OptionDefinition {
  final String? argName;
  final String? argAbbrev;
  final int? argPos;
  final String? envName;
  final String? configKey;
  final String? Function(Configuration<T> cfg)? fromCustom;
  final String Function()? fromDefault;
  final String? defaultsTo;

  final String? helpText;
  final String? valueHelp;
  final bool mandatory;
  final bool hide;
  final bool isFlag;
  final bool negatable;

  const ConfigOption({
    this.argName,
    this.argAbbrev,
    this.argPos,
    this.envName,
    this.configKey,
    this.fromCustom,
    this.fromDefault,
    this.defaultsTo,
    this.helpText,
    this.valueHelp,
    this.mandatory = false,
    this.hide = false,
    this.isFlag = false,
    this.negatable = true,
  });

  String? defaultValue() {
    final df = fromDefault;
    return (df != null ? df() : defaultsTo);
  }

  /// Adds this configuration option to the provided argument parser.
  void _addToArgParser(final ArgParser argParser) {
    final argName = this.argName;
    if (argName == null) {
      throw StateError("Can't add option without arg name to arg parser.");
    }
    if (isFlag) {
      argParser.addFlag(
        argName,
        abbr: argAbbrev,
        help: helpText,
        defaultsTo:
            bool.tryParse(defaultValue() ?? 'false', caseSensitive: false),
        negatable: negatable,
        hide: hide,
      );
      return;
    } else {
      argParser.addOption(
        argName,
        abbr: argAbbrev,
        help: helpText,
        valueHelp: valueHelp,
        defaultsTo: defaultValue(),
        mandatory: mandatory,
        hide: hide,
      );
    }
  }

  void _validate() {
    if (argName == null && argAbbrev != null) {
      throw InvalidOptionConfigurationError(this,
          "An argument option can't have an abbreviation but not a full name");
    }

    if (argPos != null && isFlag) {
      throw InvalidOptionConfigurationError(
          this, "Positional options can't be flags");
    }

    if ((fromDefault != null || defaultsTo != null) && mandatory) {
      throw InvalidOptionConfigurationError(
          this, "Mandatory options can't have default values");
    }
  }

  /// Returns self.
  @override
  ConfigOption get option => this;

  @override
  String toString() => argName ?? envName ?? '<unnamed option>';

  String qualifiedString() {
    if (argName != null) {
      return isFlag ? 'flag `$argName`' : 'option `$argName`';
    }
    if (envName != null) {
      return 'environment variable `$envName`';
    }
    if (argPos != null) {
      return 'positional argument $argPos';
    }
    if (configKey != null) {
      return 'configuration key `$configKey`';
    }
    return _unnamedOptionString;
  }

  static const _unnamedOptionString = '<unnamed option>';
}

/// Extension to add a [qualifiedString] shorthand method to [OptionDefinition].
/// Since enum classes that implement [OptionDefinition] don't inherit
/// its method implementations, this extension provides this method
/// implementation instead.
extension QualifiedString on OptionDefinition {
  String qualifiedString() {
    final str = option.qualifiedString();
    if (str == ConfigOption._unnamedOptionString && this is Enum) {
      return (this as Enum).name;
    }
    return str;
  }
}

/// Validates and prepares a set of options for the provided argument parser.
void prepareOptionsForParsing(
  final Iterable<OptionDefinition> options,
  final ArgParser argParser,
) {
  final argNameOpts = <String, OptionDefinition>{};
  final argPosOpts = <int, OptionDefinition>{};
  final envNameOpts = <String, OptionDefinition>{};
  for (final opt in options) {
    opt.option._validate();
    final argName = opt.option.argName;
    if (argName != null) {
      if (argNameOpts.containsKey(opt.option.argName)) {
        throw InvalidOptionConfigurationError(
            opt, 'Duplicate argument name: ${opt.option.argName} for $opt');
      }
      argNameOpts[argName] = opt;
    }
    final argPos = opt.option.argPos;
    if (argPos != null) {
      if (argPosOpts.containsKey(opt.option.argPos)) {
        throw InvalidOptionConfigurationError(
            opt, 'Duplicate argument position: ${opt.option.argPos} for $opt');
      }
      argPosOpts[argPos] = opt;
    }
    final envName = opt.option.envName;
    if (envName != null) {
      if (envNameOpts.containsKey(opt.option.envName)) {
        throw InvalidOptionConfigurationError(opt,
            'Duplicate environment variable name: ${opt.option.envName} for $opt');
      }
      envNameOpts[envName] = opt;
    }
  }

  if (argPosOpts.isNotEmpty) {
    final orderedPosOpts = argPosOpts.values.sorted(
        (final a, final b) => a.option.argPos!.compareTo(b.option.argPos!));
    if (orderedPosOpts.first.option.argPos != 0) {
      throw InvalidOptionConfigurationError(
        orderedPosOpts.first,
        'First positional argument must have index 0.',
      );
    }
    if (orderedPosOpts.last.option.argPos != orderedPosOpts.length - 1) {
      throw InvalidOptionConfigurationError(
        orderedPosOpts.last,
        'The positional arguments must have consecutive indices without gaps.',
      );
    }
  }

  for (final opt in argNameOpts.values) {
    opt.option._addToArgParser(argParser);
  }
}

extension PrepareOptions on Iterable<OptionDefinition> {
  /// Validates and prepares these options for the provided argument parser.
  void prepareForParsing(final ArgParser argParser) =>
      prepareOptionsForParsing(this, argParser);
}

/// Resolves configuration values dynamically
/// and possibly from multiple sources.
abstract interface class ConfigurationBroker<T extends OptionDefinition> {
  /// Returns the value for the given key, or `null` if the key is not found
  /// or has no value.
  ///
  /// Resolution may depend on the value of other options, accessed via [cfg].
  String? valueOrNull(final String key, final Configuration<T> cfg);
}

/// A configuration object that holds resolved values for a set of configuration options.
class Configuration<T extends OptionDefinition> {
  final List<T> _options;
  final Map<T, String?> _config;
  final List<String> _errors;

  /// Instantiates a configuration with option values resolved from the provided context.
  Configuration.fromEnvAndArgs({
    required final Iterable<T> options,
    final ArgResults? args,
    final Map<String, String>? env,
    final ConfigurationBroker? configBroker,
  })  : _options = List<T>.from(options),
        _config = <T, String?>{},
        _errors = <String>[] {
    _resolveFromEnvAndArgs(
      args: args,
      env: env,
      configBroker: configBroker,
    );
  }

  /// Gets the option definitions for this configuration.
  Iterable<T> get options => _config.keys;

  /// Returns the errors that occurred during configuration resolution.
  Iterable<String> get errors => _errors;

  /// Returns the option definition for the given enum name,
  /// or any provided argument name, position,
  /// environment variable name, or configuration key.
  /// The first one that matches is returned, or null if none match.
  ///
  /// The recommended practice is to define options as enums and identify them by the enum name.
  T? findOption({
    final String? enumName,
    final String? argName,
    final int? argPos,
    final String? envName,
    final String? configKey,
  }) {
    return _options.firstWhereOrNull((final o) {
      return (enumName != null && o is Enum && (o as Enum).name == enumName) ||
          (argName != null && o.option.argName == argName) ||
          (argPos != null && o.option.argPos == argPos) ||
          (envName != null && o.option.envName == envName) ||
          (configKey != null && o.option.configKey == configKey);
    });
  }

  /// Returns the value of the given configuration option.
  /// Throws [UsageException] if the option is mandatory and no value is provided.
  /// This method should only be called for options that are guaranteed to have a value,
  /// i.e. are mandatory or have defaults. For other options it throws [StateError].
  /// See also [valueOrNull].
  String value(final T option) {
    if (!(option.option.mandatory ||
        option.option.fromDefault != null ||
        option.option.defaultsTo != null)) {
      throw StateError(
          "Can't invoke non-nullable value() for ${option.qualifiedString()} "
          "which is neither mandatory nor has a default value.");
    }
    final val = valueOrNull(option);
    if (val != null) return val;
    throw UsageException('${option.qualifiedString()} is mandatory', '');
  }

  /// Returns the value of the given configuration flag.
  /// Throws [UsageException] if the option is mandatory and no value is provided.
  /// This method should only be called for flags that are guaranteed to have a value,
  /// i.e. are mandatory or have defaults. For other flags it throws [StateError].
  /// See also [flagOrNull].
  bool flag(final T option) {
    if (!(option.option.mandatory ||
        option.option.fromDefault != null ||
        option.option.defaultsTo != null)) {
      throw StateError(
          "Can't invoke non-nullable flag() for ${option.qualifiedString()} "
          "which is neither mandatory nor has a default value.");
    }
    final val = flagOrNull(option);
    if (val != null) return val;
    throw UsageException('${option.qualifiedString()} is mandatory', '');
  }

  /// Returns the value of the given configuration option.
  String? valueOrNull(final T option) {
    if (!_config.containsKey(option) && _options.contains(option)) {
      if (errors.isNotEmpty) {
        throw StateError(
            'No value available for ${option.qualifiedString()} due to previous errors');
      }
      throw InvalidOptionConfigurationError(option,
          "Out-of-order dependency on not-yet-resolved ${option.qualifiedString()}");
    }
    return _config[option];
  }

  /// Returns the value of the given configuration flag.
  bool? flagOrNull(final T option) {
    if (!option.option.isFlag) {
      throw UnsupportedError('${option.qualifiedString()} is not a flag.');
    }
    final String? value = valueOrNull(option);
    return value != null
        ? bool.tryParse(value, caseSensitive: false) ?? false
        : null;
  }

  void _resolveFromEnvAndArgs({
    final ArgResults? args,
    final Map<String, String>? env,
    final ConfigurationBroker? configBroker,
  }) {
    Iterable<String> remainingPosArgs = List<String>.from(args?.rest ?? []);
    final orderedOpts = _options.sorted((final a, final b) =>
        (a.option.argPos ?? -1).compareTo(b.option.argPos ?? -1));

    for (final opt in orderedOpts) {
      String? error;
      try {
        final result = _resolveValue(
          opt,
          args: args,
          remainingPosArgs: remainingPosArgs,
          env: env ?? {},
          configBroker: configBroker,
        );

        _config[opt] = result.value;
        remainingPosArgs = result.remainingPosArgs;
        error = result.error;
      } catch (e) {
        error = 'Failed to resolve ${opt.qualifiedString()}: $e';
      }
      if (error != null) {
        _errors.add(error);
      }
    }

    if (remainingPosArgs.isNotEmpty) {
      _errors.add(
          "Unexpected positional argument(s): '${remainingPosArgs.join("', '")}'");
    }
  }

  /// Returns the resolved value of a configuration option from the provided context.
  /// For options with positional arguments this must be invoked in ascending position order.
  /// Returns a tuple with the resolved value or error, and the remaining positional arguments.
  _OptResolution _resolveValue(
    final T option, {
    final ArgResults? args,
    final Iterable<String> remainingPosArgs = const [],
    final Map<String, String> env = const {},
    final ConfigurationBroker? configBroker,
  }) {
    final argOptName = option.option.argName;
    final argOptPos = option.option.argPos;
    final envVarName = option.option.envName;
    final configKey = option.option.configKey;

    String? value;
    String? error;
    Iterable<String> nextRemainingPosArgs = remainingPosArgs;

    if (argOptName != null && args != null && args.wasParsed(argOptName)) {
      // Named arguments takes precedence over other config sources.
      value = option.option.isFlag
          ? args.flag(argOptName).toString()
          : args.option(argOptName);
    } else if (argOptPos != null && remainingPosArgs.isNotEmpty) {
      // Positional arguments have second highest precedence.
      value = remainingPosArgs.first;
      nextRemainingPosArgs = remainingPosArgs.skip(1);
    } else if (envVarName != null && env.containsKey(envVarName)) {
      // Environment variables have third highest precedence.
      value = env[envVarName];
    } else if (_configValue(configBroker, configKey) case final String val) {
      // Value from configuration callback has fourth highest precedence.
      // (The case pattern matches if the value is of type String i.e. non-null.)
      value = val;
    } else if (option.option.fromCustom?.call(this) case final String val) {
      // Default value from callback has second lowest precedence.
      value = val;
    } else if (option.option.fromDefault?.call() case final String val) {
      // Default value from callback has second lowest precedence.
      value = val;
    } else {
      // Default value has lowest precedence.
      value = option.option.defaultsTo;
    }

    if (value == null && option.option.mandatory) {
      error = '${option.qualifiedString()} is mandatory';
    }

    return (value: value, error: error, remainingPosArgs: nextRemainingPosArgs);
  }

  String? _configValue(
    final ConfigurationBroker? configBroker,
    final String? key,
  ) {
    if (configBroker == null || key == null) return null;
    return configBroker.valueOrNull(key, this);
  }
}

typedef _OptResolution = ({
  String? value,
  String? error,
  Iterable<String> remainingPosArgs,
});

/// Indicates that the option definition is invalid.
class InvalidOptionConfigurationError extends Error {
  final OptionDefinition option;
  final String? message;

  InvalidOptionConfigurationError(this.option, [this.message]);

  @override
  String toString() {
    return message != null
        ? 'Invalid configuration for ${option.qualifiedString()}: $message'
        : 'Invalid configuration for ${option.qualifiedString()}';
  }
}
