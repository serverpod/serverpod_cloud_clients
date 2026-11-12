import 'dart:convert';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/app/app_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';
import 'package:yaml_codec/yaml_codec.dart';

import '../../../test_utils/test_command_logger.dart';

const _projectId = 'my-project-id';

void main() {
  final logger = TestCommandLogger();
  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(apiClientFactory: (_) => client),
  );

  tearDown(() {
    logger.clear();
    reset(client.appBuilds);
    reset(client.appPublishing);
  });

  test('Given app status command when instantiated then requires login', () {
    expect(CloudAppStatusCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given stores connected for iOS and Android with uploaded builds', () {
    setUp(() {
      _stubSetup(
        client,
        AppPublishingSetupBuilder()
            .withAndroidStore(
              GooglePlayAccess(serviceAccountEmail: 'publisher@acme.dev'),
            )
            .build(),
      );
      _stubLatestBuilds(client, [
        AppBuildSummaryBuilder().withPlatform(AppPlatform.ios).build(),
        AppBuildSummaryBuilder().withPlatform(AppPlatform.android).build(),
      ]);
    });

    test('when showing the status '
        'then one row per platform shows its latest build', () async {
      await cli.run(['app', 'status', '--project', _projectId]);

      expect(
        logger.lineCalls.map((call) => call.line),
        containsAllInOrder([
          allOf(
            startsWith('Platform'),
            contains('Store'),
            contains('Version'),
            contains('State'),
          ),
          anything,
          allOf(
            startsWith('iOS '),
            contains('App Store'),
            contains('1.4.2 (37)'),
            contains('Uploaded · 2m ago'),
          ),
          allOf(
            startsWith('Android '),
            contains('Google Play'),
            contains('1.4.2 (37)'),
            contains('Uploaded · 2m ago'),
          ),
        ]),
      );
    });

    test('when showing the status then no command hint is shown', () async {
      await cli.run(['app', 'status', '--project', _projectId]);

      expect(logger.terminalCommandCalls, isEmpty);
    });

    test(
      'when showing the status with --format json '
      'then each platform is emitted with its store and latest build',
      () async {
        await cli.run([
          'app',
          'status',
          '--project',
          _projectId,
          '--format',
          'json',
        ]);

        expect(logger.lineCalls, isEmpty);
        final payload = jsonDecode(logger.rawCalls.single.content) as List;
        expect(payload.map((row) => (row as Map)['platform']), [
          'ios',
          'android',
        ]);
        expect((payload.last as Map)['store'], 'googlePlay');
        expect(((payload.last as Map)['latestBuild'] as Map)['requestedBy'], {
          'name': null,
          'email': 'test@example.com',
        });
        expect(
          ((payload.last as Map)['latestBuild'] as Map)['status'],
          'succeeded',
        );
      },
    );

    test('when showing the status with --format yaml '
        'then each platform is emitted with its store', () async {
      await cli.run([
        'app',
        'status',
        '--project',
        _projectId,
        '--format',
        'yaml',
      ]);

      expect(logger.lineCalls, isEmpty);
      final payload = yamlDecode(logger.rawCalls.single.content) as List;
      expect(payload.map((row) => (row as Map)['store']), [
        'appStore',
        'googlePlay',
      ]);
    });
  });

  group('Given a store connected only for iOS', () {
    setUp(() {
      _stubSetup(
        client,
        AppPublishingSetupBuilder().withAndroidStore(null).build(),
      );
      _stubLatestBuilds(client, [
        AppBuildSummaryBuilder().withPlatform(AppPlatform.ios).build(),
        AppBuildSummaryBuilder().withPlatform(AppPlatform.android).build(),
      ]);
    });

    test('when showing the status then only iOS is shown', () async {
      await cli.run(['app', 'status', '--project', _projectId]);

      final lines = logger.lineCalls.map((call) => call.line);
      expect(lines, contains(startsWith('iOS ')));
      expect(lines, isNot(contains(startsWith('Android '))));
    });
  });

  group('Given a store connected for iOS without builds', () {
    setUp(() {
      _stubSetup(client, AppPublishingSetupBuilder().build());
      _stubLatestBuilds(client, []);
    });

    test('when showing the status then iOS has no builds yet', () async {
      await cli.run(['app', 'status', '--project', _projectId]);

      expect(
        logger.lineCalls.map((call) => call.line),
        contains(allOf(startsWith('iOS '), contains('No builds yet'))),
      );
    });

    test('when showing the status with --format json '
        'then iOS is emitted without a latest build', () async {
      await cli.run([
        'app',
        'status',
        '--project',
        _projectId,
        '--format',
        'json',
      ]);

      final payload = jsonDecode(logger.rawCalls.single.content) as List;
      expect((payload.single as Map)['latestBuild'], isNull);
    });
  });

  group('Given a running iOS build', () {
    final uploadId = const Uuid().v4obj();

    setUp(() {
      _stubSetup(client, AppPublishingSetupBuilder().build());
      _stubLatestBuilds(client, [
        AppBuildSummaryBuilder()
            .withUploadId(uploadId)
            .withStatus(AppBuildStatus.running)
            .withBuildNumber(null)
            .withStartedAt(DateTime.now().subtract(const Duration(minutes: 5)))
            .build(),
      ]);
    });

    test('when showing the status '
        'then the state shows when the build started', () async {
      await cli.run(['app', 'status', '--project', _projectId]);

      expect(
        logger.lineCalls.map((call) => call.line),
        contains(
          allOf(
            startsWith('iOS '),
            contains('1.4.2 '),
            contains('Running · 5m ago'),
          ),
        ),
      );
    });

    test('when showing the status '
        'then the command to follow the build is shown', () async {
      await cli.run(['app', 'status', '--project', _projectId]);

      expect(
        logger.terminalCommandCalls,
        contains(
          isA<TerminalCommandCall>()
              .having(
                (call) => call.message,
                'message',
                'Follow the iOS build:',
              )
              .having(
                (call) => call.command,
                'command',
                endsWith(' app show $uploadId --project $_projectId'),
              ),
        ),
      );
    });
  });

  test(
    'Given two active platforms of the same upload '
    'when showing status then one project-aware follow command is shown',
    () async {
      final uploadId = const Uuid().v4obj();
      _stubSetup(
        client,
        AppPublishingSetupBuilder()
            .withAndroidStore(
              GooglePlayAccess(serviceAccountEmail: 'publisher@acme.dev'),
            )
            .build(),
      );
      _stubLatestBuilds(client, [
        AppBuildSummaryBuilder()
            .withUploadId(uploadId)
            .withPlatform(AppPlatform.ios)
            .withStatus(AppBuildStatus.running)
            .build(),
        AppBuildSummaryBuilder()
            .withUploadId(uploadId)
            .withPlatform(AppPlatform.android)
            .withStatus(AppBuildStatus.queued)
            .build(),
      ]);

      await cli.run(['app', 'status', '--project', _projectId]);

      expect(logger.terminalCommandCalls, hasLength(1));
      expect(
        logger.terminalCommandCalls.single.command,
        endsWith(' app show $uploadId --project $_projectId'),
      );
    },
  );

  group('Given a queued iOS build', () {
    setUp(() {
      _stubSetup(client, AppPublishingSetupBuilder().build());
      _stubLatestBuilds(client, [
        AppBuildSummaryBuilder()
            .withStatus(AppBuildStatus.queued)
            .withCreatedAt(DateTime.now().subtract(const Duration(minutes: 3)))
            .build(),
      ]);
    });

    test('when showing the status '
        'then the state shows when the build was requested', () async {
      await cli.run(['app', 'status', '--project', _projectId]);

      expect(
        logger.lineCalls.map((call) => call.line),
        contains(allOf(startsWith('iOS '), contains('Queued · 3m ago'))),
      );
    });
  });

  group('Given a failed Android build', () {
    final uploadId = const Uuid().v4obj();

    setUp(() {
      _stubSetup(
        client,
        AppPublishingSetupBuilder()
            .withIosStore(null)
            .withAndroidStore(
              GooglePlayAccess(serviceAccountEmail: 'publisher@acme.dev'),
            )
            .build(),
      );
      _stubLatestBuilds(client, [
        AppBuildSummaryBuilder()
            .withUploadId(uploadId)
            .withPlatform(AppPlatform.android)
            .withStatus(AppBuildStatus.failed)
            .withMessage('Gradle task assembleRelease failed.')
            .build(),
      ]);
    });

    test('when showing the status '
        'then the state shows when the build failed', () async {
      await cli.run(['app', 'status', '--project', _projectId]);

      expect(
        logger.lineCalls.map((call) => call.line),
        contains(allOf(startsWith('Android '), contains('Failed · 2m ago'))),
      );
    });

    test('when showing the status '
        'then the reason and the command to read the log are shown', () async {
      await cli.run(['app', 'status', '--project', _projectId]);

      expect(
        logger.terminalCommandCalls,
        contains(
          isA<TerminalCommandCall>()
              .having(
                (call) => call.message,
                'message',
                'The Android build failed: Gradle task assembleRelease failed.',
              )
              .having(
                (call) => call.command,
                'command',
                endsWith(
                  ' app log $uploadId --platform android --project $_projectId',
                ),
              ),
        ),
      );
    });

    test('when showing the status with --format csv '
        'then only the table is shown', () async {
      await cli.run([
        'app',
        'status',
        '--project',
        _projectId,
        '--format',
        'csv',
      ]);

      expect(logger.lineCalls.map((call) => call.line), [
        'Platform,Store,Version,State',
        startsWith('Android,Google Play,1.4.2 (37),Failed'),
      ]);
      expect(logger.terminalCommandCalls, isEmpty);
    });
  });

  group('Given a cancelled iOS build', () {
    final uploadId = const Uuid().v4obj();

    setUp(() {
      _stubSetup(client, AppPublishingSetupBuilder().build());
      _stubLatestBuilds(client, [
        AppBuildSummaryBuilder()
            .withUploadId(uploadId)
            .withStatus(AppBuildStatus.cancelled)
            .build(),
      ]);
    });

    test(
      'when showing the status '
      'then the cancellation and the command to read the log are shown',
      () async {
        await cli.run(['app', 'status', '--project', _projectId]);

        expect(
          logger.terminalCommandCalls,
          contains(
            isA<TerminalCommandCall>()
                .having(
                  (call) => call.message,
                  'message',
                  'The iOS build was cancelled.',
                )
                .having(
                  (call) => call.command,
                  'command',
                  endsWith(
                    ' app log $uploadId --platform ios --project $_projectId',
                  ),
                ),
          ),
        );
      },
    );
  });

  group('Given an iOS build cancelled while queued', () {
    setUp(() {
      _stubSetup(client, AppPublishingSetupBuilder().build());
      _stubLatestBuilds(client, [
        AppBuildSummaryBuilder()
            .withStatus(AppBuildStatus.cancelled)
            .withStartedAt(null)
            .build(),
      ]);
    });

    test('when showing the status then the cancellation is shown', () async {
      await cli.run(['app', 'status', '--project', _projectId]);

      expect(
        logger.infoCalls.map((call) => call.message),
        contains('The iOS build was cancelled.'),
      );
    });

    test('when showing the status '
        'then no command to read the log is shown', () async {
      await cli.run(['app', 'status', '--project', _projectId]);

      expect(logger.terminalCommandCalls, isEmpty);
    });
  });

  group('Given no connected store', () {
    setUp(() {
      _stubSetup(
        client,
        AppPublishingSetupBuilder().withNothingSetUp().build(),
      );
    });

    test('when showing the status then no builds are fetched', () async {
      await cli.run(['app', 'status', '--project', _projectId]);

      verifyNever(
        () => client.appBuilds.getLatestBuilds(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
        ),
      );
    });

    test('when showing the status then no store is shown', () async {
      await cli.run(['app', 'status', '--project', _projectId]);

      expect(logger.lineCalls, isEmpty);
      expect(
        logger.infoCalls.map((call) => call.message),
        contains('No store is connected to the project yet.'),
      );
    });

    test('when showing the status with --format json '
        'then an empty list is emitted', () async {
      await cli.run([
        'app',
        'status',
        '--project',
        _projectId,
        '--format',
        'json',
      ]);

      expect(logger.infoCalls, isEmpty);
      expect(jsonDecode(logger.rawCalls.single.content), isEmpty);
    });
  });

  group('Given latest builds that cannot be fetched', () {
    setUp(() {
      _stubSetup(client, AppPublishingSetupBuilder().build());
      when(
        () => client.appBuilds.getLatestBuilds(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
        ),
      ).thenThrow(Exception('Connection refused'));
    });

    group('when showing the status', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run(['app', 'status', '--project', _projectId]);
      });

      test('then the command throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the failed fetch is logged', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.errorCalls.map((call) => call.message),
          contains('Failed to fetch the app status.'),
        );
      });
    });
  });

  group('Given app publishing is off', () {
    setUp(() {
      when(
        () => client.appPublishing.getSetup(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
        ),
      ).thenThrow(
        AppPublishingDisabledException(message: 'App publishing is off.'),
      );
    });

    group('when showing the status', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run(['app', 'status', '--project', _projectId]);
      });

      test('then the command throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the error is logged', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.errorCalls.map((call) => call.message),
          contains('App publishing is off.'),
        );
      });
    });
  });
}

void _stubSetup(ClientMock client, AppPublishingSetup setup) {
  when(
    () => client.appPublishing.getSetup(
      cloudCapsuleId: any(named: 'cloudCapsuleId'),
    ),
  ).thenAnswer((_) async => setup);
}

void _stubLatestBuilds(ClientMock client, List<AppBuildSummary> builds) {
  when(
    () => client.appBuilds.getLatestBuilds(
      cloudCapsuleId: any(named: 'cloudCapsuleId'),
    ),
  ).thenAnswer((_) async => builds);
}
