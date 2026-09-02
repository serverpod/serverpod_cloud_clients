import 'dart:async';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/base_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';

import '../../test_utils/test_command_logger.dart';

const _baseCommand = 'serverpod cloud';

void main() {
  final logger = TestCommandLogger();
  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    baseCommand: _baseCommand,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (globalCfg) => client,
    ),
  );

  /// Runs [args] and returns everything the CLI wrote to the user, both
  /// through the logger and directly to the terminal.
  Future<String> runAndCaptureOutput(List<String> args) async {
    final printed = StringBuffer();
    await runZoned(
      () => cli.run(args),
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) => printed.writeln(line),
      ),
    );
    return [
      printed.toString(),
      ...logger.infoCalls.map((call) => call.message),
      ...logger.lineCalls.map((call) => call.line),
    ].join('\n');
  }

  tearDown(() {
    logger.clear();
  });

  group('Given a cli command runner with a wrapper base command', () {
    group('when running the help command', () {
      late String output;

      setUp(() async {
        output = await runAndCaptureOutput(['help']);
      });

      test('then the usage line uses the base command', () {
        expect(output, contains('$_baseCommand <command> [arguments]'));
      });

      test('then the usage line does not use the default base command', () {
        expect(
          output,
          isNot(contains('$defaultBaseCommand <command> [arguments]')),
        );
      });
    });

    group('when running the help command for a nested subcommand', () {
      late String output;

      setUp(() async {
        output = await runAndCaptureOutput(['help', 'deployment', 'show']);
      });

      test('then the invocation line uses the base command', () {
        expect(output, contains('$_baseCommand deployment show [arguments]'));
      });
    });

    group('when the session credentials are rejected', () {
      setUp(() async {
        when(
          () => client.environmentVariables.list(any()),
        ).thenThrow(ServerpodClientUnauthorized());

        await expectLater(
          cli.run(['variable', 'list', '--project', 'projectId']),
          throwsA(isA<ErrorExitException>()),
        );
      });

      test('then the suggested terminal commands use the base command', () {
        expect(logger.terminalCommandCalls.map((call) => call.command), [
          '$_baseCommand auth logout',
          '$_baseCommand auth login',
        ]);
      });
    });

    group('when setting a variable with a reserved name prefix', () {
      setUp(() async {
        await expectLater(
          cli.run([
            'variable',
            'set',
            'SERVERPOD_PASSWORD_DB',
            'value',
            '--project',
            'projectId',
          ]),
          throwsA(isA<ErrorExitException>()),
        );
      });

      test('then the failure hint uses the base command', () {
        expect(
          logger.errorCalls.single.hint,
          contains('$_baseCommand password set'),
        );
      });
    });

    group('when listing variables whose values contain the word scloud', () {
      late String output;

      setUp(() async {
        when(() => client.environmentVariables.list(any())).thenAnswer(
          (_) async => [
            EnvironmentVariable(
              name: 'BUCKET',
              value: 'scloud-artifacts',
              capsuleId: 0,
            ),
          ],
        );
        when(
          () => client.secrets.list(any()),
        ).thenAnswer((_) async => <String>[]);

        output = await runAndCaptureOutput([
          'variable',
          'list',
          '--project',
          'scloud-demo',
        ]);
      });

      test('then the value is printed verbatim', () {
        expect(output, contains('scloud-artifacts'));
      });
    });
  });
}
