import 'dart:async';
import 'dart:convert';

import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:yaml_codec/yaml_codec.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/projects/admin_projects_commands.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';

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

  tearDown(() async {
    logger.clear();
  });

  test(
    'Given admin project list command when instantiated then requires login',
    () {
      expect(AdminListProjectsCommand(logger: logger).requireLogin, isTrue);
    },
  );

  group('Given authenticated', () {
    group('when executing admin project list', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminProjects.listAdminProjectsInfo(
            includeArchived: any(named: 'includeArchived', that: isTrue),
            includeLatestDeployAttemptTime: any(
              named: 'includeLatestDeployAttemptTime',
              that: isTrue,
            ),
            includePaymentsStatus: any(
              named: 'includePaymentsStatus',
              that: isFalse,
            ),
          ),
        ).thenAnswer(
          (invocation) => Stream.fromIterable([
            AdminProjectInfoBuilder()
                .withProject(
                  ProjectBuilder()
                      .withCreatedAt(DateTime.parse('2025-07-02T11:00:00'))
                      .withCloudProjectId('projectId')
                      .withUserOwner(
                        UserBuilder().withEmail('test@example.com').build(),
                      ),
                )
                .withSubscriptionId('orb_sub_1')
                .withOverduePaymentsStatuses([
                  PaymentsStatusBuilder()
                      .withInvoiceId('inv-new')
                      .withOutstandingAmount('5.50')
                      .withDueDate(DateTime.utc(2024, 6, 1))
                      .build(),
                  PaymentsStatusBuilder()
                      .withInvoiceId('inv-old')
                      .withOutstandingAmount('10.00')
                      .withDueDate(DateTime.utc(2024, 1, 1))
                      .build(),
                ])
                .build(),
            AdminProjectInfoBuilder()
                .withProject(
                  ProjectBuilder()
                      .withCreatedAt(DateTime.parse('2025-07-02T11:00:00'))
                      .withArchivedAt(DateTime.parse('2025-07-02T12:10:00'))
                      .withCloudProjectId('projectId2')
                      .withUserOwner(
                        UserBuilder().withEmail('test@example.com').build(),
                      )
                      .withDeveloperUser(
                        UserBuilder().withEmail('dev@example.com').build(),
                      ),
                )
                .withSubscriptionId('orb_sub_2')
                .build(),
          ]),
        );

        commandResult = cli.run([
          'admin',
          'project',
          'list',
          '--include-archived',
        ]);
      });

      test('then command completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then command outputs the project ids and owners', () async {
        await commandResult.catchError((_) {});

        final lines = logger.lineCalls.map((call) => call.line);
        expect(
          lines,
          containsAllInOrder([
            contains('Project Id'),
            contains('projectId'),
            contains('projectId2'),
          ]),
        );
        expect(lines, contains(contains('Archived At')));
        expect(lines, contains(contains('test@example.com')));
        expect(lines, contains(contains('Developer: dev@example.com')));
      });

      test('then command outputs orb subscription ids', () async {
        await commandResult.catchError((_) {});

        final lines = logger.lineCalls.map((call) => call.line);
        expect(lines, contains(contains('Orb Subscription Id')));
        expect(lines, contains(contains('orb_sub_1')));
        expect(lines, contains(contains('orb_sub_2')));
      });

      test('then command does not output overdue payment columns', () async {
        await commandResult.catchError((_) {});

        final output = logger.lineCalls.map((call) => call.line).join('\n');
        expect(output, isNot(contains('Oldest Overdue')));
        expect(output, isNot(contains('Newest Overdue')));
        expect(output, isNot(contains('Total Overdue')));
      });
    });

    group('when executing admin project list with --include-payments', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminProjects.listAdminProjectsInfo(
            includeArchived: any(named: 'includeArchived', that: isFalse),
            includeLatestDeployAttemptTime: any(
              named: 'includeLatestDeployAttemptTime',
              that: isTrue,
            ),
            includePaymentsStatus: any(
              named: 'includePaymentsStatus',
              that: isTrue,
            ),
          ),
        ).thenAnswer(
          (invocation) => Stream.fromIterable([
            AdminProjectInfoBuilder()
                .withProject(
                  ProjectBuilder()
                      .withCloudProjectId('projectId')
                      .withUserOwner(
                        UserBuilder().withEmail('test@example.com').build(),
                      ),
                )
                .withSubscriptionId('orb_sub_1')
                .withOverduePaymentsStatuses([
                  PaymentsStatusBuilder()
                      .withInvoiceId('inv-new')
                      .withOutstandingAmount('5.50')
                      .withDueDate(DateTime.utc(2024, 6, 1))
                      .build(),
                  PaymentsStatusBuilder()
                      .withInvoiceId('inv-old')
                      .withOutstandingAmount('10.00')
                      .withDueDate(DateTime.utc(2024, 1, 1))
                      .build(),
                ])
                .build(),
            AdminProjectInfoBuilder()
                .withProject(
                  ProjectBuilder()
                      .withCloudProjectId('projectId2')
                      .withUserOwner(
                        UserBuilder().withEmail('test@example.com').build(),
                      ),
                )
                .withSubscriptionId('orb_sub_2')
                .build(),
          ]),
        );

        commandResult = cli.run([
          'admin',
          'project',
          'list',
          '--include-payments',
        ]);
      });

      test('then command outputs overdue unpaid amounts', () async {
        await commandResult;

        final lines = logger.lineCalls.map((call) => call.line);
        expect(lines, contains(contains('Oldest Overdue')));
        expect(lines, contains(contains('Newest Overdue')));
        expect(lines, contains(contains('Total Overdue')));
        expect(lines, contains(contains('10.00')));
        expect(lines, contains(contains('5.50')));
        expect(lines, contains(contains('15.50')));
        expect(lines, contains(contains('0.00')));
      });
    });

    group('when executing admin project list without --include-archived', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminProjects.listAdminProjectsInfo(
            includeArchived: any(named: 'includeArchived', that: isFalse),
            includeLatestDeployAttemptTime: any(
              named: 'includeLatestDeployAttemptTime',
              that: isTrue,
            ),
            includePaymentsStatus: any(
              named: 'includePaymentsStatus',
              that: isFalse,
            ),
          ),
        ).thenAnswer(
          (invocation) => Stream.fromIterable([
            AdminProjectInfoBuilder()
                .withProject(
                  ProjectBuilder()
                      .withCloudProjectId('projectId')
                      .withUserOwner(
                        UserBuilder().withEmail('test@example.com').build(),
                      ),
                )
                .withSubscriptionId('orb_sub_1')
                .build(),
          ]),
        );

        commandResult = cli.run(['admin', 'project', 'list']);
      });

      test('then command does not output the archived at column', () async {
        await commandResult;

        expect(
          logger.lineCalls.map((call) => call.line).join('\n'),
          isNot(contains('Archived At')),
        );
      });
    });

    group('when executing admin project list with --format json', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminProjects.listAdminProjectsInfo(
            includeArchived: any(named: 'includeArchived', that: isTrue),
            includeLatestDeployAttemptTime: any(
              named: 'includeLatestDeployAttemptTime',
              that: isTrue,
            ),
            includePaymentsStatus: any(
              named: 'includePaymentsStatus',
              that: isFalse,
            ),
          ),
        ).thenAnswer(
          (invocation) => Stream.fromIterable([
            AdminProjectInfoBuilder()
                .withProject(
                  ProjectBuilder()
                      .withCreatedAt(DateTime.parse('2025-07-02T11:00:00'))
                      .withCloudProjectId('projectId')
                      .withUserOwner(
                        UserBuilder().withEmail('test@example.com').build(),
                      ),
                )
                .withSubscriptionId('orb_sub_1')
                .withOverduePaymentsStatuses([
                  PaymentsStatusBuilder()
                      .withInvoiceId('inv-new')
                      .withOutstandingAmount('5.50')
                      .withDueDate(DateTime.utc(2024, 6, 1))
                      .build(),
                  PaymentsStatusBuilder()
                      .withInvoiceId('inv-old')
                      .withOutstandingAmount('10.00')
                      .withDueDate(DateTime.utc(2024, 1, 1))
                      .build(),
                ])
                .build(),
            AdminProjectInfoBuilder()
                .withProject(
                  ProjectBuilder()
                      .withCreatedAt(DateTime.parse('2025-07-02T11:00:00'))
                      .withArchivedAt(DateTime.parse('2025-07-02T12:10:00'))
                      .withCloudProjectId('projectId2')
                      .withUserOwner(
                        UserBuilder().withEmail('test@example.com').build(),
                      )
                      .withDeveloperUser(
                        UserBuilder().withEmail('dev@example.com').build(),
                      ),
                )
                .withSubscriptionId('orb_sub_2')
                .build(),
          ]),
        );

        commandResult = cli.run([
          'admin',
          'project',
          'list',
          '--include-archived',
          '--format',
          'json',
        ]);
      });

      test('then emits one JSON object per project', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(logger.rawCalls, hasLength(2));
        final first = jsonDecode(logger.rawCalls[0].content) as Map;
        expect((first['project'] as Map)['cloudProjectId'], 'projectId');
        expect(first['subscriptionId'], 'orb_sub_1');
        expect(first.containsKey('oldestOverdueUnpaidAmount'), isFalse);
        expect(first.containsKey('totalAmountOverdue'), isFalse);
        final second = jsonDecode(logger.rawCalls[1].content) as Map;
        expect((second['project'] as Map)['cloudProjectId'], 'projectId2');
        expect((second['project'] as Map)['archivedAt'], isNotNull);
        expect(second['subscriptionId'], 'orb_sub_2');
        expect(second.containsKey('totalAmountOverdue'), isFalse);
      });
    });

    group(
      'when executing admin project list with --include-payments and --format json',
      () {
        late Future commandResult;
        setUp(() async {
          when(
            () => client.adminProjects.listAdminProjectsInfo(
              includeArchived: any(named: 'includeArchived', that: isFalse),
              includeLatestDeployAttemptTime: any(
                named: 'includeLatestDeployAttemptTime',
                that: isTrue,
              ),
              includePaymentsStatus: any(
                named: 'includePaymentsStatus',
                that: isTrue,
              ),
            ),
          ).thenAnswer(
            (invocation) => Stream.fromIterable([
              AdminProjectInfoBuilder()
                  .withProject(
                    ProjectBuilder()
                        .withCreatedAt(DateTime.parse('2025-07-02T11:00:00'))
                        .withCloudProjectId('projectId')
                        .withUserOwner(
                          UserBuilder().withEmail('test@example.com').build(),
                        ),
                  )
                  .withSubscriptionId('orb_sub_1')
                  .withOverduePaymentsStatuses([
                    PaymentsStatusBuilder()
                        .withInvoiceId('inv-new')
                        .withOutstandingAmount('5.50')
                        .withDueDate(DateTime.utc(2024, 6, 1))
                        .build(),
                    PaymentsStatusBuilder()
                        .withInvoiceId('inv-old')
                        .withOutstandingAmount('10.00')
                        .withDueDate(DateTime.utc(2024, 1, 1))
                        .build(),
                  ])
                  .build(),
            ]),
          );

          commandResult = cli.run([
            'admin',
            'project',
            'list',
            '--include-payments',
            '--format',
            'json',
          ]);
        });

        test('then emits overdue totals on each JSON object', () async {
          await commandResult;

          expect(logger.lineCalls, isEmpty);
          final first = jsonDecode(logger.rawCalls.single.content) as Map;
          expect(first['oldestOverdueUnpaidAmount'], '10.00');
          expect(first['oldestOverdueUnpaidDueDate'], '2024-01-01');
          expect(first['newestOverdueUnpaidAmount'], '5.50');
          expect(first['newestOverdueUnpaidDueDate'], '2024-06-01');
          expect(first['totalAmountOverdue'], '15.50');
        });
      },
    );

    group('when executing admin project list with --format yaml', () {
      late Future commandResult;
      setUp(() async {
        when(
          () => client.adminProjects.listAdminProjectsInfo(
            includeArchived: any(named: 'includeArchived', that: isTrue),
            includeLatestDeployAttemptTime: any(
              named: 'includeLatestDeployAttemptTime',
              that: isTrue,
            ),
            includePaymentsStatus: any(
              named: 'includePaymentsStatus',
              that: isFalse,
            ),
          ),
        ).thenAnswer(
          (invocation) => Stream.fromIterable([
            AdminProjectInfoBuilder()
                .withProject(
                  ProjectBuilder()
                      .withCreatedAt(DateTime.parse('2025-07-02T11:00:00'))
                      .withCloudProjectId('projectId')
                      .withUserOwner(
                        UserBuilder().withEmail('test@example.com').build(),
                      ),
                )
                .withSubscriptionId('orb_sub_1')
                .build(),
            AdminProjectInfoBuilder()
                .withProject(
                  ProjectBuilder()
                      .withCreatedAt(DateTime.parse('2025-07-02T11:00:00'))
                      .withArchivedAt(DateTime.parse('2025-07-02T12:10:00'))
                      .withCloudProjectId('projectId2')
                      .withUserOwner(
                        UserBuilder().withEmail('test@example.com').build(),
                      )
                      .withDeveloperUser(
                        UserBuilder().withEmail('dev@example.com').build(),
                      ),
                )
                .withSubscriptionId('orb_sub_2')
                .build(),
          ]),
        );

        commandResult = cli.run([
          'admin',
          'project',
          'list',
          '--include-archived',
          '--format',
          'yaml',
        ]);
      });

      test('then emits one YAML document per project', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(logger.rawCalls, hasLength(2));
        final first = yamlDecode(logger.rawCalls[0].content) as Map;
        expect((first['project'] as Map)['cloudProjectId'], 'projectId');
        expect(first['subscriptionId'], 'orb_sub_1');
        expect(first.containsKey('totalAmountOverdue'), isFalse);
        final second = yamlDecode(logger.rawCalls[1].content) as Map;
        expect((second['project'] as Map)['cloudProjectId'], 'projectId2');
        expect(second['subscriptionId'], 'orb_sub_2');
      });
    });
  });
}
