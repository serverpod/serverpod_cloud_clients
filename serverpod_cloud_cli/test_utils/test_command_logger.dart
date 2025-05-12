// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';

import 'mock_stdin.dart';
import 'mock_stdout.dart';

class BoxCall {
  final String message;
  final bool newParagraph;

  BoxCall({
    required this.message,
    this.newParagraph = false,
  });

  @override
  String toString() {
    return {
      'message': message,
      'newParagraph': newParagraph,
    }.toString();
  }
}

class ErrorCall {
  final String message;
  final Exception? exception;
  final String? hint;
  final bool newParagraph;
  final StackTrace? stackTrace;

  ErrorCall({
    required this.message,
    this.exception,
    this.hint,
    this.newParagraph = false,
    this.stackTrace,
  });

  @override
  String toString() {
    return {
      'message': message,
      'exception': exception,
      'hint': hint,
      'newParagraph': newParagraph,
      'stackTrace': stackTrace,
    }.toString();
  }
}

class InfoCall {
  final String message;
  final bool newParagraph;

  InfoCall({required this.message, this.newParagraph = false});

  @override
  String toString() {
    return {
      'message': message,
      'newParagraph': newParagraph,
    }.toString();
  }
}

class LineCall {
  final String line;

  LineCall({required this.line});

  @override
  String toString() {
    return {
      'line': line,
    }.toString();
  }
}

class ListCall {
  final List<String> items;
  final String? title;
  final bool newParagraph;

  ListCall({
    required this.items,
    this.title,
    this.newParagraph = false,
  });

  @override
  String toString() {
    return {
      'items': items,
      'title': title,
      'newParagraph': newParagraph,
    }.toString();
  }
}

class ProgressCall {
  final String message;
  final bool newParagraph;

  ProgressCall({
    required this.message,
    this.newParagraph = false,
  });

  @override
  String toString() {
    return {
      'message': message,
      'newParagraph': newParagraph,
    }.toString();
  }
}

class SuccessCall {
  final String message;
  final bool trailingRocket;
  final bool newParagraph;
  final String? followUp;

  SuccessCall({
    required this.message,
    this.trailingRocket = false,
    this.newParagraph = false,
    this.followUp,
  });

  @override
  String toString() {
    return {
      'message': message,
      'trailingRocket': trailingRocket,
      'newParagraph': newParagraph,
      'followUp': followUp,
    }.toString();
  }
}

class ConfirmCall {
  final String message;
  final bool? defaultValue;

  ConfirmCall({
    required this.message,
    required this.defaultValue,
  });

  @override
  String toString() {
    return {
      'message': message,
      'defaultValue': defaultValue,
    }.toString();
  }
}

class InputCall {
  final String message;
  final String? defaultValue;

  InputCall({
    required this.message,
    required this.defaultValue,
  });

  @override
  String toString() {
    return {
      'message': message,
      'defaultValue': defaultValue,
    }.toString();
  }
}

class TerminalCommandCall {
  final String command;
  final String? message;
  final bool newParagraph;

  TerminalCommandCall({
    required this.command,
    this.message,
    this.newParagraph = false,
  });

  @override
  String toString() {
    return {
      'command': command,
      'message': message,
      'newParagraph': newParagraph,
    }.toString();
  }
}

class TestCommandLogger extends CommandLogger {
  final List<BoxCall> boxCalls = [];
  final List<ErrorCall> errorCalls = [];
  var flushCallsCount = 0;
  final List<InfoCall> infoCalls = [];
  final List<LineCall> lineCalls = [];
  final List<ListCall> listCalls = [];
  final List<ProgressCall> progressCalls = [];
  final List<SuccessCall> successCalls = [];
  final List<TerminalCommandCall> terminalCommandCalls = [];
  final List<WarningCall> warningCalls = [];
  final List<ConfirmCall> confirmCalls = [];
  final List<InputCall> inputCalls = [];

  Completer<void> _somethingLogged = Completer<void>();

  final List<bool> _nextConfirmAnswers = [];
  final List<String> _nextInputAnswers = [];

  final bool printToStdout;
  final Logger _logger;

  /// Enable [printToStdout] temporarily to aid debugging.
  TestCommandLogger({
    this.printToStdout = false,
  })  : _logger = VoidLogger(),
        super(VoidLogger());

  int get totalLogCalls =>
      boxCalls.length +
      errorCalls.length +
      infoCalls.length +
      lineCalls.length +
      listCalls.length +
      progressCalls.length +
      successCalls.length +
      terminalCommandCalls.length +
      warningCalls.length;

  @override
  void box(
    final String message, {
    final LogLevel level = LogLevel.info,
    final bool newParagraph = false,
  }) {
    if (printToStdout) {
      print('log box: $message');
    }

    if (!_somethingLogged.isCompleted) {
      _somethingLogged.complete();
    }

    boxCalls.add(
      BoxCall(
        message: message,
        newParagraph: newParagraph,
      ),
    );
  }

  void clear() {
    flushCallsCount = 0;
    errorCalls.clear();
    infoCalls.clear();
    lineCalls.clear();
    listCalls.clear();
    progressCalls.clear();
    successCalls.clear();
    terminalCommandCalls.clear();
    warningCalls.clear();
    boxCalls.clear();
    confirmCalls.clear();
    inputCalls.clear();
    _nextConfirmAnswers.clear();
    _nextInputAnswers.clear();
  }

  @override
  void debug(
    final String message, {
    final LogType type = TextLogType.normal,
    final bool newParagraph = false,
  }) {
    if (printToStdout) {
      print('log debug: $message');
    }

    // debug calls should not be asserted in tests
  }

  @override
  void error(
    final String message, {
    final Exception? exception,
    final String? hint,
    final bool newParagraph = false,
    final StackTrace? stackTrace,
  }) {
    if (printToStdout) {
      print('log error: $message');
      if (exception != null) {
        print('  exception: $exception');
      }
      if (stackTrace != null) {
        print('  stackTrace: $stackTrace');
      }
      if (hint != null) {
        print('  hint: $hint');
      }
    }

    if (!_somethingLogged.isCompleted) {
      _somethingLogged.complete();
    }

    errorCalls.add(ErrorCall(
      message: message,
      exception: exception,
      hint: hint,
      newParagraph: newParagraph,
      stackTrace: stackTrace,
    ));
  }

  Future<void> waitForLog() async {
    _somethingLogged = Completer<void>();
    await _somethingLogged.future;
  }

  @override
  Future<void> flush() async {
    flushCallsCount++;
  }

  @override
  void info(
    final String message, {
    final bool newParagraph = false,
  }) {
    if (printToStdout) {
      print('log info: $message');
    }

    if (!_somethingLogged.isCompleted) {
      _somethingLogged.complete();
    }

    infoCalls.add(InfoCall(message: message, newParagraph: newParagraph));
  }

  @override
  void line(
    final String line, {
    final LogLevel level = LogLevel.info,
  }) {
    if (printToStdout) {
      print('log line: $line');
    }

    if (!_somethingLogged.isCompleted) {
      _somethingLogged.complete();
    }

    lineCalls.add(LineCall(line: line));
  }

  @override
  void list(
    final Iterable<String> items, {
    final LogLevel level = LogLevel.info,
    final String? title,
    final bool newParagraph = false,
  }) {
    final itemList = items.toList();
    if (printToStdout) {
      print('log list: $itemList');
    }

    if (!_somethingLogged.isCompleted) {
      _somethingLogged.complete();
    }

    listCalls.add(
      ListCall(items: itemList, title: title, newParagraph: newParagraph),
    );
  }

  @override
  Future<bool> progress(
    final String message,
    final Future<bool> Function() runner, {
    final bool newParagraph = false,
  }) async {
    if (printToStdout) {
      print('log progress: $message');
    }

    if (!_somethingLogged.isCompleted) {
      _somethingLogged.complete();
    }

    progressCalls
        .add(ProgressCall(message: message, newParagraph: newParagraph));
    return _logger.progress(message, runner);
  }

  @override
  void success(
    final String message, {
    final LogLevel level = LogLevel.info,
    final bool trailingRocket = false,
    final bool newParagraph = false,
    final String? followUp,
  }) {
    if (printToStdout) {
      print('log success: $message');
    }

    if (!_somethingLogged.isCompleted) {
      _somethingLogged.complete();
    }

    successCalls.add(SuccessCall(
      message: message,
      trailingRocket: trailingRocket,
      newParagraph: newParagraph,
      followUp: followUp,
    ));
  }

  @override
  void terminalCommand(
    final String command, {
    final String? message,
    final LogLevel level = LogLevel.info,
    final bool newParagraph = false,
  }) {
    if (printToStdout) {
      print('log terminal command: $command, message: $message');
    }

    if (!_somethingLogged.isCompleted) {
      _somethingLogged.complete();
    }

    terminalCommandCalls.add(TerminalCommandCall(
      command: command,
      message: message,
      newParagraph: newParagraph,
    ));
  }

  @override
  void warning(
    final String message, {
    final bool newParagraph = false,
    final String? hint,
  }) {
    if (printToStdout) {
      print('log warning: $message');
    }

    if (!_somethingLogged.isCompleted) {
      _somethingLogged.complete();
    }

    warningCalls.add(WarningCall(
      message: message,
      newParagraph: newParagraph,
      hint: hint,
    ));
  }

  @override
  Future<bool> confirm(
    final String message, {
    final bool? defaultValue,
  }) async {
    if (printToStdout) {
      print('log confirm: $message');
    }

    if (_nextConfirmAnswers.isEmpty) {
      throw StateError(
        'No answer set for confirm call. '
        'Use TestCommandLogger.answerNextConfirmWith() to set the answer.',
      );
    }
    final nextConfirmAnswer = _nextConfirmAnswers.removeAt(0);

    confirmCalls.add(ConfirmCall(
      message: message,
      defaultValue: defaultValue,
    ));

    return nextConfirmAnswer;
  }

  @override
  Future<String> input(
    final String message, {
    final String? defaultValue,
  }) async {
    if (printToStdout) {
      print('log input: $message');
    }

    if (_nextInputAnswers.isEmpty) {
      throw StateError(
        'No answer set for input call. '
        'Use TestCommandLogger.answerNextInputsWith() to set the answer.',
      );
    }
    final nextInputAnswer = _nextInputAnswers.removeAt(0);

    inputCalls.add(InputCall(
      message: message,
      defaultValue: defaultValue,
    ));

    return nextInputAnswer;
  }

  void answerNextConfirmWith(final bool answer) {
    _nextConfirmAnswers.add(answer);
  }

  void answerNextConfirmsWith(final Iterable<bool> answers) {
    _nextConfirmAnswers.addAll(answers);
  }

  void answerNextInputsWith(final Iterable<String> answers) {
    _nextInputAnswers.addAll(answers);
  }
}

class WarningCall {
  final String message;
  final String? hint;
  final bool newParagraph;

  WarningCall({
    required this.message,
    this.hint,
    this.newParagraph = false,
  });

  @override
  String toString() {
    return {
      'message': message,
      'hint': hint,
      'newParagraph': newParagraph,
    }.toString();
  }
}

Future<({MockStdout stdout, MockStdout stderr, MockStdin stdin})>
    collectOutput<T>(
  final FutureOr<T> Function() runner, {
  final List<String> stdinLines = const [],
  final MockStdout? stdout,
  final MockStdout? stderr,
  final MockStdin? stdin,
}) async {
  final standardOut = stdout ?? MockStdout();
  final standardError = stderr ?? MockStdout();
  final standardIn = stdin ?? MockStdin(stdinLines);

  await IOOverrides.runZoned(
    () async {
      final result = await runner();

      return result;
    },
    stdout: () => standardOut,
    stderr: () => standardError,
    stdin: () => standardIn,
  );

  return (stdout: standardOut, stderr: standardError, stdin: standardIn);
}
