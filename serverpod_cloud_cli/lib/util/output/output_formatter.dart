import 'dart:convert' show jsonEncode, jsonDecode;

import 'package:ground_control_client/ground_control_client.dart'
    show SerializableModel;
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/duration_formatter.dart';
import 'package:yaml_codec/yaml_codec.dart' show yamlEncode;

/// Base class for output formatters - given an input "object" type O
/// returns a formatted "data" type D.
abstract class OutputFormatter<O extends Object, D extends Object> {
  final bool utc;

  const OutputFormatter({required this.utc});

  D format(O object);
}

class JsonOutputFormatter<O extends Object> extends OutputFormatter<O, String> {
  const JsonOutputFormatter({super.utc = false});

  @override
  String format(O object) {
    final encoded = jsonEncode(object, toEncodable: _structuredValue);
    return '$encoded\n';
  }
}

class YamlOutputFormatter<O extends Object> extends OutputFormatter<O, String> {
  const YamlOutputFormatter({super.utc = false});

  @override
  String format(O object) {
    // decode via json to support the same value types
    final jsonEncoded = jsonEncode(object, toEncodable: _structuredValue);
    final tmp = jsonDecode(jsonEncoded);
    return yamlEncode(tmp);
  }
}

/// A function that returns the desired value for a given object
/// or for an attribute of that object.
typedef ValueGetter<O extends Object> = Object? Function(O object);

/// A function that returns a formatted String value for a given object
/// or for an attribute of that object.
typedef ValueFormatter<O extends Object> =
    String Function(O object, {required bool? utc});

/// Returns a [ValueFormatter] function that gets the desired value for
/// an object and applies standard formatting on it,
/// depending on its datatype.
ValueFormatter<O> objValueFormatter<O extends Object>({
  required ValueGetter<O> getter,
}) {
  return (O object, {bool? utc}) {
    return _tableCell(getter(object), utc: utc ?? false) ?? '';
  };
}

/// Returns a [ValueFormatter] function that gets the value for the given key
/// of a [Map<String, Object?>] and applies standard formatting on it,
/// depending on its datatype.
ValueFormatter<O> mapValueFormatter<O extends Map<String, Object?>>({
  required String key,
}) {
  return objValueFormatter(getter: (object) => object[key]);
}

Object? _structuredValue(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value.toUtc().toIso8601String();
  }
  if (value is Duration) {
    return value.inSeconds;
  }
  if (value is Enum) {
    return value.name;
  }
  if (value is List) {
    return [for (final element in value) _structuredValue(element)];
  }
  if (value is Map) {
    return {
      for (final entry in value.entries)
        entry.key.toString(): _structuredValue(entry.value),
    };
  }
  if (value is SerializableModel) {
    return value.toJson();
  }
  if (value is num || value is bool || value is String) {
    return value;
  }
  return value.toString();
}

String? _tableCell(Object? value, {required bool utc}) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value.toTzString(utc, numTimeStampChars);
  }
  if (value is Duration) {
    return value.friendlyFormat();
  }
  if (value is List) {
    return [
      for (final element in value) _tableCell(element, utc: utc) ?? '',
    ].join(', ');
  }
  if (value is Enum) {
    return value.name;
  }
  return value.toString();
}
