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

const List<Set<String>> _frameworkEntryKeys = [
  {'sessionLogId', 'serverId', 'time', 'logLevel', 'message', 'order'},
  {'sessionLogId', 'serverId', 'query', 'duration', 'slow', 'order'},
  {'serverId', 'time', 'touched'},
  {
    'sessionLogId',
    'serverId',
    'messageId',
    'endpoint',
    'messageName',
    'duration',
    'slow',
    'order',
  },
];

const List<String> _logLevels = ['DEBUG', 'INFO', 'WARNING', 'ERROR', 'FATAL'];

class LogPayload {
  final String raw;
  final String? headline;
  final String? logLevel;
  final int? sessionLogId;
  final Map<String, Object?> fields;

  const LogPayload({
    required this.raw,
    this.headline,
    this.logLevel,
    this.sessionLogId,
    this.fields = const {},
  });

  bool get isStructured => fields.isNotEmpty || headline != raw;

  static LogPayload parse(String content) {
    final Object? decoded = decode(content);
    if (decoded is! Map<String, Object?>) {
      return LogPayload(raw: content, headline: content);
    }

    final bool isFrameworkEntry = _frameworkEntryKeys.any(
      (Set<String> keys) => decoded.keys.toSet().containsAll(keys),
    );

    final Map<String, Object?> fields = {
      for (final MapEntry<String, Object?> entry in decoded.entries)
        if (entry.value != null &&
            !(isFrameworkEntry && _hiddenFields.contains(entry.key)))
          entry.key: entry.value,
    };

    return LogPayload(
      raw: content,
      headline: isFrameworkEntry ? _takeHeadline(fields) : null,
      logLevel: isFrameworkEntry ? _readLogLevel(decoded['logLevel']) : null,
      sessionLogId: isFrameworkEntry ? _readSessionLogId(decoded) : null,
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

  static int? _readSessionLogId(Map<String, Object?> entry) {
    final Object? sessionLogId = entry['sessionLogId'];
    if (sessionLogId is int) return sessionLogId;

    final Object? id = entry['id'];
    return entry.containsKey('touched') && id is int ? id : null;
  }

  static String? _readLogLevel(Object? value) {
    return switch (value) {
      final int index when index >= 0 && index < _logLevels.length =>
        _logLevels[index],
      final String name when _logLevels.contains(name.toUpperCase()) =>
        name.toUpperCase(),
      _ => null,
    };
  }

  static String formatValue(Object? value) {
    if (value is String) return value;
    if (value is Map || value is List) return _prettyJson.convert(value);

    return '$value';
  }

  /// Decodes [content] as JSON, unwrapping string-encoded JSON.
  /// Returns null when the content is empty or not valid JSON.
  static Object? decode(String content) {
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
