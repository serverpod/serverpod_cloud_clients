import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart' show UsageException;
import 'package:ground_control_client/ground_control_client.dart'
    show InvalidValueException;
import 'package:serverpod_cloud_cli/shared/error_reporting/sentry_error_reporter.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';

void main() {
  group('SentryErrorReporter.isReportable -', () {
    test('Given an UnexpectedErrorExitException '
        'then it is reportable', () {
      expect(
        SentryErrorReporter.isReportable(UnexpectedErrorExitException()),
        isTrue,
      );
    });

    test('Given an ErrorExitException '
        'then it is not reportable', () {
      expect(SentryErrorReporter.isReportable(ErrorExitException()), isFalse);
    });

    test('Given a UserAbortException '
        'then it is not reportable', () {
      expect(SentryErrorReporter.isReportable(UserAbortException()), isFalse);
    });

    test('Given a FailureException '
        'then it is not reportable', () {
      expect(SentryErrorReporter.isReportable(FailureException()), isFalse);
    });

    test('Given a UsageException '
        'then it is not reportable', () {
      expect(
        SentryErrorReporter.isReportable(UsageException('invalid', 'usage')),
        isFalse,
      );
    });

    test('Given a StateError '
        'then it is reportable', () {
      expect(SentryErrorReporter.isReportable(StateError('bug')), isTrue);
    });

    test('Given an unrecognized Exception '
        'then it is reportable', () {
      expect(SentryErrorReporter.isReportable(Exception('unknown')), isTrue);
    });

    test('Given an UnexpectedErrorExitException '
        'with a nested StateError '
        'then it is reportable', () {
      expect(
        SentryErrorReporter.isReportable(
          UnexpectedErrorExitException('reason', StateError('bug')),
        ),
        isTrue,
      );
    });

    test('Given an UnexpectedErrorExitException '
        'with a nested SocketException '
        'then it is not reportable', () {
      expect(
        SentryErrorReporter.isReportable(
          UnexpectedErrorExitException(
            'reason',
            const SocketException('connection refused'),
          ),
        ),
        isFalse,
      );
    });

    test('Given an UnexpectedErrorExitException '
        'with a nested FileSystemException '
        'then it is not reportable', () {
      expect(
        SentryErrorReporter.isReportable(
          UnexpectedErrorExitException(
            'reason',
            const FileSystemException('read-only'),
          ),
        ),
        isFalse,
      );
    });

    test('Given an UnexpectedErrorExitException '
        'with a nested TimeoutException '
        'then it is not reportable', () {
      expect(
        SentryErrorReporter.isReportable(
          UnexpectedErrorExitException('reason', TimeoutException('timed out')),
        ),
        isFalse,
      );
    });

    test('Given an UnexpectedErrorExitException '
        'with a nested FormatException '
        'then it is not reportable', () {
      expect(
        SentryErrorReporter.isReportable(
          UnexpectedErrorExitException(
            'reason',
            const FormatException('bad yaml'),
          ),
        ),
        isFalse,
      );
    });

    test('Given an UnexpectedErrorExitException '
        'with a nested SerializableException '
        'then it is not reportable', () {
      expect(
        SentryErrorReporter.isReportable(
          UnexpectedErrorExitException(
            'reason',
            InvalidValueException(message: 'Invalid username bob@example.com'),
          ),
        ),
        isFalse,
      );
    });

    test('Given a raw SerializableException '
        'then it is not reportable', () {
      expect(
        SentryErrorReporter.isReportable(
          InvalidValueException(message: 'Invalid username bob@example.com'),
        ),
        isFalse,
      );
    });

    test('Given a raw SocketException '
        'then it is not reportable', () {
      expect(
        SentryErrorReporter.isReportable(
          const SocketException('connection refused'),
        ),
        isFalse,
      );
    });

    test('Given a raw FormatException '
        'then it is not reportable', () {
      expect(
        SentryErrorReporter.isReportable(const FormatException('bad input')),
        isFalse,
      );
    });
  });

  group('SentryErrorReporter.forCli -', () {
    test('Given the CLI reporter '
        'then it uses the CLI DSN', () {
      expect(SentryErrorReporter.forCli().dsn, SentryErrorReporter.cliDsn);
    });

    test('Given the CLI reporter '
        'then the environment defaults to dev', () {
      expect(SentryErrorReporter.forCli().environment, 'dev');
    });

    test('Given the CLI reporter '
        'then the release identifies the CLI package and version', () {
      expect(
        SentryErrorReporter.forCli().release,
        matches(RegExp(r'^serverpod_cloud_cli@\d+\.\d+\.\d+')),
      );
    });
  });

  group('SentryErrorReporter.environmentFromApiServerUrl -', () {
    test('Given the production API server URL '
        'then the environment is prod', () {
      expect(
        SentryErrorReporter.environmentFromApiServerUrl(
          'https://api.serverpod.dev',
        ),
        'prod',
      );
    });

    test('Given a preview API server URL '
        'then the environment is preview', () {
      expect(
        SentryErrorReporter.environmentFromApiServerUrl(
          'https://preview-1234.api.ground-control-dev.serverpod.xyz',
        ),
        'preview',
      );
    });

    test('Given a localhost API server URL '
        'then the environment is dev', () {
      expect(
        SentryErrorReporter.environmentFromApiServerUrl(
          'http://localhost:8080',
        ),
        'dev',
      );
    });

    test('Given an unparsable API server URL '
        'then the environment is dev', () {
      expect(
        SentryErrorReporter.environmentFromApiServerUrl('::not a url::'),
        'dev',
      );
    });
  });

  group('SentryErrorReporter.apiServerUrl -', () {
    test('Given a reporter '
        'when setting the production API server URL '
        'then the environment becomes prod', () {
      final reporter = SentryErrorReporter.forCli();

      reporter.apiServerUrl = 'https://api.serverpod.dev';

      expect(reporter.environment, 'prod');
    });
  });

  group('SentryErrorReporter.report -', () {
    final capturedErrors = <Object>[];
    final capturedStackTraces = <StackTrace>[];

    Future<void> recordingCapture(
      final Object error,
      final StackTrace stackTrace,
    ) async {
      capturedErrors.add(error);
      capturedStackTraces.add(stackTrace);
    }

    SentryErrorReporter createReporter({
      final String dsn = 'https://key@sentry.example.com/1',
      final Duration flushTimeout = const Duration(seconds: 3),
      final SentryCapture? captureOverride,
    }) {
      return SentryErrorReporter(
        dsn: dsn,
        release: 'serverpod_cloud_cli@0.0.0',
        flushTimeout: flushTimeout,
        captureOverride: captureOverride ?? recordingCapture,
      );
    }

    setUp(() {
      capturedErrors.clear();
      capturedStackTraces.clear();
    });

    group('Given consent is not resolved', () {
      test('when reporting a reportable error '
          'then nothing is captured', () async {
        final reporter = createReporter();

        await reporter.report(StateError('bug'), StackTrace.current);

        expect(capturedErrors, isEmpty);
      });
    });

    group('Given consent is declined', () {
      test('when reporting a reportable error '
          'then nothing is captured', () async {
        final reporter = createReporter();
        reporter.analyticsConsent = false;

        await reporter.report(StateError('bug'), StackTrace.current);

        expect(capturedErrors, isEmpty);
      });
    });

    group('Given consent is revoked after being granted', () {
      test('when reporting a reportable error '
          'then nothing is captured', () async {
        final reporter = createReporter();
        reporter.analyticsConsent = true;
        reporter.analyticsConsent = false;

        await reporter.report(StateError('bug'), StackTrace.current);

        expect(capturedErrors, isEmpty);
      });
    });

    group('Given consent is granted', () {
      test('when reporting a reportable error '
          'then the error is captured', () async {
        final reporter = createReporter();
        reporter.analyticsConsent = true;
        final error = StateError('bug');

        await reporter.report(error, StackTrace.current);

        expect(capturedErrors, equals([error]));
      });

      test('when reporting an UnexpectedErrorExitException '
          'with a nested exception '
          'then the nested exception is captured', () async {
        final reporter = createReporter();
        reporter.analyticsConsent = true;
        final nested = Exception('root cause');
        final error = UnexpectedErrorExitException('reason', nested);

        await reporter.report(error, StackTrace.current);

        expect(capturedErrors, equals([nested]));
      });

      test('when reporting an UnexpectedErrorExitException '
          'with a nested stack trace '
          'then the nested stack trace is captured', () async {
        final reporter = createReporter();
        reporter.analyticsConsent = true;
        final nestedStackTrace = StackTrace.current;
        final error = UnexpectedErrorExitException(
          'reason',
          Exception('root cause'),
          nestedStackTrace,
        );

        await reporter.report(error, StackTrace.current);

        expect(capturedStackTraces, equals([nestedStackTrace]));
      });

      test('when reporting an UnexpectedErrorExitException '
          'without a nested exception '
          'then the exception itself is captured', () async {
        final reporter = createReporter();
        reporter.analyticsConsent = true;
        final error = UnexpectedErrorExitException('reason');

        await reporter.report(error, StackTrace.current);

        expect(capturedErrors, equals([error]));
      });

      test('when reporting an ErrorExitException '
          'then nothing is captured', () async {
        final reporter = createReporter();
        reporter.analyticsConsent = true;

        await reporter.report(ErrorExitException(), StackTrace.current);

        expect(capturedErrors, isEmpty);
      });

      test('when reporting a UsageException '
          'then nothing is captured', () async {
        final reporter = createReporter();
        reporter.analyticsConsent = true;

        await reporter.report(
          UsageException('invalid', 'usage'),
          StackTrace.current,
        );

        expect(capturedErrors, isEmpty);
      });

      test('when the capture never completes '
          'then report completes after the flush timeout', () async {
        final reporter = createReporter(
          flushTimeout: const Duration(milliseconds: 50),
          captureOverride: (final error, final stackTrace) =>
              Completer<void>().future,
        );
        reporter.analyticsConsent = true;
        final stopwatch = Stopwatch()..start();

        await expectLater(
          reporter.report(StateError('bug'), StackTrace.current),
          completes,
        );

        expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
      });

      test('when the capture throws '
          'then report completes normally', () async {
        final reporter = createReporter(
          captureOverride: (final error, final stackTrace) =>
              throw StateError('sentry is broken'),
        );
        reporter.analyticsConsent = true;

        await expectLater(
          reporter.report(StateError('bug'), StackTrace.current),
          completes,
        );
      });
    });

    group('Given consent is granted and the DSN is empty', () {
      test('when reporting a reportable error '
          'then nothing is captured', () async {
        final reporter = createReporter(dsn: '');
        reporter.analyticsConsent = true;

        await reporter.report(StateError('bug'), StackTrace.current);

        expect(capturedErrors, isEmpty);
      });
    });
  });
}
