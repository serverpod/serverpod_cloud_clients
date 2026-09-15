import 'dart:async';

import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/projects/admin_project_list_row.dart';
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
          AdminProjectListTextUi(
            utc: true,
            includeArchived: false,
            includePaymentsStatus: false,
          ),
          data: Stream.fromIterable([
            AdminProjectListRow(
              projectInfo: ProjectInfoBuilder()
                  .withProject(
                    ProjectBuilder()
                        .withCloudProjectId('my-project')
                        .withCreatedAt(DateTime.utc(2024, 12, 31, 10, 20, 30))
                        .withUserOwner(owner),
                  )
                  .build(),
              subscriptionId: 'orb_sub_1',
            ),
          ]),
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the table headings', () {
        expect(stdout, contains('Project Id'));
        expect(stdout, contains('Created At (UTC)'));
        expect(stdout, contains('Owner'));
        expect(stdout, contains('Users'));
        expect(stdout, contains('Orb Subscription Id'));
      });

      test('then stdout does not contain the archived at column', () {
        expect(stdout, isNot(contains('Archived At')));
      });

      test('then stdout does not contain overdue payment columns', () {
        expect(stdout, isNot(contains('Oldest Overdue')));
        expect(stdout, isNot(contains('Newest Overdue')));
        expect(stdout, isNot(contains('Total Overdue')));
      });

      test('then stdout contains the project id', () {
        expect(stdout, contains('my-project'));
      });

      test('then stdout contains the owner email', () {
        expect(stdout, contains('owner@example.com'));
      });

      test('then stdout contains the orb subscription id', () {
        expect(stdout, contains('orb_sub_1'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered with archived projects included', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          AdminProjectListTextUi(
            utc: true,
            includeArchived: true,
            includePaymentsStatus: false,
          ),
          data: Stream.fromIterable([
            AdminProjectListRow(
              projectInfo: ProjectInfoBuilder()
                  .withProject(
                    ProjectBuilder()
                        .withCloudProjectId('old-project')
                        .withArchivedAt(DateTime.utc(2025, 1, 2, 3, 4, 5)),
                  )
                  .build(),
              subscriptionId: 'orb_sub_1',
            ),
          ]),
        );
        stdout = io.stdout;
      });

      test('then stdout contains the archived at column', () {
        expect(stdout, contains('Archived At (UTC)'));
      });
    });

    group('when rendered with payments included', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          AdminProjectListTextUi(
            utc: true,
            includeArchived: false,
            includePaymentsStatus: true,
          ),
          data: Stream.fromIterable([
            AdminProjectListRow(
              projectInfo: ProjectInfoBuilder()
                  .withProject(
                    ProjectBuilder().withCloudProjectId('my-project'),
                  )
                  .build(),
              subscriptionId: 'orb_sub_1',
              includePaymentsStatus: true,
              oldestOverdueUnpaidAmount: '10.00',
              oldestOverdueUnpaidDueDate: DateTime.utc(2024, 1, 1),
              newestOverdueUnpaidAmount: '5.50',
              newestOverdueUnpaidDueDate: DateTime.utc(2024, 6, 1),
              totalAmountOverdue: '15.50',
            ),
          ]),
        );
        stdout = io.stdout;
      });

      test('then stdout contains the overdue payment columns', () {
        expect(stdout, contains('Oldest Overdue'));
        expect(stdout, contains('Oldest Overdue Date'));
        expect(stdout, contains('Newest Overdue'));
        expect(stdout, contains('Newest Overdue Date'));
        expect(stdout, contains('Total Overdue'));
      });

      test('then stdout contains the overdue amounts', () {
        expect(stdout, contains('10.00'));
        expect(stdout, contains('5.50'));
        expect(stdout, contains('15.50'));
      });

      test('then stdout contains due dates without a time of day', () {
        expect(stdout, contains('2024-01-01'));
        expect(stdout, contains('2024-06-01'));
        expect(stdout, isNot(contains('2024-01-01 00:00:00')));
        expect(stdout, isNot(contains('2024-06-01 00:00:00')));
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
