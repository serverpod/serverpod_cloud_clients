@Tags(['concurrency_one']) // due to current directory manipulation
library;

import 'dart:io';

import 'package:cli_tools/config.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';

import '../../test_utils/command_logger_matchers.dart';
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
  final runner = CloudCliCommandRunner.create(
    logger: logger,
  );
  final commandThatRequiresLogin = CommandThatRequiresLogin(logger: logger);
  final commandThatDoesNotRequiredLogin =
      CommandThatDoesNotRequiredLogin(logger: logger);
  runner.addCommand(commandThatRequiresLogin);
  runner.addCommand(commandThatDoesNotRequiredLogin);

  final testCacheFolderPath = p.join(
    'test_integration',
    const Uuid().v4(),
  );
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
      'when calling run then throws exception', () async {
    await expectLater(
      runner.run(
        [
          commandThatRequiresLogin.name,
          '--scloud-dir',
          testCacheFolderPath,
        ],
      ),
      throwsA(isA<ErrorExitException>()),
    );

    expect(
      logger.errorCalls.first,
      equalsErrorCall(
        message: 'This command requires you to be logged in.',
      ),
    );
    expect(
      logger.terminalCommandCalls.first,
      equalsTerminalCommandCall(
        message: 'Please run the login command to authenticate and try again:',
        command: 'scloud auth login',
      ),
    );
  });

  test(
      'Given command that requires login and user is logged in '
      'when calling run then completes', () async {
    await ResourceManager.storeServerpodCloudData(
      cloudData: ServerpodCloudData('my-token'),
      localStoragePath: testCacheFolderPath,
    );

    await expectLater(
      runner.run(
        [
          commandThatRequiresLogin.name,
          '--scloud-dir',
          testCacheFolderPath,
        ],
      ),
      completes,
    );
    expect(logger.errorCalls, isEmpty);
  });

  test(
      'Given command that does not requires login and user is not logged in '
      'when calling run then completes', () {
    expect(
      runner.run(
        [
          commandThatDoesNotRequiredLogin.name,
          '--scloud-dir',
          testCacheFolderPath,
        ],
      ),
      completes,
    );
  });
}
