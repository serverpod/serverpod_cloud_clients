import 'package:args/command_runner.dart';

class CloudCliUsageException extends UsageException {
  final String? hint;

  CloudCliUsageException(final String message, {this.hint})
      : super(message, '');

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write(message);
    if (hint != null) {
      buffer.write('\n$hint');
    }
    if (usage != '') {
      buffer.writeln('\n\n$usage');
    }
    return buffer.toString();
  }
}
