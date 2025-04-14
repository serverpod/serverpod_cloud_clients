import 'package:cli_tools/cli_tools.dart';

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
