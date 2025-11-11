import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';

import '../test_utils/command_logger_matchers.dart';
import '../test_utils/mock_http_client.dart';
import '../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();

  final testCacheFolderPath = p.join(
    'test_integration',
    const Uuid().v4(),
  );

  tearDown(() {
    final directory = Directory(testCacheFolderPath);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }

    logger.clear();
  });

  group('Given version is the latest when calling the cli', () {
    late Future commandResult;
    setUp(() async {
      await ResourceManager.storeLatestCliVersion(
        cliVersionData: PackageVersionData(
          Version(1, 0, 0),
          DateTime.now().add(
            Duration(days: 1),
          ),
        ),
        logger: logger,
        localStoragePath: testCacheFolderPath,
      );
      final cli = CloudCliCommandRunner.create(
        logger: logger,
        version: Version(1, 0, 0),
      );

      commandResult = cli.run([
        'version',
        '--config-dir',
        testCacheFolderPath,
      ]);
    });

    test('then should complete', () async {
      await expectLater(
        commandResult,
        completes,
      );
    });

    test('then should not log any update info', () async {
      try {
        await commandResult;
      } catch (_) {}

      expect(
        logger.boxCalls,
        isEmpty,
      );
    });
  });

  group(
      'Given latest version cannot be checked (e.g. offline)'
      'when calling the cli', () {
    late Future commandResult;
    setUp(() async {
      final cli = CloudCliCommandRunner.create(
        logger: logger,
        version: Version(1, 0, 0),
      );

      commandResult = HttpOverrides.runZoned(
        () async {
          return cli.run([
            'version',
            '--config-dir',
            testCacheFolderPath,
          ]);
        },
        createHttpClient: (final _) => MockOfflineHttpClient(),
      );
    });

    test('then should complete', () async {
      await expectLater(
        commandResult,
        completes,
      );
    });

    test('then should not log any update info', () async {
      try {
        await commandResult;
      } catch (_) {}

      expect(
        logger.boxCalls,
        isEmpty,
      );
    });
  });

  group(
      'Given latest and actual major version is same and greater than 0 and minor version outdated '
      'when calling the cli', () {
    late Future commandResult;

    setUp(() async {
      await ResourceManager.storeLatestCliVersion(
        cliVersionData: PackageVersionData(
          Version(1, 1, 0),
          DateTime.now().add(
            Duration(days: 1),
          ),
        ),
        logger: logger,
        localStoragePath: testCacheFolderPath,
      );
      final cli = CloudCliCommandRunner.create(
        logger: logger,
        version: Version(1, 0, 0),
      );

      commandResult = cli.run([
        'version',
        '--config-dir',
        testCacheFolderPath,
      ]);
    });

    test('then should complete', () async {
      await expectLater(
        commandResult,
        completes,
      );
    });

    test('then should inform about update', () async {
      try {
        await commandResult;
      } catch (_) {}

      expect(
        logger.boxCalls.first,
        equalsBoxCall(
          message: 'A new version 1.1.0 of Serverpod Cloud CLI is available!\n'
              '\n'
              'To update to the latest version, run "dart pub global activate serverpod_cloud_cli".',
        ),
      );
    });
  });

  group(
      'Given latest and actual major version is 0 and minor version outdated '
      'when calling the cli ', () {
    late Future commandResult;

    setUp(() async {
      await ResourceManager.storeLatestCliVersion(
        cliVersionData: PackageVersionData(
          Version(0, 1, 0),
          DateTime.now().add(
            Duration(days: 1),
          ),
        ),
        logger: logger,
        localStoragePath: testCacheFolderPath,
      );
      final cli = CloudCliCommandRunner.create(
        logger: logger,
        version: Version(0, 0, 0),
      );

      commandResult = cli.run([
        'version',
        '--config-dir',
        testCacheFolderPath,
      ]);
    });

    test('then should throw exit exception', () async {
      await expectLater(
        commandResult,
        throwsA(isA<ErrorExitException>()),
      );
    });

    test('then should require update', () async {
      try {
        await commandResult;
      } catch (_) {}

      expect(logger.totalLogCalls, 1);
      expect(
        logger.boxCalls.first,
        equalsBoxCall(
          message: 'A new version 0.1.0 of Serverpod Cloud CLI is available!\n'
              '\n'
              'To update to the latest version, run "dart pub global activate serverpod_cloud_cli". '
              'You need to update the CLI to continue.',
        ),
      );
    });
  });

  group('Given major version is outdated when calling the cli', () {
    late Future commandResult;
    setUp(() async {
      await ResourceManager.storeLatestCliVersion(
        cliVersionData: PackageVersionData(
          Version(2, 0, 0),
          DateTime.now().add(
            Duration(days: 1),
          ),
        ),
        logger: logger,
        localStoragePath: testCacheFolderPath,
      );
      final cli = CloudCliCommandRunner.create(
        logger: logger,
        version: Version(1, 0, 0),
      );

      commandResult = cli.run([
        'version',
        '--config-dir',
        testCacheFolderPath,
      ]);
    });

    test('then should throw exception', () async {
      await expectLater(
        commandResult,
        throwsA(isA<ErrorExitException>()),
      );
    });

    test('then should require update', () async {
      try {
        await commandResult;
      } catch (_) {}

      expect(logger.totalLogCalls, 1);
      expect(
        logger.boxCalls.first,
        equalsBoxCall(
          message: 'A new version 2.0.0 of Serverpod Cloud CLI is available!\n'
              '\n'
              'To update to the latest version, run "dart pub global activate serverpod_cloud_cli". '
              'You need to update the CLI to continue.',
        ),
      );
    });
  });
}
