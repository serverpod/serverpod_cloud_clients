import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/util/configuration.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';
import 'package:test/test.dart';

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
    version: Version(0, 0, 0),
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
          '--auth-dir',
          testCacheFolderPath,
        ],
      ),
      throwsA(isA<ExitException>()),
    );

    expect(
        logger.errorCalls,
        contains(
          equalsErrorCall(
            message: 'This command requires you to be logged in. '
                'Please run `scloud login` to authenticate and try again.',
          ),
        ));
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
          '--auth-dir',
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
          '--auth-dir',
          testCacheFolderPath,
        ],
      ),
      completes,
    );
  });
}
