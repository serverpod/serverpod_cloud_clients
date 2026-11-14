import 'dart:convert';

import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/app/app_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/flutter_release_setup.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:yaml_codec/yaml_codec.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/project_factory.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );
  String? localFlutterVersion;
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (_) => client,
      localFlutterVersionReader: (_, _) async => localFlutterVersion,
    ),
  );

  tearDown(() {
    logger.clear();
    localFlutterVersion = null;
  });

  test('Given app doctor command when instantiated '
      'then it does not require login', () {
    expect(CloudAppDoctorCommand(logger: logger).requireLogin, isFalse);
  });

  group('Given a Flutter app set up for publishing', () {
    setUp(() async {
      await ProjectFactory.nonWorkspaceFlutterAppDir(
        contents: [
          ProjectFactory.flutterAndroidDir(
            applicationId: 'com.acme.app',
            releaseSigning: ProjectFactory.serverpodCloudReleaseSigning,
          ),
          ProjectFactory.flutterIosDir(
            bundleId: 'com.acme.app',
            usesNonExemptEncryption: false,
          ),
        ],
      ).create();
    });

    for (final (input, expected) in [
      ('IOS', ['iOS']),
      ('Android', ['Android']),
      (' iOs , ANDROID ', ['Android', 'iOS']),
    ]) {
      test('when checking platforms $input '
          'then only $expected are checked', () async {
        await cli.run([
          'app',
          'doctor',
          '--app-dir',
          d.path('project_flutter'),
          '--platforms',
          input,
        ]);

        expect(
          logger.lineCalls
              .map((call) => call.line)
              .where((line) => line == 'iOS' || line == 'Android'),
          expected,
        );
      });
    }

    group('when checking the app', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'doctor',
          '--app-dir',
          d.path('project_flutter'),
        ]);
      });

      test('then each check of the app and its platforms passes, '
          'with a blank line between the sections', () async {
        await commandResult;

        expect(
          logger.lineCalls.map((call) => call.line),
          containsAllInOrder([
            'App',
            '  ✓ Flutter version: 3.29.0 (from pubspec.yaml)',
            '',
            'Android',
            '  ✓ Package name: com.acme.app',
            '  ✓ Release signing: android/app/build.gradle.kts signs release '
                'builds on Serverpod Cloud with the release signing config',
            '',
            'iOS',
            '  ✓ Bundle ID: com.acme.app',
            '  ✓ Export compliance: ITSAppUsesNonExemptEncryption is false',
          ]),
        );
      });

      test('then the command completes', () async {
        await expectLater(commandResult, completes);
      });

      test('then no issues are reported', () async {
        await commandResult;

        expect(
          logger.successCalls,
          contains(
            equalsSuccessCall(message: 'No issues found.', newParagraph: true),
          ),
        );
      });
    });

    test('when checking the app with --format json '
        'then each check is listed as passed', () async {
      await cli.run([
        '--format',
        'json',
        'app',
        'doctor',
        '--app-dir',
        d.path('project_flutter'),
      ]);

      final checks = (jsonDecode(logger.rawCalls.single.content) as List)
          .cast<Map>();
      expect(checks.map((check) => (check['platform'], check['check'])), [
        (null, 'flutterVersion'),
        ('android', 'appIdentifier'),
        ('android', 'releaseSigning'),
        ('ios', 'appIdentifier'),
        ('ios', 'exportCompliance'),
      ]);
      expect(checks.map((check) => check['status']), everyElement('passed'));
      expect(logger.lineCalls, isEmpty);
    });

    test('when checking the app with --format yaml '
        'then each check is listed as passed', () async {
      await cli.run([
        '--format',
        'yaml',
        'app',
        'doctor',
        '--app-dir',
        d.path('project_flutter'),
      ]);

      final checks = (yamlDecode(logger.rawCalls.single.content) as List)
          .cast<Map>();
      expect(checks, hasLength(5));
      expect(checks.map((check) => check['status']), everyElement('passed'));
    });

    test('when checking the app with --platforms ios '
        'then only the checks of the app and iOS are shown', () async {
      await cli.run([
        'app',
        'doctor',
        '--app-dir',
        d.path('project_flutter'),
        '--platforms',
        'ios',
      ]);

      final lines = logger.lineCalls.map((call) => call.line);
      expect(lines, containsAllInOrder(['App', 'iOS']));
      expect(lines, isNot(contains('Android')));
    });

    test('when checking the app with --flutter-version '
        'then the requested version passes', () async {
      await cli.run([
        'app',
        'doctor',
        '--app-dir',
        d.path('project_flutter'),
        '--flutter-version',
        '3.38.4',
      ]);

      expect(
        logger.lineCalls.map((call) => call.line),
        contains('  ✓ Flutter version: 3.38.4 (from --flutter-version flag)'),
      );
    });

    group('when checking the app with a --flutter-version '
        'that is not a release version', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'doctor',
          '--app-dir',
          d.path('project_flutter'),
          '--flutter-version',
          'beta',
        ]);
      });

      test('then the command throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the Flutter version check fails with its fix', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.lineCalls.map((call) => call.line),
          containsAllInOrder([
            '  ✗ Flutter version: Unsupported Flutter version "beta" '
                '(from --flutter-version flag).',
            '    Use a Flutter release version such as 3.38.4 with '
                "--flutter-version, or pin one in environment.flutter of the app's "
                'pubspec.yaml.',
          ]),
        );
      });

      test('then one failed check is reported', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.warningCalls,
          contains(
            equalsWarningCall(
              message: '1 check failed. Fix it before you publish the app.',
              newParagraph: true,
            ),
          ),
        );
      });
    });
  });

  group('Given a Flutter app set up for publishing without a requested '
      'Flutter version', () {
    late Future<void> commandResult;

    setUp(() async {
      await ProjectFactory.nonWorkspaceFlutterAppDir(
        withFlutterConstraint: '>=3.29.0',
        contents: [
          ProjectFactory.flutterAndroidDir(
            releaseSigning: ProjectFactory.serverpodCloudReleaseSigning,
          ),
        ],
      ).create();

      commandResult = cli.run([
        'app',
        'doctor',
        '--app-dir',
        d.path('project_flutter'),
      ]);
    });

    test('when checking the app then the command completes despite the '
        'warning', () async {
      await expectLater(commandResult, completes);
    });

    test(
      'when checking the app then the summary is the number of warnings',
      () async {
        await commandResult;

        expect(
          logger.infoCalls,
          contains(
            equalsInfoCall(message: '1 warning found', newParagraph: true),
          ),
        );
        expect(logger.successCalls, isEmpty);
      },
    );
  });

  group('Given a Flutter app set up for publishing without a requested '
      'Flutter version and a local Flutter SDK', () {
    late Future<void> commandResult;

    setUp(() async {
      await ProjectFactory.nonWorkspaceFlutterAppDir(
        withFlutterConstraint: '>=3.29.0',
        contents: [
          ProjectFactory.flutterAndroidDir(
            releaseSigning: ProjectFactory.serverpodCloudReleaseSigning,
          ),
        ],
      ).create();
      localFlutterVersion = '3.38.4';

      commandResult = cli.run([
        'app',
        'doctor',
        '--app-dir',
        d.path('project_flutter'),
      ]);
    });

    test('when checking the app then the Flutter version check passes '
        'with the version of the local Flutter SDK', () async {
      await commandResult;

      expect(
        logger.lineCalls.map((call) => call.line),
        contains('  ✓ Flutter version: 3.38.4 (from local Flutter SDK)'),
      );
    });
  });

  group('Given a Flutter app as flutter create writes it', () {
    setUp(() async {
      await ProjectFactory.nonWorkspaceFlutterAppDir(
        withFlutterConstraint: '>=3.29.0',
        contents: [
          ProjectFactory.flutterAndroidDir(
            applicationId: 'com.example.app',
            releaseSigning: ProjectFactory.debugKeyReleaseSigning,
          ),
          ProjectFactory.flutterIosDir(
            bundleId: 'com.example.app',
            withInfoPlist: true,
          ),
        ],
      ).create();
    });

    group('when checking the app', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'doctor',
          '--app-dir',
          d.path('project_flutter'),
        ]);
      });

      test('then the command throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the Flutter version check warns '
          'that the latest stable release is used', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.lineCalls.map((call) => call.line),
          containsAllInOrder([
            '  ! Flutter version: No Flutter version is requested, so the '
                'builds use the latest stable release.',
            '    Set project.flutterSdk in scloud.yaml to the Flutter version '
                'the app is developed with.',
          ]),
        );
      });

      test('then the release signing check fails '
          'with a link to set it up', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.lineCalls.map((call) => call.line),
          containsAllInOrder([
            '  ✗ Release signing: android/app/build.gradle.kts signs release '
                'builds with the debug key.',
            '    Android release signing is managed by Serverpod Cloud. Follow '
                'this link to set it up for your project.',
            '    $androidReleaseSigningDocsUrl',
          ]),
        );
      });

      test('then the export compliance check fails', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.lineCalls.map((call) => call.line),
          contains(
            startsWith(
              '  ✗ Export compliance: ios/Runner/Info.plist does not set '
              'ITSAppUsesNonExemptEncryption',
            ),
          ),
        );
      });

      test('then the export compliance hint shows the Info.plist lines '
          'that set it to false', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.lineCalls.map((call) => call.line),
          containsAllInOrder([
            '    If the app uses no encryption, or only exempt encryption such '
                'as HTTPS, add these lines inside <dict> in '
                'ios/Runner/Info.plist:',
            '      <key>ITSAppUsesNonExemptEncryption</key>',
            '      <false/>',
            startsWith('    Otherwise set it to <true/>'),
          ]),
        );
      });

      test('then the placeholder app identifiers fail', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.lineCalls.map((call) => call.line),
          containsAllInOrder([
            startsWith(
              '  ✗ Package name: The Android package name com.example.app is '
              "Flutter's placeholder",
            ),
            startsWith(
              "  ✗ Bundle ID: The iOS bundle ID com.example.app is Flutter's "
              'placeholder',
            ),
          ]),
        );
      });

      test('then the number of failed checks is reported', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.warningCalls,
          contains(
            equalsWarningCall(
              message: '4 checks failed. Fix them before you publish the app.',
              newParagraph: true,
            ),
          ),
        );
      });
    });

    group('when checking the app with --format json', () {
      late List<Map> checks;

      setUp(() async {
        await cli
            .run([
              '--format',
              'json',
              'app',
              'doctor',
              '--app-dir',
              d.path('project_flutter'),
            ])
            .catchError((_) {});
        checks = (jsonDecode(logger.rawCalls.single.content) as List)
            .cast<Map>();
      });

      test('then the Flutter version check is a warning with its hint', () {
        final flutterVersion = checks.singleWhere(
          (check) => check['check'] == 'flutterVersion',
        );
        expect(flutterVersion['status'], 'warning');
        expect(flutterVersion['hint'], contains('project.flutterSdk'));
      });

      test('then the release signing check failed with its hint', () {
        final releaseSigning = checks.singleWhere(
          (check) => check['check'] == 'releaseSigning',
        );
        expect(releaseSigning['status'], 'failed');
        expect(releaseSigning['hint'], contains(androidReleaseSigningDocsUrl));
      });
    });
  });

  group('Given a workspace with a Serverpod server and a Flutter app '
      'set up for publishing', () {
    setUp(() async {
      await ProjectFactory.serverpodAppWorkspace().create();
      await d.dir('monorepo', [
        d.dir('project_flutter', [
          ProjectFactory.flutterAndroidDir(
            releaseSigning: ProjectFactory.serverpodCloudReleaseSigning,
          ),
        ]),
      ]).create();
    });

    test('when checking the app from the server directory '
        "then the workspace's Flutter app is checked", () async {
      await cli.run([
        'app',
        'doctor',
        '--project-dir',
        p.join(d.sandbox, 'monorepo', 'project_server'),
      ]);

      expect(
        logger.lineCalls.map((call) => call.line),
        containsAllInOrder(['Android', '  ✓ Package name: com.acme.app']),
      );
    });

    group('and a scloud.yaml whose project.appDir does not exist', () {
      setUp(() async {
        await d.dir('monorepo', [
          d.dir('project_server', [
            d.file('scloud.yaml', '''
project:
  projectId: "my-project-id"
  appDir: "../missing_flutter"
'''),
          ]),
        ]).create();
      });

      group('when checking the app with --format json', () {
        late Future<void> commandResult;

        setUp(() {
          commandResult = cli.run([
            '--format',
            'json',
            'app',
            'doctor',
            '--project-dir',
            p.join(d.sandbox, 'monorepo', 'project_server'),
          ]);
        });

        test('then the command throws ErrorExitException', () async {
          await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test(
          'then the missing directory is reported as a json error document',
          () async {
            await commandResult.catchError((_) {});

            expect(
              jsonDecode(logger.errorCalls.single.message),
              contains('set by project.appDir'),
            );
          },
        );
      });
    });

    group('and a Flutter SDK range in the pubspec of the app '
        'and a scloud.yaml that sets the Flutter version and the Android '
        'package name', () {
      setUp(() async {
        await d.dir('monorepo', [
          d.dir('project_flutter', [
            d.file(
              'pubspec.yaml',
              ProjectFactory.serverpodFlutterAppPubspec(
                withFlutterConstraint: '">=3.29.0"',
              ),
            ),
            ProjectFactory.flutterAndroidDir(
              applicationId: 'com.example.app',
              releaseSigning: ProjectFactory.serverpodCloudReleaseSigning,
            ),
          ]),
          d.dir('project_server', [
            d.file('scloud.yaml', '''
project:
  projectId: "my-project-id"
  flutterSdk: "3.38.3"
  appIdentifiers:
    android: "com.acme.configured"
'''),
          ]),
        ]).create();
      });

      group('when checking the app', () {
        late Future<void> commandResult;

        setUp(() {
          commandResult = cli.run([
            'app',
            'doctor',
            '--project-dir',
            p.join(d.sandbox, 'monorepo', 'project_server'),
          ]);
        });

        test('then the configured Flutter version passes', () async {
          await commandResult;

          expect(
            logger.lineCalls.map((call) => call.line),
            contains('  ✓ Flutter version: 3.38.3 (from scloud.yaml)'),
          );
        });

        test('then the configured package name passes '
            "over the app's placeholder", () async {
          await commandResult;

          expect(
            logger.lineCalls.map((call) => call.line),
            contains('  ✓ Package name: com.acme.configured'),
          );
        });
      });
    });
  });

  group('Given a Flutter app without Android or iOS code', () {
    late Future<void> commandResult;

    setUp(() async {
      await ProjectFactory.nonWorkspaceFlutterAppDir(
        contents: [
          d.dir('windows', [d.file('CMakeLists.txt', '')]),
        ],
      ).create();

      commandResult = cli.run([
        'app',
        'doctor',
        '--app-dir',
        d.path('project_flutter'),
      ]);
    });

    test(
      'when checking the app then the command throws ErrorExitException',
      () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      },
    );
  });
}
