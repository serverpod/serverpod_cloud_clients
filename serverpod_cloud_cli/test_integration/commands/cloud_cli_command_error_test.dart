import 'package:cli_tools/cli_tools.dart';
import 'package:config/config.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../../test_utils/test_command_logger.dart';

class _ThrowingCommand extends CloudCliCommand {
  @override
  bool get requireLogin => false;

  final Object Function() _throwError;

  _ThrowingCommand({
    required super.logger,
    required final Object Function() throwError,
  }) : _throwError = throwError;

  @override
  String get name => 'throwing';

  @override
  String get description => 'Test command that throws the configured error.';

  @override
  Future<void> runWithOutput(
    final Configuration<OptionDefinition> commandConfig,
    final CommandOutput output,
  ) async {
    throw _throwError();
  }
}

void main() {
  final logger = TestCommandLogger();
  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );

  late String settingsDir;

  CloudCliCommandRunner createCli(final Object Function() throwError) {
    final cli = CloudCliCommandRunner.create(
      logger: logger,
      version: Version(1, 0, 0),
      serviceProvider: CloudCliServiceProvider(
        apiClientFactory: (final globalCfg) => client,
      ),
    );
    cli.addCommand(_ThrowingCommand(logger: logger, throwError: throwError));
    return cli;
  }

  setUp(() async {
    logger.clear();

    await d.dir('settings_dir').create();
    settingsDir = p.join(d.sandbox, 'settings_dir');

    await ResourceManager.storeLatestCliVersion(
      cliVersionData: PackageVersionData(
        Version(1, 0, 0),
        DateTime.now().add(const Duration(days: 1)),
      ),
      logger: logger,
      localStoragePath: settingsDir,
    );
  });

  group('Given a command that throws an unanticipated exception', () {
    final cause = Exception('unanticipated');
    late Future commandResult;

    setUp(() {
      final cli = createCli(() => cause);
      commandResult = cli.run(['throwing', '--config-dir', settingsDir]);
    });

    test('then an UnexpectedErrorExitException is thrown', () async {
      await expectLater(
        commandResult,
        throwsA(isA<UnexpectedErrorExitException>()),
      );
    });

    test('then the causing exception is nested', () async {
      await expectLater(
        commandResult,
        throwsA(
          isA<UnexpectedErrorExitException>().having(
            (final e) => e.nestedException,
            'nestedException',
            same(cause),
          ),
        ),
      );
    });

    test('then the causing stack trace is nested', () async {
      await expectLater(
        commandResult,
        throwsA(
          isA<UnexpectedErrorExitException>().having(
            (final e) => e.nestedStackTrace,
            'nestedStackTrace',
            isNotNull,
          ),
        ),
      );
    });
  });

  group('Given a command that throws a FailureException '
      'without a nested exception', () {
    late Future commandResult;

    setUp(() {
      final cli = createCli(
        () => FailureException(error: 'The user did something wrong.'),
      );
      commandResult = cli.run(['throwing', '--config-dir', settingsDir]);
    });

    test('then a plain ErrorExitException is thrown', () async {
      await expectLater(
        commandResult,
        throwsA(
          allOf(
            isA<ErrorExitException>(),
            isNot(isA<UnexpectedErrorExitException>()),
          ),
        ),
      );
    });
  });

  group('Given a command that throws a FailureException '
      'with a nested exception', () {
    final cause = Exception('unanticipated');
    late Future commandResult;

    setUp(() {
      final cli = createCli(
        () => FailureException(
          error: 'The operation failed.',
          nestedException: cause,
        ),
      );
      commandResult = cli.run(['throwing', '--config-dir', settingsDir]);
    });

    test('then an UnexpectedErrorExitException '
        'with the causing exception nested is thrown', () async {
      await expectLater(
        commandResult,
        throwsA(
          isA<UnexpectedErrorExitException>().having(
            (final e) => e.nestedException,
            'nestedException',
            same(cause),
          ),
        ),
      );
    });
  });
}
