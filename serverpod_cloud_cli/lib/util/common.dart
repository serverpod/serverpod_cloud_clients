/// Returns the maximum value from an iterable of values, which must extend [Comparable].
T max<T extends Comparable>(final Iterable<T> values) {
  return values.reduce((final a, final b) => a.compareTo(b) > 0 ? a : b);
}
