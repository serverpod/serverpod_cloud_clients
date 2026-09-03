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
}
