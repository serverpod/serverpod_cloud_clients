import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:args/command_runner.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/release/release_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:yaml_codec/yaml_codec.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/project_factory.dart';
import '../../../test_utils/recording_file_uploader.dart';
import '../../../test_utils/test_command_logger.dart';

const _projectId = 'my-project-id';
const _appUploadDescription = 'app-upload-description';

void main() {
  final logger = TestCommandLogger();
  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );
  final fileUploader = RecordingFileUploader();
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    version: Version.parse('999.0.0'),
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (_) => client,
      fileUploaderFactory: fileUploader.factory,
    ),
  );

  tearDown(() {
    logger.clear();
    fileUploader.clear();
    reset(client.deploy);
  });

  test('Given release app command when instantiated then requires login', () {
    expect(CloudReleaseAppCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given a workspace with a Serverpod server and Flutter app', () {
    setUp(() async {
      await ProjectFactory.serverpodAppWorkspace().create();
      await d.dir('monorepo', [
        d.dir('project_flutter', [
          d.dir('lib', [d.file('main.dart', 'void main() {}')]),
          d.dir('android', [d.file('build.gradle.kts', '')]),
          d.dir('windows', [d.file('CMakeLists.txt', '')]),
        ]),
      ]).create();

      when(
        () => client.deploy.createAppUploadDescription(
          any(),
          archiveSize: any(named: 'archiveSize'),
        ),
      ).thenAnswer((_) async => _appUploadDescription);
    });

    group('when releasing the app', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'release',
          'app',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
        ]);
      });

      test('then the command completes', () async {
        await expectLater(commandResult, completes);
      });

      test('then the upload description is requested for the project '
          'and the archive size', () async {
        await commandResult;

        final archiveSize = verify(
          () => client.deploy.createAppUploadDescription(
            _projectId,
            archiveSize: captureAny(named: 'archiveSize'),
          ),
        ).captured.single;
        expect(archiveSize, fileUploader.uploads.single.data.length);
      });

      test(
        'then the archive is uploaded with the upload description',
        () async {
          await commandResult;

          expect(
            fileUploader.uploads.single.uploadDescription,
            _appUploadDescription,
          );
        },
      );

      test('then the archive contains the app and the client '
          'but not the server', () async {
        await commandResult;

        final fileNames = _uploadedArchive(
          fileUploader,
        ).files.map((file) => file.name);
        expect(
          fileNames,
          containsAll([
            'pubspec.yaml',
            'pubspec.lock',
            'project_flutter/pubspec.yaml',
            'project_flutter/lib/main.dart',
            'project_client/pubspec.yaml',
          ]),
        );
        expect(
          fileNames.where((name) => name.startsWith('project_server/')),
          isEmpty,
        );
      });

      test(
        'then the archived workspace lists only the app and the client',
        () async {
          await commandResult;

          final rootPubspec = _archivedYaml(
            _uploadedArchive(fileUploader),
            'pubspec.yaml',
          );
          expect(
            rootPubspec['workspace'],
            unorderedEquals(['project_flutter', 'project_client']),
          );
        },
      );

      test('then the archived app pubspec has no dev dependencies', () async {
        await commandResult;

        final appPubspec = _archivedYaml(
          _uploadedArchive(fileUploader),
          'project_flutter/pubspec.yaml',
        );
        expect(appPubspec.containsKey('dev_dependencies'), isFalse);
      });

      test('then the upload is reported as successful', () async {
        await commandResult;

        expect(
          logger.successCalls,
          contains(
            equalsSuccessCall(
              message: 'The app was uploaded.',
              newParagraph: true,
            ),
          ),
        );
      });
    });

    test('when releasing the app without --platforms '
        'then the code of every platform is uploaded', () async {
      await cli.run([
        'release',
        'app',
        '--project',
        _projectId,
        '--project-dir',
        p.join(d.sandbox, 'monorepo', 'project_server'),
      ]);

      expect(
        _uploadedArchive(fileUploader).files.map((file) => file.name),
        containsAll([
          'project_flutter/android/build.gradle.kts',
          'project_flutter/windows/CMakeLists.txt',
        ]),
      );
    });

    group('when releasing the app with --platforms android', () {
      late Iterable<String> fileNames;

      setUp(() async {
        await cli.run([
          'release',
          'app',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
          '--platforms',
          'android',
        ]);
        fileNames = _uploadedArchive(
          fileUploader,
        ).files.map((file) => file.name);
      });

      test('then the Android code is uploaded', () {
        expect(fileNames, contains('project_flutter/android/build.gradle.kts'));
      });

      test('then the code of the other platforms is left out', () {
        expect(
          fileNames.where(
            (name) => name.startsWith('project_flutter/windows/'),
          ),
          isEmpty,
        );
      });

      test('then the shared app code is uploaded', () {
        expect(fileNames, contains('project_flutter/lib/main.dart'));
      });
    });

    group('when releasing the app with --platforms android,ios', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'release',
          'app',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
          '--platforms',
          'android,ios',
        ]);
      });

      test('then the command throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the missing platform is logged', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.errorCalls,
          contains(
            equalsErrorCall(
              message: 'The app has no code for the platforms: ios.',
              hint:
                  'Add them with "flutter create --platforms=ios ." '
                  'in the app directory, or leave them out of --platforms.',
            ),
          ),
        );
      });

      test('then no upload description is requested', () async {
        await commandResult.catchError((_) {});

        verifyNever(
          () => client.deploy.createAppUploadDescription(
            any(),
            archiveSize: any(named: 'archiveSize'),
          ),
        );
      });
    });

    group('when releasing the app with --platforms android,linux,windows', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'release',
          'app',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
          '--platforms',
          'android,linux,windows',
        ]);
      });

      test('then a UsageException names the unsupported platforms', () async {
        await expectLater(
          commandResult,
          throwsA(
            isA<UsageException>().having(
              (e) => e.message,
              'message',
              contains(
                'Releasing for linux, windows is not supported yet. '
                'Supported platforms: android, ios.',
              ),
            ),
          ),
        );
      });

      test('then no upload description is requested', () async {
        await commandResult.catchError((_) {});

        verifyNever(
          () => client.deploy.createAppUploadDescription(
            any(),
            archiveSize: any(named: 'archiveSize'),
          ),
        );
      });
    });

    test('when releasing the app with an unknown platform '
        'then a UsageException names the unknown platform', () async {
      await expectLater(
        cli.run([
          'release',
          'app',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
          '--platforms',
          'fuchsia',
        ]),
        throwsA(
          isA<UsageException>().having(
            (e) => e.message,
            'message',
            contains(
              'Failed to resolve option `platforms`: FormatException: '
              '"fuchsia" is not in android|ios|linux|macos|windows.',
            ),
          ),
        ),
      );
    });

    test('when releasing the app with --app-dir '
        'then the app archive is uploaded', () async {
      await cli.run([
        'release',
        'app',
        '--project',
        _projectId,
        '--app-dir',
        p.join(d.sandbox, 'monorepo', 'project_flutter'),
      ]);

      expect(
        _uploadedArchive(fileUploader).findFile('project_flutter/pubspec.yaml'),
        isNotNull,
      );
    });

    group('and an archive above the upload limit when releasing the app', () {
      late Future<void> commandResult;

      setUp(() {
        when(
          () => client.deploy.createAppUploadDescription(
            any(),
            archiveSize: any(named: 'archiveSize'),
          ),
        ).thenThrow(
          UploadTooLargeException(
            message: 'The app archive is too large.',
            sizeBytes: 2,
            maxSizeBytes: 1,
          ),
        );

        commandResult = cli.run([
          'release',
          'app',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
        ]);
      });

      test('then the command throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the error is logged with a hint to exclude files', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.errorCalls,
          contains(
            equalsErrorCall(
              message: 'The app archive is too large.',
              hint:
                  'Exclude files from the app with a .scloudignore file, '
                  'or release fewer platforms with the --platforms option.',
            ),
          ),
        );
      });

      test('then nothing is uploaded', () async {
        await commandResult.catchError((_) {});

        expect(fileUploader.uploads, isEmpty);
      });
    });
  });

  group('Given a non-workspace Serverpod server project '
      'when releasing the app', () {
    late Future<void> commandResult;

    setUp(() async {
      await ProjectFactory.serverpodServerDir().create();

      commandResult = cli.run([
        'release',
        'app',
        '--project',
        _projectId,
        '--project-dir',
        p.join(d.sandbox, ProjectFactory.defaultDirectoryName),
      ]);
    });

    test('then the command throws ErrorExitException', () async {
      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
    });

    test('then the workspace requirement is logged', () async {
      await commandResult.catchError((_) {});

      expect(
        logger.errorCalls,
        contains(
          equalsErrorCall(
            message: 'Releasing the app requires a Dart workspace project.',
            hint:
                'Use the --app-dir option to select the Flutter app directory.',
          ),
        ),
      );
    });
  });
}

Archive _uploadedArchive(RecordingFileUploader fileUploader) {
  return ZipDecoder().decodeBytes(fileUploader.uploads.single.data);
}

Map _archivedYaml(Archive archive, String path) {
  final file = archive.findFile(path);
  if (file == null) throw StateError('$path is not in the archive.');
  return yamlDecode(utf8.decode(file.content)) as Map;
}
