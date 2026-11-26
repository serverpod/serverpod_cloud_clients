import 'package:config/config.dart' show CommandUsageException;

class CloudCliUsageException extends CommandUsageException {
  final String? hint;

  CloudCliUsageException(super.message, super.command, {this.hint});

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write(super.toString());
    if (hint != null) {
      buffer.write('\n$hint');
    }
    return buffer.toString();
  }
}
