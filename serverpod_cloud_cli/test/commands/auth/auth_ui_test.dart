import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/auth/auth_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given an AuthSessionListTextUi', () {
    group('when rendered with a session', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final createdAt = DateTime.utc(2024, 12, 31, 10, 20, 30);
        final io = await renderCommandUi(
          AuthSessionListTextUi(utc: true),
          data: [
            AuthTokenInfoBuilder()
                .withTokenId('tok-1')
                .withMethod('email')
                .withCreatedAt(createdAt)
                .withLastUsedAt(createdAt)
                .withExpiresAt(DateTime.utc(2025, 1, 31, 10, 20, 30))
                .withExpireAfterUnusedFor(const Duration(days: 30))
                .build(),
          ],
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the table headings', () {
        expect(stdout, contains('Token Id'));
        expect(stdout, contains('Method'));
        expect(stdout, contains('Created'));
      });

      test('then stdout contains the token id', () {
        expect(stdout, contains('tok-1'));
      });

      test('then stdout contains the auth method', () {
        expect(stdout, contains('email'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given an AuthCreateTokenTextUi', () {
    group('when rendered after creating a token', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const AuthCreateTokenTextUi(baseCommand: 'scloud'),
          data: const {'token': 'secret-token'},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the success message', () {
        expect(stdout, contains('Successfully created an API token.'));
      });

      test('then stdout contains the one-time token', () {
        expect(stdout, contains('The token is only visible once:'));
        expect(stdout, contains('secret-token'));
      });

      test('then stdout mentions scloud authentication', () {
        expect(stdout, contains('scloud commands'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given an AuthLogoutTextUi', () {
    group('when rendered with no stored credentials', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const AuthLogoutTextUi(),
          data: const {'hadCredentials': false},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout reports that no credentials were found', () {
        expect(
          stdout,
          contains('No stored Serverpod Cloud credentials found.'),
        );
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered after logging out selected sessions', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const AuthLogoutTextUi(),
          data: const {'currentSessionLoggedOut': false},
        );
        stdout = io.stdout;
      });

      test('then stdout reports logout of the selected sessions', () {
        expect(
          stdout,
          contains('Successfully logged out the selected sessions.'),
        );
      });
    });

    group('when rendered after logging out the current session', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const AuthLogoutTextUi(),
          data: const {'currentSessionLoggedOut': true},
        );
        stdout = io.stdout;
      });

      test('then stdout reports logout from Serverpod Cloud', () {
        expect(
          stdout,
          contains('Successfully logged out from Serverpod Cloud.'),
        );
      });
    });
  });

  group('Given an AuthRevokeTokenTextUi', () {
    group('when rendered after revoking another session', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const AuthRevokeTokenTextUi(),
          data: const {'currentSessionRevoked': false},
        );
        stdout = io.stdout;
      });

      test('then stdout reports logout of the selected sessions', () {
        expect(
          stdout,
          contains('Successfully logged out the selected sessions.'),
        );
      });
    });

    group('when rendered after revoking the current session', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const AuthRevokeTokenTextUi(),
          data: const {'currentSessionRevoked': true},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout reports logout from Serverpod cloud', () {
        expect(
          stdout,
          contains('Successfully logged out from Serverpod cloud.'),
        );
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });
}
