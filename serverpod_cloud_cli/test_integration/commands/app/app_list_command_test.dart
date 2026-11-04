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

  setUpAll(() {
    registerFallbackValue(AppPlatform.ios);
    registerFallbackValue(const Uuid().v4obj());
  });

  tearDown(() {
    logger.clear();
    reset(client.appBuilds);
  });

  test('Given app list command when instantiated then requires login', () {
    expect(CloudAppListCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given a running and a succeeded publish for iOS and Android', () {
    final runningUploadId = const Uuid().v4obj();
    final succeededUploadId = const Uuid().v4obj();

    setUp(() {
      final runningAt = DateTime.now().subtract(const Duration(minutes: 2));
      final succeededAt = DateTime.now().subtract(const Duration(hours: 2));
      _stubListBuilds(client, [
        AppBuildSummaryBuilder()
            .withUploadId(runningUploadId)
            .withPlatform(AppPlatform.android)
            .withStatus(AppBuildStatus.queued)
            .withVersionName('1.4.3')
            .withBuildNumber(null)
            .withCreatedAt(runningAt)
            .build(),
        AppBuildSummaryBuilder()
            .withUploadId(runningUploadId)
            .withPlatform(AppPlatform.ios)
            .withStatus(AppBuildStatus.running)
            .withVersionName('1.4.3')
            .withBuildNumber(null)
            .withCreatedAt(runningAt)
            .build(),
        AppBuildSummaryBuilder()
            .withUploadId(succeededUploadId)
            .withPlatform(AppPlatform.ios)
            .withVersionName('1.4.2')
            .withBuildNumber('37')
            .withCreatedAt(succeededAt)
            .build(),
        AppBuildSummaryBuilder()
            .withUploadId(succeededUploadId)
            .withPlatform(AppPlatform.android)
            .withVersionName('1.4.2')
            .withBuildNumber('37')
            .withCreatedAt(succeededAt)
            .build(),
      ]);
    });

    group('when listing the publishes', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run(['app', 'list', '--project', _projectId]);
      });

      test('then one row per publish is listed', () async {
        await commandResult;

        expect(
          logger.lineCalls.map((call) => call.line),
          containsAllInOrder([
            allOf(
              startsWith('Version'),
              contains('Platforms'),
              contains('State'),
              contains('Started'),
            ),
            anything,
            allOf(
              startsWith('1.4.3 '),
              contains('iOS, Android'),
              contains('Running'),
              contains('2 minutes ago'),
            ),
            allOf(
              startsWith('1.4.2 (37)'),
              contains('iOS, Android'),
              contains('Succeeded'),
              contains('2 hours ago'),
            ),
          ]),
        );
      });
    });

    group('when listing the publishes with --format json', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'list',
          '--project',
          _projectId,
          '--format',
          'json',
        ]);
      });

      test('then the publishes are emitted with their builds', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        final payload = jsonDecode(logger.rawCalls.single.content) as List;
        expect(payload, hasLength(2));
        final running = payload.first as Map;
        expect(running['uploadId'], runningUploadId.toString());
        expect(running['versionName'], '1.4.3');
        expect(running['platforms'], ['ios', 'android']);
        expect(running['status'], 'running');
        expect(
          (running['builds'] as List).map((build) => (build as Map)['status']),
          ['running', 'queued'],
        );
      });
    });

    group('when listing the publishes with --format yaml', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'list',
          '--project',
          _projectId,
          '--format',
          'yaml',
        ]);
      });

      test('then the publishes are emitted with their builds', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        final payload = yamlDecode(logger.rawCalls.single.content) as List;
        expect(payload, hasLength(2));
        final succeeded = payload.last as Map;
        expect(succeeded['uploadId'], succeededUploadId.toString());
        expect(succeeded['platforms'], ['ios', 'android']);
        expect(succeeded['status'], 'succeeded');
        expect(succeeded['builds'], hasLength(2));
      });
    });

    group('when listing one publish', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'list',
          '--project',
          _projectId,
          '--limit',
          '1',
          '--format',
          'json',
        ]);
      });

      test('then the newest publish is listed with all its builds', () async {
        await commandResult;

        final payload = jsonDecode(logger.rawCalls.single.content) as List;
        expect(payload, hasLength(1));
        expect((payload.single as Map)['uploadId'], runningUploadId.toString());
        expect((payload.single as Map)['builds'], hasLength(2));
      });
    });

    group('when listing the iOS builds', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'list',
          '--project',
          _projectId,
          '--platforms',
          'ios',
        ]);
      });

      test('then one row per iOS build is listed', () async {
        await commandResult;

        expect(
          logger.lineCalls.map((call) => call.line),
          containsAllInOrder([
            allOf(
              startsWith('Version'),
              isNot(contains('Platform')),
              contains('State'),
              contains('Started'),
            ),
            anything,
            allOf(startsWith('1.4.3 '), contains('Running')),
            allOf(startsWith('1.4.2 (37)'), contains('Succeeded')),
          ]),
        );
        expect(logger.lineCalls, hasLength(4));
      });
    });

    group('when listing the iOS builds with --format json', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'list',
          '--project',
          _projectId,
          '--platforms',
          'ios',
          '--format',
          'json',
        ]);
      });

      test('then the iOS builds are emitted', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        final payload = jsonDecode(logger.rawCalls.single.content) as List;
        expect(payload.map((build) => (build as Map)['platform']), [
          'ios',
          'ios',
        ]);
        expect(payload.map((build) => (build as Map)['status']), [
          'running',
          'succeeded',
        ]);
      });
    });

    group('when listing the iOS builds with --format yaml', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'list',
          '--project',
          _projectId,
          '--platforms',
          'ios',
          '--format',
          'yaml',
        ]);
      });

      test('then the iOS builds are emitted', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        final payload = yamlDecode(logger.rawCalls.single.content) as List;
        expect(payload.map((build) => (build as Map)['platform']), [
          'ios',
          'ios',
        ]);
      });
    });

    group('when listing the iOS and Android builds', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'list',
          '--project',
          _projectId,
          '--platforms',
          'android,ios',
        ]);
      });

      test(
        'then one row per build is listed newest first with its platform',
        () async {
          await commandResult;

          expect(
            logger.lineCalls.map((call) => call.line),
            containsAllInOrder([
              allOf(startsWith('Version'), contains('Platform')),
              anything,
              allOf(contains('iOS'), contains('Running')),
              allOf(contains('Android'), contains('Queued')),
              allOf(contains('iOS'), contains('Succeeded')),
              allOf(contains('Android'), contains('Succeeded')),
            ]),
          );
        },
      );
    });

    group('when listing 3 iOS and Android builds', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'list',
          '--project',
          _projectId,
          '--platforms',
          'android,ios',
          '--limit',
          '3',
          '--format',
          'json',
        ]);
      });

      test('then only the 3 newest builds are listed', () async {
        await commandResult;

        final payload = jsonDecode(logger.rawCalls.single.content) as List;
        expect(payload.map((build) => (build as Map)['status']), [
          'running',
          'queued',
          'succeeded',
        ]);
      });
    });
  });

  group('Given a publish with a failed and a succeeded build', () {
    setUp(() {
      final uploadId = const Uuid().v4obj();
      _stubListBuilds(client, [
        AppBuildSummaryBuilder()
            .withUploadId(uploadId)
            .withPlatform(AppPlatform.ios)
            .withStatus(AppBuildStatus.failed)
            .build(),
        AppBuildSummaryBuilder()
            .withUploadId(uploadId)
            .withPlatform(AppPlatform.android)
            .build(),
      ]);
    });

    test('when listing the publishes then the publish has failed', () async {
      await cli.run(['app', 'list', '--project', _projectId]);

      expect(
        logger.lineCalls.map((call) => call.line),
        contains(allOf(contains('iOS, Android'), contains('Failed'))),
      );
    });
  });

  group('Given more iOS builds than fit on one page', () {
    setUp(() {
      _stubListBuilds(client, [
        for (var minutes = 1; minutes <= 150; minutes++)
          AppBuildSummaryBuilder()
              .withCreatedAt(
                DateTime.now().subtract(Duration(minutes: minutes)),
              )
              .build(),
      ]);
    });

    test('when listing 120 iOS builds '
        'then 120 distinct builds are listed', () async {
      await cli.run([
        'app',
        'list',
        '--project',
        _projectId,
        '--platforms',
        'ios',
        '--limit',
        '120',
        '--format',
        'json',
      ]);

      final payload = jsonDecode(logger.rawCalls.single.content) as List;
      expect(payload, hasLength(120));
      expect(
        payload.map((build) => (build as Map)['id']).toSet(),
        hasLength(120),
      );
    });
  });

  group('Given more publishes than fit on one page', () {
    setUp(() {
      _stubListBuilds(client, [
        for (final (minutes, uploadId) in List.generate(
          61,
          (_) => const Uuid().v4obj(),
        ).indexed) ...[
          for (final platform in AppPlatform.values)
            AppBuildSummaryBuilder()
                .withUploadId(uploadId)
                .withPlatform(platform)
                .withCreatedAt(
                  DateTime.utc(2026).subtract(Duration(minutes: minutes)),
                )
                .build(),
        ],
      ]);
    });

    test('when listing 60 publishes '
        'then 60 publishes are listed with both their builds', () async {
      await cli.run([
        'app',
        'list',
        '--project',
        _projectId,
        '--limit',
        '60',
        '--format',
        'json',
      ]);

      final payload = jsonDecode(logger.rawCalls.single.content) as List;
      expect(payload, hasLength(60));
      expect((payload.last as Map)['builds'], hasLength(2));
    });
  });

  group('Given no publishes', () {
    setUp(() {
      _stubListBuilds(client, []);
    });

    test('when listing the publishes then none are shown', () async {
      await cli.run(['app', 'list', '--project', _projectId]);

      expect(logger.lineCalls, isEmpty);
      expect(
        logger.infoCalls.map((call) => call.message),
        contains('No publishes yet.'),
      );
    });

    test('when listing the publishes with --format json '
        'then an empty list is emitted', () async {
      await cli.run([
        'app',
        'list',
        '--project',
        _projectId,
        '--format',
        'json',
      ]);

      expect(logger.infoCalls, isEmpty);
      expect(jsonDecode(logger.rawCalls.single.content), isEmpty);
    });

    test('when listing the iOS builds then none are shown', () async {
      await cli.run([
        'app',
        'list',
        '--project',
        _projectId,
        '--platforms',
        'ios',
      ]);

      expect(
        logger.infoCalls.map((call) => call.message),
        contains('No iOS publishes yet.'),
      );
    });

    test(
      'when listing the iOS and Android builds then none are shown',
      () async {
        await cli.run([
          'app',
          'list',
          '--project',
          _projectId,
          '--platforms',
          'android,ios',
        ]);

        expect(
          logger.infoCalls.map((call) => call.message),
          contains('No iOS or Android publishes yet.'),
        );
      },
    );
  });

  group('Given an unknown project', () {
    setUp(() {
      when(
        () => client.appBuilds.listBuilds(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          platform: any(named: 'platform'),
          limit: any(named: 'limit'),
          afterBuildId: any(named: 'afterBuildId'),
        ),
      ).thenThrow(NotFoundException(message: 'Project not found.'));
    });

    test('when listing the publishes then the error is logged', () async {
      await cli
          .run(['app', 'list', '--project', _projectId])
          .catchError((_) {});

      expect(
        logger.errorCalls.map((call) => call.message),
        contains('Project not found.'),
      );
    });
  });

  group('Given app publishing is off', () {
    setUp(() {
      when(
        () => client.appBuilds.listBuilds(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          platform: any(named: 'platform'),
          limit: any(named: 'limit'),
          afterBuildId: any(named: 'afterBuildId'),
        ),
      ).thenThrow(
        AppPublishingDisabledException(message: 'App publishing is off.'),
      );
    });

    group('when listing the publishes', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run(['app', 'list', '--project', _projectId]);
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

/// Answers listBuilds from [builds], given newest first, the way Ground
/// Control filters and pages them.
void _stubListBuilds(ClientMock client, List<AppBuildSummary> builds) {
  when(
    () => client.appBuilds.listBuilds(
      cloudCapsuleId: any(named: 'cloudCapsuleId'),
      platform: any(named: 'platform'),
      limit: any(named: 'limit'),
      afterBuildId: any(named: 'afterBuildId'),
    ),
  ).thenAnswer((invocation) async {
    final platform = invocation.namedArguments[#platform] as AppPlatform?;
    final limit = invocation.namedArguments[#limit] as int;
    final afterBuildId = invocation.namedArguments[#afterBuildId] as UuidValue?;
    final platformBuilds = builds.where(
      (build) => platform == null || build.platform == platform,
    );
    final remaining = afterBuildId == null
        ? platformBuilds
        : platformBuilds.skipWhile((build) => build.id != afterBuildId).skip(1);
    return remaining.take(limit).toList();
  });
}
