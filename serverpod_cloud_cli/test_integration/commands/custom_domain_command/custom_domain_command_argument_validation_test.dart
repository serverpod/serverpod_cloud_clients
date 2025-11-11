import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_auth_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:test/test.dart';

import '../../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final cli = CloudCliCommandRunner.create(
    logger: logger,
  );

  final testCacheFolderPath = p.join(
    'test_integration',
    const Uuid().v4(),
  );

  tearDown(() {
    final directory = Directory(testCacheFolderPath);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }

    logger.clear();
  });

  const projectId = 'projectId';
  group('Given authenticated', () {
    setUp(() async {
      await ResourceManager.storeServerpodCloudAuthData(
        authData: ServerpodCloudAuthData('my-token'),
        localStoragePath: testCacheFolderPath,
      );
    });

    group('when executing domain attach with invalid target', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'domain',
          'attach',
          'domain.com',
          '--target',
          'some-invalid-target',
          '--project',
          projectId,
          '--config-dir',
          testCacheFolderPath,
        ]);
      });

      test('then command throws UsageException', () async {
        await expectLater(
          commandResult,
          throwsA(isA<UsageException>().having(
            (final e) => e.message,
            'message',
            contains(
                'Invalid value for option `target`: "some-invalid-target" is not in api|insights|web'),
          )),
        );
      });
    });
  });
}
