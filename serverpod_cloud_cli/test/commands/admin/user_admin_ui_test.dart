import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/users/user_admin_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
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
