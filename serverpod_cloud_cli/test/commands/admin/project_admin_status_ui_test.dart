import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/projects/project_admin_status_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given an AdminProjectStatusTextUi', () {
    group('when rendered with role memberships and deploy info', () {
      test('then stdout lists each role with member emails', () async {
        final io = await renderCommandUi(
          AdminProjectStatusTextUi(utc: true),
          data: AdminProjectInfoBuilder()
              .withProjectInfo(
                ProjectInfoBuilder().withProject(
                  ProjectBuilder().withCloudProjectId('my-project').withRoles([
                    RoleBuilder.admin()
                        .withUser(
                          UserBuilder().withEmail('ada@example.com').build(),
                        )
                        .build(),
                    RoleBuilder()
                        .withRoleName(ProjectRole.unknown)
                        .withUser(
                          UserBuilder().withEmail('bob@example.com').build(),
                        )
                        .build(),
                  ]),
                ),
              )
              .build(),
        );

        expect(io.stdout, contains('admin: ada@example.com'));
        expect(io.stdout, contains('unknown: bob@example.com'));
      });

      test('then stdout contains the orb subscription link', () async {
        final io = await renderCommandUi(
          AdminProjectStatusTextUi(utc: true),
          data: AdminProjectInfoBuilder().build(),
        );

        expect(
          io.stdout,
          contains('https://app.withorb.com/subscriptions/orb_sub_test'),
        );
      });

      test('then stdout contains the latest deploy commit line', () async {
        final io = await renderCommandUi(
          AdminProjectStatusTextUi(utc: true),
          data: AdminProjectInfoBuilder()
              .withLatestDeployAttempt(
                DeployAttemptBuilder()
                    .withSuccessfulDeployment()
                    .withCommitHash('7915fd821')
                    .withCommitMessage('fix(gc): example commit')
                    .build(),
              )
              .build(),
        );

        expect(io.stdout, contains('Deployed'));
        expect(io.stdout, contains('7915fd821'));
        expect(io.stdout, contains('fix(gc): example commit'));
      });
    });

    group('when rendered with no role memberships', () {
      test('then the roles row shows none', () async {
        final io = await renderCommandUi(
          AdminProjectStatusTextUi(utc: true),
          data: AdminProjectInfoBuilder()
              .withProjectInfo(
                ProjectInfoBuilder().withProject(
                  ProjectBuilder()
                      .withCloudProjectId('my-project')
                      .withRoles([]),
                ),
              )
              .build(),
        );

        expect(io.stdout, contains('Roles'));
        expect(io.stdout, contains('none'));
      });
    });

    group('when rendered with no billing subscription', () {
      test('then the billing row shows none', () async {
        final io = await renderCommandUi(
          AdminProjectStatusTextUi(utc: true),
          data: AdminProjectInfoBuilder()
              .withPlanProductId('')
              .withSubscriptionId('')
              .withBillingPlanId(null)
              .build(),
        );

        expect(io.stdout, contains('Billing'));
        expect(io.stdout, contains('none'));
      });
    });

    group('when rendered for an active project', () {
      test(
        'then stdout shows the status and omits suspension details',
        () async {
          final io = await renderCommandUi(
            AdminProjectStatusTextUi(utc: true),
            data: AdminProjectInfoBuilder()
                .withStatus(ProjectLifecycleStatus.active)
                .build(),
          );

          expect(io.stdout, contains('Phase'));
          expect(io.stdout, contains('active'));
          expect(io.stdout, isNot(contains('Suspended')));
          expect(io.stdout, isNot(contains('Reason')));
        },
      );
    });

    group('when rendered for a suspended project', () {
      test('then stdout shows when and why it was suspended', () async {
        final io = await renderCommandUi(
          AdminProjectStatusTextUi(utc: true),
          data: AdminProjectInfoBuilder()
              .withSuspended(ProjectSuspensionReason.paymentOverdue)
              .withSuspendedAt(DateTime.utc(2024, 3, 4, 5, 6, 7))
              .build(),
        );

        expect(io.stdout, contains('suspended'));
        expect(io.stdout, contains('Suspended'));
        expect(io.stdout, contains('2024-03-04 05:06:07 (UTC)'));
        expect(io.stdout, contains('Reason'));
        expect(io.stdout, contains('paymentOverdue'));
      });
    });

    group('when rendered with a role that has no members', () {
      test('then the role is listed with a dash', () async {
        final io = await renderCommandUi(
          AdminProjectStatusTextUi(utc: true),
          data: AdminProjectInfoBuilder()
              .withProjectInfo(
                ProjectInfoBuilder().withProject(
                  ProjectBuilder().withCloudProjectId('my-project').withRoles([
                    RoleBuilder.admin().withMemberships(const []).build(),
                  ]),
                ),
              )
              .build(),
        );

        expect(io.stdout, contains('admin: —'));
      });
    });
  });
}
