import 'package:config/command.dart';
import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/cloud_cli_usage_exception.dart';
import 'package:test/test.dart';

const _message = 'Invalid amount "59.999".';
const _hint = 'Give the amount in US dollars, such as 60 or 59.99.';

void main() {
  late Command<OptionDefinition, void> command;

  setUp(() {
    final runner = CommandRunner<OptionDefinition, void>(
      'tool',
      'A tool.',
      completion: const CompletionSettings(enabled: false),
    );
    command = CommandImpl.leafWithRunFunction<OptionDefinition, void>(
      name: 'greet',
      description: 'Says hello.',
      run: (_) {},
    );
    runner.addSubcommand(command);
  });

  group('Given the cloud usage exception printer', () {
    group('when printing a cloud usage exception with a hint', () {
      late CloudCliUsageException exception;

      setUp(() {
        exception = CloudCliUsageException(_message, command, hint: _hint);
      });

      test(
        'then the error is the standard usage text followed by the hint',
        () {
          expect(
            _printed(exception),
            '${_standardPrinted(exception)}\n$_hint\n',
          );
        },
      );

      test('then nothing is written to standard output', () {
        final out = StringBuffer();
        CloudUsageExceptionPrinter().printException(
          exception,
          usageOutput: UsageOutputHandler(
            sinks: OutputSinks(out: out, err: StringBuffer()),
          ),
          fromCommand: command,
        );

        expect(out.toString(), isEmpty);
      });
    });

    group('when printing a cloud usage exception without a hint', () {
      test('then the error matches the standard usage exception', () {
        final exception = CloudCliUsageException(_message, command);

        expect(_printed(exception), _standardPrinted(exception));
      });
    });

    group('when printing a command usage exception', () {
      test('then the error matches the standard usage exception', () {
        final exception = CommandUsageException(_message, command);

        expect(_printed(exception), _standardPrinted(exception));
      });
    });

    group('when printing a usage exception that names another command', () {
      test('then the error matches the standard usage exception', () {
        final exception = UsageException('bad input', 'Try --help.');

        expect(
          _printed(exception, fromCommand: command),
          _standardPrinted(exception, fromCommand: command),
        );
      });
    });
  });
}

String _printed(
  UsageException exception, {
  UsageExceptionPrinter? printer,
  CommandDefinition? fromCommand,
}) {
  final err = StringBuffer();
  (printer ?? CloudUsageExceptionPrinter()).printException(
    exception,
    usageOutput: UsageOutputHandler(sinks: OutputSinks(err: err)),
    fromCommand: fromCommand,
  );
  return err.toString();
}

String _standardPrinted(
  UsageException exception, {
  CommandDefinition? fromCommand,
}) {
  return _printed(
    exception,
    printer: const StandardUsageExceptionPrinter(),
    fromCommand: fromCommand,
  );
}
