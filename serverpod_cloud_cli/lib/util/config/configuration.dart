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
      return V is bool ? 'flag `$argName`' : 'option `$argName`';
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

  /////////////////////
  // Value resolution

  /// Returns the resolved value of this configuration option from the provided context.
  /// For options with positional arguments this must be invoked in ascending position order.
  /// Returns the result with the resolved value or error.
  _OptionResolution<V> _resolveValue(
    final Configuration cfg, {
    final ArgResults? args,
    final Iterator<String>? posArgs,
    final Map<String, String>? env,
    final ConfigurationBroker? configBroker,
  }) {
    final res = _doResolve(
      cfg,
      args: args,
      posArgs: posArgs,
      env: env,
      configBroker: configBroker,
    );

    if (res.error != null) {
      return res;
    }

    final stringValue = res.stringValue;
    if (stringValue != null) {
      // value provided by string-based config source, parse to the designated type
      try {
        res.value = option.option.valueParser.parse(stringValue);
      } on FormatException catch (e) {
        res.error = _makeFormatErrorMessage(e);
        return res;
      }
    }

    res.error = _validateOptionValue(res.value);
    return res;
  }

  _OptionResolution<V> _doResolve(
    final Configuration cfg, {
    final ArgResults? args,
    final Iterator<String>? posArgs,
    final Map<String, String>? env,
    final ConfigurationBroker? configBroker,
  }) {
    _OptionResolution<V>? result;

    result = _resolveNamedArg(args);
    if (result != null) return result;

    result = _resolvePosArg(posArgs);
    if (result != null) return result;

    result = _resolveEnvVar(env);
    if (result != null) return result;

    result = _resolveConfigValue(cfg, configBroker);
    if (result != null) return result;

    result = _resolveCustomValue(cfg);
    if (result != null) return result;

    result = _resolveDefaultValue();
    if (result != null) return result;

    return _OptionResolution();
  }

  _OptionResolution<V>? _resolveNamedArg(final ArgResults? args) {
    final argOptName = argName;
    if (argOptName == null || args == null || !args.wasParsed(argOptName)) {
      return null;
    }
    return _OptionResolution(stringValue: args.option(argOptName));
  }

  _OptionResolution<V>? _resolvePosArg(final Iterator<String>? posArgs) {
    final argOptPos = argPos;
    if (argOptPos == null || posArgs == null) return null;
    if (!posArgs.moveNext()) return null;
    return _OptionResolution(stringValue: posArgs.current);
  }

  _OptionResolution<V>? _resolveEnvVar(final Map<String, String>? env) {
    final envVarName = envName;
    if (envVarName == null || env == null || !env.containsKey(envVarName)) {
      return null;
    }
    return _OptionResolution(stringValue: env[envVarName]);
  }

  _OptionResolution<V>? _resolveConfigValue(
    final Configuration cfg,
    final ConfigurationBroker? configBroker,
  ) {
    final key = configKey;
    if (configBroker == null || key == null) return null;
    final value = configBroker.valueOrNull(key, cfg);
    if (value == null) return null;
    if (value is String) return _OptionResolution(stringValue: value);
    if (value is V) return _OptionResolution(value: value as V);
    return _OptionResolution(
      error: '${option.qualifiedString()} value $value '
          'is of type ${value.runtimeType}, not $V.',
    );
  }

  _OptionResolution<V>? _resolveCustomValue(final Configuration cfg) {
    final value = fromCustom?.call(cfg);
    if (value == null) return null;
    return _OptionResolution(value: value);
  }

  _OptionResolution<V>? _resolveDefaultValue() {
    final value = fromDefault?.call() ?? defaultsTo;
    if (value == null) return null;
    return _OptionResolution(value: value);
  }

  /// Returns an error message if the value is invalid, or null if valid.
  String? _validateOptionValue(final V? value) {
    if (value == null && mandatory) {
      return '${qualifiedString()} is mandatory';
    }

    if (value != null) {
      try {
        validateValue(value);
      } on FormatException catch (e) {
        return _makeFormatErrorMessage(e);
      }
    }
    return null;
  }

  String? _makeFormatErrorMessage(final FormatException e) {
    const prefix = 'FormatException: ';
    var message = e.toString();
    if (message.startsWith(prefix)) {
      message = message.substring(prefix.length);
    }
    final help = valueHelp != null ? ' <$valueHelp>' : '';
    return 'Invalid value for ${qualifiedString()}$help: $message';
  }
}

class _OptionResolution<V> {
  String? stringValue;
  V? value;
  String? error;

  _OptionResolution({
    this.stringValue,
    this.value,
    this.error,
  });
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
  final bool negatable;

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
    this.negatable = true,
  }) : super(
          valueParser: const BoolParser(),
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

  @override
  _OptionResolution<bool>? _resolveNamedArg(final ArgResults? args) {
    final argOptName = argName;
    if (argOptName == null || args == null || !args.wasParsed(argOptName)) {
      return null;
    }
    return _OptionResolution(value: args.flag(argOptName));
  }
}

/// Parses a list of values from a comma-separated string.
///
/// The [elementParser] is used to parse the individual elements.
///
/// The [separator] is the pattern that separates the elements,
/// if the input is a single string. It is comma by default.
/// The [joiner] is the string that joins the elements in the
/// formatted display string, also comma by default.
class MultiParser<T> extends ValueParser<List<T>> {
  final ValueParser<T> elementParser;
  final Pattern separator;
  final String joiner;

  const MultiParser({
    required this.elementParser,
    this.separator = ',',
    this.joiner = ',',
  });

  @override
  List<T> parse(final String value) {
    return value.split(separator).map(elementParser.parse).toList();
  }

  @override
  String format(final List<T> value) {
    return value.map(elementParser.format).join(joiner);
  }
}

/// Multi-value configuration option.
class MultiOption<T> extends ConfigOptionBase<List<T>> {
  const MultiOption({
    required final MultiParser<T> multiParser,
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
  }) : super(
          valueParser: multiParser,
        );

  @override
  void _addToArgParser(final ArgParser argParser) {
    final argName = this.argName;
    if (argName == null) {
      throw StateError("Can't add option without arg name to arg parser.");
    }

    final multiParser = valueParser as MultiParser<T>;
    argParser.addMultiOption(
      argName,
      abbr: argAbbrev,
      help: helpText,
      valueHelp: valueHelpString(),
      defaultsTo: defaultValue()?.map(multiParser.elementParser.format),
      hide: hide,
      splitCommas: multiParser.separator == ',',
    );
  }

  @override
  _OptionResolution<List<T>>? _resolveNamedArg(final ArgResults? args) {
    final argOptName = argName;
    if (argOptName == null || args == null || !args.wasParsed(argOptName)) {
      return null;
    }
    final multiParser = valueParser as MultiParser<T>;
    return _OptionResolution(
      value: args
          .multiOption(argOptName)
          .map(multiParser.elementParser.parse)
          .toList(),
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
  Object? valueOrNull(final String key, final Configuration<O> cfg);
}

/// A configuration object that holds the values for a set of configuration options.
class Configuration<O extends OptionDefinition> {
  final List<O> _options;
  final Map<O, Object?> _config;
  final List<String> _errors;

  /// Creates a configuration with the provided option values.
  ///
  /// This does not throw upon value parsing or validation errors,
  /// instead the caller is responsible for checking if [errors] is non-empty.
  Configuration.fromValues({
    required final Map<O, Object?> values,
  })  : _options = List<O>.from(values.keys),
        _config = Map<O, Object?>.from(values),
        _errors = <String>[] {
    for (final opt in _options) {
      final error = opt.option._validateOptionValue(values[opt]);
      if (error != null) {
        _errors.add(error);
      }
    }
  }

  /// Creates a configuration with option values resolved from the provided context.
  ///
  /// [argResults] is used if provided. Otherwise [args] is used if provided.
  ///
  /// This does not throw upon value parsing or validation errors,
  /// instead the caller is responsible for checking if [errors] is non-empty.
  Configuration.resolve({
    required final Iterable<O> options,
    ArgResults? argResults,
    final Iterable<String>? args,
    final Map<String, String>? env,
    final ConfigurationBroker? configBroker,
  })  : _options = List<O>.from(options),
        _config = <O, Object?>{},
        _errors = <String>[] {
    if (argResults == null && args != null) {
      final parser = ArgParser();
      options.prepareForParsing(parser);
      argResults = parser.parse(args);
    }

    _resolveWithArgResults(
      args: argResults,
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
      throw InvalidParseStateError(
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
        throw InvalidParseStateError(
            'No value available for ${option.qualifiedString()} due to previous errors');
      }
      throw InvalidOptionConfigurationError(option,
          "Out-of-order dependency on not-yet-resolved ${option.qualifiedString()}");
    }

    return _config[option] as V?;
  }

  void _resolveWithArgResults({
    final ArgResults? args,
    final Map<String, String>? env,
    final ConfigurationBroker? configBroker,
  }) {
    final posArgs = (args?.rest ?? []).iterator;
    final orderedOpts = _options.sorted((final a, final b) =>
        (a.option.argPos ?? -1).compareTo(b.option.argPos ?? -1));

    for (final opt in orderedOpts) {
      try {
        final result = opt.option._resolveValue(
          this,
          args: args,
          posArgs: posArgs,
          env: env,
          configBroker: configBroker,
        );

        final error = result.error;
        if (error != null) {
          _errors.add(error);
        } else {
          _config[opt] = result.value;
        }
      } on Exception catch (e) {
        _errors.add('Failed to resolve ${opt.qualifiedString()}: $e');
      } on InvalidParseStateError catch (_) {
        // ignored since these follow from previous errors
      }
    }

    final remainingPosArgs = <String>[];
    while (posArgs.moveNext()) {
      remainingPosArgs.add(posArgs.current);
    }
    if (remainingPosArgs.isNotEmpty) {
      _errors.add(
          "Unexpected positional argument(s): '${remainingPosArgs.join("', '")}'");
    }
  }
}

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

/// Specialized [StateError] that indicates that the configuration
/// has not been successfully parsed and this prevents accessing
/// some or all of the configuration values.
class InvalidParseStateError extends StateError {
  InvalidParseStateError(super.message);
}
