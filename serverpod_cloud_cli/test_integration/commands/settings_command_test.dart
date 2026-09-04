import 'dart:async';
import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/settings/settings_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/scloud_settings_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:yaml_codec/yaml_codec.dart';

import '../../test_utils/command_logger_matchers.dart';
import '../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final client = ClientMock();
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
  });

  tearDown(() async {
    logger.clear();
  });

  test(
    'Given settings list command when instantiated then does not require login',
    () {
      expect(CloudSettingsListCommand(logger: logger).requireLogin, isFalse);
    },
  );

  test(
    'Given settings set command when instantiated then does not require login',
    () {
      expect(CloudSettingsSetCommand(logger: logger).requireLogin, isFalse);
    },
  );

  test(
    'Given settings unset command when instantiated then does not require login',
    () {
      expect(CloudSettingsUnsetCommand(logger: logger).requireLogin, isFalse);
    },
  );

  group('Given no local settings are stored', () {
    group('when executing settings list', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'settings',
          'list',
          '--config-dir',
          testConfigDirPath,
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs analytics as not set', () async {
        await commandResult;

        expect(
          logger.lineCalls.map((final call) => call.line).join('\n'),
          allOf(contains('analytics'), contains('not set')),
        );
      });
    });

    group('when executing settings list with --format json', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'settings',
          'list',
          '--config-dir',
          testConfigDirPath,
          '--format',
          'json',
        ]);
      });

      test('then emits analytics with a null value', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        final payload = jsonDecode(logger.rawCalls.single.content) as List;
        expect(payload, hasLength(1));
        expect((payload.single as Map)['name'], 'analytics');
        expect((payload.single as Map)['value'], isNull);
      });
    });

    group('when executing settings list with --format yaml', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'settings',
          'list',
          '--config-dir',
          testConfigDirPath,
          '--format',
          'yaml',
        ]);
      });

      test('then emits analytics with a null value', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        final payload = yamlDecode(logger.rawCalls.single.content) as List;
        expect(payload, hasLength(1));
        expect((payload.single as Map)['name'], 'analytics');
        expect((payload.single as Map)['value'], isNull);
      });
    });

    group('when executing settings set analytics true', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'settings',
          'set',
          'analytics',
          'true',
          '--config-dir',
          testConfigDirPath,
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs a success message', () async {
        await commandResult;

        expect(logger.successCalls, isNotEmpty);
        expect(
          logger.successCalls.first,
          equalsSuccessCall(message: 'Set analytics to "true".'),
        );
      });

      test('then the setting is persisted', () async {
        await commandResult;

        final settings = await ResourceManager.tryLoadSettings(
          localStoragePath: testConfigDirPath,
        );
        expect(settings?.enableAnalytics, isTrue);
      });
    });

    group('when executing settings set analytics false', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'settings',
          'set',
          'analytics',
          'false',
          '--config-dir',
          testConfigDirPath,
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then the setting is persisted', () async {
        await commandResult;

        final settings = await ResourceManager.tryLoadSettings(
          localStoragePath: testConfigDirPath,
        );
        expect(settings?.enableAnalytics, isFalse);
      });
    });

    group('when executing settings set analytics true with --format json', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'settings',
          'set',
          'analytics',
          'true',
          '--config-dir',
          testConfigDirPath,
          '--format',
          'json',
        ]);
      });

      test('then emits a JSON object with the setting', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(logger.successCalls, isEmpty);
        expect(jsonDecode(logger.rawCalls.single.content), {
          'name': 'analytics',
          'value': true,
        });
      });
    });

    group('when executing settings set analytics false with --format yaml', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'settings',
          'set',
          'analytics',
          'false',
          '--config-dir',
          testConfigDirPath,
          '--format',
          'yaml',
        ]);
      });

      test('then emits a YAML object with the setting', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(logger.successCalls, isEmpty);
        final payload = yamlDecode(logger.rawCalls.single.content) as Map;
        expect(payload['name'], 'analytics');
        expect(payload['value'], isFalse);
      });
    });

    group('when executing settings set analytics with a non-boolean value', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'settings',
          'set',
          'analytics',
          'yes',
          '--config-dir',
          testConfigDirPath,
        ]);
      });

      test('then throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs a boolean value error', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errorCalls, isNotEmpty);
        expect(
          logger.errorCalls.first,
          equalsErrorCall(
            message: 'The analytics setting requires a boolean value.',
            hint: 'Use "true" or "false".',
          ),
        );
      });
    });

    group('when executing settings set with an unknown name', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'settings',
          'set',
          'unknown',
          'true',
          '--config-dir',
          testConfigDirPath,
        ]);
      });

      test('then throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs an unknown setting error', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errorCalls, isNotEmpty);
        expect(
          logger.errorCalls.first,
          equalsErrorCall(
            message: 'Unknown setting "unknown".',
            hint: 'Available settings: analytics.',
          ),
        );
      });
    });

    group('when executing settings unset analytics', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'settings',
          'unset',
          'analytics',
          '--config-dir',
          testConfigDirPath,
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs a success message', () async {
        await commandResult;

        expect(logger.successCalls, isNotEmpty);
        expect(
          logger.successCalls.first,
          equalsSuccessCall(message: 'Unset analytics.'),
        );
      });
    });
  });

  group('Given analytics is enabled', () {
    setUp(() async {
      await ResourceManager.storeSettings(
        settings: ServerpodCloudSettingsData()..enableAnalytics = true,
        localStoragePath: testConfigDirPath,
      );
    });

    group('when executing settings list', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'settings',
          'list',
          '--config-dir',
          testConfigDirPath,
        ]);
      });

      test('then outputs analytics as true', () async {
        await commandResult;

        expect(
          logger.lineCalls.map((final call) => call.line).join('\n'),
          allOf(contains('analytics'), contains('true')),
        );
      });
    });

    group('when executing settings list with --format json', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'settings',
          'list',
          '--config-dir',
          testConfigDirPath,
          '--format',
          'json',
        ]);
      });

      test('then emits analytics as true', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        final payload = jsonDecode(logger.rawCalls.single.content) as List;
        expect((payload.single as Map)['value'], isTrue);
      });
    });

    group('when executing settings set analytics false', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'settings',
          'set',
          'analytics',
          'false',
          '--config-dir',
          testConfigDirPath,
        ]);
      });

      test('then the setting is updated', () async {
        await commandResult;

        final settings = await ResourceManager.tryLoadSettings(
          localStoragePath: testConfigDirPath,
        );
        expect(settings?.enableAnalytics, isFalse);
      });
    });

    group('when executing settings unset analytics', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'settings',
          'unset',
          'analytics',
          '--config-dir',
          testConfigDirPath,
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then the setting is unset', () async {
        await commandResult;

        final settings = await ResourceManager.tryLoadSettings(
          localStoragePath: testConfigDirPath,
        );
        expect(settings?.enableAnalytics, isNull);
      });
    });

    group('when executing settings unset analytics with --format json', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'settings',
          'unset',
          'analytics',
          '--config-dir',
          testConfigDirPath,
          '--format',
          'json',
        ]);
      });

      test('then emits a JSON object with the setting name', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(logger.successCalls, isEmpty);
        expect(jsonDecode(logger.rawCalls.single.content), {
          'name': 'analytics',
        });
      });
    });

    group('when executing settings unset analytics with --format yaml', () {
      late Future commandResult;

      setUp(() async {
        commandResult = cli.run([
          'settings',
          'unset',
          'analytics',
          '--config-dir',
          testConfigDirPath,
          '--format',
          'yaml',
        ]);
      });

      test('then emits a YAML object with the setting name', () async {
        await commandResult;

        expect(logger.lineCalls, isEmpty);
        expect(logger.successCalls, isEmpty);
        final payload = yamlDecode(logger.rawCalls.single.content) as Map;
        expect(payload['name'], 'analytics');
      });
    });
  });
}
