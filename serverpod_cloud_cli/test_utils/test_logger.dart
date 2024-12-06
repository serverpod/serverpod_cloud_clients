import 'dart:async';
import 'dart:io';

import 'package:cli_tools/logger.dart';

class TestLogger extends VoidLogger {
  final List<String> messages = [];
  final List<String> errors = [];
  Completer<void> _somethingLogged = Completer<void>();

  late final IOSink? _infoOut;
  late final IOSink? _errorOut;

  TestLogger({final bool echo = false}) {
    _infoOut = echo ? stdout : null;
    _errorOut = echo ? stderr : null;
  }

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
    if (_infoOut != null) {
      _infoOut.writeln(message);
    }
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
    errors.add(message);
    if (_errorOut != null) {
      _errorOut.writeln(message);
    }
  }

  void clear() {
    messages.clear();
    errors.clear();
  }

  Future<void> waitForLog() async {
    _somethingLogged = Completer<void>();
    await _somethingLogged.future;
  }
}
