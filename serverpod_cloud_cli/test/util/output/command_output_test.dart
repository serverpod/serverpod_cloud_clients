import 'dart:convert';

import 'package:serverpod_cloud_cli/util/output/command_output.dart';
import 'package:serverpod_cloud_cli/util/output/command_ui.dart';
import 'package:serverpod_cloud_cli/util/output/output_context.dart';
import 'package:serverpod_cloud_cli/util/output/output_format.dart';
import 'package:serverpod_cloud_cli/util/output/output_widget.dart';
import 'package:serverpod_cloud_cli/util/output/text_table_widget.dart';
import 'package:serverpod_cloud_cli/util/output/widgets.dart';
import 'package:test/test.dart';
import 'package:yaml_codec/yaml_codec.dart';

import '../../../test_utils/test_command_logger.dart';

typedef _Item = Map<String, Object?>;

class _ItemListUi extends OutputWidget {
  final bool utc;

  _ItemListUi({required this.utc});

  @override
  OutputWidget build(final OutputContext context) {
    return CommandWidget.text(textOutputUi: _ItemListTextUi(utc: utc));
  }
}

class _ItemListTextUi extends OutputWidget {
  final bool utc;

  _ItemListTextUi({required this.utc});

  @override
  OutputWidget build(final OutputContext context) {
    final objects = context.get<List<_Item>>();
    if (objects.isEmpty) {
      return const InfoTextWidget('No items available.');
    }
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter(
        columns: [
          TableColumnFormatter.forKey('Id', key: 'id'),
          TableColumnFormatter.forKey('Created At', key: 'createdAt'),
          TableColumnFormatter.forKey('Tags', key: 'tags'),
          TableColumnFormatter.forKey('TTL', key: 'ttl'),
        ],
        utc: utc,
      ),
    );
  }
}

class _ItemUi extends OutputWidget {
  @override
  OutputWidget build(final OutputContext context) {
    return CommandWidget.text(textOutputUi: const InfoTextWidget('item'));
  }
}

void main() {
  final createdAt = DateTime.utc(2024, 12, 31, 10, 20, 30);
  final item = <String, Object?>{
    'id': 'alpha',
    'createdAt': createdAt,
    'tags': const ['a', 'b'],
    'ttl': const Duration(hours: 2),
  };
  final items = [item];

  final encodedItem = {
    'id': 'alpha',
    'createdAt': '2024-12-31T10:20:30.000Z',
    'tags': ['a', 'b'],
    'ttl': 7200,
  };

  group('Given text output', () {
    late TestCommandLogger logger;
    late CommandOutput output;

    setUp(() {
      logger = TestCommandLogger();
      output = CommandOutput(format: OutputFormat.text, logger: logger);
    });

    test(
      'when rendering a list then table headers and row values are written',
      () async {
        await output.render(
          operation: () async => items,
          ui: _ItemListUi(utc: true),
        );

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
      'when rendering an empty list then the empty text is written',
      () async {
        await output.render(
          operation: () async => <_Item>[],
          ui: _ItemListUi(utc: true),
        );

        expect(logger.infoCalls, hasLength(1));
        expect(logger.infoCalls.single.message, 'No items available.');
        expect(logger.lineCalls, isEmpty);
        expect(logger.rawCalls, isEmpty);
      },
    );
  });

  group('Given json output', () {
    late TestCommandLogger logger;
    late CommandOutput output;

    setUp(() {
      logger = TestCommandLogger();
      output = CommandOutput(format: OutputFormat.json, logger: logger);
    });

    test(
      'when rendering a list then a JSON array of objects is written',
      () async {
        await output.render(
          operation: () async => items,
          ui: _ItemListUi(utc: true),
        );

        expect(logger.lineCalls, isEmpty);
        expect(logger.rawCalls, hasLength(1));
        expect(jsonDecode(logger.rawCalls.single.content), [encodedItem]);
      },
    );

    test('when rendering an object then a JSON object is written', () async {
      await output.render(operation: () async => item, ui: _ItemUi());

      expect(logger.lineCalls, isEmpty);
      expect(logger.rawCalls, hasLength(1));
      expect(jsonDecode(logger.rawCalls.single.content), encodedItem);
    });

    test(
      'when rendering an empty list then an empty JSON array is written',
      () async {
        await output.render(
          operation: () async => <_Item>[],
          ui: _ItemListUi(utc: true),
        );

        expect(logger.lineCalls, isEmpty);
        expect(jsonDecode(logger.rawCalls.single.content), <Object?>[]);
        expect(logger.infoCalls, isEmpty);
      },
    );
  });

  group('Given yaml output', () {
    late TestCommandLogger logger;
    late CommandOutput output;

    setUp(() {
      logger = TestCommandLogger();
      output = CommandOutput(format: OutputFormat.yaml, logger: logger);
    });

    test('when rendering a list then the same objects are encoded', () async {
      await output.render(
        operation: () async => items,
        ui: _ItemListUi(utc: true),
      );

      expect(logger.lineCalls, isEmpty);
      expect(logger.rawCalls, hasLength(1));
      expect(yamlDecode(logger.rawCalls.single.content), [encodedItem]);
    });

    test('when rendering an object then the same object is encoded', () async {
      await output.render(operation: () async => item, ui: _ItemUi());

      expect(logger.lineCalls, isEmpty);
      expect(logger.rawCalls, hasLength(1));
      expect(yamlDecode(logger.rawCalls.single.content), encodedItem);
    });

    test(
      'when rendering an empty list then an empty YAML array is written',
      () async {
        await output.render(
          operation: () async => <_Item>[],
          ui: _ItemListUi(utc: true),
        );

        expect(logger.lineCalls, isEmpty);
        expect(yamlDecode(logger.rawCalls.single.content), <Object?>[]);
        expect(logger.infoCalls, isEmpty);
      },
    );
  });
}
