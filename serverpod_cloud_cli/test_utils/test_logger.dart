import 'dart:async';

import 'package:cli_tools/logger.dart';

class TestLogger extends VoidLogger {
  final List<String> messages = [];
  Completer<void> _somethingLogged = Completer<void>();

  @override
  void info(
    final String message, {
    final bool newParagraph = false,
    final LogType type = const RawLogType(),
  }) {
    if (_somethingLogged.isCompleted == false) {
      _somethingLogged.complete();
    }
    messages.add(message);
  }

  @override
  void error(
    final String message, {
    final bool newParagraph = false,
    final StackTrace? stackTrace,
    final LogType type = const RawLogType(),
  }) {
    if (_somethingLogged.isCompleted == false) {
      _somethingLogged.complete();
    }
    messages.add(message);
  }

  void clear() {
    messages.clear();
  }

  Future<void> waitForLog() async {
    _somethingLogged = Completer<void>();
    await _somethingLogged.future;
  }
}
