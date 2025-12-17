import 'package:serverpod_cloud_cli/util/scloud_config/yaml_schema.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test(
    'Given simple primitive types when calling validate then does not throw',
    () {
      final schema = YamlSchema(
        YamlMap.wrap({
          'name': String,
          'age': int,
          'height': double,
          'is_active': bool,
        }),
      );

      final validData = YamlMap.wrap({
        'name': 'John Doe',
        'age': 30,
        'height': 1.85,
        'is_active': true,
      });

      expect(() => schema.validate(validData), returnsNormally);
    },
  );

  test('Given missing required key when calling validate then throws', () {
    final schema = YamlSchema(YamlMap.wrap({'name': String, 'age': int}));

    final invalidData = YamlMap.wrap({'name': 'John Doe'});

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
      final schema = YamlSchema(
        YamlMap.wrap({
          'user': YamlMap.wrap({'name': String, 'age': int}),
        }),
      );

      final invalidData = YamlMap.wrap({
        'user': {'name': 'John Doe'},
      });

      expect(
        () => schema.validate(invalidData),
        throwsA(
          isA<SchemaValidationException>().having(
            (final e) => e.message,
            'error message',
            'Missing required key: "user.age"',
          ),
        ),
      );
    },
  );

  test('Given nested structure when calling validate then does not throw', () {
    final schema = YamlSchema(
      YamlMap.wrap({
        'users': [
          YamlMap.wrap({'name': String, 'age': int}),
        ],
      }),
    );

    final validData = YamlMap.wrap({
      'users': [
        {'name': 'John', 'age': 30},
        {'name': 'Jane', 'age': 25},
      ],
    });

    expect(() => schema.validate(validData), returnsNormally);
  });

  test(
    'Given nested structure with incorrect types when calling validate then throws',
    () {
      final schema = YamlSchema(
        YamlMap.wrap({
          'users': [
            YamlMap.wrap({'name': String, 'age': int}),
          ],
        }),
      );

      final invalidData = YamlMap.wrap({
        'users': [
          {'name': 'John', 'age': '30'},
        ],
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
    },
  );

  test(
    'Given deeply nested structure when calling validate then does not throw',
    () {
      final schema = YamlSchema(
        YamlMap.wrap({
          'organization': YamlMap.wrap({
            'name': String,
            'departments': [
              YamlMap.wrap({
                'name': String,
                'employees': [
                  YamlMap.wrap({
                    'name': String,
                    'age': int,
                    'skills': [String],
                  }),
                ],
              }),
            ],
          }),
        }),
      );

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
                  'skills': ['Dart', 'Flutter'],
                },
              ],
            },
          ],
        },
      });

      expect(() => schema.validate(validData), returnsNormally);
    },
  );

  test(
    'Given data with empty list when calling validate then does not throw',
    () {
      final schema = YamlSchema(
        YamlMap.wrap({
          'tags': [String],
        }),
      );

      final validData = YamlMap.wrap({'tags': []});

      expect(() => schema.validate(validData), returnsNormally);
    },
  );

  test(
    'Given incorrect nested structure when calling validate then throws',
    () {
      final schema = YamlSchema(
        YamlMap.wrap({
          'user': YamlMap.wrap({'name': String}),
        }),
      );

      final invalidData = YamlMap.wrap({'user': 'Not a map'});

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
    },
  );

  test(
    'Given a schema with mixed list types when calling validate then throws because it only uses the first type',
    () async {
      final schema = YamlSchema(
        YamlMap.wrap({
          'items': [String, int],
        }),
      );

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
    },
  );

  group('Given a schema with an optional type', () {
    test(
      'of String when calling validate without the key then does not throw',
      () {
        final schema = YamlSchema(YamlMap.wrap({'item': YamlOptional(String)}));

        final validData = YamlMap.wrap({});

        expect(() => schema.validate(validData), returnsNormally);
      },
    );

    test(
      'of Optional String when calling validate with valid data then does not throw',
      () {
        final schema = YamlSchema(YamlMap.wrap({'item': YamlOptional(String)}));

        final validData = YamlMap.wrap({'item': 'valid'});

        expect(() => schema.validate(validData), returnsNormally);
      },
    );

    test(
      'of nested Optional String when calling validate without the key then does not throw',
      () {
        final schema = YamlSchema(
          YamlMap.wrap({
            'item': YamlMap.wrap({'name': YamlOptional(String)}),
          }),
        );

        final validData = YamlMap.wrap({'item': {}});

        expect(() => schema.validate(validData), returnsNormally);
      },
    );
  });

  group('Given a schema with a union type', () {
    test(
      'of String when calling validate with valid data then does not throw',
      () {
        final schema = YamlSchema(
          YamlMap.wrap({
            'item': YamlUnion({String}),
          }),
        );

        final validData = YamlMap.wrap({'item': 'valid'});

        expect(() => schema.validate(validData), returnsNormally);
      },
    );

    test('of String when calling validate with invalid data then throws', () {
      final schema = YamlSchema(
        YamlMap.wrap({
          'item': YamlUnion({String}),
        }),
      );

      final validData = YamlMap.wrap({'item': 1});

      expect(() => schema.validate(validData), throwsException);
    });

    test(
      'of int and String when calling validate with valid data then does not throw',
      () {
        final schema = YamlSchema(
          YamlMap.wrap({
            'item': YamlUnion({int, String}),
          }),
        );

        final validData = YamlMap.wrap({'item': 1});

        expect(() => schema.validate(validData), returnsNormally);
      },
    );

    test(
      'of List<String> and String when calling validate with string data then does not throw',
      () {
        final schema = YamlSchema(
          YamlMap.wrap({
            'item': YamlUnion({
              [String],
              String,
            }),
          }),
        );

        final validData = YamlMap.wrap({'item': 'data'});

        expect(() => schema.validate(validData), returnsNormally);
      },
    );

    test(
      'of List<String> and String when calling validate with list data then does not throw',
      () {
        final schema = YamlSchema(
          YamlMap.wrap({
            'item': YamlUnion({
              [String],
              String,
            }),
          }),
        );

        final validData = YamlMap.wrap({
          'item': ['one', 'two'],
        });

        expect(() => schema.validate(validData), returnsNormally);
      },
    );

    test(
      'of List<String> and String when calling validate with invalid data then throws',
      () {
        final schema = YamlSchema(
          YamlMap.wrap({
            'item': YamlUnion({
              [String],
              String,
            }),
          }),
        );

        final validData = YamlMap.wrap({'item': 2});

        expect(() => schema.validate(validData), throwsException);
      },
    );

    test(
      'of Optional List<String> and String when calling validate without the key then does not throw',
      () {
        final schema = YamlSchema(
          YamlMap.wrap({
            'item': YamlOptional(
              YamlUnion({
                [String],
                String,
              }),
            ),
          }),
        );

        final validData = YamlMap.wrap({});

        expect(() => schema.validate(validData), returnsNormally);
      },
    );

    test(
      'of YamlMap and String when calling validate with valid data then does not throw',
      () {
        final schema = YamlSchema(
          YamlMap.wrap({
            'item': YamlOptional(
              YamlUnion({
                YamlMap.wrap({'name': String}),
                String,
              }),
            ),
          }),
        );

        final validData = YamlMap.wrap({
          'item': {'name': 'valid'},
        });

        expect(() => schema.validate(validData), returnsNormally);
      },
    );

    test(
      'of List<int> and YamlMap when calling validate with valid data then does not throw',
      () {
        final schema = YamlSchema(
          YamlMap.wrap({
            'value': YamlUnion({
              [int],
              YamlMap.wrap({'name': String}),
            }),
          }),
        );

        final data = YamlMap.wrap({
          'value': {'name': 'valid'},
        });

        expect(() => schema.validate(data), returnsNormally);
      },
    );
  });
}
