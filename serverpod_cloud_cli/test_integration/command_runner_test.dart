import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cli_updater.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../test_utils/command_logger_matchers.dart';
import '../test_utils/fake_cli_updater.dart';
import '../test_utils/test_command_logger.dart';

const _updateAlert =
    'A new version 2.0.0 of Serverpod Cloud CLI is available!\n'
    '\n'
    'To update to the latest version, run "dart install serverpod_cloud_cli".';

const _nonBreakingAlert =
    'A new version 1.1.0 of Serverpod Cloud CLI is available!\n'
    '\n'
    'To update to the latest version, run "dart install serverpod_cloud_cli".';

void main() {
  final logger = TestCommandLogger();

  final testCacheFolderPath = p.join('test_integration', const Uuid().v4());

  tearDown(() {
    final directory = Directory(testCacheFolderPath);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }

    logger.clear();
  });

  final reportedErrors = <Object>[];

  tearDown(reportedErrors.clear);

  Future<CloudCliCommandRunner> createCli({
    required Version currentVersion,
    required Version latestVersion,
    FakeCliUpdater? updater,
    Version? attemptedUpdateVersion,
  }) async {
    await ResourceManager.storeLatestCliVersion(
      cliVersionData: PackageVersionData(
        latestVersion,
        DateTime.now().add(const Duration(days: 1)),
      ),
      logger: logger,
      localStoragePath: testCacheFolderPath,
    );

    return CloudCliCommandRunner.create(
      logger: logger,
      version: currentVersion,
      cliUpdater: updater ?? FakeCliUpdater(),
      attemptedUpdateVersion: attemptedUpdateVersion,
      onErrorReport: (error, stackTrace) async {
        reportedErrors.add(error);
      },
    );
  }

  group('Given the version is the latest when calling the cli', () {
    late FakeCliUpdater updater;
    late Future commandResult;

    setUp(() async {
      updater = FakeCliUpdater();
      final cli = await createCli(
        currentVersion: Version(1, 0, 0),
        latestVersion: Version(1, 0, 0),
        updater: updater,
      );

      commandResult = cli.run(['version', '--config-dir', testCacheFolderPath]);
    });

    test('then should complete', () async {
      await expectLater(commandResult, completes);
    });

    test('then should not install anything', () async {
      await commandResult;

      expect(updater.installCalls, isEmpty);
    });

    test('then should run the command in this process', () async {
      await commandResult;

      expect(
        logger.infoCalls.first,
        equalsInfoCall(message: 'Serverpod Cloud CLI version: 1.0.0'),
      );
    });
  });

  group('Given a newer non-breaking version when calling the cli', () {
    late FakeCliUpdater updater;
    late Future commandResult;

    setUp(() async {
      updater = FakeCliUpdater();
      final cli = await createCli(
        currentVersion: Version(1, 0, 0),
        latestVersion: Version(1, 1, 0),
        updater: updater,
      );

      commandResult = cli.run(['version', '--config-dir', testCacheFolderPath]);
    });

    test('then should complete', () async {
      await expectLater(commandResult, completes);
    });

    test('then should not install anything', () async {
      await commandResult;

      expect(updater.installCalls, isEmpty);
    });

    test('then should not rerun the command', () async {
      await commandResult;

      expect(updater.rerunCalls, isEmpty);
    });

    test('then should alert about the update', () async {
      await commandResult;

      expect(logger.boxCalls.first, equalsBoxCall(message: _nonBreakingAlert));
    });

    test('then should run the command on the current version', () async {
      await commandResult;

      expect(
        logger.infoCalls.first,
        equalsInfoCall(message: 'Serverpod Cloud CLI version: 1.0.0'),
      );
    });
  });

  group('Given a newer breaking version when calling the cli', () {
    late FakeCliUpdater updater;
    late Future commandResult;

    setUp(() async {
      updater = FakeCliUpdater();
      final cli = await createCli(
        currentVersion: Version(1, 0, 0),
        latestVersion: Version(2, 0, 0),
        updater: updater,
      );

      commandResult = cli.run(['version', '--config-dir', testCacheFolderPath]);
    });

    test('then should complete', () async {
      await expectLater(commandResult, completes);
    });

    test('then should install the latest version', () async {
      await commandResult;

      expect(updater.installCalls, [Version(2, 0, 0)]);
    });

    test('then should rerun the command', () async {
      await commandResult;

      expect(updater.rerunCalls, hasLength(1));
    });

    test('then should not alert about the update', () async {
      await commandResult;

      expect(logger.boxCalls, isEmpty);
    });
  });

  group('Given a newer version and the rerun cannot be started '
      'when calling the cli', () {
    late Future commandResult;

    setUp(() async {
      final cli = await createCli(
        currentVersion: Version(1, 0, 0),
        latestVersion: Version(2, 0, 0),
        updater: FakeCliUpdater(rerunSucceeds: false),
      );

      commandResult = cli.run(['version', '--config-dir', testCacheFolderPath]);
    });

    test('then should throw UnexpectedErrorExitException', () async {
      await expectLater(
        commandResult,
        throwsA(isA<UnexpectedErrorExitException>()),
      );
    });

    test('then should tell the user the command was not run again', () async {
      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));

      expect(logger.errorCalls, [
        equalsErrorCall(
          message:
              'The CLI was updated to 2.0.0,'
              ' but the command could not be run again.',
          hint: 'Run the command again.',
        ),
      ]);
    });
  });

  group('Given a newer version and the rerun exits with an error '
      'when calling the cli', () {
    late Future commandResult;

    setUp(() async {
      final cli = await createCli(
        currentVersion: Version(1, 0, 0),
        latestVersion: Version(2, 0, 0),
        updater: FakeCliUpdater(rerunExitCode: 3),
      );

      commandResult = cli.run(['version', '--config-dir', testCacheFolderPath]);
    });

    test(
      'then should throw ErrorExitException with the rerun exit code',
      () async {
        await expectLater(
          commandResult,
          throwsA(
            isA<ErrorExitException>().having((e) => e.exitCode, 'exitCode', 3),
          ),
        );
      },
    );
  });

  group(
    'Given a newer version when calling the cli with --exit-on-updated',
    () {
      late FakeCliUpdater updater;
      late Future commandResult;

      setUp(() async {
        updater = FakeCliUpdater();
        final cli = await createCli(
          currentVersion: Version(1, 0, 0),
          latestVersion: Version(2, 0, 0),
          updater: updater,
        );

        commandResult = cli.run([
          'version',
          '--config-dir',
          testCacheFolderPath,
          '--exit-on-updated',
        ]);
      });

      test('then should throw ErrorExitException with exit code 75', () async {
        await expectLater(
          commandResult,
          throwsA(
            isA<ErrorExitException>().having((e) => e.exitCode, 'exitCode', 75),
          ),
        );
      });

      test('then should install the latest version', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(updater.installCalls, [Version(2, 0, 0)]);
      });

      test('then should not rerun the command', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(updater.rerunCalls, isEmpty);
      });
    },
  );

  group('Given a newer breaking version and a failing install '
      'when calling the cli', () {
    late FakeCliUpdater updater;
    late Future commandResult;

    setUp(() async {
      updater = FakeCliUpdater(installSucceeds: false);
      final cli = await createCli(
        currentVersion: Version(1, 0, 0),
        latestVersion: Version(2, 0, 0),
        updater: updater,
      );

      commandResult = cli.run(['version', '--config-dir', testCacheFolderPath]);
    });

    test('then should throw ErrorExitException with exit code 69', () async {
      await expectLater(
        commandResult,
        throwsA(
          isA<ErrorExitException>().having((e) => e.exitCode, 'exitCode', 69),
        ),
      );
    });

    test('then should alert that the update is required', () async {
      try {
        await commandResult;
      } catch (_) {}

      expect(
        logger.boxCalls.first,
        equalsBoxCall(
          message: '$_updateAlert You need to update the CLI to continue.',
        ),
      );
    });

    test('then should not rerun the command', () async {
      try {
        await commandResult;
      } catch (_) {}

      expect(updater.rerunCalls, isEmpty);
    });

    test('then should report the failure for diagnostics', () async {
      try {
        await commandResult;
      } catch (_) {}

      expect(reportedErrors.single, isA<CliUpdateFailedException>());
    });
  });

  group('Given a newer breaking version and a failing install when calling '
      'the cli with --no-breaking-version-check', () {
    late Future commandResult;

    setUp(() async {
      final cli = await createCli(
        currentVersion: Version(1, 0, 0),
        latestVersion: Version(2, 0, 0),
        updater: FakeCliUpdater(installSucceeds: false),
      );

      commandResult = cli.run([
        'version',
        '--config-dir',
        testCacheFolderPath,
        '--no-breaking-version-check',
      ]);
    });

    test('then should complete', () async {
      await expectLater(commandResult, completes);
    });

    test('then should alert about the update', () async {
      await commandResult;

      expect(logger.boxCalls.first, equalsBoxCall(message: _updateAlert));
    });

    test('then should run the command on the current version', () async {
      await commandResult;

      expect(
        logger.infoCalls.first,
        equalsInfoCall(message: 'Serverpod Cloud CLI version: 1.0.0'),
      );
    });
  });

  group('Given a CLI that cannot update itself and a newer breaking version '
      'when calling the cli', () {
    late FakeCliUpdater updater;
    late Future commandResult;

    setUp(() async {
      updater = FakeCliUpdater(canSelfUpdate: false);
      final cli = await createCli(
        currentVersion: Version(1, 0, 0),
        latestVersion: Version(2, 0, 0),
        updater: updater,
      );

      commandResult = cli.run(['version', '--config-dir', testCacheFolderPath]);
    });

    test('then should not install anything', () async {
      try {
        await commandResult;
      } catch (_) {}

      expect(updater.installCalls, isEmpty);
    });

    test('then should alert that the update is required', () async {
      try {
        await commandResult;
      } catch (_) {}

      expect(
        logger.boxCalls.first,
        equalsBoxCall(
          message: '$_updateAlert You need to update the CLI to continue.',
        ),
      );
    });

    test('then should throw ErrorExitException with exit code 69', () async {
      await expectLater(
        commandResult,
        throwsA(
          isA<ErrorExitException>().having((e) => e.exitCode, 'exitCode', 69),
        ),
      );
    });

    test('then should not report anything for diagnostics', () async {
      try {
        await commandResult;
      } catch (_) {}

      expect(reportedErrors, isEmpty);
    });
  });

  group('Given the update to the available version was already attempted '
      'when calling the cli', () {
    late FakeCliUpdater updater;
    late Future commandResult;

    setUp(() async {
      updater = FakeCliUpdater();
      final cli = await createCli(
        currentVersion: Version(1, 0, 0),
        latestVersion: Version(2, 0, 0),
        updater: updater,
        attemptedUpdateVersion: Version(2, 0, 0),
      );

      commandResult = cli.run(['version', '--config-dir', testCacheFolderPath]);
    });

    test('then should not install anything', () async {
      try {
        await commandResult;
      } catch (_) {}

      expect(updater.installCalls, isEmpty);
    });

    test('then should not rerun the command', () async {
      try {
        await commandResult;
      } catch (_) {}

      expect(updater.rerunCalls, isEmpty);
    });

    test('then should throw ErrorExitException with exit code 69', () async {
      await expectLater(
        commandResult,
        throwsA(
          isA<ErrorExitException>().having((e) => e.exitCode, 'exitCode', 69),
        ),
      );
    });
  });

  group('Given an older update attempt than the available version '
      'when calling the cli', () {
    late FakeCliUpdater updater;
    late Future commandResult;

    setUp(() async {
      updater = FakeCliUpdater();
      final cli = await createCli(
        currentVersion: Version(1, 0, 0),
        latestVersion: Version(2, 0, 0),
        updater: updater,
        attemptedUpdateVersion: Version(1, 5, 0),
      );

      commandResult = cli.run(['version', '--config-dir', testCacheFolderPath]);
    });

    test('then should install the latest version', () async {
      await commandResult;

      expect(updater.installCalls, [Version(2, 0, 0)]);
    });
  });
}
