import 'dart:convert';

import 'package:config/config.dart' show UsageException;
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/app/app_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/flutter_release_setup.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:yaml_codec/yaml_codec.dart';

import '../../../test/util/inline_tui/helpers/fake_terminal.dart';
import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/project_factory.dart';
import '../../../test_utils/test_command_logger.dart';

const _projectId = 'my-project-id';

void main() {
  final logger = TestCommandLogger();
  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(apiClientFactory: (_) => client),
  );

  setUp(() {
    when(
      () => client.appPublishing.setAndroidPackageName(
        cloudCapsuleId: any(named: 'cloudCapsuleId'),
        packageName: any(named: 'packageName'),
      ),
    ).thenAnswer((_) async => AppPublishingSetupBuilder().build());
    when(
      () => client.appPublishing.setIosBundleId(
        cloudCapsuleId: any(named: 'cloudCapsuleId'),
        bundleId: any(named: 'bundleId'),
      ),
    ).thenAnswer((_) async => AppPublishingSetupBuilder().build());
  });

  tearDown(() {
    logger.clear();
    reset(client.appPublishing);
  });

  test('Given app setup command when instantiated '
      'then it requires login', () {
    expect(CloudAppSetupCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given a Flutter app set up for publishing', () {
    setUp(() async {
      await ProjectFactory.nonWorkspaceFlutterAppDir(
        contents: [
          ProjectFactory.flutterAndroidDir(
            applicationId: 'com.acme.app',
            releaseSigning: ProjectFactory.serverpodCloudReleaseSigning,
          ),
          ProjectFactory.flutterIosDir(bundleId: 'com.acme.app'),
        ],
      ).create();
    });

    group('when setting up the app', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'setup',
          '--project',
          _projectId,
          '--app-dir',
          d.path('project_flutter'),
        ]);
      });

      test('then each check of each platform passes', () async {
        await commandResult;

        expect(
          logger.lineCalls.map((call) => call.line),
          containsAllInOrder([
            'Android',
            '  ✓ Package name: com.acme.app',
            '  ✓ Release signing',
            '',
            'iOS',
            '  ✓ Bundle ID: com.acme.app',
          ]),
        );
      });

      test('then the app is reported as set up', () async {
        await commandResult;

        expect(
          logger.successCalls,
          contains(
            equalsSuccessCall(
              message: 'The app is set up for publishing.',
              newParagraph: true,
            ),
          ),
        );
      });

      test('then no app identifier is asked for', () async {
        await commandResult;

        expect(logger.inputCalls, isEmpty);
      });

      test('then the Android package name is recorded', () async {
        await commandResult;

        verify(
          () => client.appPublishing.setAndroidPackageName(
            cloudCapsuleId: _projectId,
            packageName: 'com.acme.app',
          ),
        ).called(1);
      });

      test('then the iOS bundle ID is recorded', () async {
        await commandResult;

        verify(
          () => client.appPublishing.setIosBundleId(
            cloudCapsuleId: _projectId,
            bundleId: 'com.acme.app',
          ),
        ).called(1);
      });
    });

    test('when setting up the app with --format json '
        'then each check is listed as passed', () async {
      await cli.run([
        '--format',
        'json',
        'app',
        'setup',
        '--project',
        _projectId,
        '--app-dir',
        d.path('project_flutter'),
      ]);

      final checks = (jsonDecode(logger.rawCalls.single.content) as List)
          .cast<Map>();
      expect(checks.map((check) => (check['platform'], check['check'])), [
        ('android', 'appIdentifier'),
        ('android', 'releaseSigning'),
        ('ios', 'appIdentifier'),
      ]);
      expect(checks.map((check) => check['status']), everyElement('passed'));
      expect(logger.lineCalls, isEmpty);
    });

    test('when setting up the app with --format yaml '
        'then each check is listed as passed', () async {
      await cli.run([
        '--format',
        'yaml',
        'app',
        'setup',
        '--project',
        _projectId,
        '--app-dir',
        d.path('project_flutter'),
      ]);

      final checks = (yamlDecode(logger.rawCalls.single.content) as List)
          .cast<Map>();
      expect(checks, hasLength(3));
      expect(checks.map((check) => check['status']), everyElement('passed'));
    });
  });

  group("Given a Flutter app with Flutter's placeholder app identifiers", () {
    setUp(() async {
      await ProjectFactory.nonWorkspaceFlutterAppDir(
        contents: [
          ProjectFactory.flutterAndroidDir(
            applicationId: 'com.example.my_app',
            releaseSigning: ProjectFactory.serverpodCloudReleaseSigning,
          ),
          ProjectFactory.flutterIosDir(bundleId: 'com.example.myApp'),
        ],
      ).create();
    });

    group('when setting up Android and choosing the suggested package name', () {
      late Future<void> commandResult;

      setUp(() {
        logger.inlineTerminal = FakeTerminal()..queueInput(FakeTerminal.enter);
        commandResult = cli.run([
          'app',
          'setup',
          '--project',
          _projectId,
          '--app-dir',
          d.path('project_flutter'),
          '--platforms',
          'android',
        ]);
      });

      test('then the choice reports the placeholder', () async {
        await commandResult;

        expect(
          (logger.inlineTerminal as FakeTerminal).output,
          contains(
            "The Android package name com.example.my_app is Flutter's "
            'placeholder.\nChoose a new package name to publish the app with:',
          ),
        );
      });

      test('then a package name based on the project id is offered', () async {
        await commandResult;

        expect(
          (logger.inlineTerminal as FakeTerminal).output,
          contains('Use space.serverpod.my_project_id'),
        );
      });

      test('then no package name is typed in', () async {
        await commandResult;

        expect(logger.inputCalls, isEmpty);
      });

      test('then applicationId is set to the suggested package name', () async {
        await commandResult;

        await expectLater(
          d.dir('project_flutter', [
            d.dir('android', [
              d.dir('app', [
                d.file(
                  'build.gradle.kts',
                  contains('applicationId = "space.serverpod.my_project_id"'),
                ),
              ]),
            ]),
          ]).validate(),
          completes,
        );
      });

      test('then the suggested package name is recorded', () async {
        await commandResult;

        verify(
          () => client.appPublishing.setAndroidPackageName(
            cloudCapsuleId: _projectId,
            packageName: 'space.serverpod.my_project_id',
          ),
        ).called(1);
      });

      test('then the package name check passes with the new one '
          'and the file it was set in', () async {
        await commandResult;

        expect(
          logger.lineCalls.map((call) => call.line),
          contains(
            '  ✓ Package name: space.serverpod.my_project_id '
            '(set in android/app/build.gradle.kts)',
          ),
        );
      });
    });

    group('when setting up Android and typing an invalid package name and '
        'then a valid one', () {
      late Future<void> commandResult;

      setUp(() {
        logger.inlineTerminal = FakeTerminal()
          ..queueInput([...'com.acme.my-app'.codeUnits, ...FakeTerminal.enter])
          ..queueInput([
            for (var i = 0; i < 'my-app'.length; i++) 0x7f,
            ...'my_app'.codeUnits,
            ...FakeTerminal.enter,
          ]);
        commandResult = cli.run([
          'app',
          'setup',
          '--project',
          _projectId,
          '--app-dir',
          d.path('project_flutter'),
          '--platforms',
          'android',
        ]);
      });

      test('then the option to enter a package name is offered', () async {
        await commandResult;

        expect(
          (logger.inlineTerminal as FakeTerminal).output,
          contains('Enter a different package name'),
        );
      });

      test('then a hint on how to make a package name is shown beneath the '
          'input after a blank line', () async {
        await commandResult;

        expect(
          (logger.inlineTerminal as FakeTerminal).output,
          contains(
            'Package name: com.acme.my-app_\n'
            '\n'
            '      The Android package name com.acme.my-app is not valid.\n'
            '\n'
            '      Use a reverse domain you own, like com.yourcompany.app.\n',
          ),
        );
      });

      test('then the invalid package name is reported in the prompt', () async {
        await commandResult;

        expect(
          (logger.inlineTerminal as FakeTerminal).output,
          contains('The Android package name com.acme.my-app is not valid.'),
        );
      });

      test('then the prompt is printed once', () async {
        await commandResult;

        expect(
          'Choose a new package name to publish the app with:'.allMatches(
            (logger.inlineTerminal as FakeTerminal).output,
          ),
          hasLength(1),
        );
      });

      test('then the valid package name is recorded', () async {
        await commandResult;

        verify(
          () => client.appPublishing.setAndroidPackageName(
            cloudCapsuleId: _projectId,
            packageName: 'com.acme.my_app',
          ),
        ).called(1);
      });
    });

    group('when setting up Android, typing a package name and going back up '
        'to the suggested one', () {
      late Future<void> commandResult;

      setUp(() {
        logger.inlineTerminal = FakeTerminal()
          ..queueInput('com.acme'.codeUnits)
          ..queueInput([...FakeTerminal.arrowUp, ...FakeTerminal.enter]);
        commandResult = cli.run([
          'app',
          'setup',
          '--project',
          _projectId,
          '--app-dir',
          d.path('project_flutter'),
          '--platforms',
          'android',
        ]);
      });

      test('then the suggested package name is recorded', () async {
        await commandResult;

        verify(
          () => client.appPublishing.setAndroidPackageName(
            cloudCapsuleId: _projectId,
            packageName: 'space.serverpod.my_project_id',
          ),
        ).called(1);
      });
    });

    group('when setting up Android and cancelling the prompt', () {
      late Future<void> commandResult;

      setUp(() {
        logger.inlineTerminal = FakeTerminal()..queueInput(FakeTerminal.escape);
        commandResult = cli.run([
          'app',
          'setup',
          '--project',
          _projectId,
          '--app-dir',
          d.path('project_flutter'),
          '--platforms',
          'android',
        ]);
      });

      test('then the command throws UserAbortException', () async {
        await expectLater(commandResult, throwsA(isA<UserAbortException>()));
      });

      test('then the app project files keep the placeholder', () async {
        await commandResult.catchError((_) {});

        await expectLater(
          d.dir('project_flutter', [
            d.dir('android', [
              d.dir('app', [
                d.file(
                  'build.gradle.kts',
                  contains('applicationId = "com.example.my_app"'),
                ),
              ]),
            ]),
          ]).validate(),
          completes,
        );
      });
    });

    group('when setting up iOS and typing a bundle ID', () {
      late Future<void> commandResult;

      setUp(() {
        logger.inlineTerminal = FakeTerminal()
          ..queueInput('com.acme.app'.codeUnits)
          ..queueInput(FakeTerminal.enter);
        commandResult = cli.run([
          'app',
          'setup',
          '--project',
          _projectId,
          '--app-dir',
          d.path('project_flutter'),
          '--platforms',
          'ios',
        ]);
      });

      test('then a bundle ID based on the project id is offered', () async {
        await commandResult;

        expect(
          (logger.inlineTerminal as FakeTerminal).output,
          contains('Use space.serverpod.my-project-id'),
        );
      });

      test('then the hint names the App Store', () async {
        await commandResult;

        expect(
          (logger.inlineTerminal as FakeTerminal).output,
          contains('It must be unique on the App Store'),
        );
      });

      test(
        'then the bundle IDs of the Xcode project are built on the new one',
        () async {
          await commandResult;

          await expectLater(
            d.dir('project_flutter', [
              d.dir('ios', [
                d.dir('Runner.xcodeproj', [
                  d.file(
                    'project.pbxproj',
                    allOf(
                      contains('PRODUCT_BUNDLE_IDENTIFIER = com.acme.app;'),
                      contains(
                        'PRODUCT_BUNDLE_IDENTIFIER = com.acme.app.RunnerTests;',
                      ),
                    ),
                  ),
                ]),
              ]),
            ]).validate(),
            completes,
          );
        },
      );

      test('then the new bundle ID is recorded', () async {
        await commandResult;

        verify(
          () => client.appPublishing.setIosBundleId(
            cloudCapsuleId: _projectId,
            bundleId: 'com.acme.app',
          ),
        ).called(1);
      });
    });

    group('when setting up the app with --non-interactive', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          '--non-interactive',
          'app',
          'setup',
          '--project',
          _projectId,
          '--app-dir',
          d.path('project_flutter'),
        ]);
      });

      test('then the command throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the package name check fails with a hint to pass '
          '--android-package-name', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.lineCalls.map((call) => call.line),
          containsAllInOrder([
            "  ✗ Package name: The Android package name com.example.my_app "
                "is Flutter's placeholder.",
            '    Pass the Android package name to publish the app with, such '
                'as --android-package-name space.serverpod.my_project_id.',
          ]),
        );
      });

      test('then the bundle ID check fails with a hint to pass '
          '--ios-bundle-id', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.lineCalls.map((call) => call.line),
          containsAllInOrder([
            "  ✗ Bundle ID: The iOS bundle ID com.example.myApp is Flutter's "
                'placeholder.',
            '    Pass the iOS bundle ID to publish the app with, such as '
                '--ios-bundle-id space.serverpod.my-project-id.',
          ]),
        );
      });

      test('then no package name is recorded', () async {
        await commandResult.catchError((_) {});

        verifyNever(
          () => client.appPublishing.setAndroidPackageName(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            packageName: any(named: 'packageName'),
          ),
        );
      });

      test('then the app project files keep the placeholder', () async {
        await commandResult.catchError((_) {});

        await expectLater(
          d.dir('project_flutter', [
            d.dir('android', [
              d.dir('app', [
                d.file(
                  'build.gradle.kts',
                  contains('applicationId = "com.example.my_app"'),
                ),
              ]),
            ]),
          ]).validate(),
          completes,
        );
      });
    });
  });

  group("Given a Flutter app with Flutter's placeholder app identifiers "
      'when setting up the app with --non-interactive and the identifiers '
      'as options', () {
    late Future<void> commandResult;

    setUp(() async {
      await ProjectFactory.nonWorkspaceFlutterAppDir(
        contents: [
          ProjectFactory.flutterAndroidDir(
            applicationId: 'com.example.my_app',
            releaseSigning: ProjectFactory.serverpodCloudReleaseSigning,
          ),
          ProjectFactory.flutterIosDir(bundleId: 'com.example.myApp'),
        ],
      ).create();
      commandResult = cli.run([
        '--non-interactive',
        'app',
        'setup',
        '--project',
        _projectId,
        '--app-dir',
        d.path('project_flutter'),
        '--android-package-name',
        'com.acme.app',
        '--ios-bundle-id',
        'com.acme.ios',
      ]);
    });

    test('then the command completes', () async {
      await expectLater(commandResult, completes);
    });

    test('then nothing is asked for', () async {
      await commandResult;

      expect(logger.inputCalls, isEmpty);
    });

    test('then applicationId is set to the requested package name', () async {
      await commandResult;

      await expectLater(
        d.dir('project_flutter', [
          d.dir('android', [
            d.dir('app', [
              d.file(
                'build.gradle.kts',
                contains('applicationId = "com.acme.app"'),
              ),
            ]),
          ]),
        ]).validate(),
        completes,
      );
    });

    test('then the Xcode project has the requested bundle ID', () async {
      await commandResult;

      await expectLater(
        d.dir('project_flutter', [
          d.dir('ios', [
            d.dir('Runner.xcodeproj', [
              d.file(
                'project.pbxproj',
                contains('PRODUCT_BUNDLE_IDENTIFIER = com.acme.ios;'),
              ),
            ]),
          ]),
        ]).validate(),
        completes,
      );
    });

    test('then the requested package name is recorded', () async {
      await commandResult;

      verify(
        () => client.appPublishing.setAndroidPackageName(
          cloudCapsuleId: _projectId,
          packageName: 'com.acme.app',
        ),
      ).called(1);
    });

    test('then the requested bundle ID is recorded', () async {
      await commandResult;

      verify(
        () => client.appPublishing.setIosBundleId(
          cloudCapsuleId: _projectId,
          bundleId: 'com.acme.ios',
        ),
      ).called(1);
    });
  });

  group(
    "Given a Flutter app with Flutter's placeholder Android package name",
    () {
      setUp(() async {
        await ProjectFactory.nonWorkspaceFlutterAppDir(
          contents: [
            ProjectFactory.flutterAndroidDir(
              applicationId: 'com.example.my_app',
              releaseSigning: ProjectFactory.serverpodCloudReleaseSigning,
            ),
          ],
        ).create();
      });

      group('when setting up the app with --format json '
          'and --android-package-name', () {
        late Future<void> commandResult;

        setUp(() {
          commandResult = cli.run([
            '--format',
            'json',
            'app',
            'setup',
            '--project',
            _projectId,
            '--app-dir',
            d.path('project_flutter'),
            '--android-package-name',
            'com.acme.app',
          ]);
        });

        test('then only the json document is written', () async {
          await commandResult;

          expect(logger.successCalls, isEmpty);
          expect(logger.lineCalls, isEmpty);
        });

        test(
          'then the package name check passes with the file it was set in',
          () async {
            await commandResult;

            final checks = (jsonDecode(logger.rawCalls.single.content) as List)
                .cast<Map>();
            expect(
              checks.firstWhere((check) => check['check'] == 'appIdentifier'),
              {
                'platform': 'android',
                'check': 'appIdentifier',
                'status': 'passed',
                'detail': 'com.acme.app (set in android/app/build.gradle.kts)',
              },
            );
          },
        );
      });

      group('when setting up the app with --format json', () {
        late Future<void> commandResult;

        setUp(() {
          commandResult = cli.run([
            '--format',
            'json',
            'app',
            'setup',
            '--project',
            _projectId,
            '--app-dir',
            d.path('project_flutter'),
          ]);
        });

        test('then nothing is asked for', () async {
          await commandResult.catchError((_) {});

          expect(logger.inputCalls, isEmpty);
        });

        test('then the package name check fails with a hint to pass '
            '--android-package-name', () async {
          await commandResult.catchError((_) {});

          final checks = (jsonDecode(logger.rawCalls.single.content) as List)
              .cast<Map>();
          final check = checks.firstWhere(
            (check) => check['check'] == 'appIdentifier',
          );
          expect(check['status'], 'failed');
          expect(check['hint'], contains('--android-package-name'));
        });
      });
    },
  );

  group(
    'Given a Flutter app with an Android package name that is not valid',
    () {
      setUp(() async {
        await ProjectFactory.nonWorkspaceFlutterAppDir(
          contents: [
            ProjectFactory.flutterAndroidDir(
              applicationId: 'com.acme.my-app',
              releaseSigning: ProjectFactory.serverpodCloudReleaseSigning,
            ),
          ],
        ).create();
      });

      test(
        'when setting up the app then the prompt says it is not valid',
        () async {
          logger.inlineTerminal = FakeTerminal()
            ..queueInput(FakeTerminal.enter);

          await cli.run([
            'app',
            'setup',
            '--project',
            _projectId,
            '--app-dir',
            d.path('project_flutter'),
          ]);

          expect(
            (logger.inlineTerminal as FakeTerminal).output,
            contains(
              'The Android package name com.acme.my-app is not valid.\n',
            ),
          );
        },
      );
    },
  );

  group('Given a Flutter app with its own Android package name', () {
    setUp(() async {
      await ProjectFactory.nonWorkspaceFlutterAppDir(
        contents: [
          ProjectFactory.flutterAndroidDir(
            applicationId: 'com.acme.app',
            releaseSigning: ProjectFactory.serverpodCloudReleaseSigning,
          ),
        ],
      ).create();
    });

    group('when setting up the app with another --android-package-name', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'setup',
          '--project',
          _projectId,
          '--app-dir',
          d.path('project_flutter'),
          '--android-package-name',
          'com.acme.other',
        ]);
      });

      test('then applicationId is set to the requested package name', () async {
        await commandResult;

        await expectLater(
          d.dir('project_flutter', [
            d.dir('android', [
              d.dir('app', [
                d.file(
                  'build.gradle.kts',
                  contains('applicationId = "com.acme.other"'),
                ),
              ]),
            ]),
          ]).validate(),
          completes,
        );
      });

      test('then the requested package name is recorded', () async {
        await commandResult;

        verify(
          () => client.appPublishing.setAndroidPackageName(
            cloudCapsuleId: _projectId,
            packageName: 'com.acme.other',
          ),
        ).called(1);
      });
    });

    group('when setting up the app with the --android-package-name it '
        'declares', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'setup',
          '--project',
          _projectId,
          '--app-dir',
          d.path('project_flutter'),
          '--android-package-name',
          'com.acme.app',
        ]);
      });

      test(
        'then the package name check passes without naming a file',
        () async {
          await commandResult;

          expect(
            logger.lineCalls.map((call) => call.line),
            contains('  ✓ Package name: com.acme.app'),
          );
        },
      );

      test('then the package name is recorded', () async {
        await commandResult;

        verify(
          () => client.appPublishing.setAndroidPackageName(
            cloudCapsuleId: _projectId,
            packageName: 'com.acme.app',
          ),
        ).called(1);
      });
    });

    test('when setting up the app with an invalid --ios-bundle-id '
        'then throws UsageException saying it is not valid', () async {
      await expectLater(
        cli.run([
          'app',
          'setup',
          '--project',
          _projectId,
          '--app-dir',
          d.path('project_flutter'),
          '--ios-bundle-id',
          'com.acme.my_app',
        ]),
        throwsA(
          isA<UsageException>().having(
            (error) => error.message,
            'message',
            contains('The iOS bundle ID "com.acme.my_app" is not valid.'),
          ),
        ),
      );
    });

    test('when setting up the app with an invalid --android-package-name '
        'then throws UsageException saying it is not valid', () async {
      await expectLater(
        cli.run([
          'app',
          'setup',
          '--project',
          _projectId,
          '--app-dir',
          d.path('project_flutter'),
          '--android-package-name',
          'com.acme.my-app',
        ]),
        throwsA(
          isA<UsageException>().having(
            (error) => error.message,
            'message',
            contains(
              'The Android package name "com.acme.my-app" is not valid.',
            ),
          ),
        ),
      );
    });
  });

  group('Given a scloud.yaml that sets the Android package name', () {
    setUp(() async {
      await d.dir('monorepo', [
        d.dir('project_flutter', [
          d.file('pubspec.yaml', ProjectFactory.serverpodFlutterAppPubspec()),
          ProjectFactory.flutterAndroidDir(
            releaseSigning: ProjectFactory.serverpodCloudReleaseSigning,
          ),
        ]),
        d.dir('project_server', [
          d.file('scloud.yaml', '''
project:
  projectId: "my-project-id"
  app:
    dir: "../project_flutter"
    identifiers:
      android: "com.acme.configured"
'''),
        ]),
      ]).create();
    });

    test('when setting up the app with another --android-package-name '
        'then the package name check fails with a hint to change '
        'scloud.yaml', () async {
      await cli
          .run([
            'app',
            'setup',
            '--project',
            _projectId,
            '--project-dir',
            p.join(d.sandbox, 'monorepo', 'project_server'),
            '--android-package-name',
            'com.acme.other',
          ])
          .catchError((_) {});

      expect(
        logger.lineCalls.map((call) => call.line),
        containsAllInOrder([
          '  ✗ Package name: --android-package-name is com.acme.other, but '
              'scloud.yaml sets project.app.identifiers.android to '
              'com.acme.configured.',
          '    Set project.app.identifiers.android in scloud.yaml to '
              'com.acme.other, or remove it to use the one the app declares.',
        ]),
      );
    });
  });

  group('Given a Flutter app whose Android release builds are signed with '
      'the debug key', () {
    setUp(() async {
      await ProjectFactory.nonWorkspaceFlutterAppDir(
        contents: [
          ProjectFactory.flutterAndroidDir(
            releaseSigning: ProjectFactory.debugKeyReleaseSigning,
          ),
        ],
      ).create();
    });

    group('when setting up the app', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'setup',
          '--project',
          _projectId,
          '--app-dir',
          d.path('project_flutter'),
        ]);
      });

      test(
        'then the release signing check fails with a link to the docs',
        () async {
          await commandResult.catchError((_) {});

          expect(
            logger.lineCalls.map((call) => call.line),
            containsAllInOrder([
              '  ✗ Release signing: Release builds are signed with the debug '
                  'key.',
              '    Learn more: $androidReleaseSigningDocsUrl',
            ]),
          );
        },
      );

      test('then the command throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the package name is still recorded', () async {
        await commandResult.catchError((_) {});

        verify(
          () => client.appPublishing.setAndroidPackageName(
            cloudCapsuleId: _projectId,
            packageName: 'com.acme.app',
          ),
        ).called(1);
      });
    });
  });

  group("Given a scloud.yaml that sets Flutter's placeholder as the Android "
      'package name', () {
    setUp(() async {
      await d.dir('monorepo', [
        d.dir('project_flutter', [
          d.file('pubspec.yaml', ProjectFactory.serverpodFlutterAppPubspec()),
          ProjectFactory.flutterAndroidDir(
            releaseSigning: ProjectFactory.serverpodCloudReleaseSigning,
          ),
        ]),
        d.dir('project_server', [
          d.file('scloud.yaml', '''
project:
  projectId: "my-project-id"
  app:
    dir: "../project_flutter"
    identifiers:
      android: "com.example.configured"
'''),
        ]),
      ]).create();
    });

    group('when setting up the app', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'setup',
          '--project',
          _projectId,
          '--project-dir',
          p.join(d.sandbox, 'monorepo', 'project_server'),
        ]);
      });

      test('then the package name check fails with a hint to change '
          'scloud.yaml', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.lineCalls.map((call) => call.line),
          containsAllInOrder([
            "  ✗ Package name: The Android package name com.example.configured "
                "is Flutter's placeholder.",
            '    Set project.app.identifiers.android in scloud.yaml to the '
                "app's own Android package name.",
          ]),
        );
      });

      test('then no package name is asked for', () async {
        await commandResult.catchError((_) {});

        expect(logger.inputCalls, isEmpty);
      });

      test('then no package name is recorded', () async {
        await commandResult.catchError((_) {});

        verifyNever(
          () => client.appPublishing.setAndroidPackageName(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            packageName: any(named: 'packageName'),
          ),
        );
      });
    });
  });

  group('Given a Flutter app set up for publishing '
      'and app publishing is off on Serverpod Cloud', () {
    setUp(() async {
      when(
        () => client.appPublishing.setAndroidPackageName(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
          packageName: any(named: 'packageName'),
        ),
      ).thenThrow(
        AppPublishingDisabledException(message: 'App publishing is off.'),
      );
      await ProjectFactory.nonWorkspaceFlutterAppDir(
        contents: [
          ProjectFactory.flutterAndroidDir(
            releaseSigning: ProjectFactory.serverpodCloudReleaseSigning,
          ),
        ],
      ).create();
    });

    group('when setting up the app', () {
      late Future<void> commandResult;

      setUp(() {
        commandResult = cli.run([
          'app',
          'setup',
          '--project',
          _projectId,
          '--app-dir',
          d.path('project_flutter'),
        ]);
      });

      test('then the command throws ErrorExitException', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then the error is logged', () async {
        await commandResult.catchError((_) {});

        expect(
          logger.errorCalls,
          contains(equalsErrorCall(message: 'App publishing is off.')),
        );
      });
    });
  });
}
