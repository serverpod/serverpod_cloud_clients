import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/projects/project_admin_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given an AdminProjectListTextUi', () {
    group('when rendered with a project', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final owner = UserBuilder().withEmail('owner@example.com').build();
        final io = await renderCommandUi(
          AdminProjectListTextUi(utc: true),
          data: [
            ProjectInfoBuilder()
                .withProject(
                  ProjectBuilder()
                      .withCloudProjectId('my-project')
                      .withCreatedAt(DateTime.utc(2024, 12, 31, 10, 20, 30))
                      .withUserOwner(owner),
                )
                .build(),
          ],
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the table headings', () {
        expect(stdout, contains('Project Id'));
        expect(stdout, contains('Created At (UTC)'));
        expect(stdout, contains('Owner'));
        expect(stdout, contains('Users'));
      });

      test('then stdout contains the project id', () {
        expect(stdout, contains('my-project'));
      });

      test('then stdout contains the owner email', () {
        expect(stdout, contains('owner@example.com'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given an AdminProjectDeleteTextUi', () {
    group('when rendered after deleting a project', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const AdminProjectDeleteTextUi(),
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
