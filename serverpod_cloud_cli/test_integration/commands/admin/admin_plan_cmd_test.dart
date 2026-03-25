import 'dart:async';

import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/admin_plan_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';

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
    'Given admin plan list command when instantiated then requires login',
    () {
      expect(AdminListOrbPlansCommand(logger: logger).requireLogin, isTrue);
    },
  );

  test(
    'Given admin plan update command when instantiated then requires login',
    () {
      expect(AdminUpdatePlanCommand(logger: logger).requireLogin, isTrue);
    },
  );

  group('Given authenticated', () {
    group('when executing admin plan list', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminUpdatePlan.listOrbPlans(),
        ).thenAnswer((final invocation) async => ['plan-alpha', 'plan-beta']);

        commandResult = cli.run(['admin', 'plan', 'list']);
      });

      test('then command completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then command outputs plan table', () async {
        await commandResult.catchError((final _) {});

        expect(
          logger.lineCalls,
          containsAllInOrder([
            equalsLineCall(line: 'External Plan ID'),
            equalsLineCall(line: '----------------'),
            equalsLineCall(line: 'plan-alpha      '),
            equalsLineCall(line: 'plan-beta       '),
          ]),
        );
      });
    });

    group('when executing admin plan update', () {
      group('with applied version', () {
        late Future commandResult;
        setUp(() async {
          when(
            () => client.adminUpdatePlan.updateOrbPlan(
              externalPlanId: any(named: 'externalPlanId'),
            ),
          ).thenAnswer(
            (final invocation) async => {'appliedVersion': '2025-03-01-v2'},
          );

          commandResult = cli.run(['admin', 'plan', 'update', 'plan-alpha']);
        });

        test('then command completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then command logs success', () async {
          await commandResult.catchError((final _) {});

          expect(
            logger.successCalls,
            contains(
              equalsSuccessCall(
                message:
                    'Orb plan "plan-alpha" successfully updated to version '
                    '2025-03-01-v2.',
                newParagraph: true,
              ),
            ),
          );
        });
      });

      group('when plan is already up to date', () {
        late Future commandResult;
        setUp(() async {
          when(
            () => client.adminUpdatePlan.updateOrbPlan(
              externalPlanId: any(named: 'externalPlanId'),
            ),
          ).thenAnswer((final invocation) async => {'appliedVersion': ''});

          commandResult = cli.run(['admin', 'plan', 'update', 'plan-alpha']);
        });

        test('then command completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then command logs info', () async {
          await commandResult.catchError((final _) {});

          expect(
            logger.infoCalls,
            contains(
              equalsInfoCall(
                message: 'Orb plan "plan-alpha" already up to date.',
                newParagraph: true,
              ),
            ),
          );
        });
      });
    });
  });
}
