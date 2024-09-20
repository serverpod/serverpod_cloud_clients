import 'package:args/args.dart';
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
/// If [mandatory] is true, the option must be provided in the configuration sources.
/// If no value is provided from the configuration sources, the [defaultFrom] callback is used
/// if available, otherwise the [defaultsTo] value is used.
/// [defaultFrom] must return the same value if called multiple times.
class ConfigOption implements OptionDefinition {
  final String? argName;
  final String? argAbbrev;
  final int? argPos;
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
    this.argPos,
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
      throw ArgumentError(
          "An argument option can't have an abbreviation but not a full name: $this");
    }
    if (argPos != null && isFlag) {
      throw ArgumentError("Positional options can't be flags: $this");
    }
    if ((defaultFrom != null || defaultsTo != null) && mandatory) {
      throw ArgumentError("Mandatory options can't have default value: $this");
    }
  }

  /// Returns self.
  @override
  ConfigOption get option => this;

  @override
  String toString() => argName ?? envName ?? '<unnamed option>';
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
        throw ArgumentError(
            'Duplicate argument name: ${opt.option.argName} for $opt');
      }
      argNameOpts[argName] = opt;
    }
    final argPos = opt.option.argPos;
    if (argPos != null) {
      if (argPosOpts.containsKey(opt.option.argPos)) {
        throw ArgumentError(
            'Duplicate argument position: ${opt.option.argPos} for $opt');
      }
      argPosOpts[argPos] = opt;
    }
    final envName = opt.option.envName;
    if (envName != null) {
      if (envNameOpts.containsKey(opt.option.envName)) {
        throw ArgumentError(
            'Duplicate environment variable name: ${opt.option.envName} for $opt');
      }
      envNameOpts[envName] = opt;
    }
  }

  if (argPosOpts.isNotEmpty) {
    final orderedPosOpts = argPosOpts.values.sorted(
        (final a, final b) => a.option.argPos!.compareTo(b.option.argPos!));
    if (orderedPosOpts.first.option.argPos != 0) {
      throw ArgumentError('First positional argument must have index 0.');
    }
    if (orderedPosOpts.last.option.argPos != orderedPosOpts.length - 1) {
      throw ArgumentError(
          'The positional arguments must have consecutive indices without gaps.');
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

/// A configuration object that holds resolved values for a set of configuration options.
class Configuration<T extends OptionDefinition> {
  final Map<T, String?> _config;

  const Configuration._(final Map<T, String?> config) : _config = config;

  /// Instantiates a configuration with option values resolved from the provided context.
  Configuration.fromEnvAndArgs({
    required final Iterable<T> options,
    final ArgResults? args,
    final Map<String, String>? env,
  }) : this._(_resolveFromEnvAndArgs(options, args: args, env: env));

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

  static Map<T, String?> _resolveFromEnvAndArgs<T extends OptionDefinition>(
    final Iterable<T> options, {
    final ArgResults? args,
    final Map<String, String>? env,
  }) {
    final config = <T, String?>{};
    Iterable<String> remainingPosArgs = List<String>.from(args?.rest ?? []);
    final orderedOpts = options.sorted((final a, final b) =>
        (a.option.argPos ?? -1).compareTo(b.option.argPos ?? -1));
    for (final opt in orderedOpts) {
      final result = _resolveValue(
        opt.option,
        args: args,
        remainingPosArgs: remainingPosArgs,
        env: env ?? {},
      );
      config[opt] = result.$1;
      remainingPosArgs = result.$2;
    }
    if (remainingPosArgs.isNotEmpty) {
      throw ArgumentError(
          "Unexpected positional argument(s): '${remainingPosArgs.join("', '")}'");
    }
    return config;
  }

  /// Returns the resolved value of a configuration option from the provided context.
  /// For options with positional arguments this must be invoked in ascending position order.
  /// Returns a tuple with the resolved value and the remaining positional arguments.
  static (String?, Iterable<String>) _resolveValue<T extends OptionDefinition>(
    final T option, {
    final ArgResults? args,
    final Iterable<String> remainingPosArgs = const [],
    final Map<String, String> env = const {},
  }) {
    final argOptName = option.option.argName;
    final argOptPos = option.option.argPos;
    final envVarName = option.option.envName;

    String? value;
    Iterable<String> nextRemPosArgs = remainingPosArgs;
    if (argOptName != null && args != null && args.wasParsed(argOptName)) {
      // Named arguments takes precedence over other config sources.
      value = option.option.isFlag
          ? args.flag(argOptName).toString()
          : args.option(argOptName);
    } else if (argOptPos != null && remainingPosArgs.isNotEmpty) {
      // Positional arguments have second highest precedence.
      value = remainingPosArgs.first;
      nextRemPosArgs = remainingPosArgs.skip(1);
    } else if (envVarName != null && env.containsKey(envVarName)) {
      // Environment variables have third highest precedence.
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
    return (value, nextRemPosArgs);
  }
}
