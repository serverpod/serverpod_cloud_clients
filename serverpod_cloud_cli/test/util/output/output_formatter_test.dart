import 'dart:convert';

import 'package:ground_control_client/ground_control_client.dart'
    show SerializableModel;
import 'package:serverpod_cloud_cli/util/output/output_formatter.dart';
import 'package:test/test.dart';
import 'package:yaml_codec/yaml_codec.dart';

enum _Kind { alpha }

class _SerializableItem implements SerializableModel {
  final String id;

  const _SerializableItem(this.id);

  @override
  Map<String, dynamic> toJson() => {'id': id};

  @override
  String toString() => 'Item($id)';
}

class _Opaque {
  @override
  String toString() => 'opaque-value';
}

void main() {
  group('Given a JSON output formatter', () {
    const formatter = JsonOutputFormatter<Object>();

    test('when formatting a DateTime then the value is UTC ISO-8601', () {
      final encoded = jsonDecode(
        formatter.format(DateTime.utc(2024, 12, 31, 10, 20, 30)),
      );

      expect(encoded, '2024-12-31T10:20:30.000Z');
    });

    test(
      'when formatting a local DateTime then the value is still UTC ISO-8601',
      () {
        final encoded = jsonDecode(
          formatter.format(DateTime.utc(2024, 12, 31, 10, 20, 30).toLocal()),
        );

        expect(encoded, '2024-12-31T10:20:30.000Z');
      },
    );

    test('when formatting a Duration then the value is seconds', () {
      final encoded = jsonDecode(formatter.format(const Duration(hours: 2)));

      expect(encoded, 7200);
    });

    test('when formatting an enumerated value then the name is written', () {
      final encoded = jsonDecode(formatter.format(_Kind.alpha));

      expect(encoded, 'alpha');
    });

    test(
      'when formatting a serializable model then the model JSON is written',
      () {
        final encoded = jsonDecode(
          formatter.format(const _SerializableItem('alpha')),
        );

        expect(encoded, {'id': 'alpha'});
      },
    );

    test(
      'when formatting an unrecognized object then the string form is written',
      () {
        final encoded = jsonDecode(formatter.format(_Opaque()));

        expect(encoded, 'opaque-value');
      },
    );

    test('when formatting a list then each element is encoded', () {
      final encoded = jsonDecode(
        formatter.format([
          DateTime.utc(2024, 12, 31, 10, 20, 30),
          const Duration(hours: 2),
          _Kind.alpha,
        ]),
      );

      expect(encoded, ['2024-12-31T10:20:30.000Z', 7200, 'alpha']);
    });

    test('when formatting a nested map then nested values are encoded', () {
      final encoded =
          jsonDecode(
                formatter.format({
                  'id': 'alpha',
                  'nested': {
                    'createdAt': DateTime.utc(2024, 12, 31, 10, 20, 30),
                    'ttl': const Duration(hours: 2),
                  },
                }),
              )
              as Map;

      expect(encoded['id'], 'alpha');
      expect(
        (encoded['nested'] as Map)['createdAt'],
        '2024-12-31T10:20:30.000Z',
      );
      expect((encoded['nested'] as Map)['ttl'], 7200);
    });

    test('when formatting a map with a null field then the field is null', () {
      final encoded = jsonDecode(formatter.format({'id': null})) as Map;

      expect(encoded['id'], isNull);
    });

    test('when formatting an empty list then an empty array is written', () {
      expect(jsonDecode(formatter.format(<String>[])), <Object?>[]);
    });
  });

  group('Given a YAML output formatter', () {
    const formatter = YamlOutputFormatter<Object>();

    test(
      'when formatting a map then DateTime and Duration use the JSON rules',
      () {
        final encoded =
            yamlDecode(
                  formatter.format({
                    'id': 'alpha',
                    'createdAt': DateTime.utc(2024, 12, 31, 10, 20, 30),
                    'ttl': const Duration(hours: 2),
                    'kind': _Kind.alpha,
                  }),
                )
                as Map;

        expect(encoded['id'], 'alpha');
        expect(encoded['createdAt'], '2024-12-31T10:20:30.000Z');
        expect(encoded['ttl'], 7200);
        expect(encoded['kind'], 'alpha');
      },
    );

    test('when formatting a list then the same objects are encoded', () {
      final encoded =
          yamlDecode(
                formatter.format([
                  {
                    'id': 'alpha',
                    'createdAt': DateTime.utc(2024, 12, 31, 10, 20, 30),
                  },
                ]),
              )
              as List;

      expect(encoded, hasLength(1));
      expect((encoded.single as Map)['id'], 'alpha');
      expect((encoded.single as Map)['createdAt'], '2024-12-31T10:20:30.000Z');
    });

    test('when formatting an empty list then an empty array is written', () {
      expect(yamlDecode(formatter.format(<String>[])), <Object?>[]);
    });
  });
}
