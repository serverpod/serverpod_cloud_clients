import 'package:cli_tools/cli_tools.dart';

/// Thrown to indicate that the process shall exit in orderly fashion
/// with an error code.
///
/// An optional technical reason and causing exception can be provided.
/// This is not output to the user, but aids in testing and debugging.
///
/// Business logic such as command implementations should avoid using this
/// directly.
/// If the user aborted, throw [UserAbortException].
/// If an operation failed, throw [FailureException].
class ErrorExitException extends ExitException {
  final String? reason;

  final Object? nestedException;
  final StackTrace? nestedStackTrace;

  /// Creates an [ErrorExitException].
  /// Provide a reason and causing exception if available
  /// which aids in testing and debugging.
  ErrorExitException([this.reason, this.nestedException, this.nestedStackTrace])
    : super.error();

  /// Creates an [ErrorExitException] with a specific exit code.
  ErrorExitException.code(super.code, [this.reason])
    : nestedException = null,
      nestedStackTrace = null;

  @override
  String toString() {
    final reasonStr = reason == null ? '' : ': $reason';
    final str = '$runtimeType$reasonStr';
    if (nestedException == null) {
      return str;
    }
    if (nestedStackTrace == null) {
      return '$str\n  nested exception is: $nestedException';
    }
    return '$str\n  nested exception is: $nestedException\n$nestedStackTrace';
  }
}

/// An [ErrorExitException] caused by an exception that the CLI code
/// did not anticipate.
///
/// Indicates a potential internal error in the CLI or Serverpod Cloud,
/// rather than a failure the user can correct.
/// Errors of this type are eligible for diagnostics reporting.
class UnexpectedErrorExitException extends ErrorExitException {
  UnexpectedErrorExitException([
    super.reason,
    super.nestedException,
    super.nestedStackTrace,
  ]);
}

/// Indicates that we are existing with an error code since the user
/// has aborted the operation / command.
class UserAbortException extends ErrorExitException {
  UserAbortException() : super('User aborted');
}

/// Indicates failure of an operation / command.
///
/// Includes user-friendly error messages for the failure
/// and hints if available. These should be shown to the user.
///
/// A technical reason and causing exception is also included
/// to aid in testing and debugging.
class FailureException extends ExitException {
  /// The error messages for this failure, if any, in a user-friendly format.
  final List<String> errors;

  /// The user hint relevant for this failure, if any.
  final String? hint;

  /// The technical reason for this failure, if known.
  /// Might be technical rather than user-friendly.
  final String? reason;

  /// The exception that caused this failure, if any.
  final Exception? nestedException;

  /// The stack trace of the exception that caused this failure, if any.
  final StackTrace? nestedStackTrace;

  /// Creates a [FailureException].
  ///
  /// Provide user-friendly error messages and hints if possible.
  ///
  /// Provide a reason and causing exception if available
  /// which aids in testing and debugging.
  FailureException({
    String? error,
    Iterable<String>? errors,
    this.hint,
    this.reason,
    this.nestedException,
    this.nestedStackTrace,
  }) : errors = [?error, ...?errors],
       super.error();

  /// Simplified factory constructor for a [FailureException] with a nested
  /// exception.
  /// If the nested exception is a [FailureException] it is returned as is.
  factory FailureException.nested(
    Exception nestedException, [
    StackTrace? nestedStackTrace,
    String? error,
    String? hint,
  ]) {
    if (nestedException is FailureException) {
      return nestedException;
    }
    return FailureException(
      error: error,
      hint: hint,
      nestedException: nestedException,
      nestedStackTrace: nestedStackTrace,
    );
  }

  @override
  String toString() {
    final message = [...errors, if (reason != null) reason].join('\n');
    final str = '$runtimeType: $message';

    if (nestedException == null) {
      return str;
    }
    if (nestedStackTrace == null) {
      return '$str\n  nested exception is: $nestedException';
    }
    return '$str\n  nested exception is: $nestedException\n$nestedStackTrace';
  }
}
