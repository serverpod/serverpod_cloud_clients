import 'package:yaml/yaml.dart';

class SchemaValidationException implements Exception {
  final String message;
  SchemaValidationException(this.message);

  @override
  String toString() => 'SchemaValidationException: $message';
}

class YamlSchema {
  final YamlMap _schema;

  YamlSchema(this._schema);

  void validate(final YamlMap data) {
    for (final entry in _schema.entries) {
      final key = entry.key;
      final type = entry.value;

      if (!data.containsKey(key)) {
        throw SchemaValidationException('Missing required key: "$key"');
      }

      final value = data[key];
      _validate(value, type, path: key);
    }
  }

  void _validate(
    final dynamic value,
    final dynamic schemaType, {
    required final String path,
  }) {
    switch (schemaType) {
      case List():
        {
          if (value is! List) {
            throw SchemaValidationException(
                'At path "$path": Expected List, got ${value.runtimeType}');
          }

          if (schemaType.isEmpty) return;

          final itemType = schemaType.first;

          for (var i = 0; i < value.length; i++) {
            _validate(value[i], itemType, path: '$path[$i]');
          }
          return;
        }
      case YamlMap():
        {
          if (value is! YamlMap) {
            throw SchemaValidationException(
              'At path "$path": Expected YamlMap, got ${value.runtimeType}',
            );
          }

          for (final schemaEntry in schemaType.entries) {
            final fieldName = schemaEntry.key;
            final fieldType = schemaEntry.value;

            if (value.containsKey(fieldName)) {
              _validate(
                value[fieldName],
                fieldType,
                path: '$path.$fieldName',
              );
            } else {
              throw SchemaValidationException(
                'At path "$path": Missing required key: "$fieldName"',
              );
            }
          }
          return;
        }
      // Primitive types supported by YAML
      case Type():
        {
          final supportedYamlTypes = {
            String,
            int,
            double,
            bool,
          };

          if (!supportedYamlTypes.contains(schemaType)) {
            throw SchemaValidationException(
                'At path "$path": Unsupported schema type: ${schemaType.toString()}');
          }

          if (value.runtimeType != schemaType) {
            throw SchemaValidationException(
                'At path "$path": Expected type ${schemaType.toString()}, got ${value.runtimeType}');
          }
          return;
        }
    }

    throw SchemaValidationException(
        'At path "$path": Unsupported schema type: ${schemaType.runtimeType}');
  }
}
