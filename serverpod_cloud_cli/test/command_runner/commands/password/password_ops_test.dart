import 'package:test/test.dart';

import 'package:serverpod_cloud_cli/command_runner/commands/password/password_ops.dart';

void main() {
  group('Given PasswordDefinitions', () {
    group('when getting the category of scloudAuthEmailKey', () {
      test('then it is Auth', () {
        expect(
          PasswordDefinitions.getCategory('scloudAuthEmailKey'),
          PasswordCategory.auth,
        );
      });
    });

    group('when getting the category of an unknown password', () {
      test('then it is Custom', () {
        expect(
          PasswordDefinitions.getCategory('myCustomPassword'),
          PasswordCategory.custom,
        );
      });
    });
  });
}
