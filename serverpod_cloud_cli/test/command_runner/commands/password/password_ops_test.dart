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

    group('when getting the platform-managed names', () {
      test('then it contains the platform-generated passwords', () {
        expect(
          PasswordDefinitions.platformManagedNames,
          containsAll(['database', 'serviceSecret', 'scloudAuthEmailKey']),
        );
      });

      test('then it excludes the user-supplied known passwords', () {
        expect(
          PasswordDefinitions.platformManagedNames,
          isNot(contains('AWSAccessKeyId')),
        );
        expect(
          PasswordDefinitions.platformManagedNames,
          isNot(contains('serverpod_auth_googleClientSecret')),
        );
      });
    });
  });
}
