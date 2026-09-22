import 'package:serverpod_cloud_shared/serverpod_cloud_shared.dart';
import 'package:test/test.dart';

void main() {
  group('Given an address with a local part and a domain', () {
    test('when checking it then it looks valid', () {
      expect(EmailValidator.looksValid('colleague@example.com'), isTrue);
    });

    test('when the domain is not ascii then it looks valid', () {
      expect(EmailValidator.looksValid('user@münchen.de'), isTrue);
    });

    test('when the domain has no dot then it looks valid', () {
      expect(EmailValidator.looksValid('user@localhost'), isTrue);
    });

    test('when it is padded with whitespace then it looks valid', () {
      expect(EmailValidator.looksValid('  user@example.com  '), isTrue);
    });
  });

  group('Given an input that cannot be an address', () {
    test('when it is empty then it does not look valid', () {
      expect(EmailValidator.looksValid(''), isFalse);
    });

    test('when there is no at sign then it does not look valid', () {
      expect(EmailValidator.looksValid('example.com'), isFalse);
    });

    test('when the local part is missing then it does not look valid', () {
      expect(EmailValidator.looksValid('@example.com'), isFalse);
    });

    test('when the domain is missing then it does not look valid', () {
      expect(EmailValidator.looksValid('user@'), isFalse);
    });

    test('when there is more than one at sign then it does not look valid', () {
      expect(EmailValidator.looksValid('user@host@example.com'), isFalse);
    });

    test('when it contains inner whitespace then it does not look valid', () {
      expect(EmailValidator.looksValid('user name@example.com'), isFalse);
    });
  });
}
