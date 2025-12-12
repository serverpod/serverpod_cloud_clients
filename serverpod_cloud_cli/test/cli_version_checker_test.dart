import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cli_version_checker.dart';
import 'package:test/test.dart';
import 'package:cli_tools/package_version.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

import '../test_utils/test_command_logger.dart';

class PubApiClientMock extends Mock implements PubApiClient {}

void main() {
  final logger = TestCommandLogger();

  final testCacheFolderPath = p.join('test_integration', const Uuid().v4());

  tearDown(() {
    final directory = Directory(testCacheFolderPath);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }

    logger.clear();
  });

  group('Given pub api client returns version', () {
    late PubApiClient pubClient;
    late Version version;

    setUp(() async {
      pubClient = PubApiClientMock();
      version = Version(1, 0, 0);
      when(
        () => pubClient.tryFetchLatestStableVersion('serverpod_cloud_cli'),
      ).thenAnswer((final _) async => version);
    });

    test('when calling fetchLatestCLIVersion '
        'then returns version', () async {
      final result = await CLIVersionChecker.fetchLatestCLIVersion(
        logger: logger,
        localStoragePath: testCacheFolderPath,
        pubClientOverride: pubClient,
      );

      expect(result, version);
    });
  });

  group('Given pub api client throws VersionFetchException', () {
    late PubApiClient pubClient;

    setUp(() async {
      pubClient = PubApiClientMock();
      when(
        () => pubClient.tryFetchLatestStableVersion('serverpod_cloud_cli'),
      ).thenThrow(
        VersionFetchException(
          'Offline',
          SocketException('Offline'),
          StackTrace.current,
        ),
      );
    });

    test('when calling fetchLatestCLIVersion '
        'then returns null', () async {
      final result = await CLIVersionChecker.fetchLatestCLIVersion(
        logger: logger,
        localStoragePath: testCacheFolderPath,
        pubClientOverride: pubClient,
      );

      expect(result, isNull);
    });
  });

  group('Given pub api client throws exception', () {
    late PubApiClient pubClient;

    setUp(() async {
      pubClient = PubApiClientMock();
      when(
        () => pubClient.tryFetchLatestStableVersion('serverpod_cloud_cli'),
      ).thenThrow(Exception('Unexpected'));
    });

    test('when calling fetchLatestCLIVersion '
        'then throws exception', () async {
      final result = CLIVersionChecker.fetchLatestCLIVersion(
        logger: logger,
        localStoragePath: testCacheFolderPath,
        pubClientOverride: pubClient,
      );

      await expectLater(
        result,
        throwsA(
          isA<Exception>().having(
            (final e) => e.toString(),
            'toString()',
            'Exception: Unexpected',
          ),
        ),
      );
    });
  });

  test('Given major version is outdated '
      'when calling isBreakingUpdate '
      'then returns true', () async {
    final currentVersion = Version(1, 0, 0);
    final latestVersion = Version(2, 0, 0);

    final result = CLIVersionChecker.isBreakingUpdate(
      currentVersion: currentVersion,
      latestVersion: latestVersion,
    );

    expect(result, isTrue);
  });

  test('Given latest major version is 0 and minor version outdated '
      'when calling isBreakingUpdate '
      'then returns true', () async {
    final currentVersion = Version(0, 1, 0);
    final latestVersion = Version(0, 2, 0);

    final result = CLIVersionChecker.isBreakingUpdate(
      currentVersion: currentVersion,
      latestVersion: latestVersion,
    );

    expect(result, isTrue);
  });

  test(
    'Given latest major version is greater than 0 and minor version outdated '
    'when calling isBreakingUpdate '
    'then returns false',
    () async {
      final currentVersion = Version(1, 1, 0);
      final latestVersion = Version(1, 2, 0);

      final result = CLIVersionChecker.isBreakingUpdate(
        currentVersion: currentVersion,
        latestVersion: latestVersion,
      );

      expect(result, isFalse);
    },
  );

  test('Given versions are equal '
      'when calling isBreakingUpdate '
      'then returns false', () async {
    final currentVersion = Version(0, 1, 0);
    final latestVersion = Version(0, 1, 0);

    final result = CLIVersionChecker.isBreakingUpdate(
      currentVersion: currentVersion,
      latestVersion: latestVersion,
    );

    expect(result, isFalse);
  });
}
