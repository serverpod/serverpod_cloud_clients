import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/shared/base_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/shared/helpers/common_client_exception_view.dart';
import 'package:serverpod_cloud_cli/shared/helpers/common_exceptions_handler.dart';
import 'package:test/test.dart';

void main() {
  const consoleUrl = HostConstants.serverpodCloudConsole;

  group('Given a ServerpodClientUnauthorized', () {
    test('when describing it then the credentials-invalid copy is used', () {
      final view = CommonClientExceptionView.tryDescribe(
        ServerpodClientUnauthorized(),
        baseCommand: defaultBaseCommand,
      );

      expect(view, isNotNull);
      expect(
        view?.message,
        'The credentials for this session seem to no longer be valid.',
      );
      expect(
        view?.exitReason,
        'The credentials for this session seem to no longer be valid.',
      );
    });

    test(
      'when describing it then the re-auth commands use the base command',
      () {
        final view = CommonClientExceptionView.tryDescribe(
          ServerpodClientUnauthorized(),
          baseCommand: 'xcloud',
        );

        expect(view?.commandHints, hasLength(2));
        expect(
          view?.commandHints[0].message,
          'Run the following commands to re-authenticate:',
        );
        expect(view?.commandHints[0].command, 'xcloud auth logout');
        expect(view?.commandHints[1].message, isNull);
        expect(view?.commandHints[1].command, 'xcloud auth login');
      },
    );
  });

  group('Given an UnauthorizedException', () {
    test('when describing it then the unauthorized copy is used', () {
      final view = CommonClientExceptionView.tryDescribe(
        UnauthorizedException(message: 'some error'),
        baseCommand: defaultBaseCommand,
      );

      expect(view?.message, 'You are not authorized to perform this action.');
      expect(
        view?.exitReason,
        'You are not authorized to perform this action.',
      );
      expect(view?.hint, isNull);
      expect(view?.commandHints, isEmpty);
    });
  });

  group('Given a ProcurementDeniedException whose message matches the '
      'payment-method phrase but whose reason is unrelated', () {
    test('when describing it then the message match wins over the reason '
        'and the payment-method copy is used', () {
      final view = CommonClientExceptionView.tryDescribe(
        ProcurementDeniedException(
          message: 'Owner has no valid payment method on file.',
          reason: ProcurementDeniedReason.tooManyProjects,
        ),
        baseCommand: defaultBaseCommand,
      );

      expect(view?.message, 'You need a payment method!');
      expect(view?.exitReason, 'The procurement was not allowed.');
      expect(
        view?.hint,
        'To set up your account, visit: $consoleUrl/project/create\n',
      );
      expect(view?.newParagraph, isTrue);
      expect(view?.attachCauseToExit, isFalse);
    });
  });

  group('Given a ProcurementDeniedException for unavailable backups', () {
    test('when describing it then the Growth-plan hint is used', () {
      final view = CommonClientExceptionView.tryDescribe(
        ProcurementDeniedException(
          message: "Database backup is not available for this project's plan.",
          reason: ProcurementDeniedReason.productNotAvailable,
        ),
        baseCommand: defaultBaseCommand,
      );

      expect(
        view?.message,
        "Database backup is not available for this project's plan.",
      );
      expect(view?.exitReason, 'The procurement was not allowed.');
      expect(
        view?.hint,
        'Database backups are available on the Growth plan. '
        'To upgrade the plan, visit: $consoleUrl/project\n',
      );
      expect(view?.newParagraph, isTrue);
      expect(view?.attachCauseToExit, isFalse);
    });
  });

  group('Given a ProcurementDeniedException for too many projects', () {
    test(
      'when describing it then the exception message and account URL are used',
      () {
        final view = CommonClientExceptionView.tryDescribe(
          ProcurementDeniedException(
            message:
                'The maximum number of projects that can be created has been reached (5).',
            reason: ProcurementDeniedReason.tooManyProjects,
          ),
          baseCommand: defaultBaseCommand,
        );

        expect(
          view?.message,
          'The maximum number of projects that can be created has been reached (5).',
        );
        expect(view?.exitReason, 'The procurement was not allowed.');
        expect(view?.hint, 'To see your account, visit: $consoleUrl/project\n');
        expect(view?.newParagraph, isTrue);
        expect(view?.attachCauseToExit, isFalse);
      },
    );
  });

  group('Given a NotFoundException', () {
    test(
      'when describing it then the not-found copy uses the exception message as hint',
      () {
        final view = CommonClientExceptionView.tryDescribe(
          NotFoundException(message: 'No such project.'),
          baseCommand: defaultBaseCommand,
        );

        expect(view?.message, 'The requested resource did not exist.');
        expect(view?.exitReason, 'The requested resource did not exist.');
        expect(view?.hint, 'No such project.');
        expect(view?.newParagraph, isFalse);
      },
    );
  });

  group('Given a ProcurementDeniedException', () {
    test(
      'when getting the exit exception then the causing exception is not nested',
      () {
        final stackTrace = StackTrace.current;

        expect(
          commonClientExceptionExit(
            ProcurementDeniedException(
              message:
                  'The maximum number of projects that can be created has been reached (5).',
              reason: ProcurementDeniedReason.tooManyProjects,
            ),
            stackTrace,
          ),
          isA<ErrorExitException>()
              .having(
                (final e) => e.reason,
                'reason',
                'The procurement was not allowed.',
              )
              .having((final e) => e.nestedException, 'nestedException', isNull)
              .having(
                (final e) => e.nestedStackTrace,
                'nestedStackTrace',
                isNull,
              ),
        );
      },
    );
  });

  group('Given a NotFoundException', () {
    test('when getting the exit exception '
        'then the causing exception and stack trace are nested', () {
      final stackTrace = StackTrace.current;
      final exception = NotFoundException(message: 'No such project.');

      expect(
        commonClientExceptionExit(exception, stackTrace),
        isA<ErrorExitException>()
            .having(
              (final e) => e.reason,
              'reason',
              'The requested resource did not exist.',
            )
            .having(
              (final e) => e.nestedException,
              'nestedException',
              same(exception),
            )
            .having(
              (final e) => e.nestedStackTrace,
              'nestedStackTrace',
              same(stackTrace),
            ),
      );
    });
  });

  group('Given an exception that is not commonly handled', () {
    test('when describing it then the result is null', () {
      expect(
        CommonClientExceptionView.tryDescribe(
          Exception(),
          baseCommand: defaultBaseCommand,
        ),
        isNull,
      );
    });
  });
}
