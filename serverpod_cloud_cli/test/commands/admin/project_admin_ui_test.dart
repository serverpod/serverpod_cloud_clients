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
              planProductId: 'closed-beta:0',
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
        expect(stdout, contains('Plan Product Id'));
        expect(stdout, contains('Orb Subscription Id'));
      });

      test('then stdout does not contain the archived at column', () {
        expect(stdout, isNot(contains('Archived At')));
      });

      test('then stdout does not contain overdue payment columns', () {
        expect(stdout, isNot(contains('Oldest Overdue')));
        expect(stdout, isNot(contains('Newest Overdue')));
        expect(stdout, isNot(contains('Invoiced Overdue')));
        expect(stdout, isNot(contains('Uninvoiced Overdue')));
      });

      test('then stdout contains the project id', () {
        expect(stdout, contains('my-project'));
      });

      test('then stdout contains the owner email', () {
        expect(stdout, contains('owner@example.com'));
      });

      test('then stdout contains the plan product id', () {
        expect(stdout, contains('closed-beta:0'));
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
              planProductId: 'closed-beta:0',
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
              planProductId: 'closed-beta:0',
              subscriptionId: 'orb_sub_1',
              includePaymentsStatus: true,
              oldestOverdueUnpaidAmount: '10.00',
              oldestOverdueUnpaidDueDate: DateTime.utc(2024, 1, 1),
              newestOverdueUnpaidAmount: '5.50',
              newestOverdueUnpaidDueDate: DateTime.utc(2024, 6, 1),
              invoicedAmountOverdue: '10.00',
              uninvoicedAmountOverdue: '5.50',
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
        expect(stdout, contains('Invoiced Overdue'));
        expect(stdout, contains('Uninvoiced Overdue'));
      });

      test('then stdout contains the overdue amounts', () {
        expect(stdout, contains('10.00'));
        expect(stdout, contains('5.50'));
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

  group('Given an AdminProjectChangeOwnerTextUi', () {
    group('when rendered after changing a project owner', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const AdminProjectChangeOwnerTextUi(),
          data: const {
            'projectId': 'my-project',
            'ownerEmail': 'new-owner@example.com',
          },
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the change-owner success message', () {
        expect(
          stdout,
          contains(
            'Changed the owner of project "my-project" '
            'to "new-owner@example.com".',
          ),
        );
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given an AdminProjectUpdatePlanTextUi', () {
    group('when rendered after updating a project plan', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const AdminProjectUpdatePlanTextUi(),
          data: const {'projectId': 'my-project', 'planType': 'growth'},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the update-plan success message', () {
        expect(
          stdout,
          contains('Updated the plan of project "my-project" to "growth".'),
        );
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given an AdminProjectReprocureTextUi', () {
    group('when rendered after re-procuring a project', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const AdminProjectReprocureTextUi(),
          data: const {
            'projectId': 'my-project',
            'planType': 'starter',
            'subscriptionId': '11111111-1111-4111-8111-111111111111',
          },
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the reprocure success message', () {
        expect(
          stdout,
          contains('Re-procured project "my-project" on plan "starter"'),
        );
        expect(stdout, contains('11111111-1111-4111-8111-111111111111'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });
}
