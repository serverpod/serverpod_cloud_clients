import 'package:serverpod_cloud_cli/command_runner/commands/admin/notification/notification_admin_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given a PushNotificationTextUi', () {
    group('when rendered after pushing a notification', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const PushNotificationTextUi(),
          data: const {'notificationType': 'test'},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout confirms the notification type', () {
        expect(stdout, contains('Pushed an example test notification.'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });
}
