import 'dart:async';
import 'dart:convert';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/storage/storage_command.dart';
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

  tearDown(() async {
    logger.clear();
    reset(client.bucket);
  });

  const projectId = 'projectId';

  test('Given storage list command when instantiated then requires login', () {
    expect(CloudStorageListCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given unauthenticated', () {
    setUp(() {
      when(
        () => client.bucket.listBuckets(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
        ),
      ).thenThrow(ServerpodClientUnauthorized());
    });

    group('when executing storage list', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run(['storage', 'list', '--project', projectId]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });
    });

    group('when executing storage list with --format json', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'storage',
          'list',
          '--project',
          projectId,
          '--format',
          'json',
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then emits a JSON error for the unauthorized exception', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.lineCalls, isEmpty);
        expect(logger.rawCalls, isEmpty);
        expect(logger.errorCalls, isNotEmpty);
        final payload = jsonDecode(logger.errorCalls.single.message);
        expect(payload, contains('Failed to list storages'));
        expect(payload, contains('Unauthorized'));
      });
    });

    group('when executing storage list with --format yaml', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'storage',
          'list',
          '--project',
          projectId,
          '--format',
          'yaml',
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then emits a YAML error for the unauthorized exception', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.lineCalls, isEmpty);
        expect(logger.rawCalls, isEmpty);
        expect(logger.errorCalls, isNotEmpty);
        expect(
          logger.errorCalls.single.message,
          contains('Failed to list storages'),
        );
        expect(logger.errorCalls.single.message, contains('Unauthorized'));
      });
    });
  });

  group('Given authenticated and a project with two storages', () {
    setUp(() {
      when(
        () => client.bucket.listBuckets(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
        ),
      ).thenAnswer(
        (_) async => [
          BucketResourceBuilder()
              .withStorageId('public')
              .withVisibility(BucketVisibility.public)
              .build(),
          BucketResourceBuilder()
              .withStorageId('private')
              .withVisibility(BucketVisibility.private)
              .build(),
        ],
      );
    });

    group('when executing storage list', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run(['storage', 'list', '--project', projectId]);
      });

      test('then queries the storages of the project', () async {
        await commandResult;

        verify(
          () => client.bucket.listBuckets(cloudCapsuleId: projectId),
        ).called(1);
      });

      test('then prints the table headers', () async {
        await commandResult;

        expect(
          logger.lineCalls.first.line,
          allOf(
            contains('Storage Id'),
            contains('Access'),
            contains('Region'),
            contains('Status'),
          ),
        );
      });

      test('then prints the storages sorted by storage id', () async {
        await commandResult;

        final rows = logger.lineCalls
            .map((call) => call.line)
            .where((line) => line.contains('Ready'))
            .toList();
        expect(rows, hasLength(2));
        expect(rows[0], contains('private'));
        expect(rows[1], contains('public'));
      });

      test('then prints the access labels', () async {
        await commandResult;

        final lines = logger.lineCalls.map((call) => call.line).toList();
        expect(lines.any((line) => line.contains('Private')), isTrue);
        expect(lines.any((line) => line.contains('Public')), isTrue);
      });
    });

    group('when executing storage list with --format json', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'storage',
          'list',
          '--project',
          projectId,
          '--format',
          'json',
        ]);
      });

      test('then emits a JSON list of storages', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        final payload = jsonDecode(logger.rawCalls.single.content) as List;
        expect(payload, hasLength(2));

        final first = payload.first as Map;
        expect(first['storageId'], 'private');
        expect(first['visibility'], 'private');
        expect(first['status'], 'provisioned');
        expect(first, contains('region'));
      });
    });

    group('when executing storage list with --format yaml', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'storage',
          'list',
          '--project',
          projectId,
          '--format',
          'yaml',
        ]);
      });

      test('then emits a YAML list of storages', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        final payload = yamlDecode(logger.rawCalls.single.content) as List;
        expect(payload, hasLength(2));
        expect((payload.first as Map)['storageId'], 'private');
        expect((payload.first as Map)['visibility'], 'private');
      });
    });
  });

  group('Given authenticated and a storage that is being created', () {
    setUp(() {
      when(
        () => client.bucket.listBuckets(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
        ),
      ).thenAnswer(
        (_) async => [
          BucketResourceBuilder().withStatus(BucketStatus.created).build(),
        ],
      );
    });

    group('when executing storage list', () {
      test('then the status is shown as Creating', () async {
        await cli.run(['storage', 'list', '--project', projectId]);

        expect(
          logger.lineCalls.map((call) => call.line).join('\n'),
          contains('Creating'),
        );
      });
    });
  });

  group('Given authenticated and a storage that is being deleted', () {
    setUp(() {
      when(
        () => client.bucket.listBuckets(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
        ),
      ).thenAnswer(
        (_) async => [
          BucketResourceBuilder()
              .withStatus(BucketStatus.deletionRequested)
              .build(),
        ],
      );
    });

    group('when executing storage list', () {
      test('then the status is shown as Deleting', () async {
        await cli.run(['storage', 'list', '--project', projectId]);

        expect(
          logger.lineCalls.map((call) => call.line).join('\n'),
          contains('Deleting'),
        );
      });
    });
  });

  group('Given authenticated and a storage with revoked access', () {
    setUp(() {
      when(
        () => client.bucket.listBuckets(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
        ),
      ).thenAnswer(
        (_) async => [
          BucketResourceBuilder()
              .withAccessRevoked(
                reason: BucketAccessRevocationReason.storageOverage,
              )
              .build(),
        ],
      );
    });

    group('when executing storage list', () {
      test('then the status shows the revocation reason', () async {
        await cli.run(['storage', 'list', '--project', projectId]);

        expect(
          logger.lineCalls.map((call) => call.line).join('\n'),
          contains('Access revoked (storage overage)'),
        );
      });
    });
  });

  group('Given authenticated and a project without storages', () {
    setUp(() {
      when(
        () => client.bucket.listBuckets(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
        ),
      ).thenAnswer((_) async => []);
    });

    group('when executing storage list', () {
      test('then informs that there are no storages', () async {
        await cli.run(['storage', 'list', '--project', projectId]);

        expect(logger.lineCalls, isEmpty);
        expect(
          logger.infoCalls.single,
          equalsInfoCall(message: 'No storages available.'),
        );
        expect(
          logger.terminalCommandCalls.single,
          equalsTerminalCommandCall(
            command: 'scloud storage create <storage-id>',
            message: 'Create one with:',
          ),
        );
      });
    });

    group('when executing storage list with --format json', () {
      test('then emits an empty JSON array', () async {
        await cli.run([
          'storage',
          'list',
          '--project',
          projectId,
          '--format',
          'json',
        ]);

        expect(logger.lineCalls, isEmpty);
        expect(logger.infoCalls, isEmpty);
        expect(jsonDecode(logger.rawCalls.single.content), <Object?>[]);
      });
    });
  });

  group('Given authenticated and a project that does not exist', () {
    setUp(() {
      when(
        () => client.bucket.listBuckets(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
        ),
      ).thenThrow(NotFoundException(message: 'no such project'));
    });

    group('when executing storage list', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run(['storage', 'list', '--project', projectId]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs the project not found error with a hint', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(
          logger.errorCalls.single,
          equalsErrorCall(
            message: 'Project "projectId" was not found.',
            hint: 'Run "scloud project list" to see your projects.',
          ),
        );
      });
    });
  });
}
