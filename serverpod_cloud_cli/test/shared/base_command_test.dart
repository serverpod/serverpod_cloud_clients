import 'package:serverpod_cloud_cli/shared/base_command.dart';
import 'package:test/test.dart';

void main() {
  group('Given no base command name', () {
    test('when resolving the invocation then it is scloud', () {
      expect(BaseCommandInvocation.from(null), BaseCommandInvocation.scloud);
    });
  });

  group('Given an empty base command name', () {
    test('when resolving the invocation then it is scloud', () {
      expect(BaseCommandInvocation.from(''), BaseCommandInvocation.scloud);
    });
  });

  group('Given a known base command name', () {
    test('when resolving the invocation then it is serverpod cloud', () {
      expect(
        BaseCommandInvocation.from('serverpod cloud'),
        BaseCommandInvocation.serverpodCloud,
      );
    });

    test('when resolving the invocation then it is xcloud', () {
      expect(
        BaseCommandInvocation.from('xcloud'),
        BaseCommandInvocation.xcloud,
      );
    });
  });

  group('Given a known base command name with padding and mixed case', () {
    test('when resolving the invocation then it is normalized', () {
      expect(
        BaseCommandInvocation.from('  Serverpod Cloud '),
        BaseCommandInvocation.serverpodCloud,
      );
    });
  });

  group('Given an unknown base command name', () {
    test('when resolving the invocation then it is other', () {
      expect(
        BaseCommandInvocation.from('my wrapper'),
        BaseCommandInvocation.other,
      );
    });

    test('when reporting the invocation then the raw name is not used', () {
      expect(BaseCommandInvocation.from('my wrapper').reportedName, 'other');
    });
  });
}
