import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_auth_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final cli = CloudCliCommandRunner.create(
    logger: logger,
  );

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

  group('Given stored credentials', () {
    setUp(() async {
      await ResourceManager.storeServerpodCloudAuthData(
        authData: ServerpodCloudAuthData('my-token'),
        localStoragePath: testCacheFolderPath,
      );
    });

    tearDown(() async {
      await ResourceManager.removeServerpodCloudAuthData(
        localStoragePath: testCacheFolderPath,
      );
    });

    test(
        'when logging in through cli then ErrorExitException with exit code 1 is thrown.',
        () async {
      final result =
          cli.run(['auth', 'login', '--scloud-dir', testCacheFolderPath]);

      await expectLater(
          result,
          throwsA(
            isA<ErrorExitException>()
                .having((final e) => e.exitCode, 'exitCode', equals(1)),
          ));
    });

    test(
        'when logging in through cli then "logout first to log in again" message is logged.',
        () async {
      try {
        await cli.run(['auth', 'login', '--scloud-dir', testCacheFolderPath]);
      } catch (_) {}

      expect(logger.errorCalls, isNotEmpty);
      expect(
        logger.errorCalls.first,
        equalsErrorCall(
          message: 'Detected an existing login session for Serverpod cloud. '
              'Log out first to log in again.',
        ),
      );
      expect(logger.terminalCommandCalls, isNotEmpty);
      expect(
        logger.terminalCommandCalls.first,
        equalsTerminalCommandCall(
          command: 'scloud auth logout',
        ),
      );
    });
  });

  group('Given response with token', () {
    const testToken = 'myTestToken';
    late Completer tokenSent;
    setUp(() async {
      tokenSent = Completer();
      final loggerFuture = logger.waitForLog();
      unawaited(loggerFuture.then((final _) async {
        assert(logger.infoCalls.isNotEmpty, 'Expected log info messages.');
        final loggedMessage = logger.infoCalls.first.message;
        final splitMessage = loggedMessage.split('callback=');
        assert(
            splitMessage.length == 2, 'Expected callback URL in log message.');

        final callbackUrl = Uri.parse(Uri.decodeFull(splitMessage[1]));
        final urlWithToken =
            callbackUrl.replace(queryParameters: {'token': testToken});
        final response = await http.get(urlWithToken);
        assert(response.statusCode == 200,
            'Expected token response to have status code 200.');
        tokenSent.complete();
      }));
    });

    group('when logging in through cli', () {
      late Future cliOnDone;
      setUp(() async {
        cliOnDone = cli.run([
          'auth',
          'login',
          '--no-browser',
          '--scloud-dir',
          testCacheFolderPath
        ]);
      });

      tearDown(() async {
        await ResourceManager.removeServerpodCloudAuthData(
          localStoragePath: testCacheFolderPath,
        );
      });

      test('then cli command completes.', () async {
        await tokenSent.future;

        await expectLater(cliOnDone, completes);
      });

      test('then the cloud data with token is stored.', () async {
        await tokenSent.future;

        await cliOnDone;

        final storedCloudData =
            await ResourceManager.tryFetchServerpodCloudAuthData(
          logger: logger,
          localStoragePath: testCacheFolderPath,
        );
        expect(storedCloudData?.token, testToken);
      });
    });

    group('when logging in through cli with --no-persistent flag', () {
      late Future cliOnDone;
      setUp(() async {
        cliOnDone = cli.run([
          'auth',
          'login',
          '--no-persistent',
          '--no-browser',
          '--scloud-dir',
          testCacheFolderPath,
        ]);
      });

      tearDown(() async {
        await ResourceManager.removeServerpodCloudAuthData(
          localStoragePath: testCacheFolderPath,
        );
      });

      test('then cli command completes.', () async {
        await tokenSent.future;

        await expectLater(cliOnDone, completes);
      });

      test('then no cloud data is stored.', () async {
        await tokenSent.future;

        await cliOnDone;

        final storedCloudData =
            await ResourceManager.tryFetchServerpodCloudAuthData(
          logger: logger,
          localStoragePath: testCacheFolderPath,
        );
        expect(storedCloudData, isNull);
      });
    });
  });

  group('Given response without token', () {
    late Completer tokenSent;
    setUp(() async {
      tokenSent = Completer();
      final loggerFuture = logger.waitForLog();
      unawaited(loggerFuture.then((final _) async {
        final loggedMessage = logger.infoCalls.first.message;
        final splitMessage = loggedMessage.split('callback=');
        assert(
            splitMessage.length == 2, 'Expected callback URL in log message.');

        final callbackUrl = Uri.parse(Uri.decodeFull(splitMessage[1]));
        final response = await http.get(callbackUrl);
        assert(response.statusCode == 200,
            'Expected token response to have status code 200.');

        tokenSent.complete();
      }));
    });

    group('when logging in through cli', () {
      tearDown(() async {
        await ResourceManager.removeServerpodCloudAuthData(
          localStoragePath: testCacheFolderPath,
        );
      });

      test('then cli command completes throws an exit exception.', () async {
        final cliOnDone = cli.run([
          'auth',
          'login',
          '--no-browser',
          '--scloud-dir',
          testCacheFolderPath
        ]);

        await expectLater(
          Future.wait([
            cliOnDone,
            tokenSent.future,
          ]),
          throwsA(isA<ErrorExitException>()),
        );
      });

      test('then no cloud data is stored.', () async {
        final cliOnDone = cli.run([
          'auth',
          'login',
          '--no-browser',
          '--scloud-dir',
          testCacheFolderPath
        ]);

        // Silence the error message.
        final cliFuture = cliOnDone.catchError((final _) {});

        await tokenSent.future;

        await cliFuture;

        final storedCloudData =
            await ResourceManager.tryFetchServerpodCloudAuthData(
          logger: logger,
          localStoragePath: testCacheFolderPath,
        );
        expect(storedCloudData, isNull);
      });
    });
  });
}
