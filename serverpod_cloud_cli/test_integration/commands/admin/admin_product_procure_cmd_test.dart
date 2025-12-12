import 'dart:async';

import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/admin_product_commands.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:test/test.dart';

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
      apiClientFactory: (final globalCfg) => client,
    ),
    adminUserMode: true,
  );

  tearDown(() async {
    logger.clear();
  });

  test(
    'Given admin product procure command when instantiated then requires login',
    () {
      expect(AdminProcurePlanCommand(logger: logger).requireLogin, isTrue);
    },
  );

  group('Given authenticated', () {
    group('when executing admin product procure', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminProcurement.procurePlan(
            userEmail: any(named: 'userEmail'),
            planProductName: any(named: 'planProductName'),
            planProductVersion: any(named: 'planProductVersion'),
            overrideChecks: any(named: 'overrideChecks'),
          ),
        ).thenAnswer((final invocation) async => Future.value());

        commandResult = cli.run([
          'admin',
          'product',
          'procure-plan',
          'test@example.com',
          'test-plan',
        ]);
      });

      test('then command completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then command outputs success message', () async {
        await commandResult.catchError((final _) {});

        expect(
          logger.successCalls.first,
          equalsSuccessCall(
            message: 'The plan test-plan has been procured for the user.',
            newParagraph: true,
          ),
        );
      });
    });
  });
}
