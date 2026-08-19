import 'dart:convert';

import 'package:serverpod_cloud_cli/util/output/command_output.dart';
import 'package:test/test.dart';
import 'package:yaml_codec/yaml_codec.dart';

import '../../../test_utils/test_command_logger.dart';

class _Item {
  _Item({
    required this.id,
    required this.createdAt,
    this.tags = const [],
    this.ttl,
  });

  final String id;
  final DateTime createdAt;
  final List<String> tags;
  final Duration? ttl;
}

void main() {
  final createdAt = DateTime.utc(2024, 12, 31, 10, 20, 30);
  final item = _Item(
    id: 'alpha',
    createdAt: createdAt,
    tags: const ['a', 'b'],
    ttl: const Duration(hours: 2),
  );
  final items = [item];

  OutputSchemaObject<_Item> itemSchema() {
    return OutputSchemaObject([
      OutputSchemaField(
        name: 'id',
        label: 'Id',
        value: (final item) => item.id,
      ),
      OutputSchemaField(
        name: 'createdAt',
        label: 'Created At',
        value: (final item) => item.createdAt,
      ),
      OutputSchemaField(
        name: 'tags',
        label: 'Tags',
        value: (final item) => item.tags,
      ),
      OutputSchemaField(
        name: 'ttl',
        label: 'TTL',
        value: (final item) => item.ttl,
      ),
    ]);
  }

  group('Given table output', () {
    late TestCommandLogger logger;
    late CommandOutput output;

    setUp(() {
      logger = TestCommandLogger();
      output = TextOutput(logger: logger, utc: true);
    });

    test(
      'when outputting items then table headers and row values are written',
      () {
        output.outputList(items, itemSchema());

        expect(logger.lineCalls, hasLength(3));
        expect(logger.lineCalls[0].line, contains('Id'));
        expect(logger.lineCalls[0].line, contains('Created At'));
        expect(logger.lineCalls[0].line, contains('Tags'));
        expect(logger.lineCalls[0].line, contains('TTL'));
        expect(logger.lineCalls[2].line, contains('alpha'));
        expect(logger.lineCalls[2].line, contains('2024-12-31 10:20:30z'));
        expect(logger.lineCalls[2].line, contains('a, b'));
        expect(logger.lineCalls[2].line, contains('2h'));
        expect(logger.rawCalls, isEmpty);
      },
    );

    test(
      'when outputting an object then table headers and row values are written',
      () {
        output.outputObject(item, itemSchema());

        expect(logger.lineCalls, hasLength(3));
        expect(logger.lineCalls[0].line, contains('Id'));
        expect(logger.lineCalls[0].line, contains('Created At'));
        expect(logger.lineCalls[0].line, contains('Tags'));
        expect(logger.lineCalls[0].line, contains('TTL'));
        expect(logger.lineCalls[2].line, contains('alpha'));
        expect(logger.lineCalls[2].line, contains('2024-12-31 10:20:30z'));
        expect(logger.lineCalls[2].line, contains('a, b'));
        expect(logger.lineCalls[2].line, contains('2h'));
        expect(logger.rawCalls, isEmpty);
      },
    );

    test(
      'when outputting an empty list with onEmpty then onEmpty is called',
      () {
        var onEmptyCalled = false;
        output.outputList(
          <_Item>[],
          itemSchema(),
          onEmpty: (final _) => onEmptyCalled = true,
        );

        expect(onEmptyCalled, isTrue);
        expect(logger.lineCalls, isEmpty);
        expect(logger.rawCalls, isEmpty);
      },
    );

    test('when reporting an error then the logger error is used', () {
      output.error('Failed to list items.', hint: 'Try again.');

      expect(logger.errorCalls, hasLength(1));
      expect(logger.errorCalls.single.message, 'Failed to list items.');
      expect(logger.errorCalls.single.hint, 'Try again.');
      // expect(logger.structuredErrorCalls, isEmpty);  // TODO
    });
  });

  group('Given json output', () {
    late TestCommandLogger logger;
    late CommandOutput output;

    setUp(() {
      logger = TestCommandLogger();
      output = JsonOutput(logger: logger);
    });

    test(
      'when outputting items then a JSON array of field maps is written',
      () {
        output.outputList(items, itemSchema());

        expect(logger.lineCalls, isEmpty);
        expect(logger.rawCalls, hasLength(1));
        expect(jsonDecode(logger.rawCalls.single.content), [
          {
            'id': 'alpha',
            'createdAt': '2024-12-31T10:20:30.000Z',
            'tags': ['a', 'b'],
            'ttl': 7200,
          },
        ]);
      },
    );

    test('when outputting an object then a JSON field map is written', () {
      output.outputObject(item, itemSchema());

      expect(logger.lineCalls, isEmpty);
      expect(logger.rawCalls, hasLength(1));
      expect(jsonDecode(logger.rawCalls.single.content), {
        'id': 'alpha',
        'createdAt': '2024-12-31T10:20:30.000Z',
        'tags': ['a', 'b'],
        'ttl': 7200,
      });
    });

    test(
      'when outputting an empty list then an empty JSON array is written',
      () {
        output.outputList(<_Item>[], itemSchema());

        expect(jsonDecode(logger.rawCalls.single.content), <Object?>[]);
      },
    );

    test(
      'when outputting an empty list with onEmpty then onEmpty is ignored',
      () {
        var onEmptyCalled = false;
        output.outputList(
          <_Item>[],
          itemSchema(),
          onEmpty: (final _) => onEmptyCalled = true,
        );

        expect(onEmptyCalled, isFalse);
        expect(jsonDecode(logger.rawCalls.single.content), <Object?>[]);
      },
    );

    test('when reporting an error then a JSON error object is written', () {
      output.error('Failed to list items.', hint: 'Try again.', exitCode: 2);

      expect(logger.rawCalls, hasLength(1));
      expect(
        logger.rawCalls.single.content,
        jsonEncode({
          'message': 'Failed to list items.',
          'hint': 'Try again.',
          'exitCode': 2,
        }),
      );
    });
  });

  group('Given yaml output', () {
    late TestCommandLogger logger;
    late CommandOutput output;

    setUp(() {
      logger = TestCommandLogger();
      output = YamlOutput(logger: logger);
    });

    test('when outputting items then the same field maps are encoded', () {
      output.outputList(items, itemSchema());

      expect(logger.rawCalls, hasLength(1));
      final payload =
          yamlDecode(logger.rawCalls.single.content) as List<dynamic>;
      expect(payload, hasLength(1));
      final first = payload.first as Map<dynamic, dynamic>;
      expect(first['id'], 'alpha');
      expect(first['createdAt'], '2024-12-31T10:20:30.000Z');
      expect(first['ttl'], 7200);
    });

    test('when outputting an object then the same field map is encoded', () {
      output.outputObject(item, itemSchema());

      expect(logger.rawCalls, hasLength(1));
      final payload =
          yamlDecode(logger.rawCalls.single.content) as Map<dynamic, dynamic>;
      expect(payload['id'], 'alpha');
      expect(payload['createdAt'], '2024-12-31T10:20:30.000Z');
      expect(payload['ttl'], 7200);
    });
  });

  group('Given CommandOutput.forFormat', () {
    late TestCommandLogger logger;

    setUp(() {
      logger = TestCommandLogger();
    });

    test('when format is table then a TableOutput is returned', () {
      expect(
        CommandOutput.forFormat(OutputFormat.text, logger),
        isA<TextOutput>(),
      );
    });

    test('when format is json then a JsonOutput is returned', () {
      expect(
        CommandOutput.forFormat(OutputFormat.json, logger),
        isA<JsonOutput>(),
      );
    });

    test('when utc is set then a TableOutput with utc is returned', () {
      expect(
        CommandOutput.forFormat(OutputFormat.text, logger, utc: true),
        isA<TextOutput>().having((final o) => o.utc, 'utc', isTrue),
      );
    });

    test('when utc is set on json then a JsonOutput is returned', () {
      expect(
        CommandOutput.forFormat(OutputFormat.json, logger, utc: true),
        isA<JsonOutput>(),
      );
    });
  });
}
