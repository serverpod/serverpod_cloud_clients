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

  test(
      'Given admin product list-procured command when instantiated then requires login',
      () {
    expect(AdminListProcuredCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given authenticated', () {
    setUp(() async {
      await keyManager.put('mock-token');
    });

    group('when executing admin product list-procured', () {
      late Future commandResult;
      setUp(() async {
        when(() => client.adminProcurement.listProcuredProducts(
              userEmail: any(named: 'userEmail'),
            )).thenAnswer(
          (final invocation) async => Future.value([
            ('test-plan', 'PlanProduct'),
            ('test-plan2', 'PlanProduct'),
          ]),
        );

        commandResult = cli.run([
          'admin',
          'product',
          'list-procured',
          'test@example.com',
        ]);
      });

      test('then command completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then command outputs user list', () async {
        await commandResult.catchError((final _) {});

        expect(
          logger.lineCalls,
          containsAllInOrder([
            equalsLineCall(line: 'Product    | Type       '),
            equalsLineCall(line: '-----------+------------'),
            equalsLineCall(line: 'test-plan  | PlanProduct'),
            equalsLineCall(line: 'test-plan2 | PlanProduct'),
          ]),
        );
      });
    });
  });
}
