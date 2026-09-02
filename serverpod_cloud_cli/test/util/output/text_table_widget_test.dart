import 'package:serverpod_cloud_cli/util/output/output_context.dart';
import 'package:serverpod_cloud_cli/util/output/output_format.dart';
import 'package:serverpod_cloud_cli/util/output/text_table_widget.dart';
import 'package:test/test.dart';

import '../../../test_utils/test_command_logger.dart';

enum _Kind { alpha }

class _Named {
  final String name;

  const _Named(this.name);
}

void main() {
  late TestCommandLogger logger;

  setUp(() {
    logger = TestCommandLogger();
  });

  group('Given a table formatter for item maps', () {
    final createdAt = DateTime.utc(2024, 12, 31, 10, 20, 30);
    final item = <String, Object?>{
      'id': 'alpha',
      'createdAt': createdAt,
      'tags': const ['a', 'b'],
      'ttl': const Duration(hours: 2),
      'kind': _Kind.alpha,
      'expiresAt': null,
    };
    final formatter = TextTableOutputFormatter<Map<String, Object?>>(
      columns: [
        TableColumnFormatter.forKey('Id', key: 'id'),
        TableColumnFormatter.forKey('Created At', key: 'createdAt'),
        TableColumnFormatter.forKey('Tags', key: 'tags'),
        TableColumnFormatter.forKey('TTL', key: 'ttl'),
        TableColumnFormatter.forKey('Kind', key: 'kind'),
        TableColumnFormatter.forKey('Expires', key: 'expiresAt'),
      ],
      utc: true,
    );

    group('when formatting a list with one item', () {
      late TextTableData data;
      late Map<String, String> row;

      setUp(() {
        data = formatter.format([item]);
        row = Map.fromIterables(data.headers, data.rows.single);
      });

      test('then the Id cell is the item id', () {
        expect(row['Id'], 'alpha');
      });

      test('then the Created At cell is the UTC timestamp', () {
        expect(row['Created At'], '2024-12-31 10:20:30z');
      });

      test('then the Tags cell joins the list values', () {
        expect(row['Tags'], 'a, b');
      });

      test('then the TTL cell is a friendly duration', () {
        expect(row['TTL'], '2h');
      });

      test('then the Kind cell is the enumerated name', () {
        expect(row['Kind'], 'alpha');
      });

      test('then the Expires cell is empty when the value is absent', () {
        expect(row['Expires'], '');
      });
    });

    group('when formatting an empty list', () {
      late TextTableData data;

      setUp(() {
        data = formatter.format([]);
      });

      test('then the headers are still produced', () {
        expect(data.headers, contains('Id'));
        expect(data.headers, contains('TTL'));
      });

      test('then there are no rows', () {
        expect(data.rows, isEmpty);
      });
    });
  });

  group('Given a table formatter that uses local timestamps', () {
    final createdAt = DateTime.utc(2024, 12, 31, 10, 20, 30);
    final formatter = TextTableOutputFormatter<Map<String, Object?>>(
      columns: [TableColumnFormatter.forKey('Created At', key: 'createdAt')],
      utc: false,
    );

    test('when formatting a DateTime then the cell has no UTC suffix', () {
      final data = formatter.format([
        {'createdAt': createdAt},
      ]);
      final row = Map.fromIterables(data.headers, data.rows.single);

      expect(row['Created At'], isNot(endsWith('z')));
      expect(row['Created At'], isNot(endsWith('Z')));
    });
  });

  group('Given a table formatter for named elements', () {
    final formatter = TextTableOutputFormatter<_Named>(
      columns: [
        TableColumnFormatter.forElement('Name', getter: (named) => named.name),
      ],
      utc: false,
    );

    test('when formatting two rows then both names are present', () {
      final data = formatter.format(const [_Named('alpha'), _Named('beta')]);

      expect(data.rows, [
        ['alpha'],
        ['beta'],
      ]);
    });
  });

  group('Given a formatted table widget', () {
    test('when rendered then table headers and row values are written', () {
      final createdAt = DateTime.utc(2024, 12, 31, 10, 20, 30);
      final context = OutputContext(OutputFormat.text, <Map<String, Object?>>[
        {
          'id': 'alpha',
          'createdAt': createdAt,
          'tags': const ['a', 'b'],
          'ttl': const Duration(hours: 2),
        },
      ]);

      FormattedTableWidget(
        formatter: TextTableOutputFormatter(
          columns: [
            TableColumnFormatter.forKey('Id', key: 'id'),
            TableColumnFormatter.forKey('Created At', key: 'createdAt'),
            TableColumnFormatter.forKey('Tags', key: 'tags'),
            TableColumnFormatter.forKey('TTL', key: 'ttl'),
          ],
          utc: true,
        ),
      ).buildTree(context).renderTree(logger: logger);

      expect(logger.lineCalls.first.line, contains('Id'));
      expect(logger.lineCalls.first.line, contains('Created At'));
      expect(logger.lineCalls.first.line, contains('Tags'));
      expect(logger.lineCalls.first.line, contains('TTL'));
      expect(logger.lineCalls.last.line, contains('alpha'));
      expect(logger.lineCalls.last.line, contains('2024-12-31 10:20:30z'));
      expect(logger.lineCalls.last.line, contains('a, b'));
      expect(logger.lineCalls.last.line, contains('2h'));
      expect(logger.rawCalls, isEmpty);
    });
  });

  group('Given a text table widget', () {
    test('when rendered then the supplied headers and rows are written', () {
      TextTableWidget(
        TextTableData(
          ['Name', 'Value'],
          [
            ['alpha', 'one'],
          ],
        ),
      ).render(logger: logger);

      expect(logger.lineCalls.first.line, contains('Name'));
      expect(logger.lineCalls.first.line, contains('Value'));
      expect(logger.lineCalls.last.line, contains('alpha'));
      expect(logger.lineCalls.last.line, contains('one'));
    });
  });

  group('Given a string-column list widget', () {
    test('when rendered then the heading and values are written', () {
      final context = OutputContext(OutputFormat.text, <String>[
        'alpha',
        'beta',
      ]);

      const StringColumnListWidget(
        heading: 'Name',
      ).buildTree(context).renderTree(logger: logger);

      final lines = logger.lineCalls.map((call) => call.line).join('\n');
      expect(lines, contains('Name'));
      expect(lines, contains('alpha'));
      expect(lines, contains('beta'));
    });
  });
}
