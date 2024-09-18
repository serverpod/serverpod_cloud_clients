import 'package:args/args.dart';

/// Common interface to enable same treatment for [ConfigOption] and option enums.
abstract class OptionDefinition {
  ConfigOption get option;
}

/// Defines a configuration option that can be set from configuration sources -
/// through command line arguments and / or environment variables.
/// Explicit command line arguments take precedence over environment variables.
/// If [mandatory] is true, the option must be provided in the configuration sources.
/// If no value is provided from the configuration sources, the [defaultFrom] callback is used
/// if available, otherwise the [defaultsTo] value is used.
/// [defaultFrom] must return the same value if called multiple times.
class ConfigOption implements OptionDefinition {
  final String? argName;
  final String? argAbbrev;
  final String? envName;
  final String? helpText;
  final String? valueHelp;
  final String? defaultsTo;
  final String? Function()? defaultFrom;
  final bool mandatory;
  final bool hide;
  final bool isFlag;
  final bool negatable;

  const ConfigOption({
    this.argName,
    this.argAbbrev,
    this.envName,
    this.helpText,
    this.valueHelp,
    this.defaultsTo,
    this.defaultFrom,
    this.mandatory = false,
    this.hide = false,
    this.isFlag = false,
    this.negatable = true,
  });

  String? defaultValue() {
    final df = defaultFrom;
    return (df != null ? df() : defaultsTo);
  }

  /// Adds this configuration option to the provided argument parser.
  void addToArgParser(final ArgParser argParser) {
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

  /// Returns self.
  @override
  ConfigOption get option => this;

  @override
  String toString() => argName ?? envName ?? argAbbrev ?? '<unnamed option>';
}

extension AddToArgParser on Iterable<OptionDefinition> {
  /// Adds all options in the list to the provided argument parser.
  void addToArgParser(final ArgParser argParser) {
    for (final opt in this) {
      opt.option.addToArgParser(argParser);
    }
  }
}

/// A configuration object that holds resolved values for a set of configuration options.
class Configuration<T extends OptionDefinition> {
  final Map<T, String?> _config;

  const Configuration._(final Map<T, String?> config) : _config = config;

  /// Instantiates a configuration with option values resolved from the provided context.
  Configuration.fromEnvAndArgs({
    required final Iterable<T> options,
    final ArgResults? args,
    final Map<String, String>? env,
  }) : this._({
          for (final opt in options)
            opt: resolveValue(opt.option, args: args, env: env),
        });

  /// Gets the option definitions for this configuration.
  Iterable<T> get options => _config.keys;

  /// Returns the value of the given configuration option.
  /// Throws [ArgumentError] if the option is mandatory and no value is provided.
  /// This method should only be called for options that are guaranteed to have a value,
  /// i.e. are mandatory or have defaults. For other options it throws [StateError].
  /// See also [valueOrNull].
  String value(final T option) {
    if (!(option.option.mandatory ||
        option.option.defaultFrom != null ||
        option.option.defaultsTo != null)) {
      throw StateError(
          "Can't invoke non-nullable value() for $option which is neither mandatory or has a default value.");
    }
    final val = valueOrNull(option);
    if (val != null) return val;
    throw ArgumentError('Option is mandatory.', option.toString());
  }

  /// Returns the value of the given configuration flag.
  /// Throws [ArgumentError] if the option is mandatory and no value is provided.
  /// This method should only be called for flags that are guaranteed to have a value,
  /// i.e. are mandatory or have defaults. For other flags it throws [StateError].
  /// See also [flagOrNull].
  bool flag(final T option) {
    if (!(option.option.mandatory ||
        option.option.defaultFrom != null ||
        option.option.defaultsTo != null)) {
      throw StateError(
          "Can't invoke non-nullable flag() for $option which is neither mandatory or has a default value.");
    }
    final val = flagOrNull(option);
    if (val != null) return val;
    throw ArgumentError('Flag is mandatory.', option.toString());
  }

  /// Returns the value of the given configuration option.
  String? valueOrNull(final T option) => _config[option];

  /// Returns the value of the given configuration flag.
  bool? flagOrNull(final T option) => getFlag(option);

  /// Returns the value of the given configuration flag.
  bool? getFlag(final T option) {
    if (!option.option.isFlag) {
      throw ArgumentError('Option is not a flag.', option.toString());
    }
    final String? value = valueOrNull(option);
    return value != null
        ? bool.tryParse(value, caseSensitive: false) ?? false
        : null;
  }

  /// Returns the resolved value of a configuration option from the provided context.
  static String? resolveValue<T extends OptionDefinition>(
    final T option, {
    final ArgResults? args,
    Map<String, String>? env,
  }) {
    env ??= {};
    final argOptName = option.option.argName;
    final envVarName = option.option.envName;

    String? value;
    if (argOptName != null && args != null && args.wasParsed(argOptName)) {
      // Explicit arguments takes precedence over other config sources.
      value = option.option.isFlag
          ? args.flag(argOptName).toString()
          : args.option(argOptName);
    } else if (envVarName != null && env.containsKey(envVarName)) {
      // Environment variables have second highest precedence.
      value = env[envVarName];
    } else if (option.option.defaultFrom != null) {
      // Default value from callback has second lowest precedence.
      value = option.option.defaultFrom?.call();
    } else {
      // Default value has lowest precedence.
      value = option.option.defaultsTo;
    }

    if (value == null && option.option.mandatory) {
      throw ArgumentError('Option/flag is mandatory.', option.toString());
    }
    return value;
  }
}
