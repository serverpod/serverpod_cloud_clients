import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/project_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';

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
  );

  tearDown(() async {
    await keyManager.remove();

    logger.clear();
  });

  test('Given project show command when instantiated then requires login', () {
    expect(CloudProjectShowCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given unauthenticated', () {
    setUp(() async {
      await keyManager.put('mock-token');
    });

    setUpAll(() async {
      when(() => client.projects.fetchProject(cloudProjectId: any(named: 'cloudProjectId')))
          .thenThrow(ServerpodClientUnauthorized());
    });

    tearDownAll(() {
      reset(client.projects);
    });

    group('when executing project show', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'project',
          'show',
          'test-project',
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs error', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errorCalls, isNotEmpty);
        expect(
            logger.errorCalls.first,
            equalsErrorCall(
              message:
                  'The credentials for this session seem to no longer be valid.',
            ));
      });
    });
  });

  group('Given authenticated and existing project', () {
    setUp(() async {
      await keyManager.put('mock-token');
    });

    setUpAll(() async {
      final project = ProjectBuilder()
          .withCloudProjectId('test-project')
          .withCreatedAt(DateTime.parse("2024-12-31 10:20:30"))
          .build();

      when(() => client.projects.fetchProject(cloudProjectId: 'test-project'))
          .thenAnswer((final _) async => project);
    });

    tearDownAll(() {
      reset(client.projects);
    });

    group('when executing project show', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'project',
          'show',
          'test-project',
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs the project details', () async {
        await commandResult;

        expect(logger.lineCalls, isNotEmpty);
        expect(
          logger.lineCalls,
          containsAllInOrder([
            equalsLineCall(line: 'Project: test-project'),
            equalsLineCall(line: 'Status:'),
            equalsLineCall(line: '  Project Status: Active'),
            equalsLineCall(line: '  Created At: 2024-12-31 10:20:30'),
            equalsLineCall(line: 'Deployments: None'),
          ]),
        );
      });
    });

    group('when executing project show for archived project', () {
      setUpAll(() async {
        final archivedProject = ProjectBuilder()
            .withCloudProjectId('archived-project')
            .withCreatedAt(DateTime.parse("2024-12-31 10:20:30"))
            .withArchivedAt(DateTime.parse("2025-01-15 14:30:00"))
            .build();

        when(() => client.projects.fetchProject(cloudProjectId: 'archived-project'))
            .thenAnswer((final _) async => archivedProject);
      });

      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'project',
          'show',
          'archived-project',
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs archived status', () async {
        await commandResult;

        expect(logger.lineCalls, isNotEmpty);
        expect(
          logger.lineCalls,
          containsAllInOrder([
            equalsLineCall(line: 'Project: archived-project'),
            equalsLineCall(line: '  Project Status: Archived'),
            equalsLineCall(line: '  Archived At: 2025-01-15 14:30:00'),
          ]),
        );
      });
    });
  });
}
