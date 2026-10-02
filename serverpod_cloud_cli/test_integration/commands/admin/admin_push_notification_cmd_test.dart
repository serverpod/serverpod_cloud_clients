import 'dart:async';
import 'dart:convert';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/notification/admin_test_push_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';
import 'package:yaml_codec/yaml_codec.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (globalCfg) => client,
    ),
    adminUserMode: true,
  );

  tearDown(() {
    logger.clear();
    reset(client.adminTest);
  });

  test(
    'Given admin test-push command when instantiated then requires login',
    () {
      expect(AdminTestPushCommand(logger: logger).requireLogin, isTrue);
    },
  );

  group('Given authenticated', () {
    group('when executing admin test-push', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.adminTest.pushNotification(any()),
        ).thenAnswer((_) async {});

        commandResult = cli.run(['admin', 'test-push', 'test']);
      });

      test('then command completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then the notification type is pushed', () async {
        await commandResult;

        verify(() => client.adminTest.pushNotification('test')).called(1);
      });

      test('then command logs success', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.successCalls,
          contains(
            equalsSuccessCall(
              message: 'Pushed an example test notification.',
              newParagraph: true,
            ),
          ),
        );
      });
    });

    group('when executing admin test-push with --format json', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.adminTest.pushNotification(any()),
        ).thenAnswer((_) async {});

        commandResult = cli.run([
          'admin',
          'test-push',
          'invoice-failed',
          '--format',
          'json',
        ]);
      });

      test('then emits the notification type', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(jsonDecode(logger.rawCalls.single.content), {
          'notificationType': 'invoice-failed',
        });
      });
    });

    group('when executing admin test-push with --format yaml', () {
      late Future commandResult;

      setUp(() async {
        when(
          () => client.adminTest.pushNotification(any()),
        ).thenAnswer((_) async {});

        commandResult = cli.run([
          'admin',
          'test-push',
          'test',
          '--format',
          'yaml',
        ]);
      });

      test('then emits the notification type', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(yamlDecode(logger.rawCalls.single.content), {
          'notificationType': 'test',
        });
      });
    });

    group('when the server rejects the notification type', () {
      late Future commandResult;

      setUp(() async {
        when(() => client.adminTest.pushNotification(any())).thenThrow(
          InvalidValueException(
            message:
                'Unknown notification type "nope". '
                'Expected test or invoice-failed.',
          ),
        );

        commandResult = cli.run(['admin', 'test-push', 'nope']);
      });

      test('then the command exits with an error', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the server message is logged', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(
          logger.errorCalls.first,
          equalsErrorCall(
            message:
                'Unknown notification type "nope". '
                'Expected test or invoice-failed.',
          ),
        );
      });
    });
  });
}
