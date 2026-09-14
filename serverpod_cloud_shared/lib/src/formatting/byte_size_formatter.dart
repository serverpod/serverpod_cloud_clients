/// Decimal (SI) byte sizes, shared so the CLI and the console render
/// storage file sizes the same way.
///
/// Uses 1000-based units (`kB`, `MB`, …). Binary kibibyte sizes (`KB` at
/// 1024) belong in their own formatters.
abstract final class ByteSizeFormatter {
  static const List<String> _units = ['B', 'kB', 'MB', 'GB', 'TB', 'PB'];

  /// From here the value renders as `1000` of the current unit, so it
  /// belongs in the next one.
  static const double _nextUnitFrom = 999.5;

  /// Renders [bytes] as a decimal size, for example `1.5 MB`.
  static String format(int bytes) {
    if (bytes < 1000) return '$bytes B';

    var value = bytes.toDouble();
    var unit = 0;
    while (value >= _nextUnitFrom && unit < _units.length - 1) {
      value /= 1000;
      unit++;
    }

    final String rendered = value >= 100
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);

    return '$rendered ${_units[unit]}';
  }
}
