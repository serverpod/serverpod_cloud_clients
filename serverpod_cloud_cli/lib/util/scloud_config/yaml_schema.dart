import 'package:yaml/yaml.dart';

class SchemaValidationException implements Exception {
  final String message;
  SchemaValidationException(this.message);

  @override
  String toString() => 'SchemaValidationException: $message';
}

/// Represents an optional type in the schema.
/// The value should be a valid YAML type or a YamlUnion.
class YamlOptional {
  final dynamic type;

  YamlOptional(this.type);
}

/// Represents a union type in the schema.
/// The value should be a set of valid YAML types.
class YamlUnion {
  final Set<dynamic> types;

  YamlUnion(this.types);
}

class YamlSchema {
  final YamlMap _schema;

  YamlSchema(this._schema);

  /// Validates the given data against the schema.
  /// Throws a SchemaValidationException if the data is invalid.
  void validate(final YamlMap data) {
    for (final entry in _schema.entries) {
      final key = entry.key;
      final type = entry.value;

      final value = data[key];
      _validate(value, type, path: key);
    }
  }

  void _validate(
    final dynamic value,
    final dynamic schemaType, {
    required final String path,
  }) {
    if (value == null) {
      if (schemaType is YamlOptional) return;

      throw SchemaValidationException('Missing required key: "$path"');
    }

    final type = schemaType is YamlOptional ? schemaType.type : schemaType;

    switch (type) {
      case List():
        {
          if (value is! List) {
            throw SchemaValidationException(
              'At path "$path": Expected List, got ${value.runtimeType}',
            );
          }

          if (type.isEmpty) return;

          final itemType = type.first;

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

          for (final schemaEntry in type.entries) {
            final fieldName = schemaEntry.key;
            final fieldType = schemaEntry.value;

            _validate(value[fieldName], fieldType, path: '$path.$fieldName');
          }
          return;
        }
      case YamlUnion():
        {
          for (final unionType in type.types) {
            if (_isValidBasicType(value, unionType, path)) {
              return;
            }

            if (unionType is List && value is List) {
              _validate(value, unionType, path: path);
              return;
            }

            if (unionType is YamlMap && value is YamlMap) {
              _validate(value, unionType, path: path);
              return;
            }
          }

          final typeNames = type.types
              .map((final t) => t.toString())
              .join(', ');
          throw SchemaValidationException(
            'At path "$path": Expected one of $typeNames, got ${value.runtimeType}',
          );
        }
      // Primitive types supported by YAML
      case Type():
        {
          if (!_isValidBasicType(value, type, path)) {
            throw SchemaValidationException(
              'At path "$path": Expected type ${type.toString()}, got ${value.runtimeType}',
            );
          }
          return;
        }
    }

    throw SchemaValidationException(
      'At path "$path": Unsupported schema type: ${type.runtimeType}',
    );
  }

  bool _isValidBasicType(
    final dynamic value,
    final dynamic schemaType,
    final String path,
  ) {
    if (schemaType is Type) {
      if (schemaType == String && value is String) return true;
      if (schemaType == int && value is int) return true;
      if (schemaType == double && value is double) return true;
      if (schemaType == bool && value is bool) return true;
    }

    return false;
  }
}
