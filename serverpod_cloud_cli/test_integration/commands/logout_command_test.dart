import 'dart:async';
import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../../test_utils/http_server_builder.dart';
import '../../test_utils/test_logger.dart';

void main() {
  final logger = TestLogger();
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

  group('Given stored credentials and successful sign out http response', () {
    late Uri localServerAddress;
    late Completer signOutRequestCompleter;
    late HttpServer server;

    setUp(() async {
      signOutRequestCompleter = Completer();
      await ResourceManager.storeServerpodCloudData(
        cloudData: ServerpodCloudData('my-token'),
        localStoragePath: testCacheFolderPath,
      );

      final serverBuilder = HttpServerBuilder();
      serverBuilder.withOnRequest((final request) {
        signOutRequestCompleter.complete();
        request.response.statusCode = 200;
        request.response.close();
      });

      final (startedServer, serverAddress) = await serverBuilder.build();
      localServerAddress = serverAddress;
      server = startedServer;
    });

    tearDown(() async {
      await server.close(force: true);
    });

    group('when logging out through cli', () {
      late Future runLogoutCommand;
      setUp(() {
        runLogoutCommand = cli.run([
          'logout',
          '--api-url',
          localServerAddress.toString(),
          '--auth-dir',
          testCacheFolderPath,
        ]);
      });

      test('then the stored credentials are removed', () async {
        await runLogoutCommand;

        final cloudData = await ResourceManager.tryFetchServerpodCloudData(
          localStoragePath: testCacheFolderPath,
          logger: logger,
        );

        expect(cloudData, isNull);
      });

      test('then a sign out request is sent', () async {
        await runLogoutCommand;

        await expectLater(signOutRequestCompleter.future, completes);
      });

      test('then a "logged out" message is logged', () async {
        await runLogoutCommand;

        expect(logger.messages, isNotEmpty);
        expect(
          logger.messages.first,
          'Successfully logged out from Serverpod cloud.',
        );
      });
    });
  });

  group('Given stored credentials and failed sign out http response', () {
    late Uri localServerAddress;
    late Completer signOutRequestCompleter;
    late HttpServer server;
    setUp(() async {
      signOutRequestCompleter = Completer();
      await ResourceManager.storeServerpodCloudData(
        cloudData: ServerpodCloudData('my-token'),
        localStoragePath: testCacheFolderPath,
      );

      final serverBuilder = HttpServerBuilder();
      serverBuilder.withOnRequest((final request) {
        signOutRequestCompleter.complete();
        // Responds with 404 to simulate a failed sign out request.
        request.response.statusCode = 404;
        request.response.close();
      });

      final (startedServer, serverAddress) = await serverBuilder.build();
      localServerAddress = serverAddress;
      server = startedServer;
    });

    tearDown(() async {
      await server.close(force: true);
    });

    group('when logging out through cli', () {
      late Future runLogoutCommand;
      setUp(() {
        runLogoutCommand = cli.run([
          'logout',
          '--api-url',
          localServerAddress.toString(),
          '--auth-dir',
          testCacheFolderPath,
        ]);
      });

      test('then the stored credentials are removed.', () async {
        await runLogoutCommand.onError((final e, final s) {});

        final cloudData = await ResourceManager.tryFetchServerpodCloudData(
          localStoragePath: testCacheFolderPath,
          logger: logger,
        );

        expect(cloudData, isNull);
      });

      test('then a sign out request is sent', () async {
        await runLogoutCommand.onError((final e, final s) {});

        await expectLater(signOutRequestCompleter.future, completes);
      });

      test('then the command throws exit exception.', () async {
        await expectLater(runLogoutCommand, throwsA(isA<ExitException>()));
      });

      test('then a "request to sign out" error is logged.', () async {
        await runLogoutCommand.onError((final e, final s) {});

        expect(logger.errors, isNotEmpty);
        expect(
          logger.errors.first,
          contains('Request to sign out from Serverpod Cloud failed:'),
        );
      });
    });
  });

  test(
      'Given no stored credentials when logging out through cli then the command completes with no stored credentials log.',
      () async {
    final runLogoutCommand = cli.run([
      'logout',
      '--auth-dir',
      testCacheFolderPath,
    ]);

    await expectLater(runLogoutCommand, completes);

    expect(logger.messages, isNotEmpty);
    expect(
      logger.messages.first,
      'No stored Serverpod Cloud credentials found.',
    );
  });
}
