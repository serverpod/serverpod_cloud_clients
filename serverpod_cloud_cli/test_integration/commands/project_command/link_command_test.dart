@Tags(['concurrency_one']) // due to current directory manipulation
library;

import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/util/scloudignore.dart' show ScloudIgnore;
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:test/test.dart';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/project_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/yaml_schema.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/project_factory.dart';
import '../../../test_utils/push_current_dir.dart';
import '../../../test_utils/test_command_logger.dart';

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

  const projectId = 'projectId';

  tearDown(() async {
    logger.clear();
  });

  test('Given project link command when instantiated then requires login', () {
    expect(CloudProjectLinkCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given authenticated', () {
    setUp(() async {
      when(
        () => client.projects.fetchProjectConfig(
          cloudProjectId: any(named: 'cloudProjectId'),
        ),
      ).thenAnswer(
        (final invocation) async => Future.value(
          ProjectConfig(projectId: invocation.namedArguments[#cloudProjectId]),
        ),
      );
    });

    group('and serverpod directory', () {
      late String testProjectDir;

      setUp(() async {
        await ProjectFactory.serverpodServerDir(
          withDirectoryName: 'server_dir',
        ).create();
        testProjectDir = p.join(d.sandbox, 'server_dir');
      });

      group('and scloud.yaml does not already exist when executing link', () {
        late Future commandResult;
        setUp(() async {
          commandResult = cli.run([
            'project',
            'link',
            '--project',
            projectId,
            '--project-dir',
            testProjectDir,
          ]);
        });

        test('then command completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then logs success message', () async {
          await commandResult;

          expect(logger.successCalls, isNotEmpty);
          expect(
            logger.successCalls.first,
            equalsSuccessCall(
              message: 'Linked Serverpod Cloud project.',
              newParagraph: true,
            ),
          );
        });

        test('then writes scloud.yaml file', () async {
          await commandResult;

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

        test('then includes standard header in scloud.yaml file', () async {
          await commandResult;

          final expected = d.dir(testProjectDir, [
            d.file(
              'scloud.yaml',
              startsWith(
                '# This file configures your Serverpod Cloud project.',
              ),
            ),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });

      group('and scloud.yaml exists when executing link', () {
        late Future commandResult;

        setUp(() async {
          await d.dir(testProjectDir, [
            d.file('scloud.yaml', '''
project:
  projectId: "otherProjectId"
'''),
          ]).create();

          commandResult = cli.run([
            'project',
            'link',
            '--project',
            projectId,
            '--project-dir',
            testProjectDir,
          ]);
        });

        test('then command completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then logs success message', () async {
          await commandResult;

          expect(logger.successCalls, isNotEmpty);
          expect(
            logger.successCalls.first,
            equalsSuccessCall(
              message: 'Linked Serverpod Cloud project.',
              newParagraph: true,
            ),
          );
        });

        test('then writes updated project id to scloud.yaml file', () async {
          await commandResult;

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

        test('then includes standard header in scloud.yaml file', () async {
          await commandResult;

          final expected = d.dir(testProjectDir, [
            d.file(
              'scloud.yaml',
              startsWith(
                '# This file configures your Serverpod Cloud project.',
              ),
            ),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });

      group(
        'and inside a serverpod directory without .scloudignore file when executing link',
        () {
          late Future commandResult;
          setUp(() async {
            commandResult = cli.run([
              'project',
              'link',
              '--project',
              projectId,
              '--project-dir',
              testProjectDir,
            ]);
          });

          test('then writes .scloudignore file', () async {
            await commandResult;

            final expected = d.dir(testProjectDir, [
              d.file('.scloudignore', contains('# .scloudignore')),
            ]);
            await expectLater(expected.validate(), completes);
          });
        },
      );

      group(
        'and inside a serverpod directory with a custom .scloudignore file when executing link',
        () {
          late Future commandResult;
          setUp(() async {
            await d.dir(testProjectDir, [
              d.file('.scloudignore', '# Custom .scloudignore file'),
            ]).create();

            commandResult = cli.run([
              'project',
              'link',
              '--project',
              projectId,
              '--project-dir',
              testProjectDir,
            ]);
          });

          test(
            'then the content of the .scloudignore file is not changed',
            () async {
              await commandResult;

              final expected = d.dir(testProjectDir, [
                d.file(
                  '.scloudignore',
                  contains('# Custom .scloudignore file'),
                ),
              ]);
              await expectLater(expected.validate(), completes);
            },
          );
        },
      );

      group(
        'and incorrectly formatted scloud.yaml exists when executing link',
        () {
          late Future commandResult;
          setUp(() async {
            await d.dir(testProjectDir, [
              d.file('scloud.yaml', '''
project:
  - "projectId"
'''),
            ]).create();

            commandResult = cli.run([
              'project',
              'link',
              '--project',
              projectId,
              '--project-dir',
              testProjectDir,
            ]);
          });

          test('then command throws exit exception', () async {
            await expectLater(
              commandResult,
              throwsA(isA<ErrorExitException>()),
            );
          });

          test('then logs error message', () async {
            try {
              await commandResult;
            } catch (_) {}

            expect(logger.errorCalls, isNotEmpty);
            expect(
              logger.errorCalls.first,
              equalsErrorCall(
                message:
                    'Failed to write to the ${p.join(testProjectDir, 'scloud.yaml')} file',
                exception: SchemaValidationException(
                  'At path "project": Expected YamlMap, got YamlList',
                ),
              ),
            );
          });
        },
      );
    });

    group('and not a serverpod directory when executing link', () {
      late String testProjectDir;
      late Future commandResult;

      setUp(() async {
        await d.dir('not_a_serverpod_dir').create();
        testProjectDir = p.join(d.sandbox, 'not_a_serverpod_dir');

        commandResult = cli.run([
          'project',
          'link',
          '--project',
          projectId,
          '--project-dir',
          testProjectDir,
        ]);
      });

      test('then command throws exit exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs error message', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errorCalls, isNotEmpty);
        expect(
          logger.errorCalls.first,
          equalsErrorCall(
            message: '`$testProjectDir` is not a Serverpod server directory.',
            hint: "Provide the project's server directory and try again.",
          ),
        );
      });
    });

    group('and a deep directory hierarchy with a serverpod directory', () {
      setUp(() async {
        final descriptor = d.dir('topdir', [
          d.dir('parent_dir', [
            d.dir('project_server', [ProjectFactory.serverpodServerPubspec()]),
            d.dir('project_client', [
              d.file('pubspec.yaml', '''
name: my_project_client
environment:
  sdk: ${ProjectFactory.validSdkVersion}
'''),
            ]),
            d.dir('project_flutter', [
              d.file('pubspec.yaml', '''
name: my_project_flutter
environment:
  sdk: ${ProjectFactory.validSdkVersion}
'''),
            ]),
          ]),
        ]);
        await descriptor.create();
      });

      group(
        'and current dir is three levels above the project dir when executing link',
        () {
          late Future commandResult;

          setUp(() async {
            pushCurrentDirectory(p.join(d.sandbox));

            commandResult = cli.run([
              'project',
              'link',
              '--project',
              projectId,
            ]);
          });

          test('then project link command throws exit exception', () async {
            await expectLater(
              commandResult,
              throwsA(isA<ErrorExitException>()),
            );
          });

          test('then project link command logs error message', () async {
            await expectLater(
              commandResult,
              throwsA(isA<ErrorExitException>()),
            );
            expect(logger.errorCalls, isNotEmpty);
            expect(
              logger.errorCalls.first,
              equalsErrorCall(
                message: 'No valid Serverpod server directory selected.',
                hint:
                    "Provide the project's server directory with the `--project-dir` option and try again.",
              ),
            );
          });

          test('then scloud.yaml is not created', () async {
            try {
              await commandResult;
            } catch (_) {}

            final expected = d.dir('topdir', [
              d.dir('parent_dir', [
                d.dir('project_server', [d.nothing('scloud.yaml')]),
                d.dir('project_client', [d.nothing('scloud.yaml')]),
                d.dir('project_flutter', [d.nothing('scloud.yaml')]),
              ]),
            ]);
            await expectLater(expected.validate(), completes);
          });
        },
      );

      group(
        'and current dir is two levels above the project dir when executing link',
        () {
          late Future commandResult;

          setUp(() async {
            pushCurrentDirectory(p.join(d.sandbox, 'topdir'));

            commandResult = cli.run([
              'project',
              'link',
              '--project',
              projectId,
            ]);
          });

          test('then project link command completes successfully', () async {
            await expectLater(commandResult, completes);
          });

          test('then project link command logs success message', () async {
            await commandResult;

            expect(logger.successCalls, hasLength(1));
            expect(
              logger.successCalls.single,
              equalsSuccessCall(
                message: 'Linked Serverpod Cloud project.',
                newParagraph: true,
              ),
            );
          });

          test('then scloud.yaml is created in the project dir', () async {
            await commandResult;
            final expected = d.dir('topdir', [
              d.dir('parent_dir', [
                d.dir('project_server', [
                  d.file(
                    'scloud.yaml',
                    contains('''
project:
  projectId: "projectId"
'''),
                  ),
                ]),
                d.dir('project_client', [d.nothing('scloud.yaml')]),
                d.dir('project_flutter', [d.nothing('scloud.yaml')]),
              ]),
            ]);
            await expectLater(expected.validate(), completes);
          });

          test('then .scloudignore is created in the project dir', () async {
            await commandResult;
            final expected = d.dir('topdir', [
              d.dir('parent_dir', [
                d.nothing('.scloudignore'),
                d.dir('project_server', [
                  d.file(
                    '.scloudignore',
                    contains(
                      'This file specifies which files and directories should be ignored',
                    ),
                  ),
                ]),
                d.dir('project_client', [d.nothing('.scloudignore')]),
                d.dir('project_flutter', [d.nothing('.scloudignore')]),
              ]),
            ]);
            await expectLater(expected.validate(), completes);
          });

          test('then .gitignore is not created', () async {
            await commandResult;
            final expected = d.dir('topdir', [
              d.dir('parent_dir', [
                d.nothing('.gitignore'),
                d.dir('project_server', [d.nothing('.gitignore')]),
                d.dir('project_client', [d.nothing('.gitignore')]),
                d.dir('project_flutter', [d.nothing('.gitignore')]),
              ]),
            ]);
            await expectLater(expected.validate(), completes);
          });
        },
      );

      group(
        'and current dir is one level above the project dir when executing link',
        () {
          late Future commandResult;

          setUp(() async {
            pushCurrentDirectory(p.join(d.sandbox, 'topdir', 'parent_dir'));

            commandResult = cli.run([
              'project',
              'link',
              '--project',
              projectId,
            ]);
          });

          test('then project link command completes successfully', () async {
            await expectLater(commandResult, completes);
          });

          test('then project link command logs success message', () async {
            await commandResult;

            expect(logger.successCalls, hasLength(1));
            expect(
              logger.successCalls.single,
              equalsSuccessCall(
                message: 'Linked Serverpod Cloud project.',
                newParagraph: true,
              ),
            );
          });

          test('then scloud.yaml is created in the project dir', () async {
            await commandResult;
            final expected = d.dir('topdir', [
              d.dir('parent_dir', [
                d.dir('project_server', [
                  d.file(
                    'scloud.yaml',
                    contains('''
project:
  projectId: "projectId"
'''),
                  ),
                ]),
                d.dir('project_client', [d.nothing('scloud.yaml')]),
                d.dir('project_flutter', [d.nothing('scloud.yaml')]),
              ]),
            ]);
            await expectLater(expected.validate(), completes);
          });
        },
      );

      group('and current dir is in the flutter dir when executing link', () {
        late Future commandResult;

        setUp(() async {
          pushCurrentDirectory(
            p.join(d.sandbox, 'topdir', 'parent_dir', 'project_flutter'),
          );

          commandResult = cli.run(['project', 'link', '--project', projectId]);
        });

        test('then project link command completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then project link command logs success message', () async {
          await commandResult;

          expect(logger.successCalls, hasLength(1));
          expect(
            logger.successCalls.single,
            equalsSuccessCall(
              message: 'Linked Serverpod Cloud project.',
              newParagraph: true,
            ),
          );
        });

        test('then scloud.yaml is created in the project dir', () async {
          await commandResult;
          final expected = d.dir('topdir', [
            d.dir('parent_dir', [
              d.dir('project_server', [
                d.file(
                  'scloud.yaml',
                  contains('''
project:
  projectId: "projectId"
'''),
                ),
              ]),
              d.dir('project_client', [d.nothing('scloud.yaml')]),
              d.dir('project_flutter', [d.nothing('scloud.yaml')]),
            ]),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });

      group('and current dir is in the flutter dir '
          'and there is preexisting scloud.yaml file in server dir '
          'when executing link', () {
        late Future commandResult;

        setUp(() async {
          final preexistingScloudYamlFile = d.file('scloud.yaml', '''
project:
  projectId: "otherProjectId"
''');
          await preexistingScloudYamlFile.create(
            p.join(d.sandbox, 'topdir', 'parent_dir', 'project_server'),
          );

          pushCurrentDirectory(
            p.join(d.sandbox, 'topdir', 'parent_dir', 'project_flutter'),
          );

          commandResult = cli.run([
            'project',
            'link',
            '--project',
            'specialId',
          ]);
        });

        test('then project link command completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then project link command logs success message', () async {
          await commandResult;

          expect(logger.successCalls, hasLength(1));
          expect(
            logger.successCalls.single,
            equalsSuccessCall(
              message: 'Linked Serverpod Cloud project.',
              newParagraph: true,
            ),
          );
        });

        test('then scloud.yaml is updated in the project dir', () async {
          await commandResult;
          final expected = d.dir('topdir', [
            d.dir('parent_dir', [
              d.dir('project_server', [
                d.file(
                  'scloud.yaml',
                  contains('''
project:
  projectId: "specialId"
'''),
                ),
              ]),
              d.dir('project_client', [d.nothing('scloud.yaml')]),
              d.dir('project_flutter', [d.nothing('scloud.yaml')]),
            ]),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });

      group('and current dir is in the flutter dir '
          'and there is preexisting scloud.yaml file in parent dir '
          'when executing link', () {
        late Future commandResult;

        setUp(() async {
          final preexistingScloudYamlFile = d.file('scloud.yaml', '''
project:
  projectId: "otherProjectId"
''');
          await preexistingScloudYamlFile.create(
            p.join(d.sandbox, 'topdir', 'parent_dir'),
          );

          pushCurrentDirectory(
            p.join(d.sandbox, 'topdir', 'parent_dir', 'project_flutter'),
          );

          commandResult = cli.run([
            'project',
            'link',
            '--project-dir',
            p.join(d.sandbox, 'topdir', 'parent_dir', 'project_server'),
            '--project',
            'specialId',
          ]);
        });

        test('then project link command completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then project link command logs success message', () async {
          await commandResult;

          expect(logger.successCalls, hasLength(1));
          expect(
            logger.successCalls.single,
            equalsSuccessCall(
              message: 'Linked Serverpod Cloud project.',
              newParagraph: true,
            ),
          );
        });

        test('then scloud.yaml is updated in the parent dir', () async {
          await commandResult;
          final expected = d.dir('topdir', [
            d.dir('parent_dir', [
              d.dir('project_server', [d.nothing('scloud.yaml')]),
              d.dir('project_client', [d.nothing('scloud.yaml')]),
              d.dir('project_flutter', [d.nothing('scloud.yaml')]),
              d.file(
                'scloud.yaml',
                contains('''
project:
  projectId: "specialId"
'''),
              ),
            ]),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });

      group('and current dir is in the flutter dir '
          'and there is preexisting scloud.yaml file in parent dir '
          'when executing link with custom-config-file-in-parent option', () {
        late Future commandResult;

        setUp(() async {
          final preexistingScloudYamlFile = d.file('scloud.yaml', '''
project:
  projectId: "otherProjectId"
''');
          await preexistingScloudYamlFile.create(
            p.join(d.sandbox, 'topdir', 'parent_dir'),
          );

          pushCurrentDirectory(
            p.join(d.sandbox, 'topdir', 'parent_dir', 'project_flutter'),
          );

          commandResult = cli.run([
            'project',
            'link',
            '--project-dir',
            p.join(d.sandbox, 'topdir', 'parent_dir', 'project_server'),
            '--project-config-file',
            p.join(d.sandbox, 'topdir', 'parent_dir', 'custom_scloud.yaml'),
            '--project',
            'customProjectId',
          ]);
        });

        test('then project link command completes successfully', () async {
          await expectLater(commandResult, completes);
        });

        test('then project link command logs success message', () async {
          await commandResult;

          expect(logger.successCalls, hasLength(1));
          expect(
            logger.successCalls.single,
            equalsSuccessCall(
              message: 'Linked Serverpod Cloud project.',
              newParagraph: true,
            ),
          );
        });

        test('then scloud.yaml is updated in the parent dir', () async {
          await commandResult;
          final expected = d.dir('topdir', [
            d.dir('parent_dir', [
              d.dir('project_server', [d.nothing('scloud.yaml')]),
              d.dir('project_client', [d.nothing('scloud.yaml')]),
              d.dir('project_flutter', [d.nothing('scloud.yaml')]),
              d.file(
                'scloud.yaml',
                contains('''
project:
  projectId: "otherProjectId"
'''),
              ),
              d.file(
                'custom_scloud.yaml',
                contains('''
project:
  projectId: "customProjectId"
'''),
              ),
            ]),
          ]);
          await expectLater(expected.validate(), completes);
        });
      });
    });

    group(
      'and a Dart workspace directory structure containing a serverpod directory',
      () {
        setUp(() async {
          final descriptor = d.dir('topdir', [
            d.dir('workspace_dir', [
              d.file('pubspec.yaml', '''
name: workspace_package
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
            ]),
          ]);
          await descriptor.create();
        });

        group(
          'and current dir is three levels above the project dir when executing link',
          () {
            late Future commandResult;

            setUp(() async {
              pushCurrentDirectory(p.join(d.sandbox));

              commandResult = cli.run([
                'project',
                'link',
                '--project',
                projectId,
              ]);
            });

            test('then project link command throws exit exception', () async {
              await expectLater(
                commandResult,
                throwsA(isA<ErrorExitException>()),
              );
            });

            test('then project link command logs error message', () async {
              await expectLater(
                commandResult,
                throwsA(isA<ErrorExitException>()),
              );
              expect(logger.errorCalls, isNotEmpty);
              expect(
                logger.errorCalls.first,
                equalsErrorCall(
                  message: 'No valid Serverpod server directory selected.',
                  hint:
                      "Provide the project's server directory with the `--project-dir` option and try again.",
                ),
              );
            });

            test('then scloud files are not created', () async {
              try {
                await commandResult;
              } catch (_) {}

              final expected = d.dir('topdir', [
                d.dir('workspace_dir', [
                  d.nothing('scloud.yaml'),
                  d.nothing('.scloudignore'),
                  d.nothing('.gitignore'),
                  d.dir('project_server', [
                    d.nothing('scloud.yaml'),
                    d.nothing('.scloudignore'),
                    d.nothing('.gitignore'),
                  ]),
                  d.dir('project_client', [
                    d.nothing('scloud.yaml'),
                    d.nothing('.scloudignore'),
                    d.nothing('.gitignore'),
                  ]),
                ]),
              ]);
              await expectLater(expected.validate(), completes);
            });
          },
        );

        group(
          'and current dir is two levels above the project dir when executing link',
          () {
            late Future commandResult;

            setUp(() async {
              pushCurrentDirectory(p.join(d.sandbox, 'topdir'));

              commandResult = cli.run([
                'project',
                'link',
                '--project',
                projectId,
              ]);
            });

            test('then project link command completes successfully', () async {
              await expectLater(commandResult, completes);
            });

            test('then project link command logs success message', () async {
              await commandResult;

              expect(logger.successCalls, hasLength(1));
              expect(
                logger.successCalls.single,
                equalsSuccessCall(
                  message: 'Linked Serverpod Cloud project.',
                  newParagraph: true,
                ),
              );
            });

            test('then scloud.yaml is created in the project dir', () async {
              await commandResult;
              final expected = d.dir('topdir', [
                d.dir('workspace_dir', [
                  d.nothing('scloud.yaml'),
                  d.dir('project_server', [
                    d.file(
                      'scloud.yaml',
                      contains('''
project:
  projectId: "projectId"
'''),
                    ),
                  ]),
                  d.dir('project_client', [d.nothing('scloud.yaml')]),
                ]),
              ]);
              await expectLater(expected.validate(), completes);
            });

            test(
              'then .scloudignore is created in the workspace root dir',
              () async {
                await commandResult;
                final expected = d.dir('topdir', [
                  d.dir('workspace_dir', [
                    d.file(
                      '.scloudignore',
                      contains(
                        'This file specifies which files and directories should be ignored',
                      ),
                    ),
                    d.dir('project_server', [d.nothing('.scloudignore')]),
                    d.dir('project_client', [d.nothing('.scloudignore')]),
                  ]),
                ]);
                await expectLater(expected.validate(), completes);
              },
            );

            test(
              'then .gitignore is created in the workspace root dir',
              () async {
                await commandResult;
                final expected = d.dir('topdir', [
                  d.dir('workspace_dir', [
                    d.file(
                      '.gitignore',
                      equals('''
# scloud deployment generated files should not be committed to git
**/${ScloudIgnore.scloudDirName}/
'''),
                    ),
                    d.dir('project_server', [d.nothing('.gitignore')]),
                    d.dir('project_client', [d.nothing('.gitignore')]),
                  ]),
                ]);
                await expectLater(expected.validate(), completes);
              },
            );
          },
        );

        group(
          'and an existing .gitignore file without .scloud in the workspace root dir when executing link',
          () {
            late Future commandResult;

            setUp(() async {
              await d
                  .file('.gitignore', 'already_in_gitignore\n')
                  .create(p.join(d.sandbox, 'topdir', 'workspace_dir'));

              pushCurrentDirectory(p.join(d.sandbox, 'topdir'));

              commandResult = cli.run([
                'project',
                'link',
                '--project',
                projectId,
              ]);
            });

            test('then project link command completes successfully', () async {
              await expectLater(commandResult, completes);
            });

            test('then project link command logs success messages', () async {
              await commandResult;

              expect(logger.successCalls, hasLength(1));
              expect(
                logger.successCalls.single,
                equalsSuccessCall(
                  message: 'Linked Serverpod Cloud project.',
                  newParagraph: true,
                ),
              );
            });

            test(
              'then .gitignore is updated in the workspace root dir',
              () async {
                await commandResult;
                final expected = d.dir('topdir', [
                  d.dir('workspace_dir', [
                    d.file(
                      '.gitignore',
                      equals('''
already_in_gitignore

# scloud deployment generated files should not be committed to git
**/${ScloudIgnore.scloudDirName}/
'''),
                    ),
                    d.dir('project_server', [d.nothing('.gitignore')]),
                    d.dir('project_client', [d.nothing('.gitignore')]),
                  ]),
                ]);
                await expectLater(expected.validate(), completes);
              },
            );
          },
        );

        group(
          'and an existing .gitignore file with .scloud in the workspace root dir when executing link',
          () {
            late Future commandResult;

            setUp(() async {
              await d
                  .file(
                    '.gitignore',
                    'already_in_gitignore\n${ScloudIgnore.scloudDirName}/\n',
                  )
                  .create(p.join(d.sandbox, 'topdir', 'workspace_dir'));

              pushCurrentDirectory(p.join(d.sandbox, 'topdir'));

              commandResult = cli.run([
                'project',
                'link',
                '--project',
                projectId,
              ]);
            });

            test('then project link command completes successfully', () async {
              await expectLater(commandResult, completes);
            });

            test('then project link command logs success messages', () async {
              await commandResult;

              expect(logger.successCalls, hasLength(1));
              expect(
                logger.successCalls.single,
                equalsSuccessCall(
                  message: 'Linked Serverpod Cloud project.',
                  newParagraph: true,
                ),
              );
            });

            test(
              'then .gitignore is unchanged in the workspace root dir',
              () async {
                await commandResult;
                final expected = d.dir('topdir', [
                  d.dir('workspace_dir', [
                    d.file(
                      '.gitignore',
                      equals(
                        'already_in_gitignore\n${ScloudIgnore.scloudDirName}/\n',
                      ),
                    ),
                    d.dir('project_server', [d.nothing('.gitignore')]),
                    d.dir('project_client', [d.nothing('.gitignore')]),
                  ]),
                ]);
                await expectLater(expected.validate(), completes);
              },
            );
          },
        );
      },
    );
  });
}
