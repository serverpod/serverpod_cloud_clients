const List<String> _units = ['B', 'kB', 'MB', 'GB', 'TB', 'PB'];

/// From here the value renders as 1000, so it belongs in the next unit.
const double _nextUnitFrom = 999.5;

/// Formats [bytes] as a decimal byte size, for example `1.5 MB`.
///
/// Returns `-` when [bytes] is null.
String formatByteSize(final int? bytes) {
  if (bytes == null) {
    return '-';
  }
  if (bytes < 1000) {
    return '$bytes B';
  }

  var value = bytes.toDouble();
  var unit = 0;
  while (value >= _nextUnitFrom && unit < _units.length - 1) {
    value /= 1000;
    unit++;
  }

  final rendered = value >= 100
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);

  return '$rendered ${_units[unit]}';
}
