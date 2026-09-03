import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/user/user_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given a ProjectUserListTextUi', () {
    group('when rendered with a project user', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          ProjectUserListTextUi(projectId: 'my-project'),
          data: [
            UserBuilder().withEmail('ada@example.com').withMemberships([
              UserRoleMembershipBuilder()
                  .withRole(RoleBuilder().withName('admin').build())
                  .build(),
            ]).build(),
          ],
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the table headings', () {
        expect(stdout, contains('User'));
        expect(stdout, contains('Project'));
        expect(stdout, contains('Project roles'));
      });

      test('then stdout contains the user email', () {
        expect(stdout, contains('ada@example.com'));
      });

      test('then stdout contains the project id', () {
        expect(stdout, contains('my-project'));
      });

      test('then stdout contains the role name', () {
        expect(stdout, contains('admin'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given a ProjectUserInviteTextUi', () {
    group('when rendered after inviting a user', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const ProjectUserInviteTextUi(),
          data: const {
            'roles': ['admin'],
          },
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the invite success message', () {
        expect(
          stdout,
          contains('User invited to the project with roles: admin.'),
        );
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given a ProjectUserRevokeTextUi', () {
    group('when rendered after revoking all roles', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const ProjectUserRevokeTextUi(),
          data: const {
            'unassigned': ['admin'],
            'unassignAllRoles': true,
          },
        );
        stdout = io.stdout;
      });

      test('then stdout contains the revoke-all success message', () {
        expect(
          stdout,
          contains(
            'Revoked all access roles of the user from the project: admin',
          ),
        );
      });
    });

    group('when rendered when the user has no roles to revoke', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const ProjectUserRevokeTextUi(),
          data: const {'unassigned': <String>[], 'unassignAllRoles': true},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout reports that there are no roles to revoke', () {
        expect(
          stdout,
          contains('The user has no access roles to revoke on the project.'),
        );
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });
}
