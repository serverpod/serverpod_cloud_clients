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
}
