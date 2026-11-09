@Tags(['concurrency_one']) // due to current directory manipulation
library;

import 'dart:async';
import 'dart:io';

import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_auth_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

import '../../test_utils/command_logger_matchers.dart';
import '../../test_utils/test_command_logger.dart';
import '../../test_utils/wait_for_callback_info.dart';

class CommandThatRequiresLogin extends CloudCliCommand {
  @override
  final name = 'command-that-requires-login';

  @override
  bool get requireLogin => true;

  CommandThatRequiresLogin({required super.logger});

  @override
  String get description => 'description';

  @override
  Future<void> runWithOutput(
    Configuration<OptionDefinition> commandConfig,
    CommandOutput output,
  ) async {
    return;
  }
}

enum MandatoryOption<V> implements OptionDefinition<V> {
  name(StringOption(argName: 'name', mandatory: true));

  const MandatoryOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CommandWithMandatoryOption extends CloudCliCommand<MandatoryOption> {
  @override
  final name = 'command-with-mandatory-option';

  @override
  bool get requireLogin => true;

  CommandWithMandatoryOption({required super.logger})
    : super(options: MandatoryOption.values);

  @override
  String get description => 'description';

  @override
  Future<void> runWithOutput(
    Configuration<MandatoryOption> commandConfig,
    CommandOutput output,
  ) async {
    return;
  }
}

class InteractiveOnlyCommand extends CloudCliCommand {
  @override
  final name = 'interactive-only-command';

  @override
  bool get interactiveOnly => true;

  @override
  String get nonInteractiveHint => 'Use another command.';

  InteractiveOnlyCommand({required super.logger});

  @override
  String get description => 'description';

  @override
  Future<void> runWithOutput(
    Configuration<OptionDefinition> commandConfig,
    CommandOutput output,
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
    Configuration<OptionDefinition> commandConfig,
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
  final commandWithMandatoryOption = CommandWithMandatoryOption(logger: logger);
  runner.addCommand(commandThatRequiresLogin);
  runner.addCommand(commandThatDoesNotRequiredLogin);
  final interactiveOnlyCommand = InteractiveOnlyCommand(logger: logger);
  runner.addCommand(commandWithMandatoryOption);
  runner.addCommand(interactiveOnlyCommand);

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

      unawaited(
        CallbackHelper.completeAuthCallback(
          logger: logger,
          completer: tokenSent,
          token: testToken,
        ),
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

  group('Given command that requires login, user is not logged in '
      'and the user has a user auth id', () {
    final analyticsEvents = <({String event, String? userAuthId})>[];
    late CloudCliCommandRunner analyticsRunner;
    late Completer tokenSent;

    setUp(() {
      analyticsEvents.clear();
      final client = ClientMock();
      when(() => client.users.readUser()).thenAnswer(
        (_) async => UserBuilder().withUserAuthId('user-auth-id').build(),
      );
      analyticsRunner = CloudCliCommandRunner.create(
        logger: logger,
        serviceProvider: CloudCliServiceProvider(
          apiClientFactory: (_) => client,
        ),
        onAnalyticsEvent: (event, properties, {userAuthId}) =>
            analyticsEvents.add((event: event, userAuthId: userAuthId)),
      );
      analyticsRunner.addCommand(CommandThatRequiresLogin(logger: logger));

      tokenSent = Completer();
      unawaited(
        CallbackHelper.completeAuthCallback(
          logger: logger,
          completer: tokenSent,
          token: 'myTestToken',
        ),
      );
    });

    tearDown(() async {
      await ResourceManager.removeServerpodCloudAuthData(
        localStoragePath: testCacheFolderPath,
      );
    });

    test('when calling run with analytics'
        ' then the signed in event is sent under the user auth id', () async {
      final cliOnDone = analyticsRunner.run([
        commandThatRequiresLogin.name,
        '--no-browser',
        '--analytics',
        '--config-dir',
        testCacheFolderPath,
      ]);

      await tokenSent.future;
      await cliOnDone;

      expect(
        analyticsEvents.where((e) => e.event == 'serverpod_cli_signed_in'),
        [(event: 'serverpod_cli_signed_in', userAuthId: 'user-auth-id')],
      );
    });
  });

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

  group('Given command that requires login and user is not logged in '
      'when calling run with --non-interactive', () {
    late Future commandResult;
    setUp(() {
      commandResult = runner.run([
        commandThatRequiresLogin.name,
        '--non-interactive',
        '--no-browser',
        '--config-dir',
        testCacheFolderPath,
      ]);
    });

    test('then throws ErrorExitException', () async {
      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
    });

    test('then logs not logged in error with hint', () async {
      await commandResult.catchError((_) {});

      expect(
        logger.errorCalls.single,
        equalsErrorCall(
          message: 'Not logged in.',
          hint:
              'Run `scloud auth login`, or set the SERVERPOD_CLOUD_TOKEN '
              'environment variable.',
        ),
      );
    });

    test('then no login is started', () async {
      await commandResult.catchError((_) {});

      expect(logger.progressCalls, isEmpty);
      expect(logger.infoCalls, isEmpty);
    });
  });

  group('Given command with a mandatory option and user is not logged in '
      'when calling run without the option', () {
    late Future commandResult;
    setUp(() {
      commandResult = runner.run([
        commandWithMandatoryOption.name,
        '--no-browser',
        '--config-dir',
        testCacheFolderPath,
      ]);
    });

    test('then throws UsageException', () async {
      await expectLater(commandResult, throwsA(isA<UsageException>()));
    });

    test('then no login is started', () async {
      await commandResult.catchError((_) {});

      expect(logger.progressCalls, isEmpty);
    });
  });

  group('Given interactive-only command and user is not logged in '
      'when calling run with --non-interactive', () {
    late Future commandResult;
    setUp(() {
      commandResult = runner.run([
        interactiveOnlyCommand.name,
        '--non-interactive',
        '--no-browser',
        '--config-dir',
        testCacheFolderPath,
      ]);
    });

    test('then throws UsageException with the non-interactive hint', () async {
      await expectLater(
        commandResult,
        throwsA(
          isA<UsageException>().having(
            (e) => e.toString(),
            'toString',
            startsWith(
              'The interactive-only-command command is interactive '
              'and cannot run with --non-interactive.\nUse another command.',
            ),
          ),
        ),
      );
    });

    test('then no login is started', () async {
      await commandResult.catchError((_) {});

      expect(logger.progressCalls, isEmpty);
      expect(logger.errorCalls, isEmpty);
    });
  });
}
