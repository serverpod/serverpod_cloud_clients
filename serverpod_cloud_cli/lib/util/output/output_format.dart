/// The supported output formats.
enum OutputFormat {
  text,
  json,
  yaml;

  bool get isStructured => this != OutputFormat.text;
}
