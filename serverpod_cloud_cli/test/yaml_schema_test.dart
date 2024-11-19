import 'package:serverpod_cloud_cli/util/scloud_config/yaml_schema.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test(
      'Given simple primitive types when calling validate then should not throw',
      () {
    final schema = YamlSchema(YamlMap.wrap({
      'name': String,
      'age': int,
      'height': double,
      'is_active': bool,
    }));

    final validData = YamlMap.wrap({
      'name': 'John Doe',
      'age': 30,
      'height': 1.85,
      'is_active': true,
    });

    expect(() => schema.validate(validData), returnsNormally);
  });

  test('Given missing required key when calling validate then throws', () {
    final schema = YamlSchema(YamlMap.wrap({
      'name': String,
      'age': int,
    }));

    final invalidData = YamlMap.wrap({
      'name': 'John Doe',
    });

    expect(
      () => schema.validate(invalidData),
      throwsA(
        isA<SchemaValidationException>().having(
          (final e) => e.message,
          'error message',
          'Missing required key: "age"',
        ),
      ),
    );
  });

  test(
      'Given missing required key in nested map when calling validate then throws',
      () {
    final schema = YamlSchema(YamlMap.wrap({
      'user': YamlMap.wrap({'name': String, 'age': int}),
    }));

    final invalidData = YamlMap.wrap({
      'user': {'name': 'John Doe'},
    });

    expect(
      () => schema.validate(invalidData),
      throwsA(
        isA<SchemaValidationException>().having(
          (final e) => e.message,
          'error message',
          'At path "user": Missing required key: "age"',
        ),
      ),
    );
  });

  test('Given nested structure when calling validate then should not throw',
      () {
    final schema = YamlSchema(YamlMap.wrap({
      'users': [
        YamlMap.wrap({
          'name': String,
          'age': int,
        })
      ]
    }));

    final validData = YamlMap.wrap({
      'users': [
        {'name': 'John', 'age': 30},
        {'name': 'Jane', 'age': 25},
      ]
    });

    expect(() => schema.validate(validData), returnsNormally);
  });

  test(
      'Given nested structure with incorrect types when calling validate then throws',
      () {
    final schema = YamlSchema(YamlMap.wrap({
      'users': [
        YamlMap.wrap({
          'name': String,
          'age': int,
        })
      ]
    }));

    final invalidData = YamlMap.wrap({
      'users': [
        {'name': 'John', 'age': '30'},
      ]
    });

    expect(
      () => schema.validate(invalidData),
      throwsA(
        isA<SchemaValidationException>().having(
          (final e) => e.message,
          'error message',
          'At path "users[0].age": Expected type int, got String',
        ),
      ),
    );
  });

  test(
      'Given deeply nested nested structure when calling validate then should not throw',
      () {
    final schema = YamlSchema(YamlMap.wrap({
      'organization': YamlMap.wrap({
        'name': String,
        'departments': [
          YamlMap.wrap({
            'name': String,
            'employees': [
              YamlMap.wrap({
                'name': String,
                'age': int,
                'skills': [String]
              })
            ]
          })
        ]
      })
    }));

    final validData = YamlMap.wrap({
      'organization': {
        'name': 'Acme Corp',
        'departments': [
          {
            'name': 'Engineering',
            'employees': [
              {
                'name': 'John Doe',
                'age': 30,
                'skills': ['Dart', 'Flutter']
              }
            ]
          }
        ]
      }
    });

    expect(() => schema.validate(validData), returnsNormally);
  });

  test(
      'Given schema with invalid type that is not compatible with YAML '
      'when calling validate then throws exception.', () {
    final schema = YamlSchema(YamlMap.wrap({
      'data': DateTime, // DateTime is not a supported YAML type
    }));
    expect(
      () => schema.validate(YamlMap.wrap({
        'data': 1,
      })),
      throwsA(
        isA<SchemaValidationException>().having(
          (final e) => e.message,
          'error message',
          'At path "data": Unsupported schema type: DateTime',
        ),
      ),
    );
  });

  test('Given data with empty list when calling validate then should not throw',
      () {
    final schema = YamlSchema(YamlMap.wrap({
      'tags': [String]
    }));

    final validData = YamlMap.wrap({'tags': []});

    expect(() => schema.validate(validData), returnsNormally);
  });

  test('Given incorrect nested structure when calling validate then throws',
      () {
    final schema = YamlSchema(YamlMap.wrap({
      'user': YamlMap.wrap({
        'name': String,
      })
    }));

    final invalidData = YamlMap.wrap({
      'user': 'Not a map',
    });

    expect(
      () => schema.validate(invalidData),
      throwsA(
        isA<SchemaValidationException>().having(
          (final e) => e.message,
          'error message',
          'At path "user": Expected YamlMap, got String',
        ),
      ),
    );
  });

  test(
      'Given a schema with mixed list types when calling validate then throws because it only uses the first type',
      () async {
    final schema = YamlSchema(YamlMap.wrap({
      'items': [String, int],
    }));

    final invalidData = YamlMap.wrap({
      'items': ['one', 2],
    });

    expect(
      () => schema.validate(invalidData),
      throwsA(
        isA<SchemaValidationException>().having(
          (final e) => e.message,
          'error message',
          'At path "items[1]": Expected type String, got int',
        ),
      ),
    );
  });
}
