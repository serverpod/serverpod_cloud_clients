import 'package:config/command.dart' show CommandContext;
import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;
import 'package:serverpod_cloud_cli/util/scloud_version.dart';
import 'package:test/test.dart';

import '../test_utils/command_logger_matchers.dart';
import '../test_utils/test_command_logger.dart';

void main() async {
  final logger = TestCommandLogger();

  final cli = CloudCliCommandRunner.create(logger: logger);

  tearDown(() {
    logger.clear();
  });

  group('Given a cli command runner when running the help command', () {
    setUp(() async {
      await cli.run(['help']);
    });

    test('then the help is printed.', () {
      expect(logger.infoCalls, isNotEmpty);
      expect(
        logger.infoCalls.first.message,
        startsWith('Manage your Serverpod Cloud projects'),
      );
    });

    test(
      'then the version command description included in the help message.',
      () {
        expect(logger.infoCalls, isNotEmpty);
        expect(
          logger.infoCalls.first.message,
          contains('Prints the version of the Serverpod Cloud CLI.'),
        );
      },
    );
  });

  test(
    'Given a cli command runner when running the version command then the version is printed.',
    () async {
      await cli.run(['version']);
      expect(logger.infoCalls, isNotEmpty);
      expect(
        logger.infoCalls.first,
        equalsInfoCall(message: 'Serverpod Cloud CLI version: $cliVersion'),
      );
    },
  );
  group('Given a cli command runner '
      'when running any command with the auth token option ', () {
    late _ContextRecordingCommand command;

    setUp(() async {
      command = _ContextRecordingCommand(logger: logger);
      final runner = CloudCliCommandRunner.create(logger: logger)
        ..addCommand(command);
      await runner.run([command.name, '--token', 'test-token']);
    });

    test('then the auth token is set in the global configuration.', () {
      expect(command.globalConfiguration.authToken, 'test-token');
    });

    test(
      'then the auth token is set in the authentication key manager.',
      () async {
        await expectLater(
          command.authHeaderValue,
          completion('Bearer test-token'),
        );
      },
    );
  });

  test('Given a cli command runner when generating its usage '
      'then one empty line precedes the documentation link.', () {
    expect(
      cli.usage,
      endsWith(
        'Run "scloud help <command>" for more information about a command.\n'
        '\n'
        'See the full documentation at: https://docs.serverpod.dev/cloud\n',
      ),
    );
  });
}

class _ContextRecordingCommand extends CloudCliCommand {
  late GlobalConfiguration globalConfiguration;
  Future<String?>? authHeaderValue;

  @override
  final String name = 'record-context';

  @override
  final String description = 'Records the resolved command context.';

  @override
  bool get requireLogin => false;

  @override
  bool get warnIfBillingOverdue => false;

  _ContextRecordingCommand({required super.logger});

  @override
  Future<void> runWithOutput(
    final CommandContext<OptionDefinition, void> context,
    final CommandOutput output,
  ) async {
    globalConfiguration = context.globalConfiguration;
    authHeaderValue =
        context.serviceProvider.cloudApiClient.authKeyProvider?.authHeaderValue;
  }
}
