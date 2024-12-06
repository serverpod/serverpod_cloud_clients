String jsonToYaml(
  final Map<String, dynamic> data, {
  final int indentation = 2,
}) {
  final buffer = StringBuffer();
  _convertToYaml(data, buffer, indentation: indentation);
  return buffer.toString();
}

void _convertToYaml(
  final dynamic value,
  final StringBuffer buffer, {
  final int indentation = 2,
  final int currentIndent = 0,
}) {
  if (value is Map<String, dynamic>) {
    if (value.isEmpty) {
      buffer.write('{}');
      return;
    }

    value.forEach((final key, final val) {
      _writeIndent(buffer, currentIndent);
      buffer.write('$key:');

      if ((val is List && val.isNotEmpty) ||
          (val is Map<String, dynamic> && val.isNotEmpty)) {
        buffer.writeln();
      } else {
        _writeIndent(buffer, 1);
      }

      _convertToYaml(
        val,
        buffer,
        indentation: indentation,
        currentIndent: currentIndent + indentation,
      );
    });

    return;
  }

  if (value is List) {
    if (value.isEmpty) {
      buffer.writeln('[]');
    }

    for (final item in value) {
      _writeIndent(buffer, currentIndent);
      buffer.write('-');

      if ((item is List && item.isNotEmpty) ||
          (item is Map<String, dynamic> && item.isNotEmpty)) {
        buffer.writeln();
      } else {
        _writeIndent(buffer, 1);
      }

      _convertToYaml(
        item,
        buffer,
        indentation: indentation,
        currentIndent: currentIndent + indentation,
      );
    }

    return;
  }

  if (value is String) {
    buffer.writeln('"$value"');
    return;
  }

  buffer.writeln(value.toString());
}

void _writeIndent(final StringBuffer buffer, final int indent) {
  buffer.write(' ' * indent);
}
