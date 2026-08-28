import 'package:ground_control_client/ground_control_client.dart'
    show ServerpodClientException;
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/dart_version_util.dart';
import 'package:test/test.dart';

void main() {
  group('fetchSupportedDartSdkVersions', () {
    final client = ClientMock();

    setUp(() {
      reset(client.platform);
    });

    test('Given a served policy with supported versions '
        'when fetchSupportedDartSdkVersions is called '
        'then the supported versions are returned', () async {
      when(() => client.platform.getDartSdkVersionPolicy()).thenAnswer(
        (final _) async => DartSdkVersionPolicyBuilder().withSupportedVersions([
          '3.8',
          '3.9',
        ]).build(),
      );

      await expectLater(
        fetchSupportedDartSdkVersions(client),
        completion(['3.8', '3.9']),
      );
    });

    group('Given the policy fetch throws '
        'when fetchSupportedDartSdkVersions is called', () {
      setUp(() {
        when(
          () => client.platform.getDartSdkVersionPolicy(),
        ).thenThrow(ServerpodClientException('connection failed', 500));
      });

      test('then FailureException is thrown', () async {
        await expectLater(
          fetchSupportedDartSdkVersions(client),
          throwsA(isA<FailureException>()),
        );
      });

      test('then the hint states that the fault is not the project', () async {
        await expectLater(
          fetchSupportedDartSdkVersions(client),
          throwsA(
            isA<FailureException>().having(
              (final e) => e.hint,
              'hint',
              contains('not with your project'),
            ),
          ),
        );
      });
    });
  });

  group('ensureValidVersionConstraint', () {
    test('Given concrete versions and pub constraints '
        'when ensureValidVersionConstraint is called '
        'then it completes normally', () {
      for (final s in [
        '3.9.0',
        '3.8.0',
        '3.7.0',
        '3.12.0',
        '^3.10.0',
        '>=3.9.0 <4.0.0',
      ]) {
        expect(() => ensureValidVersionConstraint(s), returnsNormally);
      }
    });

    test('Given a non-parseable string '
        'when ensureValidVersionConstraint is called '
        'then FailureException is thrown', () {
      expect(
        () => ensureValidVersionConstraint('not-a-version'),
        throwsA(isA<FailureException>()),
      );
    });

    test('Given a non-parseable string '
        'when ensureValidVersionConstraint is called '
        'then the hint references the Dart SDK docs', () {
      try {
        ensureValidVersionConstraint('oops');
        fail('Expected FailureException');
      } on FailureException catch (e) {
        expect(e.hint, contains('Use a valid pub-style constraint'));
      }
    });
  });
}
