import 'package:cli_tools/cli_tools.dart';

class ErrorExitException extends ExitException {
  ErrorExitException() : super.error();
}
