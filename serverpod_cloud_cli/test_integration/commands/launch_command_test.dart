@Tags(['concurrency_one']) // due to current directory manipulation
library;

import 'dart:async';
import 'dart:convert';

import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/constants.dart' show VersionConstants;
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:test/test.dart';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/launch_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';

import '../../test_utils/command_logger_matchers.dart';
import '../../test_utils/project_factory.dart';
import '../../test_utils/push_current_dir.dart';
import '../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );
  final mockFileUploader = MockFileUploader();
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (final globalCfg) => client,
      fileUploaderFactory: (final _) => mockFileUploader,
    ),
  );

  const projectId = 'my-project-id';
  const projectUuid = '586a138e-66f3-4dcb-b2e6-bb2d38ab4a4a';
  const bucketName = 'bucket';

  final Map<String, dynamic> descriptionContent = {
    'url':
        "http://$bucketName.localhost:8000/$projectId%2F$projectUuid.zip?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential=test-service-bucket%40hosting-example-414217.iam.gserviceaccount.com%2F20240909%2Fauto%2Fstorage%2Fgoog4_request&X-Goog-Date=20240909T094501Z&X-Goog-Expires=600&X-Goog-SignedHeaders=accept%3Bcontent-type%3Bhost%3Bx-goog-meta-tenant-project-id&x-goog-signature=2a3432d7e650cd7f32e4b6ddb01051390ae40084fb45f7af25cfaa891f33425d7bf64939b78b9e339b28bcf5238dfb58c67fd8e1eb8957c2df22b1b91d1f01a3ecd1ad4217a570a7e7a80e2999164ca7d920058bfdf52851341fe3c85340da14917026c8efae8f733d5d6548a149ae0558f88307bfcf23f97c2a141317d2be5cf4035488bd7b01137333250be11a174e73096674d8eaffcc7c7d2849044a3eb7669c35f7e421f99ab9557610478c96b68b29962fa1ea002cf76a09a0f302c66157844bd1a2b4b8a36378fd18f8a8dab750d955ff1866c9b20105c56b1f3ebf88c4dcf75043518c74d3d25c54673557b397ba1e31336766004c06ddf7bbbe1940\\",
    'type': 'binary',
    'httpMethod': 'PUT',
    'headers': {
      'content-type': 'application/octet-stream',
      'accept': '*/*',
      'x-goog-meta-tenant-project-id': projectId,
      'x-goog-meta-upload-id': 'upload-$projectUuid',
      'host': '$bucketName.localhost:8000',
    },
  };

  setUp(() {
    mockFileUploader.init();
    logger.clear();
  });

  test(
    'Given project launch command when instantiated then requires login',
    () {
      expect(CloudLaunchCommand(logger: logger).requireLogin, isTrue);
    },
  );

  group('Given authenticated', () {
    setUpAll(() async {
      client.authKeyProvider = InMemoryKeyManager.authenticated();

      when(
        () => client.projects.createProject(
          cloudProjectId: any(named: 'cloudProjectId'),
        ),
      ).thenAnswer(
        (final invocation) async => Future.value(
          ProjectBuilder()
              .withCloudProjectId(invocation.namedArguments[#cloudProjectId])
              .build(),
        ),
      );

      when(
        () => client.projects.listProjectsInfo(
          includeLatestDeployAttemptTime: any(
            named: 'includeLatestDeployAttemptTime',
          ),
        ),
      ).thenAnswer((final _) async => Future.value([]));

      when(
        () => client.projects.fetchProjectConfig(
          cloudProjectId: any(named: 'cloudProjectId'),
        ),
      ).thenAnswer(
        (final invocation) async => Future.value(
          ProjectConfig(projectId: invocation.namedArguments[#cloudProjectId]),
        ),
      );

      when(
        () => client.infraResources.enableDatabase(
          cloudCapsuleId: any(named: 'cloudCapsuleId'),
        ),
      ).thenAnswer((final _) async => {});

      when(
        () => client.deploy.createUploadDescription(any()),
      ).thenAnswer((final _) async => jsonEncode(descriptionContent));

      final attemptStages = [
        DeployAttemptStage(
          cloudCapsuleId: projectId,
          attemptId: 'abc',
          stageType: DeployStageType.upload,
          stageStatus: DeployProgressStatus.success,
        ),
      ];

      when(
        () => client.status.getDeployAttemptId(
          cloudCapsuleId: projectId,
          attemptNumber: 0,
        ),
      ).thenAnswer((final _) async => attemptStages.first.attemptId);

      when(
        () => client.status.getDeployAttemptStatus(
          cloudCapsuleId: projectId,
          attemptId: attemptStages.first.attemptId,
        ),
      ).thenAnswer((final _) async => attemptStages);

      when(
        () => client.plans.listProcuredPlanNames(),
      ).thenAnswer((final invocation) async => Future.value([]));

      when(
        () => client.plans.procurePlan(
          planProductName: any(named: 'planProductName'),
        ),
      ).thenAnswer((final invocation) async => Future.value());

      when(
        () => client.plans.checkPlanAvailability(
          planProductName: any(named: 'planProductName'),
        ),
      ).thenAnswer((final invocation) async => Future.value());
    });

    group('and serverpod directory', () {
      late String testProjectDir;

      setUp(() async {
        await ProjectFactory.serverpodServerDir(
          withDirectoryName: 'server_dir',
        ).create();
        testProjectDir = p.join(d.sandbox, 'server_dir');
      });

      group('when executing launch with all settings provided via args '
          'and approving confirmation', () {
        late Future commandResult;
        setUp(() async {
          logger.answerNextConfirmsWith([true, true]);

          commandResult = cli.run([
            'launch',
            '--new-project',
            projectId,
            '--project-dir',
            testProjectDir,
            '--enable-db',
            '--deploy',
          ]);

          await expectLater(commandResult, completes);
        });

        test('then logs no input prompts', () async {
          await commandResult.catchError((final _) {});

          expect(logger.inputCalls, isEmpty);
        });

        test('then logs setup message box', () async {
          expect(logger.boxCalls, hasLength(1));
          expect(
            logger.boxCalls.single.message,
            stringContainsInOrder([
              'Project setup',
              'Project directory  $testProjectDir',
              'New project id     $projectId',
              'Enable DB          yes',
              'Perform deploy     yes',
            ]),
          );
        });

        test('then logs confirmation-to-apply message', () async {
          expect(
            logger.confirmCalls,
            contains(
              equalsConfirmCall(
                message: 'Continue and apply this setup?',
                defaultValue: true,
              ),
            ),
          );
        });

        test('then logs success messages', () async {
          expect(logger.successCalls, isNotEmpty);
          expect(
            logger.successCalls,
            containsAllInOrder([
              equalsSuccessCall(
                message: "Serverpod Cloud project created.",
                newParagraph: true,
              ),
            ]),
          );
        });

        test('then logs access info message', () async {
          expect(logger.infoCalls, isNotEmpty);
          expect(
            logger.infoCalls,
            containsAllInOrder([
              equalsInfoCall(
                message:
                    'When the server has started, you can access it at:\n'
                    '   Web:      https://$projectId.serverpod.space/\n'
                    '   API:      https://$projectId.api.serverpod.space/\n'
                    '   Insights: https://$projectId.insights.serverpod.space/',
                newParagraph: true,
              ),
            ]),
          );
        });

        test('then logs deploy status message', () async {
          expect(logger.lineCalls, isNotEmpty);
          expect(
            logger.lineCalls.map((final call) => call.line),
            containsAllInOrder([
              startsWith('Status of $projectId deploy abc'),
              contains('✅  Booster liftoff:     Upload successful!'),
            ]),
          );
        });

        test('then logs deployments show hint message', () async {
          expect(logger.terminalCommandCalls, hasLength(1));
          expect(
            logger.terminalCommandCalls,
            containsAllInOrder([
              equalsTerminalCommandCall(
                command: 'scloud deployment show',
                message: 'View the deployment status:',
                newParagraph: true,
              ),
            ]),
          );
        });

        test('then writes scloud.yaml file', () async {
          final expected = d.dir(testProjectDir, [
            d.file(
              'scloud.yaml',
              contains('''
project:
  projectId: "$projectId"
'''),
            ),
          ]);
          await expectLater(expected.validate(), completes);
        });

        test('then .scloudignore is created in the project dir', () async {
          final expected = d.dir(testProjectDir, [
            d.file(
              '.scloudignore',
              contains(
                'This file specifies which files and directories should be ignored',
              ),
            ),
          ]);
          await expectLater(expected.validate(), completes);
        });

        test('then zipped project is accessible in bucket.', () async {
          await expectLater(mockFileUploader.uploadedData, isNotEmpty);
        });
      });

      group('when executing launch with flutter_build script in pubspec.yaml '
          'and approving confirmation', () {
        late String testProjectDir;
        late Future commandResult;

        setUp(() async {
          await d.dir('server_dir', [
            d.file('pubspec.yaml', '''
name: my_project_server
environment:
  sdk: ${ProjectFactory.validSdkVersion}
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
serverpod:
  scripts:
    flutter_build: dart run tool/build_web.dart
'''),
          ]).create();
          testProjectDir = p.join(d.sandbox, 'server_dir');

          logger.answerNextConfirmsWith([true, true, true]);

          commandResult = cli.run([
            'launch',
            '--new-project',
            projectId,
            '--project-dir',
            testProjectDir,
            '--enable-db',
            '--deploy',
          ]);

          await expectLater(commandResult, completes);
        });

        test('then prompts to add flutter_build as pre-deploy hook', () async {
          await commandResult.catchError((final _) {});

          expect(
            logger.confirmCalls,
            containsAllInOrder([
              equalsConfirmCall(
                message:
                    'Would you like to run code generation (`serverpod generate`) before deploy?',
                defaultValue: true,
              ),
              equalsConfirmCall(
                message:
                    "Detected 'flutter_build' script. Add it as a pre-deploy hook?",
                defaultValue: true,
              ),
              equalsConfirmCall(
                message: 'Continue and apply this setup?',
                defaultValue: true,
              ),
            ]),
          );
        });

        test('then writes scloud.yaml with pre-deploy hook', () async {
          final expected = d.dir(testProjectDir, [
            d.file(
              'scloud.yaml',
              allOf([
                contains('projectId: "$projectId"'),
                contains('pre_deploy:'),
                contains('serverpod generate'),
                contains('serverpod run flutter_build'),
              ]),
            ),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });

      group('when executing launch with flutter_build script in pubspec.yaml '
          'and declining pre-deploy hook suggestion', () {
        late String testProjectDir;
        late Future commandResult;

        setUp(() async {
          await d.dir('server_dir', [
            d.file('pubspec.yaml', '''
name: my_project_server
environment:
  sdk: ${ProjectFactory.validSdkVersion}
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
serverpod:
  scripts:
    flutter_build: dart run tool/build_web.dart
'''),
          ]).create();
          testProjectDir = p.join(d.sandbox, 'server_dir');

          logger.answerNextConfirmsWith([true, false, true]);

          commandResult = cli.run([
            'launch',
            '--new-project',
            projectId,
            '--project-dir',
            testProjectDir,
            '--enable-db',
            '--deploy',
          ]);

          await expectLater(commandResult, completes);
        });

        test('then prompts to add flutter_build as pre-deploy hook', () async {
          await commandResult.catchError((final _) {});

          expect(
            logger.confirmCalls,
            containsAllInOrder([
              equalsConfirmCall(
                message:
                    'Would you like to run code generation (`serverpod generate`) before deploy?',
                defaultValue: true,
              ),
              equalsConfirmCall(
                message:
                    "Detected 'flutter_build' script. Add it as a pre-deploy hook?",
                defaultValue: true,
              ),
            ]),
          );
        });

        test('then does not write pre-deploy hook in scloud.yaml', () async {
          final expected = d.dir(testProjectDir, [
            d.file(
              'scloud.yaml',
              allOf([
                contains('projectId: "$projectId"'),
                contains('serverpod generate'),
                isNot(contains('serverpod run flutter_build')),
              ]),
            ),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });

      group('when executing launch without flutter_build script in pubspec.yaml '
          'and approving confirmation', () {
        late String testProjectDir;
        late Future commandResult;

        setUp(() async {
          await ProjectFactory.serverpodServerDir(
            withDirectoryName: 'server_dir',
          ).create();
          testProjectDir = p.join(d.sandbox, 'server_dir');

          logger.answerNextConfirmsWith([true, true]);

          commandResult = cli.run([
            'launch',
            '--new-project',
            projectId,
            '--project-dir',
            testProjectDir,
            '--enable-db',
            '--deploy',
          ]);

          await expectLater(commandResult, completes);
        });

        test(
          'then does not prompt to add flutter_build as pre-deploy hook',
          () async {
            await commandResult.catchError((final _) {});

            expect(
              logger.confirmCalls,
              isNot(
                contains(
                  equalsConfirmCall(
                    message:
                        "Detected 'flutter_build' script. Add it as a pre-deploy hook?",
                    defaultValue: true,
                  ),
                ),
              ),
            );
          },
        );

        test('then prompts to add code generation as pre-deploy hook', () async {
          await commandResult.catchError((final _) {});

          expect(
            logger.confirmCalls,
            containsAllInOrder([
              equalsConfirmCall(
                message:
                    'Would you like to run code generation (`serverpod generate`) before deploy?',
                defaultValue: true,
              ),
              equalsConfirmCall(
                message: 'Continue and apply this setup?',
                defaultValue: true,
              ),
            ]),
          );
        });
      });

      group('when executing launch with code generation hook suggestion '
          'and approving confirmation', () {
        late String testProjectDir;
        late Future commandResult;

        setUp(() async {
          await ProjectFactory.serverpodServerDir(
            withDirectoryName: 'server_dir',
          ).create();
          testProjectDir = p.join(d.sandbox, 'server_dir');

          logger.answerNextConfirmsWith([true, true]);

          commandResult = cli.run([
            'launch',
            '--new-project',
            projectId,
            '--project-dir',
            testProjectDir,
            '--enable-db',
            '--deploy',
          ]);

          await expectLater(commandResult, completes);
        });

        test('then prompts to add code generation as pre-deploy hook', () async {
          await commandResult.catchError((final _) {});

          expect(
            logger.confirmCalls,
            containsAllInOrder([
              equalsConfirmCall(
                message:
                    'Would you like to run code generation (`serverpod generate`) before deploy?',
                defaultValue: true,
              ),
              equalsConfirmCall(
                message: 'Continue and apply this setup?',
                defaultValue: true,
              ),
            ]),
          );
        });

        test('then writes scloud.yaml with pre-deploy hook', () async {
          final expected = d.dir(testProjectDir, [
            d.file(
              'scloud.yaml',
              allOf([contains('pre_deploy:'), contains('serverpod generate')]),
            ),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });

      group('when executing launch with code generation hook suggestion '
          'and declining pre-deploy hook suggestion', () {
        late String testProjectDir;
        late Future commandResult;

        setUp(() async {
          await ProjectFactory.serverpodServerDir(
            withDirectoryName: 'server_dir',
          ).create();
          testProjectDir = p.join(d.sandbox, 'server_dir');

          logger.answerNextConfirmsWith([false, true]);

          commandResult = cli.run([
            'launch',
            '--new-project',
            projectId,
            '--project-dir',
            testProjectDir,
            '--enable-db',
            '--deploy',
          ]);

          await expectLater(commandResult, completes);
        });

        test('then prompts to add code generation as pre-deploy hook', () async {
          await commandResult.catchError((final _) {});

          expect(
            logger.confirmCalls.first,
            equalsConfirmCall(
              message:
                  'Would you like to run code generation (`serverpod generate`) before deploy?',
              defaultValue: true,
            ),
          );
        });

        test('then does not write pre-deploy hook in scloud.yaml', () async {
          final expected = d.dir(testProjectDir, [
            d.file('scloud.yaml', isNot(contains('serverpod generate'))),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });

      group('when executing launch with code generation hook already in config '
          'and approving confirmation', () {
        late String testProjectDir;
        late Future commandResult;

        setUp(() async {
          await ProjectFactory.serverpodServerDir(
            withDirectoryName: 'server_dir',
          ).create();
          testProjectDir = p.join(d.sandbox, 'server_dir');

          await d.file(p.join(testProjectDir, 'scloud.yaml'), '''
project:
  projectId: "$projectId"
  scripts:
    pre_deploy:
      - serverpod generate
''').create();

          logger.answerNextConfirmsWith([true]);

          commandResult = cli.run([
            'launch',
            '--new-project',
            projectId,
            '--project-dir',
            testProjectDir,
            '--enable-db',
            '--deploy',
          ]);

          await expectLater(commandResult, completes);
        });

        test(
          'then does not prompt to add code generation as pre-deploy hook',
          () async {
            await commandResult.catchError((final _) {});

            expect(
              logger.confirmCalls,
              isNot(
                contains(
                  equalsConfirmCall(
                    message:
                        'Would you like to run code generation (`serverpod generate`) before deploy?',
                    defaultValue: true,
                  ),
                ),
              ),
            );
          },
        );
      });

      group('when executing launch with all settings provided via args '
          'and declining confirmation', () {
        late Future commandResult;
        setUp(() async {
          logger.answerNextConfirmsWith([true, false]);

          commandResult = cli.run([
            'launch',
            '--new-project',
            projectId,
            '--project-dir',
            testProjectDir,
            '--enable-db',
            '--deploy',
          ]);
        });

        test('then throws ErrorExitException', () async {
          expect(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then logs no input prompts', () async {
          await commandResult.catchError((final _) {});

          expect(logger.inputCalls, isEmpty);
        });

        test('then logs setup message box', () async {
          await commandResult.catchError((final _) {});

          expect(logger.boxCalls, hasLength(1));
          expect(
            logger.boxCalls.single.message,
            stringContainsInOrder([
              'Project setup',
              'Project directory  $testProjectDir',
              'New project id     $projectId',
              'Enable DB          yes',
              'Perform deploy     yes',
            ]),
          );
        });

        test('then logs confirmation-to-apply message', () async {
          await commandResult.catchError((final _) {});

          expect(
            logger.confirmCalls,
            contains(
              equalsConfirmCall(
                message: 'Continue and apply this setup?',
                defaultValue: true,
              ),
            ),
          );
        });

        test('then logs no success messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.successCalls, isEmpty);
        });

        test('then logs cancellation info message', () async {
          await commandResult.catchError((final _) {});

          expect(logger.infoCalls, hasLength(1));
          expect(
            logger.infoCalls.single,
            equalsInfoCall(message: 'Setup cancelled.'),
          );
        });

        test('then does not write scloud.yaml file', () async {
          await commandResult.catchError((final _) {});

          final expected = d.dir(testProjectDir, [d.nothing('scloud.yaml')]);
          await expectLater(expected.validate(), completes);
        });
      });

      group('when executing launch with all settings provided via args '
          'and project dir is not a serverpod server directory '
          'and declining confirmation', () {
        late Future commandResult;
        setUp(() async {
          logger.answerNextInputsWith([testProjectDir]);
          logger.answerNextConfirmsWith([true, false]);

          commandResult = cli.run([
            'launch',
            '--new-project',
            projectId,
            '--project-dir',
            d.sandbox,
            '--enable-db',
            '--deploy',
          ]);
        });

        test('then throws ErrorExitException', () async {
          expect(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then logs error message for invalid project directory', () async {
          await commandResult.catchError((final _) {});

          expect(logger.errorCalls, hasLength(1));
          expect(
            logger.errorCalls.single,
            equalsErrorCall(
              message:
                  'Could not find `pubspec.yaml` in directory `${d.sandbox}`.',
              hint: "Provide the project's server directory and try again.",
            ),
          );
        });

        test(
          'then logs input message to enter valid project directory',
          () async {
            await commandResult.catchError((final _) {});

            expect(logger.inputCalls, isNotEmpty);
            expect(
              logger.inputCalls,
              containsAllInOrder([
                equalsInputCall(message: 'Enter the project directory'),
              ]),
            );
          },
        );

        test('then logs setup message box', () async {
          await commandResult.catchError((final _) {});

          expect(logger.boxCalls, hasLength(1));
          expect(
            logger.boxCalls.single.message,
            stringContainsInOrder([
              'Project setup',
              'Project directory  $testProjectDir',
              'New project id     $projectId',
              'Enable DB          yes',
              'Perform deploy     yes',
            ]),
          );
        });

        test('then logs confirmation-to-apply message', () async {
          await commandResult.catchError((final _) {});

          expect(
            logger.confirmCalls,
            contains(
              equalsConfirmCall(
                message: 'Continue and apply this setup?',
                defaultValue: true,
              ),
            ),
          );
        });

        test('then logs no success messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.successCalls, isEmpty);
        });

        test('then logs cancellation info message', () async {
          await commandResult.catchError((final _) {});

          expect(logger.infoCalls, hasLength(1));
          expect(
            logger.infoCalls.single,
            equalsInfoCall(message: 'Setup cancelled.'),
          );
        });

        test('then does not write scloud.yaml file', () async {
          await commandResult.catchError((final _) {});

          final expected = d.dir(testProjectDir, [d.nothing('scloud.yaml')]);
          await expectLater(expected.validate(), completes);
        });
      });

      group('when executing launch with all settings provided via args '
          'and project id is not valid '
          'and declining confirmation', () {
        late Future commandResult;
        setUp(() async {
          logger.answerNextInputsWith([projectId]);
          logger.answerNextConfirmsWith([
            true, // confirm new project cost acceptance
            true, // code generation prompt
            false, // do not apply setup
          ]);

          commandResult = cli.run([
            'launch',
            '--new-project',
            'invalid-project-id_%^&',
            '--project-dir',
            testProjectDir,
            '--enable-db',
            '--deploy',
          ]);
        });

        test('then throws ErrorExitException', () async {
          expect(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then logs error message for invalid project id', () async {
          await commandResult.catchError((final _) {});

          expect(logger.errorCalls, hasLength(1));
          expect(
            logger.errorCalls.single,
            equalsErrorCall(
              message:
                  'Invalid project ID. '
                  'Must be 6-32 characters long and contain only lowercase letters, numbers, and hyphens.',
            ),
          );
        });

        test('then logs input message to enter valid project id', () async {
          await commandResult.catchError((final _) {});

          expect(logger.inputCalls, isNotEmpty);
          expect(
            logger.inputCalls,
            containsAllInOrder([
              equalsInputCall(
                message: 'Enter a new project id',
                defaultValue: 'default: my-project',
              ),
            ]),
          );
        });

        test('then logs setup message box', () async {
          await commandResult.catchError((final _) {});

          expect(logger.boxCalls, hasLength(1));
          expect(
            logger.boxCalls.single.message,
            stringContainsInOrder([
              'Project setup',
              'Project directory  $testProjectDir',
              'New project id     $projectId',
              'Enable DB          yes',
              'Perform deploy     yes',
            ]),
          );
        });

        test('then logs confirmation-to-apply message', () async {
          await commandResult.catchError((final _) {});

          expect(
            logger.confirmCalls,
            containsAllInOrder([
              equalsConfirmCall(
                message:
                    'Depending on your subscription, a new project may incur additional costs. Continue?',
                defaultValue: true,
              ),
              equalsConfirmCall(
                message: 'Continue and apply this setup?',
                defaultValue: true,
              ),
            ]),
          );
        });

        test('then logs no success messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.successCalls, isEmpty);
        });

        test('then logs cancellation info message', () async {
          await commandResult.catchError((final _) {});

          expect(logger.infoCalls, hasLength(1));
          expect(
            logger.infoCalls.single,
            equalsInfoCall(message: 'Setup cancelled.'),
          );
        });

        test('then does not write scloud.yaml file', () async {
          await commandResult.catchError((final _) {});

          final expected = d.dir(testProjectDir, [d.nothing('scloud.yaml')]);
          await expectLater(expected.validate(), completes);
        });
      });

      group('when executing launch with all settings provided interactively '
          'and declining project cost question', () {
        late Future commandResult;
        setUp(() async {
          logger.answerNextInputsWith([testProjectDir, projectId]);
          logger.answerNextConfirmsWith([
            false, // decline new project cost acceptance
          ]);

          commandResult = cli.run(['launch']);
        });

        test('then throws ErrorExitException', () async {
          expect(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then logs confirmation question', () async {
          await commandResult.catchError((final _) {});

          expect(
            logger.confirmCalls,
            contains(
              equalsConfirmCall(
                message:
                    'Depending on your subscription, a new project may incur additional costs. Continue?',
                defaultValue: true,
              ),
            ),
          );
        });
      });

      group('when executing launch with all settings provided interactively '
          'and declining confirmation', () {
        late Future commandResult;
        setUp(() async {
          logger.answerNextInputsWith([testProjectDir, projectId]);
          logger.answerNextConfirmsWith([
            true, // confirm new project cost acceptance
            true, // enable db
            true, // perform deploy
            true, // code generation prompt
            false, // do not apply setup
          ]);

          commandResult = cli.run(['launch']);
        });

        test('then throws ErrorExitException', () async {
          expect(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then logs input messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.inputCalls, isNotEmpty);
          expect(
            logger.inputCalls,
            containsAllInOrder([
              equalsInputCall(message: 'Enter the project directory'),
              equalsInputCall(
                message: 'Enter a new project id',
                defaultValue: 'default: my-project',
              ),
            ]),
          );
        });

        test('then logs confirmation messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.confirmCalls, isNotEmpty);
          expect(
            logger.confirmCalls,
            containsAllInOrder([
              equalsConfirmCall(
                message: 'Enable the database for the project?',
                defaultValue: true,
              ),
              equalsConfirmCall(
                message: "Deploy '$projectId' project right away?",
                defaultValue: true,
              ),
              equalsConfirmCall(
                message:
                    'Would you like to run code generation (`serverpod generate`) before deploy?',
                defaultValue: true,
              ),
              equalsConfirmCall(
                message: 'Continue and apply this setup?',
                defaultValue: true,
              ),
            ]),
          );
        });

        test('then logs setup message box', () async {
          await commandResult.catchError((final _) {});

          expect(logger.boxCalls, hasLength(1));
          expect(
            logger.boxCalls.single.message,
            stringContainsInOrder([
              'Project setup',
              'Project directory  $testProjectDir',
              'New project id     $projectId',
              'Enable DB          yes',
              'Perform deploy     yes',
            ]),
          );
        });

        test('then logs no success messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.successCalls, isEmpty);
        });

        test('then logs cancellation info message', () async {
          await commandResult.catchError((final _) {});

          expect(logger.infoCalls, hasLength(1));
          expect(
            logger.infoCalls.single,
            equalsInfoCall(message: 'Setup cancelled.'),
          );
        });

        test('then does not write scloud.yaml file', () async {
          await commandResult.catchError((final _) {});

          final expected = d.dir(testProjectDir, [d.nothing('scloud.yaml')]);
          await expectLater(expected.validate(), completes);
        });
      });

      group('when executing launch with all settings provided interactively '
          'and a project dir is found '
          'and declining confirmation', () {
        late Future commandResult;
        setUp(() async {
          pushCurrentDirectory(d.sandbox);

          logger.answerNextInputsWith([testProjectDir, projectId]);
          logger.answerNextConfirmsWith([
            true, // confirm new project cost acceptance
            true, // enable db
            true, // perform deploy
            true, // code generation prompt
            false, // do not apply setup
          ]);

          commandResult = cli.run(['launch']);
        });

        test('then throws ErrorExitException', () async {
          expect(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test(
          'then logs info message that found project dir is selected',
          () async {
            await commandResult.catchError((final _) {});

            expect(logger.infoCalls, isNotEmpty);
            expect(
              logger.infoCalls,
              containsAllInOrder([
                equalsInfoCall(
                  message:
                      'Found project directory: ${p.relative(testProjectDir)}',
                ),
              ]),
            );
          },
        );

        test('then logs input message for project id', () async {
          await commandResult.catchError((final _) {});

          expect(logger.inputCalls, isNotEmpty);
          expect(
            logger.inputCalls.first,
            equalsInputCall(
              message: 'Enter a new project id',
              defaultValue: 'default: my-project',
            ),
          );
        });

        test('then logs confirmation messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.confirmCalls, isNotEmpty);
          expect(
            logger.confirmCalls,
            containsAllInOrder([
              equalsConfirmCall(
                message: 'Enable the database for the project?',
                defaultValue: true,
              ),
              equalsConfirmCall(
                message: "Deploy '$projectId' project right away?",
                defaultValue: true,
              ),
              equalsConfirmCall(
                message:
                    'Would you like to run code generation (`serverpod generate`) before deploy?',
                defaultValue: true,
              ),
              equalsConfirmCall(
                message: 'Continue and apply this setup?',
                defaultValue: true,
              ),
            ]),
          );
        });

        test('then logs setup message box', () async {
          await commandResult.catchError((final _) {});

          expect(logger.boxCalls, hasLength(1));
          expect(
            logger.boxCalls.single.message,
            stringContainsInOrder([
              'Project setup',
              'Project directory  ${p.relative(testProjectDir)}',
              'New project id     $projectId',
              'Enable DB          yes',
              'Perform deploy     yes',
            ]),
          );
        });

        test('then logs no success messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.successCalls, isEmpty);
        });

        test('then logs cancellation info message', () async {
          await commandResult.catchError((final _) {});

          expect(logger.infoCalls, isNotEmpty);
          expect(
            logger.infoCalls.last,
            equalsInfoCall(message: 'Setup cancelled.'),
          );
        });

        test('then does not write scloud.yaml file', () async {
          await commandResult.catchError((final _) {});

          final expected = d.dir(testProjectDir, [d.nothing('scloud.yaml')]);
          await expectLater(expected.validate(), completes);
        });
      });

      group('when executing launch with all settings provided interactively '
          'and invalid first project dir input '
          'and declining confirmation', () {
        late Future commandResult;
        setUp(() async {
          logger.answerNextInputsWith([
            'invalid_project_dir',
            testProjectDir,
            projectId,
          ]);
          logger.answerNextConfirmsWith([
            true, // confirm new project cost acceptance
            true, // enable db
            true, // perform deploy
            true, // code generation prompt
            false, // do not apply setup
          ]);

          commandResult = cli.run(['launch']);
        });

        test('then throws ErrorExitException', () async {
          expect(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then logs input messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.inputCalls, isNotEmpty);
          expect(
            logger.inputCalls,
            containsAllInOrder([
              equalsInputCall(message: 'Enter the project directory'),
              equalsInputCall(message: 'Enter the project directory'),
              equalsInputCall(
                message: 'Enter a new project id',
                defaultValue: 'default: my-project',
              ),
            ]),
          );
        });

        test('then logs confirmation messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.confirmCalls, isNotEmpty);
          expect(
            logger.confirmCalls,
            containsAllInOrder([
              equalsConfirmCall(
                message: 'Enable the database for the project?',
                defaultValue: true,
              ),
              equalsConfirmCall(
                message: "Deploy '$projectId' project right away?",
                defaultValue: true,
              ),
              equalsConfirmCall(
                message:
                    'Would you like to run code generation (`serverpod generate`) before deploy?',
                defaultValue: true,
              ),
              equalsConfirmCall(
                message: 'Continue and apply this setup?',
                defaultValue: true,
              ),
            ]),
          );
        });

        test('then logs setup message box', () async {
          await commandResult.catchError((final _) {});

          expect(logger.boxCalls, hasLength(1));
          expect(
            logger.boxCalls.single.message,
            stringContainsInOrder([
              'Project setup',
              'Project directory  $testProjectDir',
              'New project id     $projectId',
              'Enable DB          yes',
              'Perform deploy     yes',
            ]),
          );
        });

        test('then logs no success messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.successCalls, isEmpty);
        });

        test('then logs cancellation info message', () async {
          await commandResult.catchError((final _) {});

          expect(logger.infoCalls, hasLength(1));
          expect(
            logger.infoCalls.single,
            equalsInfoCall(message: 'Setup cancelled.'),
          );
        });

        test('then does not write scloud.yaml file', () async {
          await commandResult.catchError((final _) {});

          final expected = d.dir(testProjectDir, [d.nothing('scloud.yaml')]);
          await expectLater(expected.validate(), completes);
        });
      });

      group('when executing launch with all settings provided interactively '
          'and invalid first project id input '
          'and declining confirmation', () {
        late Future commandResult;
        setUp(() async {
          logger.answerNextInputsWith([
            testProjectDir,
            'invalid_project_id_#%@',
            projectId,
          ]);
          logger.answerNextConfirmsWith([
            true, // confirm new project cost acceptance
            true, // enable db
            true, // perform deploy
            true, // code generation prompt
            false, // do not apply setup
          ]);

          commandResult = cli.run(['launch']);
        });

        test('then throws ErrorExitException', () async {
          expect(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then logs input messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.inputCalls, isNotEmpty);
          expect(
            logger.inputCalls,
            containsAllInOrder([
              equalsInputCall(message: 'Enter the project directory'),
              equalsInputCall(
                message: 'Enter a new project id',
                defaultValue: 'default: my-project',
              ),
              equalsInputCall(
                message: 'Enter a new project id',
                defaultValue: 'default: my-project',
              ),
            ]),
          );
        });

        test('then logs confirmation messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.confirmCalls, isNotEmpty);
          expect(
            logger.confirmCalls,
            containsAllInOrder([
              equalsConfirmCall(
                message: 'Enable the database for the project?',
                defaultValue: true,
              ),
              equalsConfirmCall(
                message: "Deploy '$projectId' project right away?",
                defaultValue: true,
              ),
              equalsConfirmCall(
                message:
                    'Would you like to run code generation (`serverpod generate`) before deploy?',
                defaultValue: true,
              ),
              equalsConfirmCall(
                message: 'Continue and apply this setup?',
                defaultValue: true,
              ),
            ]),
          );
        });

        test('then logs setup message box', () async {
          await commandResult.catchError((final _) {});

          expect(logger.boxCalls, hasLength(1));
          expect(
            logger.boxCalls.single.message,
            stringContainsInOrder([
              'Project setup',
              'Project directory  $testProjectDir',
              'New project id     $projectId',
              'Enable DB          yes',
              'Perform deploy     yes',
            ]),
          );
        });

        test('then logs no success messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.successCalls, isEmpty);
        });

        test('then logs cancellation info message', () async {
          await commandResult.catchError((final _) {});

          expect(logger.infoCalls, hasLength(1));
          expect(
            logger.infoCalls.single,
            equalsInfoCall(message: 'Setup cancelled.'),
          );
        });

        test('then does not write scloud.yaml file', () async {
          await commandResult.catchError((final _) {});

          final expected = d.dir(testProjectDir, [d.nothing('scloud.yaml')]);
          await expectLater(expected.validate(), completes);
        });
      });

      group('when executing launch with all settings provided interactively '
          'and 2 pre-existing projects are found but not selected '
          'and declining confirmation', () {
        setUpAll(() async {
          when(
            () => client.projects.listProjectsInfo(
              includeLatestDeployAttemptTime: any(
                named: 'includeLatestDeployAttemptTime',
              ),
            ),
          ).thenAnswer(
            (final _) async => Future.value([
              ProjectInfoBuilder()
                  .withProject(
                    ProjectBuilder().withCloudProjectId(
                      'pre-existing-project-1',
                    ),
                  )
                  .build(),
              ProjectInfoBuilder()
                  .withProject(
                    ProjectBuilder().withCloudProjectId(
                      'pre-existing-project-2',
                    ),
                  )
                  .build(),
            ]),
          );
        });

        late Future commandResult;

        setUp(() async {
          logger.answerNextInputsWith([testProjectDir, '', projectId]);
          logger.answerNextConfirmsWith([
            true, // confirm new project cost acceptance
            true, // enable db
            true, // perform deploy
            true, // code generation prompt
            false, // do not apply setup
          ]);

          commandResult = cli.run(['launch']);
        });

        test('then throws ErrorExitException', () async {
          expect(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then logs input messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.inputCalls, isNotEmpty);
          expect(
            logger.inputCalls,
            containsAllInOrder([
              equalsInputCall(message: 'Enter the project directory'),
              equalsInputCall(
                message: 'Enter a new project id',
                defaultValue: 'default: my-project',
              ),
            ]),
          );
        });

        test('then logs confirmation messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.confirmCalls, isNotEmpty);
          expect(
            logger.confirmCalls,
            containsAllInOrder([
              equalsConfirmCall(
                message: 'Enable the database for the project?',
                defaultValue: true,
              ),
              equalsConfirmCall(
                message: "Deploy '$projectId' project right away?",
                defaultValue: true,
              ),
              equalsConfirmCall(
                message: 'Continue and apply this setup?',
                defaultValue: true,
              ),
            ]),
          );
        });

        test('then logs setup message box', () async {
          await commandResult.catchError((final _) {});

          expect(logger.boxCalls, hasLength(1));
          expect(
            logger.boxCalls.single.message,
            stringContainsInOrder([
              'Project setup',
              'Project directory  $testProjectDir',
              'New project id     $projectId',
              'Enable DB          yes',
              'Perform deploy     yes',
            ]),
          );
        });

        test('then logs no success messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.successCalls, isEmpty);
        });

        test('then logs cancellation info message', () async {
          await commandResult.catchError((final _) {});

          expect(logger.infoCalls, hasLength(6));
          expect(
            logger.infoCalls.last,
            equalsInfoCall(message: 'Setup cancelled.'),
          );
        });

        test('then does not write scloud.yaml file', () async {
          await commandResult.catchError((final _) {});

          final expected = d.dir(testProjectDir, [d.nothing('scloud.yaml')]);
          await expectLater(expected.validate(), completes);
        });
      });

      group('when executing launch with all settings provided interactively '
          'and 2 pre-existing projects are found and selected '
          'and declining confirmation', () {
        setUpAll(() async {
          when(
            () => client.projects.listProjectsInfo(
              includeLatestDeployAttemptTime: any(
                named: 'includeLatestDeployAttemptTime',
              ),
            ),
          ).thenAnswer(
            (final _) async => Future.value([
              ProjectInfoBuilder()
                  .withProject(
                    ProjectBuilder().withCloudProjectId(
                      'pre-existing-project-1',
                    ),
                  )
                  .build(),
              ProjectInfoBuilder()
                  .withProject(
                    ProjectBuilder().withCloudProjectId(
                      'pre-existing-project-2',
                    ),
                  )
                  .build(),
            ]),
          );
        });

        late Future commandResult;

        setUp(() async {
          logger.answerNextInputsWith([testProjectDir, '1', projectId]);
          logger.answerNextConfirmsWith([
            true, // perform deploy
            true, // code generation prompt
            false, // do not apply setup
          ]);

          commandResult = cli.run(['launch']);
        });

        test('then throws ErrorExitException', () async {
          expect(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then logs input messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.inputCalls, isNotEmpty);
          expect(
            logger.inputCalls,
            containsAllInOrder([
              equalsInputCall(message: 'Enter the project directory'),
              equalsInputCall(
                message: 'Enter a project number from the list, or blank',
              ),
            ]),
          );
        });

        test('then logs confirmation messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.confirmCalls, isNotEmpty);
          expect(
            logger.confirmCalls,
            containsAllInOrder([
              equalsConfirmCall(
                message: "Deploy 'pre-existing-project-1' project right away?",
                defaultValue: true,
              ),
              equalsConfirmCall(
                message: 'Continue and apply this setup?',
                defaultValue: true,
              ),
            ]),
          );
        });

        test('then logs setup message box', () async {
          await commandResult.catchError((final _) {});

          expect(logger.boxCalls, hasLength(1));
          expect(
            logger.boxCalls.single.message,
            stringContainsInOrder([
              'Project setup',
              'Project directory    $testProjectDir',
              'Existing project id  pre-existing-project-1',
              'Perform deploy       yes',
            ]),
          );
        });

        test('then logs no success messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.successCalls, isEmpty);
        });

        test('then logs cancellation info message', () async {
          await commandResult.catchError((final _) {});

          expect(logger.infoCalls, hasLength(6));
          expect(
            logger.infoCalls.last,
            equalsInfoCall(message: 'Setup cancelled.'),
          );
        });

        test('then does not write scloud.yaml file', () async {
          await commandResult.catchError((final _) {});

          final expected = d.dir(testProjectDir, [d.nothing('scloud.yaml')]);
          await expectLater(expected.validate(), completes);
        });
      });

      group('when executing launch with all settings provided interactively '
          'and 1 pre-existing project is found but not selected '
          'and declining confirmation', () {
        setUpAll(() async {
          when(
            () => client.projects.listProjectsInfo(
              includeLatestDeployAttemptTime: any(
                named: 'includeLatestDeployAttemptTime',
              ),
            ),
          ).thenAnswer(
            (final _) async => Future.value([
              ProjectInfoBuilder()
                  .withProject(
                    ProjectBuilder().withCloudProjectId('pre-existing-project'),
                  )
                  .build(),
            ]),
          );
        });

        late Future commandResult;

        setUp(() async {
          logger.answerNextInputsWith([testProjectDir, projectId]);
          logger.answerNextConfirmsWith([
            false, // decline using existing project
            true, // confirm new project cost acceptance
            true, // enable db
            true, // perform deploy
            true, // code generation prompt
            false, // do not apply setup
          ]);

          commandResult = cli.run(['launch']);
        });

        test('then throws ErrorExitException', () async {
          expect(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then logs input messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.inputCalls, isNotEmpty);
          expect(
            logger.inputCalls,
            containsAllInOrder([
              equalsInputCall(message: 'Enter the project directory'),
              equalsInputCall(
                message: 'Enter a new project id',
                defaultValue: 'default: my-project',
              ),
            ]),
          );
        });

        test('then logs confirmation messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.confirmCalls, isNotEmpty);
          expect(
            logger.confirmCalls,
            containsAllInOrder([
              equalsConfirmCall(
                message: 'Enable the database for the project?',
                defaultValue: true,
              ),
              equalsConfirmCall(
                message: "Deploy '$projectId' project right away?",
                defaultValue: true,
              ),
              equalsConfirmCall(
                message: 'Continue and apply this setup?',
                defaultValue: true,
              ),
            ]),
          );
        });

        test('then logs setup message box', () async {
          await commandResult.catchError((final _) {});

          expect(logger.boxCalls, hasLength(1));
          expect(
            logger.boxCalls.single.message,
            stringContainsInOrder([
              'Project setup',
              'Project directory  $testProjectDir',
              'New project id     $projectId',
              'Enable DB          yes',
              'Perform deploy     yes',
            ]),
          );
        });

        test('then logs no success messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.successCalls, isEmpty);
        });

        test('then logs cancellation info message', () async {
          await commandResult.catchError((final _) {});

          expect(logger.infoCalls, hasLength(3));
          expect(
            logger.infoCalls.last,
            equalsInfoCall(message: 'Setup cancelled.'),
          );
        });

        test('then does not write scloud.yaml file', () async {
          await commandResult.catchError((final _) {});

          final expected = d.dir(testProjectDir, [d.nothing('scloud.yaml')]);
          await expectLater(expected.validate(), completes);
        });
      });

      group('when executing launch with all settings provided interactively '
          'and 1 pre-existing project is found and selected '
          'and declining confirmation', () {
        setUpAll(() async {
          when(
            () => client.projects.listProjectsInfo(
              includeLatestDeployAttemptTime: any(
                named: 'includeLatestDeployAttemptTime',
              ),
            ),
          ).thenAnswer(
            (final _) async => Future.value([
              ProjectInfoBuilder()
                  .withProject(
                    ProjectBuilder().withCloudProjectId('pre-existing-project'),
                  )
                  .build(),
            ]),
          );
        });

        late Future commandResult;

        setUp(() async {
          logger.answerNextInputsWith([testProjectDir, projectId]);
          logger.answerNextConfirmsWith([
            true, // confirm using existing project
            true, // perform deploy
            true, // code generation prompt
            false, // do not apply setup
          ]);

          commandResult = cli.run(['launch']);
        });

        test('then throws ErrorExitException', () async {
          expect(commandResult, throwsA(isA<ErrorExitException>()));
        });

        test('then logs input messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.inputCalls, isNotEmpty);
          expect(
            logger.inputCalls,
            containsAllInOrder([
              equalsInputCall(message: 'Enter the project directory'),
            ]),
          );
        });

        test('then logs confirmation messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.confirmCalls, isNotEmpty);
          expect(
            logger.confirmCalls,
            containsAllInOrder([
              equalsConfirmCall(message: 'Continue with pre-existing-project?'),
              equalsConfirmCall(
                message: "Deploy 'pre-existing-project' project right away?",
                defaultValue: true,
              ),
              equalsConfirmCall(
                message: 'Continue and apply this setup?',
                defaultValue: true,
              ),
            ]),
          );
        });

        test('then logs setup message box', () async {
          await commandResult.catchError((final _) {});

          expect(logger.boxCalls, hasLength(1));
          expect(
            logger.boxCalls.single.message,
            stringContainsInOrder([
              'Project setup',
              'Project directory    $testProjectDir',
              'Existing project id  pre-existing-project',
              'Perform deploy       yes',
            ]),
          );
        });

        test('then logs no success messages', () async {
          await commandResult.catchError((final _) {});

          expect(logger.successCalls, isEmpty);
        });

        test('then logs cancellation info message', () async {
          await commandResult.catchError((final _) {});

          expect(logger.infoCalls, hasLength(3));
          expect(
            logger.infoCalls.last,
            equalsInfoCall(message: 'Setup cancelled.'),
          );
        });

        test('then does not write scloud.yaml file', () async {
          await commandResult.catchError((final _) {});

          final expected = d.dir(testProjectDir, [d.nothing('scloud.yaml')]);
          await expectLater(expected.validate(), completes);
        });
      });
    });

    group('and a Serverpod server directory with invalid pubspec '
        'when executing launch with all settings provided interactively '
        'and declining confirmation', () {
      late String invalidProjectDir;
      late String validProjectDir;
      late Future commandResult;

      setUp(() async {
        await d.dir('invalid_server_dir', [
          d.file('pubspec.yaml', '''
name: my_project_server
environment:
  sdk: ${ProjectFactory.validSdkVersion}
dependencies:
  serverpod: 2.1.0  # too old version
'''),
        ]).create();
        invalidProjectDir = p.join(d.sandbox, 'invalid_server_dir');

        await ProjectFactory.serverpodServerDir(
          withDirectoryName: 'server_dir',
        ).create();
        validProjectDir = p.join(d.sandbox, 'server_dir');

        logger.answerNextInputsWith([
          invalidProjectDir,
          validProjectDir,
          projectId,
        ]);
        logger.answerNextConfirmsWith([
          true, // enable db
          true, // perform deploy
          true, // code generation prompt
          false, // do not apply setup
        ]);

        commandResult = cli.run(['launch']);
      });

      test('then throws ErrorExitException', () async {
        expect(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs input messages', () async {
        await commandResult.catchError((final _) {});

        expect(logger.inputCalls, hasLength(1));
        expect(
          logger.inputCalls.single,
          equalsInputCall(message: 'Enter the project directory'),
        );
      });

      test('then logs error message for invalid project directory', () async {
        await commandResult.catchError((final _) {});

        expect(logger.errorCalls, hasLength(1));
        expect(
          logger.errorCalls.single,
          equalsErrorCall(
            message:
                '`$invalidProjectDir` is a Serverpod server directory, but it is not valid:\n'
                'Unsupported serverpod version constraint: 2.1.0 (must adher to: ${VersionConstants.supportedServerpodConstraint})',
            hint: "Resolve the issues and try again.",
          ),
        );
      });

      test('then logs no confirmation message', () async {
        await commandResult.catchError((final _) {});

        expect(logger.confirmCalls, isEmpty);
      });

      test('then logs setup message box', () async {
        await commandResult.catchError((final _) {});

        expect(logger.boxCalls, hasLength(0));
      });

      test('then logs no success messages', () async {
        await commandResult.catchError((final _) {});

        expect(logger.successCalls, isEmpty);
      });

      test('then logs no cancellation info message', () async {
        await commandResult.catchError((final _) {});

        expect(logger.infoCalls, isEmpty);
      });

      test('then does not write scloud.yaml file', () async {
        await commandResult.catchError((final _) {});

        final expected = d.dir(validProjectDir, [d.nothing('scloud.yaml')]);
        await expectLater(expected.validate(), completes);
      });
    });

    group(
      'and a Dart workspace directory structure containing a serverpod directory',
      () {
        late String testProjectDir;

        setUp(() async {
          await d.dir('workspace_dir', [
            d.file('pubspec.yaml', '''
name: workspace_package
environment:
  sdk: ${ProjectFactory.validSdkVersion}
workspace:
  - project_server
  - project_client
'''),
            d.dir('project_server', [
              ProjectFactory.serverpodServerPubspec(
                withResolution: 'workspace',
              ),
            ]),
            d.dir('project_client', [
              d.file('pubspec.yaml', '''
name: my_project_client
environment:
  sdk: ${ProjectFactory.validSdkVersion}
resolution: workspace
'''),
            ]),
          ]).create();
          testProjectDir = p.join(d.sandbox, 'workspace_dir', 'project_server');
        });

        group('when executing launch with all settings provided via args '
            'and approving confirmation', () {
          late Future commandResult;
          setUp(() async {
            logger.answerNextConfirmsWith([true, true]);

            commandResult = cli.run([
              'launch',
              '--new-project',
              projectId,
              '--project-dir',
              testProjectDir,
              '--enable-db',
              '--deploy',
            ]);

            await commandResult;
          });

          test('then writes scloud.yaml file', () async {
            final expected = d.dir('workspace_dir', [
              d.dir('project_server', [
                d.file(
                  'scloud.yaml',
                  contains('''
project:
  projectId: "$projectId"
'''),
                ),
              ]),
            ]);
            await expectLater(expected.validate(p.join(d.sandbox)), completes);
          });

          test(
            'then .scloudignore is created in the workspace root to cover all packages',
            () async {
              final expected = d.dir('workspace_dir', [
                d.file(
                  '.scloudignore',
                  contains(
                    'This file specifies which files and directories should be ignored',
                  ),
                ),
                d.dir('project_server', [d.nothing('.scloudignore')]),
                d.dir('project_client', [d.nothing('.scloudignore')]),
              ]);
              await expectLater(
                expected.validate(p.join(d.sandbox)),
                completes,
              );
            },
          );
        });
      },
    );
  });
}
