import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/scloud_settings_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';

import '../../test_utils/test_command_logger.dart';

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

  late String testConfigDirPath;

  setUp(() async {
    await d.dir('config_dir').create();
    testConfigDirPath = p.join(d.sandbox, 'config_dir');

    when(
      () => client.environmentVariables.list(any()),
    ).thenAnswer((final _) async => []);
  });

  tearDown(() async {
    reset(client.environmentVariables);
    logger.clear();
  });

  group('Given a global project context is set', () {
    setUp(() async {
      await ResourceManager.storeSettings(
        settings: ServerpodCloudSettingsData()..projectContext = 'ctx-project',
        localStoragePath: testConfigDirPath,
      );
    });

    group(
      'when executing a project-scoped command without specifying the project',
      () {
        late Future commandResult;
        setUp(() async {
          commandResult = cli.run([
            'variable',
            'list',
            '--config-dir',
            testConfigDirPath,
          ]);
        });

        test('then completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then the project context is used as project id', () async {
          await commandResult;

          verify(
            () => client.environmentVariables.list('ctx-project'),
          ).called(1);
        });
      },
    );

    group('when specifying the project as a command line argument', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'variable',
          'list',
          '--project',
          'arg-project',
          '--config-dir',
          testConfigDirPath,
        ]);
      });

      test('then the argument takes precedence over the context', () async {
        await commandResult;

        verify(() => client.environmentVariables.list('arg-project')).called(1);
      });
    });

    group('when the project configuration specifies the project id', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'variable',
          'list',
          '--project-config-content',
          'project:\n  projectId: yaml-project\n',
          '--config-dir',
          testConfigDirPath,
        ]);
      });

      test(
        'then the project configuration takes precedence over the context',
        () async {
          await commandResult;

          verify(
            () => client.environmentVariables.list('yaml-project'),
          ).called(1);
        },
      );
    });

    group('when the project configuration does not specify the project id', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'variable',
          'list',
          '--project-config-content',
          'project: {}\n',
          '--config-dir',
          testConfigDirPath,
        ]);
      });

      test('then the project context is used as project id', () async {
        await commandResult;

        verify(() => client.environmentVariables.list('ctx-project')).called(1);
      });
    });
  });

  group('Given no global project context is set', () {
    group(
      'when executing a project-scoped command without specifying the project',
      () {
        late Future commandResult;
        setUp(() async {
          commandResult = cli.run([
            'variable',
            'list',
            '--config-dir',
            testConfigDirPath,
          ]);
        });

        test(
          'then throws UsageException that the project option is mandatory',
          () async {
            await expectLater(
              commandResult,
              throwsA(
                isA<UsageException>().having(
                  (final e) => e.message,
                  'message',
                  equals('Option `project` is mandatory.'),
                ),
              ),
            );
          },
        );
      },
    );
  });
}
