import 'dart:async';

import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (final globalCfg) => client,
    ),
  );

  tearDown(() async {
    logger.clear();
  });

  Future<String> captureHelp(final List<String> args) async {
    final printed = StringBuffer();
    await runZoned(
      () => cli.run(args),
      zoneSpecification: ZoneSpecification(
        print: (final self, final parent, final zone, final line) =>
            printed.writeln(line),
      ),
    );
    return [
      printed.toString(),
      ...logger.infoCalls.map((final call) => call.message),
    ].join('\n');
  }

  group('Given the cli when printing the top-level help', () {
    setUp(() async {
      await cli.run(['help']);
    });

    test('then lists the build command', () {
      expect(logger.infoCalls, isNotEmpty);
      expect(
        logger.infoCalls.first.message,
        contains(RegExp(r'^\s+build\s+', multiLine: true)),
      );
    });
  });

  group('Given the build command when printing its help', () {
    setUp(() async {
      await cli.run(['help', 'build']);
    });

    test('then lists the log and secret subcommands', () {
      expect(logger.infoCalls, isNotEmpty);
      final help = logger.infoCalls.first.message;
      expect(help, contains(RegExp(r'^\s+log\s+', multiLine: true)));
      expect(help, contains(RegExp(r'^\s+secret\s+', multiLine: true)));
    });
  });

  group('Given the build log command when printing its help', () {
    late String help;

    setUp(() async {
      help = await captureHelp(['help', 'build', 'log']);
    });

    test('then the examples use the public build log path', () {
      expect(help, contains(r'$ scloud build log'));
      expect(help, isNot(contains(r'$ scloud deployment build-log')));
    });
  });

  group('Given the build secret command when printing its help', () {
    late String help;

    setUp(() async {
      help = await captureHelp(['help', 'build', 'secret']);
    });

    test('then the examples use the public build secret path', () {
      expect(help, contains(r'$ scloud build secret list'));
      expect(help, isNot(contains(r'$ scloud deployment build-secret')));
    });
  });

  group(
    'Given the hidden deployment build-secret command when printing its help',
    () {
      late String help;

      setUp(() async {
        help = await captureHelp(['help', 'deployment', 'build-secret']);
      });

      test('then the examples use the legacy deployment build-secret path', () {
        expect(help, contains(r'$ scloud deployment build-secret list'));
        expect(help, isNot(contains(r'$ scloud build secret')));
      });
    },
  );

  group('Given the cli when generating carapace completions', () {
    setUp(() async {
      await cli.run([
        'completion',
        'generate',
        '--tool',
        'carapace',
        '--file',
        p.join(d.sandbox, 'spec.yaml'),
      ]);
    });

    test('then emits build once as a top-level command', () async {
      await d
          .file(
            'spec.yaml',
            predicate<String>((final content) {
              final names = RegExp(
                r'^  - name: (\S+)$',
                multiLine: true,
              ).allMatches(content).map((final match) => match.group(1));
              return names.where((final name) => name == 'build').length == 1;
            }, 'has exactly one top-level build command'),
          )
          .validate();
    });
  });
}
