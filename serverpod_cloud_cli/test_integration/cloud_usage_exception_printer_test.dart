import 'package:config/command.dart' show Command;
import 'package:config/config.dart' show OptionDefinition;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/cloud_cli_usage_exception.dart';
import 'package:test/test.dart';

import '../test_utils/test_command_logger.dart';

const _message = 'Invalid amount "59.999".';
const _hint = 'Give the amount in US dollars, such as 60 or 59.99.';

void main() {
  final logger = TestCommandLogger();
  final cli = CloudCliCommandRunner.create(logger: logger);

  tearDown(logger.clear);

  group('Given the cli command runner', () {
    group('when a cloud usage exception with a hint is reported', () {
      setUp(() {
        final command = _versionCommand(cli);
        cli.usageOutput.onUsageException(
          CloudCliUsageException(_message, command, hint: _hint),
          fromCommand: command,
        );
      });

      test(
        'then the error log is the usage exception followed by the hint',
        () {
          final command = _versionCommand(cli);

          expect(logger.errorCalls.map((call) => call.message), [
            _message,
            '',
            command.usage,
            '\n$_hint',
          ]);
        },
      );

      test('then nothing is written to the info log', () {
        expect(logger.infoCalls, isEmpty);
      });
    });

    group('when a cloud usage exception without a hint is reported', () {
      test('then the error log is the usage exception without a hint', () {
        final command = _versionCommand(cli);
        cli.usageOutput.onUsageException(
          CloudCliUsageException(_message, command),
          fromCommand: command,
        );

        expect(logger.errorCalls.map((call) => call.message), [
          _message,
          '',
          command.usage,
        ]);
      });
    });
  });
}

Command<OptionDefinition, void> _versionCommand(CloudCliCommandRunner cli) {
  for (final command in cli.subcommands) {
    if (command.name == 'version') return command;
  }
  throw StateError('The version command is not registered.');
}
