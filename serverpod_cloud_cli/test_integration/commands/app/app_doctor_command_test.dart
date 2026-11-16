import 'dart:convert';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/app/app_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/shared/helpers/console_urls.dart'
    show getAppStoreSetupUrl;
import 'package:serverpod_cloud_cli/util/flutter_release_setup.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:yaml_codec/yaml_codec.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/project_factory.dart';
import '../../../test_utils/test_command_logger.dart';

const _projectId = 'my-project-id';

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

  setUp(() {
    _stubSetup(
      client,
      AppPublishingSetupBuilder()
          .withGooglePlayAccess()
          .withAndroidKeystore()
          .build(),
    );
  });

  tearDown(() {
    logger.clear();
    localFlutterVersion = null;
  });

  test('Given app doctor command when instantiated '
      'then it requires login', () {
    expect(CloudAppDoctorCommand(logger: logger).requireLogin, isTrue);
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
          '--project',
          _projectId,
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
          '--project',
          _projectId,
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
            '✓ Flutter version: 3.29.0 (from pubspec.yaml)',
            '',
            'Android',
            '  ✓ Google Play Console connection',
            '  ✓ Package name: com.acme.app',
            '  ✓ Release signing',
            '  ✓ App icon',
            '',
            'iOS',
            '  ✓ App Store connection',
            '  ✓ Bundle ID: com.acme.app',
            '  ✓ Export compliance',
            '  ✓ App icon',
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
        '--project',
        _projectId,
        '--app-dir',
        d.path('project_flutter'),
      ]);

      final checks = (jsonDecode(logger.rawCalls.single.content) as List)
          .cast<Map>();
      expect(checks.map((check) => (check['platform'], check['check'])), [
        (null, 'flutterVersion'),
        ('android', 'consoleSetup'),
        ('android', 'appIdentifier'),
        ('android', 'releaseSigning'),
        ('android', 'appIcon'),
        ('ios', 'consoleSetup'),
        ('ios', 'appIdentifier'),
        ('ios', 'exportCompliance'),
        ('ios', 'appIcon'),
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
        '--project',
        _projectId,
        '--app-dir',
        d.path('project_flutter'),
      ]);

      final checks = (yamlDecode(logger.rawCalls.single.content) as List)
          .cast<Map>();
      expect(checks, hasLength(9));
      expect(checks.map((check) => check['status']), everyElement('passed'));
    });

    test('when checking the app with --platforms ios '
        'then only the checks of the app and iOS are shown', () async {
      await cli.run([
        'app',
        'doctor',
        '--project',
        _projectId,
        '--app-dir',
        d.path('project_flutter'),
        '--platforms',
        'ios',
      ]);

      final lines = logger.lineCalls.map((call) => call.line);
      expect(
        lines,
        containsAllInOrder([startsWith('✓ Flutter version: '), 'iOS']),
      );
      expect(lines, isNot(contains('Android')));
    });

    test('when checking the app with --flutter-version '
        'then the requested version passes', () async {
      await cli.run([
        'app',
        'doctor',
        '--project',
        _projectId,
        '--app-dir',
        d.path('project_flutter'),
        '--flutter-version',
        '3.38.4',
      ]);

      expect(
        logger.lineCalls.map((call) => call.line),
        contains('✓ Flutter version: 3.38.4 (from --flutter-version flag)'),
      );
    });

    group('when checking the app with a --flutter-version '
        'that is not a release version', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'doctor',
          '--project',
          _projectId,
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
            '✗ Flutter version: Unsupported Flutter version "beta" '
                '(from --flutter-version flag).',
            '  Use a Flutter release version such as 3.50.0 with '
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
        '--project',
        _projectId,
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
        '--project',
        _projectId,
        '--app-dir',
        d.path('project_flutter'),
      ]);
    });

    test('when checking the app then the Flutter version check passes '
        'with the version of the local Flutter SDK', () async {
      await commandResult;

      expect(
        logger.lineCalls.map((call) => call.line),
        contains('✓ Flutter version: 3.38.4 (from local Flutter SDK)'),
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
            withDefaultAppIcon: true,
          ),
          ProjectFactory.flutterIosDir(
            bundleId: 'com.example.app',
            withInfoPlist: true,
            withDefaultAppIcon: true,
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
          '--project',
          _projectId,
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
            '! Flutter version: Not pinned, so builds use the latest stable '
                'release.',
            '  Request a version with --flutter-version, or pin one in '
                "environment.flutter of the app's pubspec.yaml.",
          ]),
        );
      });

      test('then the release signing check fails '
          'with a link to the docs', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.lineCalls.map((call) => call.line),
          containsAllInOrder([
            '  ✗ Release signing: Release builds are signed with the debug '
                'key.',
            '    Learn more: $androidReleaseSigningDocsUrl',
          ]),
        );
      });

      test('then the export compliance check fails '
          'with a link to the docs', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.lineCalls.map((call) => call.line),
          containsAllInOrder([
            '  ✗ Export compliance: The app does not declare whether it uses '
                'encryption.',
            '    Learn more: $iosExportComplianceDocsUrl',
          ]),
        );
      });

      test('then the app icon check of each platform warns '
          'with a link to the docs', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.lineCalls.map((call) => call.line),
          containsAllInOrder([
            'Android',
            '  ! App icon: The app uses the default Flutter icon.',
            '    Learn more: $appIconDocsUrl',
            'iOS',
            '  ! App icon: The app uses the default Flutter icon.',
            '    Learn more: $appIconDocsUrl',
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
              '--project',
              _projectId,
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
        expect(flutterVersion['hint'], contains('pubspec.yaml'));
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
        '--project',
        _projectId,
        '--project-dir',
        p.join(d.sandbox, 'monorepo', 'project_server'),
      ]);

      expect(
        logger.lineCalls.map((call) => call.line),
        containsAllInOrder(['Android', '  ✓ Package name: com.acme.app']),
      );
    });

    group('and a scloud.yaml whose project.app.dir does not exist', () {
      setUp(() async {
        await d.dir('monorepo', [
          d.dir('project_server', [
            d.file('scloud.yaml', '''
project:
  projectId: "my-project-id"
  app:
    dir: "../missing_flutter"
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
            '--project',
            _projectId,
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
              contains('set by project.app.dir'),
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
  app:
    flutterSdk: "3.38.3"
    identifiers:
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
            '--project',
            _projectId,
            '--project-dir',
            p.join(d.sandbox, 'monorepo', 'project_server'),
          ]);
        });

        test('then the configured Flutter version passes', () async {
          await commandResult;

          expect(
            logger.lineCalls.map((call) => call.line),
            contains('✓ Flutter version: 3.38.3 (from scloud.yaml)'),
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

  group('Given a Flutter app set up for publishing in a project with '
      'nothing set up in the console', () {
    setUp(() async {
      _stubSetup(
        client,
        AppPublishingSetupBuilder().withNothingSetUp().build(),
      );
      await ProjectFactory.nonWorkspaceFlutterAppDir(
        contents: [
          ProjectFactory.flutterAndroidDir(
            releaseSigning: ProjectFactory.serverpodCloudReleaseSigning,
          ),
          ProjectFactory.flutterIosDir(usesNonExemptEncryption: false),
        ],
      ).create();
    });

    group('when checking the app', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'doctor',
          '--project',
          _projectId,
          '--app-dir',
          d.path('project_flutter'),
        ]);
      });

      test('then the command throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the console setup check of each platform fails '
          'with a link to its setup guide', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.lineCalls.map((call) => call.line),
          containsAllInOrder([
            'Android',
            '  ✗ Google Play Console connection: Not set up yet.',
            '    Finish it here: '
                '${getAppStoreSetupUrl(_projectId, AppPlatform.android)}',
            'iOS',
            '  ✗ App Store connection: Not set up yet.',
            '    Finish it here: '
                '${getAppStoreSetupUrl(_projectId, AppPlatform.ios)}',
          ]),
        );
      });
    });

    test('when checking the app with --format json '
        'then the console setup checks are listed as failed', () async {
      await cli
          .run([
            '--format',
            'json',
            'app',
            'doctor',
            '--project',
            _projectId,
            '--app-dir',
            d.path('project_flutter'),
          ])
          .catchError((_) {});

      final checks = (jsonDecode(logger.rawCalls.single.content) as List)
          .cast<Map>()
          .where((check) => check['check'] == 'consoleSetup');
      expect(checks.map((check) => (check['platform'], check['status'])), [
        ('android', 'failed'),
        ('ios', 'failed'),
      ]);
    });
  });

  group('Given an Android app set up for publishing in a project whose '
      'Google Play access Serverpod Cloud is still creating', () {
    setUp(() async {
      _stubSetup(
        client,
        AppPublishingSetupBuilder().withAndroidKeystore().build(),
      );
      await ProjectFactory.nonWorkspaceFlutterAppDir(
        contents: [
          ProjectFactory.flutterAndroidDir(
            releaseSigning: ProjectFactory.serverpodCloudReleaseSigning,
          ),
        ],
      ).create();
    });

    test('when checking the app then the console setup check fails '
        'saying it needs nothing from the user', () async {
      await cli
          .run([
            'app',
            'doctor',
            '--project',
            _projectId,
            '--app-dir',
            d.path('project_flutter'),
          ])
          .catchError((_) {});

      expect(
        logger.lineCalls.map((call) => call.line),
        containsAllInOrder([
          '  ✗ Google Play Console connection: Serverpod Cloud is still '
              'creating Google Play access.',
          '    This needs nothing from you.',
        ]),
      );
    });
  });

  group('Given a Flutter app set up for publishing in a project that does '
      'not exist', () {
    late Future<void> commandResult;

    setUp(() async {
      when(
        () => client.appPublishing.getSetup(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
        ),
      ).thenThrow(NotFoundException(message: 'Project not found.'));
      await ProjectFactory.nonWorkspaceFlutterAppDir(
        contents: [
          ProjectFactory.flutterAndroidDir(
            releaseSigning: ProjectFactory.serverpodCloudReleaseSigning,
          ),
        ],
      ).create();

      commandResult = cli.run([
        'app',
        'doctor',
        '--project',
        _projectId,
        '--app-dir',
        d.path('project_flutter'),
      ]);
    });

    test('when checking the app '
        'then the command throws ErrorExitException', () async {
      await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
    });

    test('when checking the app then the error is logged', () async {
      await commandResult.catchError((_) {});

      expect(
        logger.errorCalls,
        contains(equalsErrorCall(message: 'Project not found.')),
      );
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
        '--project',
        _projectId,
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

void _stubSetup(ClientMock client, AppPublishingSetup setup) {
  when(
    () => client.appPublishing.getSetup(
      cloudCapsuleId: any(named: 'cloudCapsuleId'),
    ),
  ).thenAnswer((_) async => setup);
}
