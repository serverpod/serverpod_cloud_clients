import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/users/user_admin_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given an AdminUserStatusTextUi', () {
    group('when rendered with owner and project rows', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          AdminUserStatusTextUi(utc: true),
          data: AdminUserStatusBuilder()
              .withOwner(
                AdminUserOwnerStatusBuilder()
                    .withUserEmail('ada@example.com')
                    .withBillingInfoRegistered(true)
                    .withPaymentMethodRegistered(true),
              )
              .withProjects([
                AdminUserProjectMembershipBuilder().withLatestDeployAttempt(
                  DeployAttemptBuilder()
                      .withSuccessfulDeployment()
                      .withCommitHash('7915fd821')
                      .withCommitMessage('fix(gc): example commit')
                      .build(),
                ),
              ])
              .build(),
        );
        stdout = io.stdout;
      });

      test('then stdout contains structured owner fields', () {
        expect(stdout, contains('User'));
        expect(stdout, contains('ada@example.com'));
        expect(stdout, contains('Owner id'));
        expect(stdout, contains('billing info registered'));
        expect(stdout, contains('in good standing'));
      });

      test('then stdout contains structured project fields', () {
        expect(stdout, contains('Project'));
        expect(stdout, contains('my-project'));
        expect(stdout, contains('Phase'));
        expect(stdout, contains('active'));
        expect(stdout, contains('Roles'));
        expect(stdout, contains('Plan'));
        expect(stdout, contains('Billing'));
        expect(
          stdout,
          contains('https://app.withorb.com/subscriptions/orb_sub_test'),
        );
        expect(stdout, contains('Deployed'));
        expect(stdout, contains('7915fd821'));
        expect(stdout, contains('fix(gc): example commit'));
      });

      test('then stdout does not use wide tables', () {
        expect(stdout, isNot(contains('| Owner id')));
      });
    });

    group('when rendered for a suspended project', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          AdminUserStatusTextUi(utc: true),
          data: AdminUserStatusBuilder().withProjects([
            AdminUserProjectMembershipBuilder()
                .withSuspended(ProjectSuspensionReason.paymentOverdue)
                .withSuspendedAt(DateTime.utc(2024, 3, 4, 5, 6, 7)),
          ]).build(),
        );
        stdout = io.stdout;
      });

      test('then stdout shows when and why the project was suspended', () {
        expect(stdout, contains('suspended'));
        expect(stdout, contains('Suspended'));
        expect(stdout, contains('2024-03-04 05:06:07 (UTC)'));
        expect(stdout, contains('Reason'));
        expect(stdout, contains('paymentOverdue'));
      });
    });

    group('when rendered with a failed last deploy', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          AdminUserStatusTextUi(utc: false),
          data: AdminUserStatusBuilder().withProjects([
            AdminUserProjectMembershipBuilder().withLatestDeployAttempt(
              DeployAttemptBuilder()
                  .withFailedDeployment()
                  .withCommitHash('c2239a46b')
                  .build(),
            ),
          ]).build(),
        );
        stdout = io.stdout;
      });

      test('then stdout labels the deploy as failed', () {
        expect(stdout, contains('Failed'));
        expect(stdout, contains('c2239a46b'));
      });
    });

    group('when rendered with no projects', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          AdminUserStatusTextUi(utc: false),
          data: AdminUserStatusBuilder().withNoProjects().build(),
        );
        stdout = io.stdout;
      });

      test('then stdout contains the empty projects message', () {
        expect(stdout, contains('Projects'));
        expect(stdout, contains('none'));
      });
    });
  });

  group('Given an AdminUserListTextUi', () {
    group('when rendered with a user row', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          AdminUserListTextUi(utc: true),
          data: [
            {
              'email': 'ada@example.com',
              'accountStatus': UserAccountStatus.registered,
              'createdAt': DateTime.utc(2024, 12, 31, 10, 20, 30),
              'archivedAt': null,
              'subscribedPlans': ['starter'],
            },
          ],
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the table headings', () {
        expect(stdout, contains('User'));
        expect(stdout, contains('Account status'));
        expect(stdout, contains('Created at (UTC)'));
        expect(stdout, contains('Subscribed Plans'));
      });

      test('then stdout contains the user row', () {
        expect(stdout, contains('ada@example.com'));
        expect(stdout, contains('registered'));
        expect(stdout, contains('starter'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given an AdminInviteUserTextUi', () {
    group('when rendered', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const AdminInviteUserTextUi(),
          data: const <String, Object?>{},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the invite success message', () {
        expect(stdout, contains('User invited to Serverpod Cloud.'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given an AdminUserAttachTextUi', () {
    group('when rendered with assigned roles', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const AdminUserAttachTextUi(),
          data: const {
            'roles': ['admin'],
          },
        );
        stdout = io.stdout;
      });

      test('then stdout contains the attach success message', () {
        expect(
          stdout,
          contains('User attached to the project with roles: admin.'),
        );
      });
    });
  });

  group('Given an AdminUserDetachTextUi', () {
    group('when rendered after detaching all roles', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const AdminUserDetachTextUi(unassignAllRoles: true),
          data: const {
            'unassigned': ['admin'],
          },
        );
        stdout = io.stdout;
      });

      test('then stdout contains the detach-all success message', () {
        expect(
          stdout,
          contains(
            'Detached all access roles of the user from the project: admin',
          ),
        );
      });
    });

    group('when rendered with no roles to detach from all roles', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const AdminUserDetachTextUi(unassignAllRoles: true),
          data: const {'unassigned': <String>[]},
        );
        stdout = io.stdout;
      });

      test('then stdout contains the empty detach-all message', () {
        expect(
          stdout,
          contains('The user has no access roles to detach from the project.'),
        );
      });
    });

    group('when rendered with no matching role to detach', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const AdminUserDetachTextUi(unassignAllRoles: false),
          data: const {'unassigned': <String>[]},
        );
        stdout = io.stdout;
      });

      test('then stdout contains the empty specific-role message', () {
        expect(
          stdout,
          contains(
            'The user does not have any of the specified project roles.',
          ),
        );
      });
    });
  });
}
