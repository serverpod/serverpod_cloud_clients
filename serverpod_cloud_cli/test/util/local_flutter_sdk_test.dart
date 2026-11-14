import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:serverpod_cloud_cli/util/local_flutter_sdk.dart';
import 'package:test/test.dart';

import '../../test_utils/command_logger_matchers.dart';
import '../../test_utils/test_command_logger.dart';

const _machineVersion = '''
{
  "frameworkVersion": "3.38.4",
  "channel": "stable",
  "flutterRoot": "/opt/flutter",
  "dartSdkVersion": "3.10.3"
}''';

void main() {
  final logger = TestCommandLogger();
  final workingDirectory = Directory.systemTemp;

  tearDown(() => logger.clear());

  group('Given a flutter tool that prints its machine version', () {
    late _FakeProcess process;
    late List<List<String>> startArguments;
    late List<String> startDirectories;
    late Future<String?> version;

    setUp(() {
      process = _FakeProcess();
      startArguments = [];
      startDirectories = [];
      version = LocalFlutterSdk.readFrameworkVersion(
        workingDirectory,
        logger: logger,
        startProcess: (arguments, directory) async {
          startArguments.add(arguments);
          startDirectories.add(directory);
          return process;
        },
      );
    });

    test(
      'when reading the version then the framework version is returned',
      () async {
        process.finish(stdout: _machineVersion);

        await expectLater(version, completion('3.38.4'));
      },
    );

    test('when reading the version then the tool is asked for its machine '
        'version in the working directory', () async {
      process.finish(stdout: _machineVersion);
      await version;

      expect(startArguments, [
        ['--version', '--machine'],
      ]);
      expect(startDirectories, [workingDirectory.path]);
    });

    test('when it prints text before the JSON '
        'then the framework version is returned', () async {
      process.finish(
        stdout:
            'Waiting for another flutter command to release the startup '
            'lock...\n$_machineVersion',
      );

      await expectLater(version, completion('3.38.4'));
    });

    test('when it prints a JSON notice before the JSON '
        'then the framework version is returned', () async {
      process.finish(
        stdout:
            '{"notice": "A new version of puro is available"}\n'
            '$_machineVersion',
      );

      await expectLater(version, completion('3.38.4'));
    });

    test('when it prints a notice with braces after the JSON '
        'then the framework version is returned', () async {
      process.finish(
        stdout:
            '$_machineVersion\n'
            '{ Run "flutter upgrade" to get the latest version }\n',
      );

      await expectLater(version, completion('3.38.4'));
    });

    test('when it exits while a process it started keeps the output open '
        'then the framework version is returned', () async {
      process.exit(stdout: _machineVersion);

      await expectLater(version, completion('3.38.4'));
    });
  });

  group('Given a flutter tool that exits with an error', () {
    late Future<String?> version;

    setUp(() {
      final process = _FakeProcess();
      version = LocalFlutterSdk.readFrameworkVersion(
        workingDirectory,
        logger: logger,
        startProcess: (_, _) async => process,
      );
      process.finish(stdout: _machineVersion, exitCode: 1);
    });

    test('when reading the version then null is returned', () async {
      await expectLater(version, completion(isNull));
    });

    test('when reading the version then a warning names the exit code '
        'and that the builds use the latest stable release', () async {
      await version;

      expect(
        logger.warningCalls,
        contains(
          equalsWarningCall(
            message:
                'Could not read the version of the local Flutter SDK: '
                '"flutter --version" exited with code 1.',
            hint:
                'The builds use the latest stable release. Request a version '
                'with --flutter-version, or pin one in environment.flutter of '
                "the app's pubspec.yaml.",
          ),
        ),
      );
    });
  });

  group('Given a flutter tool that prints no framework version', () {
    late Future<String?> version;

    setUp(() {
      final process = _FakeProcess();
      version = LocalFlutterSdk.readFrameworkVersion(
        workingDirectory,
        logger: logger,
        startProcess: (_, _) async => process,
      );
      process.finish(stdout: 'Flutter 3.38.4 • channel stable\n');
    });

    test('when reading the version then null is returned', () async {
      await expectLater(version, completion(isNull));
    });

    test(
      'when reading the version then a warning says it reported no framework version '
      'and that the builds use the latest stable release',
      () async {
        await version;

        expect(
          logger.warningCalls,
          contains(
            equalsWarningCall(
              message:
                  'Could not read the version of the local Flutter SDK: '
                  '"flutter --version" reported no framework version.',
              hint:
                  'The builds use the latest stable release. Request a version '
                  'with --flutter-version, or pin one in environment.flutter of '
                  "the app's pubspec.yaml.",
            ),
          ),
        );
      },
    );
  });

  group('Given no flutter executable', () {
    test('when reading the version then null is returned '
        'without a warning', () async {
      final version = await LocalFlutterSdk.readFrameworkVersion(
        workingDirectory,
        logger: logger,
        startProcess: (_, _) async =>
            throw const ProcessException('flutter', []),
      );

      expect(version, isNull);
      expect(logger.warningCalls, isEmpty);
    });
  });

  group('Given a flutter tool that does not answer in time', () {
    late _FakeProcess process;
    late Future<String?> version;

    setUp(() {
      process = _FakeProcess();
      version = LocalFlutterSdk.readFrameworkVersion(
        workingDirectory,
        logger: logger,
        timeout: const Duration(seconds: 1),
        startProcess: (_, _) async => process,
      );
    });

    test('when reading the version then null is returned', () async {
      await expectLater(version, completion(isNull));
    });

    test('when reading the version then the tool is stopped', () async {
      await version;

      expect(process.killed, isTrue);
    });

    test('when reading the version then its output is closed', () async {
      await version;

      expect(process.hasOutputListeners, isFalse);
    });

    test('when reading the version then a warning names the timeout', () async {
      await version;

      expect(
        logger.warningCalls.map((call) => call.message),
        contains(
          'Could not read the version of the local Flutter SDK: '
          '"flutter --version" timed out after 1s. '
          'Another Flutter command may be running.',
        ),
      );
    });
  });
}

/// A [Process] whose output and exit a test controls.
class _FakeProcess implements Process {
  final _stdout = StreamController<List<int>>();
  final _stderr = StreamController<List<int>>();
  final _exitCode = Completer<int>();

  /// Whether [kill] was called.
  bool killed = false;

  /// Whether the output streams still have listeners.
  bool get hasOutputListeners => _stdout.hasListener || _stderr.hasListener;

  /// Writes [stdout], closes the output and exits with [exitCode].
  void finish({required String stdout, int exitCode = 0}) {
    _stdout.add(utf8.encode(stdout));
    unawaited(_stdout.close());
    unawaited(_stderr.close());
    _exitCode.complete(exitCode);
  }

  /// Writes [stdout] and exits with [exitCode], leaving the output open.
  void exit({required String stdout, int exitCode = 0}) {
    _stdout.add(utf8.encode(stdout));
    _exitCode.complete(exitCode);
  }

  @override
  Stream<List<int>> get stdout => _stdout.stream;

  @override
  Stream<List<int>> get stderr => _stderr.stream;

  @override
  Future<int> get exitCode => _exitCode.future;

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    killed = true;
    return true;
  }

  @override
  int get pid => 0;

  @override
  IOSink get stdin => throw UnimplementedError();
}
