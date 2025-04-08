enum OptionSource {
  noValue,
  preset,
  arg,
  envVar,
  config,
  custom,
  defaultValue,
}

final class OptionResolution<V> {
  final String? stringValue;
  final V? value;
  final String? error;
  final OptionSource source;

  const OptionResolution._({
    required this.source,
    this.stringValue,
    this.value,
    this.error,
  });

  const OptionResolution({
    required this.source,
    this.stringValue,
    this.value,
  }) : error = null;

  const OptionResolution.noValue()
      : source = OptionSource.noValue,
        stringValue = null,
        value = null,
        error = null;

  const OptionResolution.error(this.error)
      : source = OptionSource.noValue,
        stringValue = null,
        value = null;

  OptionResolution<V> copyWithValue(final V newValue) => OptionResolution._(
        source: source,
        stringValue: stringValue,
        value: newValue,
        error: error,
      );

  OptionResolution<V> copyWithError(final String error) => OptionResolution._(
        source: source,
        stringValue: stringValue,
        value: value,
        error: error,
      );

  /// Whether the option has a proper value (without errors).
  bool get hasValue => source != OptionSource.noValue && error == null;

  /// Whether the option has a value that was specified explicitly (not default).
  bool get isSpecified => hasValue && source != OptionSource.defaultValue;

  /// Whether the option has the default value.
  bool get isDefault => hasValue && source == OptionSource.defaultValue;
}
