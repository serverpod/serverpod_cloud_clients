/// The supported output formats.
enum OutputFormat {
  text,
  csv,
  json,
  yaml;

  /// Whether the format serializes the operation result as a document.
  ///
  /// [csv] is not structured: it uses the text UI, with tables as CSV.
  bool get isStructured => switch (this) {
    OutputFormat.json || OutputFormat.yaml => true,
    OutputFormat.text || OutputFormat.csv => false,
  };
}
