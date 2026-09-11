import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/project/project_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given a ProjectListTextUi', () {
    group('when rendered with no projects', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          ProjectListTextUi(utc: true, showArchived: false),
          data: const <ProjectInfo>[],
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout reports that no projects are available', () {
        expect(stdout, contains('No projects available.'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered with a project', () {
      late String stdout;

      setUp(() async {
        final createdAt = DateTime.utc(2024, 12, 31, 10, 20, 30);
        final io = await renderCommandUi(
          ProjectListTextUi(utc: true, showArchived: false),
          data: [
            ProjectInfoBuilder()
                .withProject(
                  ProjectBuilder()
                      .withCloudProjectId('my-project')
                      .withCreatedAt(createdAt),
                )
                .withLatestDeployAttemptTime(createdAt)
                .build(),
          ],
        );
        stdout = io.stdout;
      });

      test('then stdout contains the table headings', () {
        expect(stdout, contains('Project Id'));
        expect(stdout, contains('Created At'));
        expect(stdout, contains('Last Deploy Attempt'));
      });

      test('then stdout contains the project id', () {
        expect(stdout, contains('my-project'));
      });

      test('then stdout does not contain the deleted column', () {
        expect(stdout, isNot(contains('Deleted At')));
      });

      test('then the timestamp headings state the UTC time zone', () {
        expect(stdout, contains('Created At (UTC)'));
        expect(stdout, contains('Last Deploy Attempt (UTC)'));
      });
    });

    group('when rendered with local timestamps', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          ProjectListTextUi(utc: false, showArchived: false),
          data: [
            ProjectInfoBuilder()
                .withProject(ProjectBuilder().withCloudProjectId('my-project'))
                .build(),
          ],
        );
        stdout = io.stdout;
      });

      test('then the timestamp headings state the local time zone', () {
        expect(stdout, contains('Created At (local)'));
        expect(stdout, contains('Last Deploy Attempt (local)'));
      });
    });

    group('when rendered with archived projects included', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          ProjectListTextUi(utc: true, showArchived: true),
          data: [
            ProjectInfoBuilder()
                .withProject(
                  ProjectBuilder()
                      .withCloudProjectId('old-project')
                      .withArchivedAt(DateTime.utc(2025, 1, 2, 3, 4, 5)),
                )
                .build(),
          ],
        );
        stdout = io.stdout;
      });

      test('then stdout contains the deleted column', () {
        expect(stdout, contains('Deleted At'));
      });
    });
  });

  group('Given a ProjectCreateTextUi', () {
    group('when rendered after creating a project', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const ProjectCreateTextUi(planDisplayName: 'starter'),
          data: Stream.value(const {'projectId': 'my-project'}),
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the plan name', () {
        expect(stdout, contains('On plan: starter'));
      });

      test('then stdout contains the progress success heading', () {
        expect(stdout, contains('Project registration successful.'));
      });

      test('then stdout contains the create success message', () {
        expect(stdout, contains('Serverpod Cloud project created.'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered before database creation', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const ProjectCreateTextUi(
            planDisplayName: 'starter',
            includeSuccess: false,
          ),
          data: Stream.value(const {'projectId': 'my-project'}),
        );
        stdout = io.stdout;
      });

      test('then stdout does not contain the create success message', () {
        expect(stdout, isNot(contains('Serverpod Cloud project created.')));
      });
    });
  });

  group('Given a ProjectCreateDatabaseTextUi', () {
    group('when rendered after requesting database creation', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const ProjectCreateDatabaseTextUi(),
          data: Stream.value(const {'projectId': 'my-project'}),
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the database progress success heading', () {
        expect(stdout, contains('Database creation request sent.'));
      });

      test('then stdout contains the create success message', () {
        expect(stdout, contains('Serverpod Cloud project created.'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given a ProjectLinkTextUi', () {
    group('when rendered after linking a project', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const ProjectLinkTextUi(),
          data: Stream.value(const {'projectId': 'my-project'}),
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the progress success heading', () {
        expect(stdout, contains('Configuration files written.'));
      });

      test('then stdout contains the link success message', () {
        expect(stdout, contains('Linked Serverpod Cloud project.'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given a ProjectDeleteTextUi', () {
    group('when rendered after deleting a project', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const ProjectDeleteTextUi(),
          data: const {'projectId': 'my-project'},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the delete success message', () {
        expect(stdout, contains('Deleted the project "my-project".'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given a ProjectShowTextUi', () {
    group('when rendered with a single podlet and a fixed database size', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const ProjectShowTextUi(utc: true),
          data: {
            'projectId': 'my-project',
            'createdAt': DateTime.utc(2024, 12, 31, 10, 20, 30),
            'region': ServerpodRegion.asia,
            'latestDeployAttemptAt': null,
            'plan': {
              'type': PlanType.starter,
              'displayName': 'Starter',
              'startedAt': DateTime.utc(2024, 12, 31, 10, 20, 30),
              'trialEndsAt': null,
              'cancelled': false,
              'endsAt': null,
            },
            'compute': {
              'size': ComputeSizeOption.small,
              'memoryMb': 512,
              'minInstances': 1,
              'maxInstances': 1,
            },
            'database': {
              'size': DatabaseSizeOption.small,
              'memoryMb': 2048,
              'minCu': 1.0,
              'maxCu': 1.0,
              'storageLimitGb': null,
              'computeHoursLimit': null,
            },
          },
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout reports the region', () {
        expect(stdout, contains('  Region    Asia'));
      });

      test('then stdout reports that the project is not deployed', () {
        expect(stdout, contains('  Deployed  never'));
      });

      test('then stdout reports the podlet count in singular', () {
        expect(stdout, contains('  Compute   small — 512 MB, 1 podlet'));
      });

      test('then stdout reports a single compute unit value', () {
        expect(stdout, contains('  Database  small — 2048 MB, 1 CU'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered for a cancelled plan', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const ProjectShowTextUi(utc: true),
          data: {
            'projectId': 'my-project',
            'createdAt': DateTime.utc(2024, 12, 31, 10, 20, 30),
            'region': null,
            'latestDeployAttemptAt': null,
            'plan': {
              'type': PlanType.growth,
              'displayName': 'Growth',
              'startedAt': DateTime.utc(2024, 12, 31, 10, 20, 30),
              'trialEndsAt': null,
              'cancelled': true,
              'endsAt': DateTime.utc(2025, 2, 1, 0, 0, 0),
            },
            'compute': null,
            'database': null,
          },
        );
        stdout = io.stdout;
      });

      test('then stdout reports when the plan ends', () {
        expect(
          stdout,
          contains('  Ending    cancelled, ends 2025-02-01 00:00:00 (UTC)'),
        );
      });

      test('then stdout omits the region row', () {
        expect(stdout, isNot(contains('Region')));
      });
    });
  });
}
