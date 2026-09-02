import 'dart:convert';

import 'package:serverpod_cloud_cli/util/output/command_output.dart';
import 'package:serverpod_cloud_cli/util/output/interactive_widgets.dart';
import 'package:serverpod_cloud_cli/util/output/output_context.dart';
import 'package:serverpod_cloud_cli/util/output/output_format.dart';
import 'package:serverpod_cloud_cli/util/output/output_formatter.dart';
import 'package:serverpod_cloud_cli/util/output/widgets.dart';
import 'package:test/test.dart';
import 'package:yaml_codec/yaml_codec.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  late TestCommandLogger logger;

  setUp(() {
    logger = TestCommandLogger();
  });

  group('Given a successful string operation', () {
    late CommandOutput output;
    late OutputContext context;

    setUp(() async {
      output = CommandOutput(format: OutputFormat.text, logger: logger);
      context = await output.render(
        operation: () async => 'hello',
        ui: const InfoTextWidget('rendered'),
      );
    });

    test('when rendering then the widget is written', () {
      expect(logger.infoCalls, [equalsInfoCall(message: 'rendered')]);
    });

    test('when rendering then the returned context contains the result', () {
      expect(context.get<String>(), 'hello');
    });

    test('when rendering then the returned context has no error', () {
      expect(context.find<QualifiedException>(), isNull);
    });

    test(
      'when rendering then the returned context keeps the output format',
      () {
        expect(context.format, OutputFormat.text);
      },
    );
  });

  group('Given text output and a format-branching widget', () {
    late CommandOutput output;

    setUp(() {
      output = CommandOutput(format: OutputFormat.text, logger: logger);
    });

    test('when rendering then the text branch is written', () async {
      await output.render(
        operation: () async => 'unused',
        ui: const FormatBranchingWidget(
          textWidget: InfoTextWidget('text'),
          jsonWidget: InfoTextWidget('json'),
          yamlWidget: InfoTextWidget('yaml'),
        ),
      );

      expect(logger.infoCalls, [equalsInfoCall(message: 'text')]);
    });
  });

  group('Given json output', () {
    late CommandOutput output;

    setUp(() {
      output = CommandOutput(format: OutputFormat.json, logger: logger);
    });

    test(
      'when rendering a format-branching widget then the json branch is written',
      () async {
        await output.render(
          operation: () async => 'unused',
          ui: const FormatBranchingWidget(
            textWidget: InfoTextWidget('text'),
            jsonWidget: InfoTextWidget('json'),
            yamlWidget: InfoTextWidget('yaml'),
          ),
        );

        expect(logger.infoCalls, [equalsInfoCall(message: 'json')]);
      },
    );

    test(
      'when rendering a list then a JSON array of objects is written',
      () async {
        final createdAt = DateTime.utc(2024, 12, 31, 10, 20, 30);
        await output.render(
          operation: () async => <Map<String, Object?>>[
            {
              'id': 'alpha',
              'createdAt': createdAt,
              'tags': const ['a', 'b'],
              'ttl': const Duration(hours: 2),
            },
          ],
          ui: FormattedStringWidget(
            formatter: JsonOutputFormatter<List<Map<String, Object?>>>(),
          ),
        );

        expect(logger.lineCalls, isEmpty);
        expect(logger.infoCalls, isEmpty);
        final payload = jsonDecode(logger.rawCalls.single.content) as List;
        expect(payload, hasLength(1));
        expect((payload.single as Map)['id'], 'alpha');
        expect(
          (payload.single as Map)['createdAt'],
          '2024-12-31T10:20:30.000Z',
        );
        expect((payload.single as Map)['tags'], ['a', 'b']);
        expect((payload.single as Map)['ttl'], 7200);
      },
    );

    test('when rendering an object then a JSON object is written', () async {
      final createdAt = DateTime.utc(2024, 12, 31, 10, 20, 30);
      await output.render(
        operation: () async => <String, Object?>{
          'id': 'alpha',
          'createdAt': createdAt,
          'ttl': const Duration(hours: 2),
        },
        ui: FormattedStringWidget(
          formatter: JsonOutputFormatter<Map<String, Object?>>(),
        ),
      );

      expect(logger.lineCalls, isEmpty);
      final payload = jsonDecode(logger.rawCalls.single.content) as Map;
      expect(payload['id'], 'alpha');
      expect(payload['createdAt'], '2024-12-31T10:20:30.000Z');
      expect(payload['ttl'], 7200);
    });

    test(
      'when rendering an empty list then an empty JSON array is written',
      () async {
        await output.render(
          operation: () async => <Map<String, Object?>>[],
          ui: FormattedStringWidget(
            formatter: JsonOutputFormatter<List<Map<String, Object?>>>(),
          ),
        );

        expect(logger.lineCalls, isEmpty);
        expect(logger.infoCalls, isEmpty);
        expect(jsonDecode(logger.rawCalls.single.content), <Object?>[]);
      },
    );
  });

  group('Given yaml output', () {
    late CommandOutput output;

    setUp(() {
      output = CommandOutput(format: OutputFormat.yaml, logger: logger);
    });

    test(
      'when rendering a format-branching widget then the yaml branch is written',
      () async {
        await output.render(
          operation: () async => 'unused',
          ui: const FormatBranchingWidget(
            textWidget: InfoTextWidget('text'),
            jsonWidget: InfoTextWidget('json'),
            yamlWidget: InfoTextWidget('yaml'),
          ),
        );

        expect(logger.infoCalls, [equalsInfoCall(message: 'yaml')]);
      },
    );

    test('when rendering a list then the same objects are encoded', () async {
      final createdAt = DateTime.utc(2024, 12, 31, 10, 20, 30);
      await output.render(
        operation: () async => <Map<String, Object?>>[
          {
            'id': 'alpha',
            'createdAt': createdAt,
            'ttl': const Duration(hours: 2),
          },
        ],
        ui: FormattedStringWidget(
          formatter: YamlOutputFormatter<List<Map<String, Object?>>>(),
        ),
      );

      expect(logger.lineCalls, isEmpty);
      final payload = yamlDecode(logger.rawCalls.single.content) as List;
      expect(payload, hasLength(1));
      expect((payload.single as Map)['id'], 'alpha');
      expect((payload.single as Map)['createdAt'], '2024-12-31T10:20:30.000Z');
      expect((payload.single as Map)['ttl'], 7200);
    });

    test('when rendering an object then the same object is encoded', () async {
      await output.render(
        operation: () async => <String, Object?>{'id': 'alpha'},
        ui: FormattedStringWidget(
          formatter: YamlOutputFormatter<Map<String, Object?>>(),
        ),
      );

      expect(logger.lineCalls, isEmpty);
      expect(yamlDecode(logger.rawCalls.single.content), {'id': 'alpha'});
    });

    test(
      'when rendering an empty list then an empty YAML array is written',
      () async {
        await output.render(
          operation: () async => <Map<String, Object?>>[],
          ui: FormattedStringWidget(
            formatter: YamlOutputFormatter<List<Map<String, Object?>>>(),
          ),
        );

        expect(logger.lineCalls, isEmpty);
        expect(logger.infoCalls, isEmpty);
        expect(yamlDecode(logger.rawCalls.single.content), <Object?>[]);
      },
    );
  });

  group('Given an operation that throws an exception', () {
    late CommandOutput output;
    late OutputContext context;

    setUp(() async {
      output = CommandOutput(format: OutputFormat.text, logger: logger);
      context = await output.render(
        operation: () async => throw FormatException('boom'),
        ui: ExceptionHandlingWidget(
          errorWidgetMaker: (e) => const InfoTextWidget('failed'),
          elseWidget: const InfoTextWidget('ok'),
        ),
      );
    });

    test('when rendering then the error branch is written', () {
      expect(logger.infoCalls, [equalsInfoCall(message: 'failed')]);
    });

    test('when rendering then the returned context contains the exception', () {
      final error = context.get<QualifiedException>();
      expect(error.exception, isA<FormatException>());
      expect(error.exception.toString(), contains('boom'));
    });
  });

  group('Given an operation that throws an Error', () {
    late CommandOutput output;

    setUp(() {
      output = CommandOutput(format: OutputFormat.text, logger: logger);
    });

    test('when rendering then the error is not captured', () async {
      await expectLater(
        output.render(
          operation: () async => throw ArgumentError('bad'),
          ui: const InfoTextWidget('unused'),
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(logger.infoCalls, isEmpty);
    });
  });

  group('Given an interactive confirmation', () {
    late CommandOutput output;

    setUp(() {
      output = CommandOutput(format: OutputFormat.text, logger: logger);
    });

    test('when the user confirms then the result is true', () async {
      logger.answerNextConfirmWith(true);

      final confirmed = await output.renderInteractive(
        ui: ConfirmationWidget('Continue?', defaultValue: false),
      );

      expect(confirmed, isTrue);
      expect(logger.confirmCalls, [
        equalsConfirmCall(message: 'Continue?', defaultValue: false),
      ]);
    });
  });
}
