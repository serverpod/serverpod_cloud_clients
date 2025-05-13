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
  ErrorExitException([
    this.reason,
    this.nestedException,
    this.nestedStackTrace,
  ]) : super.error();

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
    final String? error,
    final Iterable<String>? errors,
    this.hint,
    this.reason,
    this.nestedException,
    this.nestedStackTrace,
  })  : errors = [if (error != null) error, ...?errors],
        super.error();

  /// Simplified factory constructor for a [FailureException] with a nested
  /// exception.
  /// If the nested exception is a [FailureException] it is returned as is.
  factory FailureException.nested(
    final Exception nestedException, [
    final StackTrace? nestedStackTrace,
    final String? error,
    final String? hint,
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
    final message = [
      ...errors,
      if (reason != null) reason,
    ].join('\n');
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
