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
    reset(client.bucketObjects);
  });

  const projectId = 'projectId';
  const storageId = 'public';

  void stubListFiles(final BucketFileListing listing) {
    when(
      () => client.bucketObjects.listFiles(
        cloudCapsuleId: any(named: 'cloudCapsuleId'),
        storageId: any(named: 'storageId'),
        prefix: any(named: 'prefix'),
        pageToken: any(named: 'pageToken'),
      ),
    ).thenAnswer((_) async => listing);
  }

  test(
    'Given storage file list command when instantiated then requires login',
    () {
      expect(CloudStorageFileListCommand(logger: logger).requireLogin, isTrue);
    },
  );

  group('Given unauthenticated', () {
    setUp(() {
      when(
        () => client.bucketObjects.listFiles(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          storageId: any(named: 'storageId'),
          prefix: any(named: 'prefix'),
          pageToken: any(named: 'pageToken'),
        ),
      ).thenThrow(ServerpodClientUnauthorized());
    });

    group('when executing storage file list', () {
      test('then throws exception', () async {
        await expectLater(
          cli.run(['storage', 'file', 'list', storageId, '-p', projectId]),
          throwsA(isA<ErrorExitException>()),
        );
      });
    });
  });

  group('Given a storage with two files on one page', () {
    setUp(() {
      stubListFiles(
        BucketFileListing(
          files: [
            BucketFileBuilder()
                .withName('docs/report.pdf')
                .withSizeBytes(1500000)
                .build(),
            BucketFileBuilder()
                .withName('avatars/u1.png')
                .withSizeBytes(34000)
                .build(),
          ],
        ),
      );
    });

    group('when executing storage file list', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'storage',
          'file',
          'list',
          storageId,
          '-p',
          projectId,
        ]);
      });

      test('then prints the table headers', () async {
        await commandResult;

        expect(
          logger.lineCalls.first.line,
          allOf(contains('Name'), contains('Size'), contains('Last Modified')),
        );
      });

      test('then prints the files sorted by name', () async {
        await commandResult;

        final rows = logger.lineCalls
            .map((final call) => call.line)
            .where((final line) => line.contains('/'))
            .toList();
        expect(rows, hasLength(2));
        expect(rows[0], contains('avatars/u1.png'));
        expect(rows[1], contains('docs/report.pdf'));
      });

      test('then prints the file sizes in decimal units', () async {
        await commandResult;

        final lines = logger.lineCalls
            .map((final call) => call.line)
            .join('\n');
        expect(lines, contains('34.0 kB'));
        expect(lines, contains('1.5 MB'));
      });

      test('then lists every file in the storage', () async {
        await commandResult;

        verify(
          () => client.bucketObjects.listFiles(
            cloudCapsuleId: projectId,
            storageId: storageId,
            prefix: null,
            pageToken: null,
          ),
        ).called(1);
      });
    });

    group('when executing storage file list with --tree', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'storage',
          'file',
          'list',
          storageId,
          '-p',
          projectId,
          '--tree',
        ]);
      });

      test('then prints a tree instead of a table', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        final tree = logger.rawCalls.map((final call) => call.content).join();
        expect(tree, contains('├─'));
        expect(tree, contains('╰─'));
        expect(tree, contains('avatars'));
        expect(tree, contains('u1.png'));
        expect(tree, contains('report.pdf'));
      });
    });

    group('when executing storage file list with --utc', () {
      test('then the timestamps are shown in UTC', () async {
        await cli.run([
          'storage',
          'file',
          'list',
          storageId,
          '-p',
          projectId,
          '--utc',
        ]);

        final rows = logger.lineCalls
            .map((final call) => call.line)
            .where((final line) => line.contains('/'))
            .toList();
        expect(rows.first.trimRight(), endsWith('z'));
      });
    });

    group('when executing storage file list with --format json', () {
      test('then emits a JSON list of files', () async {
        await cli.run([
          'storage',
          'file',
          'list',
          storageId,
          '-p',
          projectId,
          '--format',
          'json',
        ]);

        expect(logger.lineCalls, isEmpty);
        final payload = jsonDecode(logger.rawCalls.single.content) as List;
        expect(payload, hasLength(2));

        final first = payload.first as Map;
        expect(first['name'], 'avatars/u1.png');
        expect(first['sizeBytes'], 34000);
        expect(first['updated'], '2026-07-20T10:00:00.000Z');
      });

      test('then --tree does not change the structured output', () async {
        await cli.run([
          'storage',
          'file',
          'list',
          storageId,
          '-p',
          projectId,
          '--tree',
          '--format',
          'json',
        ]);

        final payload = jsonDecode(logger.rawCalls.single.content) as List;
        expect(payload, hasLength(2));
        expect((payload.first as Map)['name'], 'avatars/u1.png');
      });
    });

    group('when executing storage file list with --format yaml', () {
      test('then emits a YAML list of files', () async {
        await cli.run([
          'storage',
          'file',
          'list',
          storageId,
          '-p',
          projectId,
          '--format',
          'yaml',
        ]);

        expect(logger.lineCalls, isEmpty);
        final payload = yamlDecode(logger.rawCalls.single.content) as List;
        expect(payload, hasLength(2));
        expect((payload.first as Map)['name'], 'avatars/u1.png');
        expect((payload.first as Map)['sizeBytes'], 34000);
      });
    });
  });

  group('Given a storage whose files span two pages', () {
    setUp(() {
      when(
        () => client.bucketObjects.listFiles(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          storageId: any(named: 'storageId'),
          prefix: any(named: 'prefix'),
          pageToken: null,
        ),
      ).thenAnswer(
        (_) async => BucketFileListing(
          files: [BucketFileBuilder().withName('a.txt').build()],
          nextPageToken: 'p2',
        ),
      );
      when(
        () => client.bucketObjects.listFiles(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          storageId: any(named: 'storageId'),
          prefix: any(named: 'prefix'),
          pageToken: 'p2',
        ),
      ).thenAnswer(
        (_) async => BucketFileListing(
          files: [BucketFileBuilder().withName('b.txt').build()],
        ),
      );
    });

    group('when executing storage file list', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'storage',
          'file',
          'list',
          storageId,
          '-p',
          projectId,
        ]);
      });

      test('then follows the page token', () async {
        await commandResult;

        verify(
          () => client.bucketObjects.listFiles(
            cloudCapsuleId: projectId,
            storageId: storageId,
            prefix: null,
            pageToken: 'p2',
          ),
        ).called(1);
      });

      test('then prints the files from both pages', () async {
        await commandResult;

        final lines = logger.lineCalls
            .map((final call) => call.line)
            .join('\n');
        expect(lines, contains('a.txt'));
        expect(lines, contains('b.txt'));
      });
    });
  });

  group('Given a folder path argument', () {
    setUp(() {
      stubListFiles(BucketFileListing(files: []));
    });

    for (final (input, prefix) in [
      ('docs', 'docs/'),
      ('docs/', 'docs/'),
      ('/docs/', 'docs/'),
    ]) {
      group('when listing the folder "$input"', () {
        test('then the request uses the prefix "$prefix"', () async {
          await cli.run([
            'storage',
            'file',
            'list',
            storageId,
            input,
            '-p',
            projectId,
          ]);

          verify(
            () => client.bucketObjects.listFiles(
              cloudCapsuleId: projectId,
              storageId: storageId,
              prefix: prefix,
              pageToken: null,
            ),
          ).called(1);
        });
      });
    }
  });

  group('Given an empty storage', () {
    setUp(() {
      stubListFiles(BucketFileListing(files: []));
    });

    group('when executing storage file list', () {
      test('then informs that the folder is empty', () async {
        await cli.run(['storage', 'file', 'list', storageId, '-p', projectId]);

        expect(logger.lineCalls, isEmpty);
        expect(
          logger.infoCalls.single,
          equalsInfoCall(message: 'This folder is empty.'),
        );
      });
    });

    group('when executing storage file list with --format json', () {
      test('then emits an empty JSON array', () async {
        await cli.run([
          'storage',
          'file',
          'list',
          storageId,
          '-p',
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

  group('Given a storage that does not exist', () {
    late Future commandResult;

    setUp(() async {
      when(
        () => client.bucketObjects.listFiles(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          storageId: any(named: 'storageId'),
          prefix: any(named: 'prefix'),
          pageToken: any(named: 'pageToken'),
        ),
      ).thenThrow(NotFoundException(message: 'no such storage'));

      commandResult = cli.run([
        'storage',
        'file',
        'list',
        storageId,
        '-p',
        projectId,
      ]);
    });

    test('then throws exception', () async {
      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
    });

    test('then logs the storage not found error with a hint', () async {
      try {
        await commandResult;
      } catch (_) {}

      expect(
        logger.errorCalls.single,
        equalsErrorCall(
          message: 'Storage "public" was not found in project "projectId".',
          hint: 'Run "scloud storage list" to see the storages of the project.',
        ),
      );
    });
  });
}
