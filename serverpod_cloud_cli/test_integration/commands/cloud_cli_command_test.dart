@Tags(['concurrency_one']) // due to current directory manipulation
library;

import 'dart:async';
import 'dart:io';

import 'package:config/config.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_auth_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';

import '../../test_utils/test_command_logger.dart';

class CommandThatRequiresLogin extends CloudCliCommand {
  @override
  final name = 'command-that-requires-login';

  @override
  bool get requireLogin => true;

  CommandThatRequiresLogin({required super.logger});

  @override
  String get description => 'description';

  @override
  Future<void> runWithConfig(
    final Configuration<OptionDefinition> commandConfig,
  ) async {
    return;
  }
}

class CommandThatDoesNotRequiredLogin extends CloudCliCommand {
  @override
  final name = 'command-that-does-not-require-login';

  @override
  bool get requireLogin => false;

  CommandThatDoesNotRequiredLogin({required super.logger});

  @override
  String get description => 'description';

  @override
  Future<void> runWithConfig(
    final Configuration<OptionDefinition> commandConfig,
  ) async {
    return;
  }
}

void main() {
  final logger = TestCommandLogger();
  final runner = CloudCliCommandRunner.create(logger: logger);
  final commandThatRequiresLogin = CommandThatRequiresLogin(logger: logger);
  final commandThatDoesNotRequiredLogin = CommandThatDoesNotRequiredLogin(
    logger: logger,
  );
  runner.addCommand(commandThatRequiresLogin);
  runner.addCommand(commandThatDoesNotRequiredLogin);

  final testCacheFolderPath = p.join('test_integration', const Uuid().v4());
  late Directory originalDirectory;

  setUp(() {
    Directory(testCacheFolderPath).createSync(recursive: true);
    originalDirectory = Directory.current;
    Directory.current = testCacheFolderPath;
  });

  tearDown(() {
    Directory.current = originalDirectory;

    final directory = Directory(testCacheFolderPath);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }

    logger.clear();
  });

  test(
    'Given command that requires login and user is not logged in '
    'when calling run then auto-auth is triggered and completes successfully',
    () async {
      const testToken = 'myTestToken';
      late Completer tokenSent;
      tokenSent = Completer();
      final loggerFuture = logger.waitForLog();
      unawaited(
        loggerFuture.then((final _) async {
          assert(logger.infoCalls.isNotEmpty, 'Expected log info messages.');
          final loggedMessage = logger.infoCalls.first.message;
          final splitMessage = loggedMessage.split('callback=');
          assert(
            splitMessage.length == 2,
            'Expected callback URL in log message.',
          );

          final callbackUrl = Uri.parse(Uri.decodeFull(splitMessage[1]));
          final urlWithToken = callbackUrl.replace(
            queryParameters: {'token': testToken},
          );
          final response = await http.get(urlWithToken);
          assert(
            response.statusCode == 200,
            'Expected token response to have status code 200.',
          );
          tokenSent.complete();
        }),
      );

      final cliOnDone = runner.run([
        commandThatRequiresLogin.name,
        '--no-browser',
        '--config-dir',
        testCacheFolderPath,
      ]);

      await tokenSent.future;

      await expectLater(cliOnDone, completes);

      final storedCloudData =
          await ResourceManager.tryFetchServerpodCloudAuthData(
            logger: logger,
            localStoragePath: testCacheFolderPath,
          );
      expect(storedCloudData?.token, testToken);

      await ResourceManager.removeServerpodCloudAuthData(
        localStoragePath: testCacheFolderPath,
      );
    },
  );

  test('Given command that requires login and user is logged in '
      'when calling run then completes', () async {
    await ResourceManager.storeServerpodCloudAuthData(
      authData: ServerpodCloudAuthData('my-token'),
      localStoragePath: testCacheFolderPath,
    );

    await expectLater(
      runner.run([
        commandThatRequiresLogin.name,
        '--config-dir',
        testCacheFolderPath,
      ]),
      completes,
    );
    expect(logger.errorCalls, isEmpty);
  });

  test('Given command that does not requires login and user is not logged in '
      'when calling run then completes', () {
    expect(
      runner.run([
        commandThatDoesNotRequiredLogin.name,
        '--config-dir',
        testCacheFolderPath,
      ]),
      completes,
    );
  });

  test('Given command that requires login and user is not logged in '
      'when calling run with --help flag then no auth is triggered', () async {
    await expectLater(
      runner.run([
        commandThatRequiresLogin.name,
        '--help',
        '--no-browser',
        '--config-dir',
        testCacheFolderPath,
      ]),
      completes,
      reason: 'The command should complete successfully with --help flag.',
    );
    expect(logger.errorCalls, isEmpty);
  });
}
