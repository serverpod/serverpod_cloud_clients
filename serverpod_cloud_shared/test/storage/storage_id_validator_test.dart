import 'package:serverpod_cloud_shared/serverpod_cloud_shared.dart';
import 'package:test/test.dart';

void main() {
  group('Given no storage ids are taken', () {
    test('when the id is empty then it asks for one', () {
      expect(StorageIdValidator.validate(''), 'Enter a storage id.');
    });

    test('when the id is only whitespace then it asks for one', () {
      expect(StorageIdValidator.validate('   '), 'Enter a storage id.');
    });

    test('when the id is lowercase alphanumeric then it is valid', () {
      expect(StorageIdValidator.validate('uploads'), isNull);
    });

    test('when the id contains inner dashes then it is valid', () {
      expect(StorageIdValidator.validate('user-uploads-2'), isNull);
    });

    test('when the id is surrounded by whitespace then it reports the '
        'character rule', () {
      expect(
        StorageIdValidator.validate('  uploads  '),
        contains('lowercase letters'),
      );
    });

    test(
      'when the id contains uppercase then it reports the character rule',
      () {
        expect(
          StorageIdValidator.validate('Uploads'),
          contains('lowercase letters'),
        );
      },
    );

    test(
      'when the id starts with a dash then it reports the character rule',
      () {
        expect(
          StorageIdValidator.validate('-uploads'),
          contains('lowercase letters'),
        );
      },
    );

    test('when the id ends with a dash then it reports the character rule', () {
      expect(
        StorageIdValidator.validate('uploads-'),
        contains('lowercase letters'),
      );
    });

    test('when the id contains an underscore then it reports the character '
        'rule', () {
      expect(
        StorageIdValidator.validate('user_uploads'),
        contains('lowercase letters'),
      );
    });

    test('when the id is at the length limit then it is valid', () {
      expect(
        StorageIdValidator.validate('a' * StorageIdValidator.maxLength),
        isNull,
      );
    });

    test('when the id exceeds the length limit then it reports the limit', () {
      expect(
        StorageIdValidator.validate('a' * (StorageIdValidator.maxLength + 1)),
        contains('at most ${StorageIdValidator.maxLength} characters'),
      );
    });
  });

  group('Given the storage id is already taken', () {
    test('when validating then it reports the duplicate', () {
      expect(
        StorageIdValidator.validate('uploads', taken: {'uploads'}),
        'This project already has that storage id.',
      );
    });

    test('when a different id is validated then it is valid', () {
      expect(
        StorageIdValidator.validate('reports', taken: {'uploads'}),
        isNull,
      );
    });
  });

  group('Given isValid is used as a submit gate', () {
    test('when the id is valid then it returns true', () {
      expect(StorageIdValidator.isValid('uploads'), isTrue);
    });

    test('when the id is taken then it returns false', () {
      expect(
        StorageIdValidator.isValid('uploads', taken: {'uploads'}),
        isFalse,
      );
    });
  });
}
