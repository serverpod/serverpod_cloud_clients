import 'dart:async';

import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/admin_redeploy_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final keyManager = InMemoryKeyManager();
  final client = ClientMock(authenticationKeyManager: keyManager);
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (final globalCfg) => client,
    ),
    adminUserMode: true,
  );

  tearDown(() async {
    await keyManager.remove();

    logger.clear();
  });

  test('Given admin redeploy command when instantiated then requires login',
      () {
    expect(AdminRedeployCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given authenticated', () {
    setUp(() async {
      await keyManager.put('mock-token');
    });

    group('when executing admin redeploy', () {
      late Future commandResult;
      setUp(() async {
        when(() => client.adminProjects.redeployCapsule('test-project'))
            .thenAnswer((final invocation) async => Future.value());

        commandResult = cli.run([
          'admin',
          'redeploy',
          'test-project',
        ]);
      });

      test('then command completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then logs success message', () async {
        await commandResult.catchError((final _) {});

        expect(
          logger.successCalls,
          contains(
            equalsSuccessCall(
              message: 'Redeployment triggered for project: test-project',
              newParagraph: true,
            ),
          ),
        );
      });
    });

    group('when executing admin redeploy with different project ID', () {
      late Future commandResult;
      setUp(() async {
        when(() => client.adminProjects.redeployCapsule('another-project'))
            .thenAnswer((final invocation) async => Future.value());

        commandResult = cli.run([
          'admin',
          'redeploy',
          'another-project',
        ]);
      });

      test('then command completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then logs success message with correct project ID', () async {
        await commandResult.catchError((final _) {});

        expect(
          logger.successCalls,
          contains(
            equalsSuccessCall(
              message: 'Redeployment triggered for project: another-project',
              newParagraph: true,
            ),
          ),
        );
      });
    });

    group('when redeployCapsule throws exception', () {
      late Future commandResult;
      setUp(() async {
        when(() => client.adminProjects.redeployCapsule('test-project'))
            .thenThrow(Exception('API Error'));

        commandResult = cli.run([
          'admin',
          'redeploy',
          'test-project',
        ]);
      });

      test('then throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs error message', () async {
        await commandResult.catchError((final _) {});

        expect(logger.errorCalls, isNotEmpty);
        expect(logger.errorCalls.first.message,
            equals('Failed to redeploy project'));
        expect(logger.errorCalls.first.exception, isNotNull);
      });
    });
  });
}
