import 'package:config/config.dart' show UsageException;
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/top/top_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';

import '../../../test/util/inline_tui/helpers/fake_terminal.dart';
import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  final TestCommandLogger logger = TestCommandLogger();
  final ClientMock client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );
  final CloudCliCommandRunner cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (final GlobalConfiguration globalCfg) {
        return client;
      },
    ),
  );

  tearDown(() {
    logger.clear();
  });

  test('Given the top command when instantiated then requires login', () {
    expect(CloudTopCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given an authenticated user', () {
    group('when executing top with --non-interactive', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'top',
          '--project',
          'my-project',
          '--non-interactive',
        ]);
      });

      test('then throws UsageException', () async {
        await expectLater(
          commandResult,
          throwsA(
            isA<UsageException>().having(
              (final UsageException e) {
                return e.message;
              },
              'message',
              'The top command is interactive and cannot run with --non-interactive.',
            ),
          ),
        );
      });
    });

    group('when executing top without a terminal', () {
      late Future<void> commandResult;

      setUp(() {
        logger.inlineTerminal = FakeTerminal(hasTerminal: false);
        commandResult = cli.run(['top', '--project', 'my-project']);
      });

      test('then throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test(
        'then logs that a terminal is needed, with the alternatives',
        () async {
          await commandResult.catchError((final Object _) {});

          expect(
            logger.errorCalls.single,
            equalsErrorCall(
              message: 'The top command needs an interactive terminal.',
              hint:
                  'Use `scloud status live` and `scloud log` '
                  'in a non-interactive environment.',
            ),
          );
        },
      );

      test('then the project status is not fetched', () async {
        await commandResult.catchError((final Object _) {});

        verifyNever(() {
          return client.status.getCapsuleRuntimeStatus(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
          );
        });
      });
    });
  });
}
