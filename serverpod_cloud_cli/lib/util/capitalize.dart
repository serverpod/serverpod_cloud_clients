extension StringCapitalize on String {
  /// Returns a new string with the first character converted to uppercase.
  String capitalize() {
    return isEmpty ? '' : this[0].toUpperCase() + substring(1);
  }
}
