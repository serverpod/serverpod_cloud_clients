import 'dart:async';
import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../../test_utils/command_logger_matchers.dart';
import '../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final version = Version.parse('0.0.1');
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    version: version,
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
      await ResourceManager.storeServerpodCloudData(
        cloudData: ServerpodCloudData('my-token'),
        localStoragePath: testCacheFolderPath,
      );
    });

    tearDown(() async {
      await ResourceManager.removeServerpodCloudData(
        localStoragePath: testCacheFolderPath,
      );
    });

    test(
        'when logging in through cli then "logout first to log in again" message is logged.',
        () async {
      await cli.run(['login', '--auth-dir', testCacheFolderPath]);

      expect(logger.infoCalls, isNotEmpty);
      expect(
        logger.infoCalls.first,
        equalsInfoCall(
          message: 'Detected an existing login session for Serverpod cloud. '
              'Log out first to log in again.',
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
        cliOnDone = cli
            .run(['login', '--no-browser', '--auth-dir', testCacheFolderPath]);
        await tokenSent.future;
      });

      tearDown(() async {
        await ResourceManager.removeServerpodCloudData(
          localStoragePath: testCacheFolderPath,
        );
      });

      test('then cli command completes.', () async {
        await expectLater(cliOnDone, completes);
      });

      test('then the cloud data with token is stored.', () async {
        await cliOnDone;
        final storedCloudData =
            await ResourceManager.tryFetchServerpodCloudData(
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
          'login',
          '--no-persistent',
          '--no-browser',
          '--auth-dir',
          testCacheFolderPath,
        ]);
        await tokenSent.future;
      });

      tearDown(() async {
        await ResourceManager.removeServerpodCloudData(
          localStoragePath: testCacheFolderPath,
        );
      });

      test('then cli command completes.', () async {
        await expectLater(cliOnDone, completes);
      });

      test('then no cloud data is stored.', () async {
        await cliOnDone;
        final storedCloudData =
            await ResourceManager.tryFetchServerpodCloudData(
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
      late Future cliOnDone;
      setUp(() async {
        cliOnDone = cli
            .run(['login', '--no-browser', '--auth-dir', testCacheFolderPath]);
        await tokenSent.future;
      });

      tearDown(() async {
        await ResourceManager.removeServerpodCloudData(
          localStoragePath: testCacheFolderPath,
        );
      });

      test('then cli command completes throws an exit exception.', () async {
        await expectLater(cliOnDone, throwsA(isA<ExitException>()));
      });

      test('then no cloud data is stored.', () async {
        // Silence the error message.
        await cliOnDone.catchError((final _) {});
        final storedCloudData =
            await ResourceManager.tryFetchServerpodCloudData(
          logger: logger,
          localStoragePath: testCacheFolderPath,
        );
        expect(storedCloudData, isNull);
      });
    });
  });
}
