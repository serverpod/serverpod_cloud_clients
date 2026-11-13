import 'package:args/command_runner.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:test/test.dart';

import '../../../test_utils/test_command_logger.dart';

const _projectId = 'my-project-id';
final _uploadId = const Uuid().v4obj();

void main() {
  final logger = TestCommandLogger();
  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    version: Version.parse('999.0.0'),
    serviceProvider: CloudCliServiceProvider(apiClientFactory: (_) => client),
  );

  tearDown(() => logger.clear());

  for (final command in ['publish', 'doctor', 'list', 'log']) {
    test('Given app $command help when showing platform choices '
        'then only the supported platforms are advertised', () {
      final usage = cli.commands['app']?.subcommands[command]?.usage;
      expect(usage, contains(command == 'log' ? 'android|ios' : 'android,ios'));
      expect(usage, isNot(matches(RegExp(r'\b(linux|macos|windows)\b'))));
    });

    for (final platform in ['LINUX', 'macOS', 'Windows', 'Fuchsia']) {
      test('Given app $command with platform $platform when run '
          'then a clean usage error lists the supported platforms', () async {
        await expectLater(
          cli.run([
            'app',
            command,
            if (command == 'log') _uploadId.uuid,
            if (command != 'doctor') ...['--project', _projectId],
            command == 'log' ? '--platform' : '--platforms',
            platform,
          ]),
          throwsA(
            isA<UsageException>()
                .having(
                  (error) => error.message,
                  'message',
                  contains(
                    'Invalid platform "$platform". '
                    'Supported platforms: android, ios.',
                  ),
                )
                .having(
                  (error) => error.toString(),
                  'displayed error',
                  isNot(contains('FormatException')),
                ),
          ),
        );
        verifyZeroInteractions(client.appBuilds);
      });
    }
  }
}
