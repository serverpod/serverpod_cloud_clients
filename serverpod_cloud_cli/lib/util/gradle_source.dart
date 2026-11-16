/// The Gradle [source] without its `//` and `/* */` comments. Comment
/// markers inside single- or double-quoted strings are kept, and the line
/// breaks of removed comments too.
String gradleWithoutComments(String source) {
  final result = StringBuffer();
  String? quote;
  var i = 0;
  while (i < source.length) {
    final char = source[i];
    final next = i + 1 < source.length ? source[i + 1] : '';
    if (quote != null) {
      result.write(char);
      if (char == '\\' && next.isNotEmpty) {
        result.write(next);
        i += 2;
        continue;
      }
      if (char == quote) quote = null;
      i++;
    } else if (char == '/' && next == '/') {
      final end = source.indexOf('\n', i);
      i = end == -1 ? source.length : end;
    } else if (char == '/' && next == '*') {
      final end = source.indexOf('*/', i + 2);
      final comment = source.substring(i, end == -1 ? source.length : end);
      result.write('\n' * '\n'.allMatches(comment).length);
      i = end == -1 ? source.length : end + 2;
    } else {
      if (char == '"' || char == "'") quote = char;
      result.write(char);
      i++;
    }
  }
  return result.toString();
}
