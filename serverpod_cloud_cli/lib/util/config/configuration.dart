import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Common interface to enable same treatment for [ConfigOptionBase] and option enums.
abstract class OptionDefinition<V> {
  ConfigOptionBase<V> get option;
}

/// A [ValueParser] converts a source string value to the specific option value type.
///
/// Must throw a [FormatException] with an appropriate message
/// if the value cannot be parsed.
abstract class ValueParser<V> {
  const ValueParser();

  V parse(final String value);

  /// Returns a usage documentation friendly string representation of the value.
  /// The default implementation simply invokes [toString].
  String format(final V value) {
    return value.toString();
  }
}

/// Defines a configuration option that can be set from configuration sources.
///
/// When an option can be set in multiple ways, the precedence is as follows:
///
/// 1. Named command line argument
/// 2. Positional command line argument
/// 3. Environment variable
/// 4. By lookup key in configuration sources (such as files)
/// 5. A custom callback function
/// 6. Default value
///
/// ### Typed values, parsing, and validation
///
/// Option values are typed, and parsed using the [ValueParser].
/// Subclasses of [ConfigOptionBase] may also override [validateValue]
/// to perform additional validation such as range checking.
///
/// The subclasses implement specific option value types,
/// e.g. [StringOption], [FlagOption] (boolean), [IntOption], etc.
///
/// ### Positional arguments
///
/// If multiple positional arguments are defined,
/// follow these restrictions to prevent ambiguity:
///  - all but the last one must be mandatory
///  - all but the last one must have no non-argument configuration sources
///
/// If an argument is defined as both named and positional,
/// and the named argument is provided, the positional index
/// is still consumed so that subsequent positional arguments
/// will get the correct value.
///
/// Note that this prevents an option from being provided both
/// named and positional on the same command line.
///
/// ### Mandatory and Default
///
/// If [mandatory] is true, the option must be provided in the
/// configuration sources, i.e. be explicitly set.
/// This cannot be used together with [defaultsTo] or [fromDefault].
///
/// If no value is provided from the configuration sources,
/// the [fromDefault] callback is used if available,
/// otherwise the [defaultsTo] value is used.
/// [fromDefault] must return the same value if called multiple times.
///
/// If an option is either mandatory or has a default value,
/// it is guaranteed to have a value and can be retrieved using
/// the non-nullable [value] method.
/// Otherwise it may be retrieved using the nullable [valueOrNull] method.
class ConfigOptionBase<V> implements OptionDefinition<V> {
  final ValueParser<V> valueParser;

  final String? argName;
  final String? argAbbrev;
  final int? argPos;
  final String? envName;
  final String? configKey;
  final V? Function(Configuration cfg)? fromCustom;
  final V Function()? fromDefault;
  final V? defaultsTo;

  final String? helpText;
  final String? valueHelp;

  final void Function(V value)? customValidator;
  final bool mandatory;
  final bool hide;
  final bool isFlag;
  final bool negatable;

  const ConfigOptionBase({
    required this.valueParser,
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
    this.customValidator,
    this.mandatory = false,
    this.hide = false,
    this.isFlag = false,
    this.negatable = true,
  });

  V? defaultValue() {
    final df = fromDefault;
    return (df != null ? df() : defaultsTo);
  }

  String? defaultValueString() {
    return defaultValue()?.toString();
  }

  String? valueHelpString() {
    return valueHelp;
  }

  /// Adds this configuration option to the provided argument parser.
  void _addToArgParser(final ArgParser argParser) {
    final argName = this.argName;
    if (argName == null) {
      throw StateError("Can't add option without arg name to arg parser.");
    }
    argParser.addOption(
      argName,
      abbr: argAbbrev,
      help: helpText,
      valueHelp: valueHelpString(),
      defaultsTo: defaultValueString(),
      mandatory: mandatory,
      hide: hide,
    );
  }

  void _validateDefinition() {
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

  /// Validates the parsed value,
  /// throwing a [FormatException] if the value is invalid,
  /// or a [UsageException] if the value is invalid for other reasons.
  ///
  /// Subclasses may override this method to perform specific validations.
  /// If they do, they must also call the super implementation.
  @mustCallSuper
  void validateValue(final V value) {
    customValidator?.call(value);
  }

  /// Returns self.
  @override
  ConfigOptionBase<V> get option => this;

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

/// Parses a boolean value from a string.
class BoolParser extends ValueParser<bool> {
  const BoolParser();

  @override
  bool parse(final String value) {
    return bool.tryParse(value, caseSensitive: false) ?? false;
  }
}

/// Boolean value configuration option.
class FlagOption extends ConfigOptionBase<bool> {
  const FlagOption({
    super.argName,
    super.argAbbrev,
    super.envName,
    super.configKey,
    super.fromCustom,
    super.fromDefault,
    super.defaultsTo,
    super.helpText,
    super.valueHelp,
    super.mandatory,
    super.hide,
    super.negatable,
  }) : super(
          valueParser: const BoolParser(),
          isFlag: true,
        );

  @override
  void _addToArgParser(final ArgParser argParser) {
    final argName = this.argName;
    if (argName == null) {
      throw StateError("Can't add flag without arg name to arg parser.");
    }
    argParser.addFlag(
      argName,
      abbr: argAbbrev,
      help: helpText,
      defaultsTo: defaultValue(),
      negatable: negatable,
      hide: hide,
    );
  }
}

/// Extension to add a [qualifiedString] shorthand method to [OptionDefinition].
/// Since enum classes that implement [OptionDefinition] don't inherit
/// its method implementations, this extension provides this method
/// implementation instead.
extension QualifiedString on OptionDefinition {
  String qualifiedString() {
    final str = option.qualifiedString();
    if (str == ConfigOptionBase._unnamedOptionString && this is Enum) {
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
    opt.option._validateDefinition();
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
abstract interface class ConfigurationBroker<O extends OptionDefinition> {
  /// Returns the value for the given key, or `null` if the key is not found
  /// or has no value.
  ///
  /// Resolution may depend on the value of other options, accessed via [cfg].
  String? valueOrNull(final String key, final Configuration<O> cfg);
}

/// A configuration object that holds resolved values for a set of configuration options.
class Configuration<O extends OptionDefinition> {
  final List<O> _options;
  final Map<O, Object?> _config;
  final List<String> _errors;

  /// Instantiates a configuration with the provided option values.
  ///
  /// This does not throw upon parsing or validation errors,
  /// instead the caller is responsible for checking if [errors] is non-empty.
  Configuration.fromValues({
    required final Map<O, Object?> values,
  })  : _options = List<O>.from(values.keys),
        _config = Map<O, Object?>.from(values),
        _errors = <String>[] {
    for (final opt in _options) {
      final error = _validateOptionValue(opt, values[opt]);
      if (error != null) {
        _errors.add(error);
      }
    }
  }

  /// Instantiates a configuration with option values resolved from the provided context.
  ///
  /// This does not throw upon parsing or validation errors,
  /// instead the caller is responsible for checking if [errors] is non-empty.
  Configuration.fromEnvAndArgs({
    required final Iterable<O> options,
    final ArgResults? args,
    final Map<String, String>? env,
    final ConfigurationBroker? configBroker,
  })  : _options = List<O>.from(options),
        _config = <O, Object?>{},
        _errors = <String>[] {
    _resolveFromEnvAndArgs(
      args: args,
      env: env,
      configBroker: configBroker,
    );
  }

  /// Gets the option definitions for this configuration.
  Iterable<O> get options => _config.keys;

  /// Gets the errors that occurred during configuration resolution.
  Iterable<String> get errors => _errors;

  /// Returns the option definition for the given enum name,
  /// or any provided argument name, position,
  /// environment variable name, or configuration key.
  /// The first one that matches is returned, or null if none match.
  ///
  /// The recommended practice is to define options as enums and identify them by the enum name.
  O? findOption({
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

  /// Returns the value of a configuration option
  /// that is guaranteed to be non-null.
  ///
  /// Throws [UsageException] if the option is mandatory and no value is provided.
  ///
  /// If called for an option that is neither mandatory nor has defaults,
  /// [StateError] is thrown. See also [optionalValue].
  ///
  /// Throws [ArgumentError] if the option is unknown.
  V value<V>(final OptionDefinition<V> option) {
    if (!(option.option.mandatory ||
        option.option.fromDefault != null ||
        option.option.defaultsTo != null)) {
      throw StateError(
          "Can't invoke non-nullable value() for ${option.qualifiedString()} "
          "which is neither mandatory nor has a default value.");
    }
    final val = optionalValue(option);
    if (val != null) return val;

    if (errors.isNotEmpty) {
      throw StateError(
          'No value available for ${option.qualifiedString()} due to previous errors');
    }
    throw UsageException('${option.qualifiedString()} is mandatory', '');
  }

  /// Returns the value of an optional configuration option.
  /// Returns `null` if the option is not set.
  ///
  /// Throws [ArgumentError] if the option is unknown.
  V? optionalValue<V>(final OptionDefinition<V> option) {
    if (!_options.contains(option)) {
      throw ArgumentError(
          "${option.qualifiedString()} is not part of this configuration");
    }

    if (!_config.containsKey(option)) {
      if (errors.isNotEmpty) {
        throw StateError(
            'No value available for ${option.qualifiedString()} due to previous errors');
      }
      throw InvalidOptionConfigurationError(option,
          "Out-of-order dependency on not-yet-resolved ${option.qualifiedString()}");
    }

    return _config[option] as V?;
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
    final O option, {
    final ArgResults? args,
    final Iterable<String> remainingPosArgs = const [],
    final Map<String, String> env = const {},
    final ConfigurationBroker? configBroker,
  }) {
    final argOptName = option.option.argName;
    final argOptPos = option.option.argPos;
    final envVarName = option.option.envName;
    final configKey = option.option.configKey;

    String? stringValue;
    Object? value;
    String? error;
    Iterable<String> nextRemainingPosArgs = remainingPosArgs;

    if (argOptName != null && args != null && args.wasParsed(argOptName)) {
      // Named arguments takes precedence over other config sources.
      stringValue = option.option.isFlag
          ? args.flag(argOptName).toString()
          : args.option(argOptName);
    } else if (argOptPos != null && remainingPosArgs.isNotEmpty) {
      // Positional arguments have second highest precedence.
      stringValue = remainingPosArgs.first;
      nextRemainingPosArgs = remainingPosArgs.skip(1);
    } else if (envVarName != null && env.containsKey(envVarName)) {
      // Environment variables have third highest precedence.
      stringValue = env[envVarName];
    } else if (_getConfigValue(configBroker, configKey) case final String val) {
      // Value from configuration callback has fourth highest precedence.
      // (The case pattern matches if the value is of type String i.e. non-null.)
      stringValue = val;
    }

    if (stringValue != null) {
      // value is provided by the highest precedence config sources
      // which are also string-based: parse to the designated type
      try {
        value = option.option.valueParser.parse(stringValue);
      } on FormatException catch (e) {
        error = _makeFormatErrorMessage(e, option.option);
      }
    } else {
      if (option.option.fromCustom?.call(this) case final Object val) {
        // Value from custom callback has fifth highest precedence.
        value = val;
      } else if (option.option.fromDefault?.call() case final Object val) {
        // Default value from callback has second lowest precedence.
        value = val;
      } else {
        // Default value has lowest precedence.
        value = option.option.defaultsTo;
      }
    }

    error ??= _validateOptionValue(option, value);

    return (value: value, error: error, remainingPosArgs: nextRemainingPosArgs);
  }

  String? _validateOptionValue(final O option, final Object? value) {
    if (value == null && option.option.mandatory) {
      return '${option.qualifiedString()} is mandatory';
    }

    if (value != null) {
      try {
        option.option.validateValue(value);
      } on FormatException catch (e) {
        return _makeFormatErrorMessage(e, option.option);
      }
    }
    return null;
  }

  String? _getConfigValue(
    final ConfigurationBroker? configBroker,
    final String? key,
  ) {
    if (configBroker == null || key == null) return null;
    return configBroker.valueOrNull(key, this);
  }

  static String? _makeFormatErrorMessage(
    final FormatException e,
    final ConfigOptionBase option,
  ) {
    const prefix = 'FormatException: ';
    var message = e.toString();
    if (message.startsWith(prefix)) {
      message = message.substring(prefix.length);
    }
    final valueHelp = option.valueHelp != null ? ' <${option.valueHelp}>' : '';
    return 'Invalid value for ${option.qualifiedString()}$valueHelp: $message';
  }
}

typedef _OptResolution = ({
  Object? value,
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
