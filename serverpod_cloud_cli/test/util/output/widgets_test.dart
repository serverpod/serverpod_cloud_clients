import 'dart:convert';

import 'package:serverpod_cloud_cli/util/output/output_context.dart';
import 'package:serverpod_cloud_cli/util/output/output_format.dart';
import 'package:serverpod_cloud_cli/util/output/output_formatter.dart';
import 'package:serverpod_cloud_cli/util/output/output_widget.dart';
import 'package:serverpod_cloud_cli/util/output/widgets.dart';
import 'package:test/test.dart';
import 'package:yaml_codec/yaml_codec.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/test_command_logger.dart';

class _HandledException implements Exception {
  @override
  String toString() => 'handled-error';
}

class _UnhandledException implements Exception {
  @override
  String toString() => 'unhandled-error';
}

void main() {
  late TestCommandLogger logger;

  setUp(() {
    logger = TestCommandLogger();
  });

  group('Given a format-branching widget', () {
    const widget = FormatBranchingWidget(
      textWidget: InfoTextWidget('text'),
      jsonWidget: InfoTextWidget('json'),
      yamlWidget: InfoTextWidget('yaml'),
    );

    test('when the format is text then the text widget is written', () {
      widget
          .buildTree(OutputContext(OutputFormat.text))
          .renderTree(logger: logger);

      expect(logger.infoCalls, [equalsInfoCall(message: 'text')]);
    });

    test('when the format is json then the json widget is written', () {
      widget
          .buildTree(OutputContext(OutputFormat.json))
          .renderTree(logger: logger);

      expect(logger.infoCalls, [equalsInfoCall(message: 'json')]);
    });

    test('when the format is yaml then the yaml widget is written', () {
      widget
          .buildTree(OutputContext(OutputFormat.yaml))
          .renderTree(logger: logger);

      expect(logger.infoCalls, [equalsInfoCall(message: 'yaml')]);
    });
  });

  group('Given an error-branching widget', () {
    final widget = ExceptionHandlingWidget(
      errorWidgetMaker: (final e) => InfoTextWidget('failed'),
      elseWidget: InfoTextWidget('ok'),
    );

    test(
      'when the context has no error then the success widget is written',
      () {
        widget
            .buildTree(OutputContext(OutputFormat.text, 'data'))
            .renderTree(logger: logger);

        expect(logger.infoCalls, [equalsInfoCall(message: 'ok')]);
      },
    );

    test('when the context has an error then the error widget is written', () {
      widget
          .buildTree(
            OutputContext.exception(
              OutputFormat.text,
              FormatException('boom'),
              StackTrace.current,
            ),
          )
          .renderTree(logger: logger);

      expect(logger.infoCalls, [equalsInfoCall(message: 'failed')]);
    });
  });

  group('Given an exception-handling widget for a handled exception', () {
    final widget = ExceptionHandlingWidget<_HandledException>(
      errorWidgetMaker: (final e) => InfoTextWidget('handled'),
    );

    test(
      'when the context holds that exception then the error widget is written',
      () {
        widget
            .buildTree(
              OutputContext.exception(
                OutputFormat.text,
                _HandledException(),
                StackTrace.current,
              ),
            )
            .renderTree(logger: logger);

        expect(logger.infoCalls, [equalsInfoCall(message: 'handled')]);
      },
    );

    test(
      'when the context holds a different exception then nothing is written',
      () {
        widget
            .buildTree(
              OutputContext.exception(
                OutputFormat.text,
                _UnhandledException(),
                StackTrace.current,
              ),
            )
            .renderTree(logger: logger);

        expect(logger.infoCalls, isEmpty);
      },
    );

    test('when the context has no error then nothing is written', () {
      widget
          .buildTree(OutputContext(OutputFormat.text))
          .renderTree(logger: logger);

      expect(logger.infoCalls, isEmpty);
    });
  });

  group('Given a raw string widget', () {
    test('when rendered then the content is written as raw output', () {
      const RawStringWidget('payload').render(logger: logger);

      expect(logger.rawCalls.single.content, 'payload');
    });
  });

  group('Given an info text widget', () {
    test('when rendered then the message is written as info', () {
      const InfoTextWidget('No items available.').render(logger: logger);

      expect(logger.infoCalls, [
        equalsInfoCall(message: 'No items available.'),
      ]);
    });

    test(
      'when rendered with a new paragraph then the info call starts a paragraph',
      () {
        const InfoTextWidget(
          'No items available.',
          newParagraph: true,
        ).render(logger: logger);

        expect(logger.infoCalls, [
          equalsInfoCall(message: 'No items available.', newParagraph: true),
        ]);
      },
    );
  });

  group('Given a success text widget', () {
    test('when rendered then the message is written as success', () {
      const SuccessTextWidget('Created.').render(logger: logger);

      expect(logger.successCalls, [equalsSuccessCall(message: 'Created.')]);
    });

    test(
      'when rendered with a new paragraph then the success call starts a paragraph',
      () {
        const SuccessTextWidget(
          'Created.',
          newParagraph: true,
        ).render(logger: logger);

        expect(logger.successCalls, [
          equalsSuccessCall(message: 'Created.', newParagraph: true),
        ]);
      },
    );
  });

  group('Given a command-hint text widget', () {
    test('when rendered then the command and message are written', () {
      const CommandHintTextWidget(
        'Create a project first.',
        command: 'scloud project create',
      ).render(logger: logger);

      expect(logger.terminalCommandCalls, [
        equalsTerminalCommandCall(
          command: 'scloud project create',
          message: 'Create a project first.',
        ),
      ]);
    });

    test(
      'when rendered without a message then only the command is written',
      () {
        const CommandHintTextWidget.command(
          'scloud auth login',
        ).render(logger: logger);

        expect(logger.terminalCommandCalls, [
          equalsTerminalCommandCall(command: 'scloud auth login'),
        ]);
      },
    );
  });

  group('Given a widget list', () {
    test('when rendered then the children are written in order', () {
      const OutputWidgetList([
        InfoTextWidget('first'),
        InfoTextWidget('second'),
      ]).buildTree(OutputContext(OutputFormat.text)).renderTree(logger: logger);

      expect(logger.infoCalls, [
        equalsInfoCall(message: 'first'),
        equalsInfoCall(message: 'second'),
      ]);
    });
  });

  group('Given a formatted string widget', () {
    test(
      'when rendered then the formatted object is written as raw output',
      () {
        final context = OutputContext(OutputFormat.json, {
          'id': 'alpha',
          'createdAt': DateTime.utc(2024, 12, 31, 10, 20, 30),
        });

        FormattedStringWidget(
          formatter: JsonOutputFormatter<Map<String, Object?>>(),
        ).buildTree(context).renderTree(logger: logger);

        expect(logger.lineCalls, isEmpty);
        final payload = jsonDecode(logger.rawCalls.single.content) as Map;
        expect(payload['id'], 'alpha');
        expect(payload['createdAt'], '2024-12-31T10:20:30.000Z');
      },
    );

    test('when the object is missing from the context then building fails', () {
      expect(
        () => FormattedStringWidget(
          formatter: JsonOutputFormatter<String>(),
        ).buildTree(OutputContext(OutputFormat.json)),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('Given a text error widget', () {
    test(
      'when the context holds an exception then it is written as an error',
      () {
        const TextErrorWidget()
            .buildTree(
              OutputContext.exception(
                OutputFormat.text,
                FormatException('boom'),
                StackTrace.current,
              ),
            )
            .renderTree(logger: logger);

        expect(logger.errorCalls, hasLength(1));
        expect(logger.errorCalls.single.message, contains('boom'));
      },
    );

    test('when the context has no error then building fails', () {
      expect(
        () =>
            const TextErrorWidget().buildTree(OutputContext(OutputFormat.text)),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('Given a text error output widget', () {
    test('when rendered with a message then that message is written', () {
      const TextErrorOutputWidget(
        'ignored',
        message: 'The requested resource did not exist.',
      ).render(logger: logger);

      expect(logger.errorCalls, [
        equalsErrorCall(message: 'The requested resource did not exist.'),
      ]);
    });

    test('when rendered with a hint then the hint is written', () {
      const TextErrorOutputWidget(
        'The requested resource did not exist.',
        hint: 'No such project.',
      ).render(logger: logger);

      expect(logger.errorCalls, [
        equalsErrorCall(
          message: 'The requested resource did not exist.',
          hint: 'No such project.',
        ),
      ]);
    });

    test(
      'when rendered with a new paragraph then the error call starts a paragraph',
      () {
        const TextErrorOutputWidget(
          'You need a payment method!',
          hint: 'To set up your account, visit: https://example.com\n',
          newParagraph: true,
        ).render(logger: logger);

        expect(logger.errorCalls, [
          equalsErrorCall(
            message: 'You need a payment method!',
            hint: 'To set up your account, visit: https://example.com\n',
            newParagraph: true,
          ),
        ]);
      },
    );
  });

  group('Given a json error widget', () {
    test(
      'when the context holds an exception then a JSON error is written',
      () {
        const JsonErrorWidget()
            .buildTree(
              OutputContext.exception(
                OutputFormat.json,
                FormatException('boom'),
                StackTrace.current,
              ),
            )
            .renderTree(logger: logger);

        expect(logger.errorCalls, hasLength(1));
        expect(logger.errorCalls.single.message, contains('boom'));
        expect(jsonDecode(logger.errorCalls.single.message), contains('boom'));
      },
    );
  });

  group('Given a yaml error widget', () {
    test(
      'when the context holds an exception then a YAML error is written',
      () {
        const YamlErrorWidget()
            .buildTree(
              OutputContext.exception(
                OutputFormat.yaml,
                FormatException('boom'),
                StackTrace.current,
              ),
            )
            .renderTree(logger: logger);

        expect(logger.errorCalls, hasLength(1));
        expect(logger.errorCalls.single.message, contains('boom'));
        expect(yamlDecode(logger.errorCalls.single.message), contains('boom'));
      },
    );
  });
}
