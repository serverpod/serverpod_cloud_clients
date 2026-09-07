import 'dart:convert';

const JsonEncoder _prettyJson = JsonEncoder.withIndent('  ');

const Set<String> _hiddenFields = {
  'id',
  'sessionLogId',
  'serverId',
  'time',
  'touched',
  'order',
  'logLevel',
};

const List<String> _headlineFields = ['message', 'query'];

class LogPayload {
  final String raw;
  final String? headline;
  final Map<String, Object?> fields;

  const LogPayload({required this.raw, this.headline, this.fields = const {}});

  bool get isStructured => fields.isNotEmpty || headline != raw;

  static LogPayload parse(String content) {
    final Object? decoded = _decode(content);
    if (decoded is! Map<String, Object?>) {
      return LogPayload(raw: content, headline: content);
    }

    final Map<String, Object?> fields = {
      for (final MapEntry<String, Object?> entry in decoded.entries)
        if (entry.value != null && !_hiddenFields.contains(entry.key))
          entry.key: entry.value,
    };

    return LogPayload(
      raw: content,
      headline: _takeHeadline(fields),
      fields: fields,
    );
  }

  static String? _takeHeadline(Map<String, Object?> fields) {
    for (final String key in _headlineFields) {
      final Object? value = fields[key];
      if (value is String && value.isNotEmpty) {
        fields.remove(key);
        return value;
      }
    }

    final Object? endpoint = fields['endpoint'];
    if (endpoint is String && endpoint.isNotEmpty) {
      final Object? method = fields['method'];
      fields.remove('endpoint');
      fields.remove('method');
      return method is String && method.isNotEmpty
          ? '$endpoint.$method'
          : endpoint;
    }

    return null;
  }

  static String formatValue(Object? value) {
    if (value is String) return value;
    if (value is Map || value is List) return _prettyJson.convert(value);

    return '$value';
  }

  static Object? _decode(String content) {
    final String trimmed = content.trim();
    if (trimmed.isEmpty) return null;

    Object? decoded;
    var depth = 0;
    do {
      try {
        decoded = jsonDecode(decoded is String ? decoded.trim() : trimmed);
      } on FormatException {
        return null;
      }
      depth++;
    } while (decoded is String && depth < 5);

    return decoded;
  }
}
