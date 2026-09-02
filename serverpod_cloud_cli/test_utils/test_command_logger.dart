// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/util/inline_tui/inline_tui.dart'
    show InlineTerminal;

import '../test/util/inline_tui/helpers/fake_terminal.dart';
import 'mock_stdin.dart';
import 'mock_stdout.dart';

class BoxCall {
  final String message;
  final bool newParagraph;

  BoxCall({required this.message, this.newParagraph = false});

  @override
  String toString() {
    return {'message': message, 'newParagraph': newParagraph}.toString();
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
    return {'message': message, 'newParagraph': newParagraph}.toString();
  }
}

class LineCall {
  final String line;

  LineCall({required this.line});

  @override
  String toString() {
    return {'line': line}.toString();
  }
}

class ListCall {
  final List<String> items;
  final String? title;
  final bool newParagraph;

  ListCall({required this.items, this.title, this.newParagraph = false});

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

  ProgressCall({required this.message, this.newParagraph = false});

  @override
  String toString() {
    return {'message': message, 'newParagraph': newParagraph}.toString();
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

  ConfirmCall({required this.message, required this.defaultValue});

  @override
  String toString() {
    return {'message': message, 'defaultValue': defaultValue}.toString();
  }
}

class InputCall {
  final String message;
  final String? defaultValue;

  InputCall({required this.message, required this.defaultValue});

  @override
  String toString() {
    return {'message': message, 'defaultValue': defaultValue}.toString();
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

class RawCall {
  final String content;
  final AnsiStyle? style;

  RawCall({required this.content, this.style});

  @override
  String toString() {
    return {'content': content, 'style': style}.toString();
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
  final List<RawCall> rawCalls = [];

  Completer<void> _somethingLogged = Completer<void>();

  final List<bool> _nextConfirmAnswers = [];
  final List<String> _nextInputAnswers = [];

  final bool printToStdout;
  final Logger _logger;
  InlineTerminal? _inlineTerminal;

  /// Enable [printToStdout] temporarily to aid debugging.
  TestCommandLogger({this.printToStdout = false})
    : _logger = VoidLogger(),
      super(VoidLogger());

  @override
  InlineTerminal get inlineTerminal => _inlineTerminal ??= FakeTerminal();

  set inlineTerminal(InlineTerminal terminal) => _inlineTerminal = terminal;

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
    String message, {
    LogLevel level = LogLevel.info,
    bool newParagraph = false,
  }) {
    if (printToStdout) {
      print('log box: $message');
    }

    if (!_somethingLogged.isCompleted) {
      _somethingLogged.complete();
    }

    boxCalls.add(BoxCall(message: message, newParagraph: newParagraph));
  }

  void clear() {
    _inlineTerminal = null;
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
    rawCalls.clear();
    _nextConfirmAnswers.clear();
    _nextInputAnswers.clear();
  }

  @override
  void debug(
    String message, {
    LogType type = TextLogType.normal,
    bool newParagraph = false,
  }) {
    if (printToStdout) {
      print('log debug: $message');
    }

    // debug calls should not be asserted in tests
  }

  @override
  void error(
    String message, {
    Exception? exception,
    String? hint,
    bool newParagraph = false,
    StackTrace? stackTrace,
    bool forcePrintStackTrace = false,
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

    errorCalls.add(
      ErrorCall(
        message: message,
        exception: exception,
        hint: hint,
        newParagraph: newParagraph,
        stackTrace: stackTrace,
      ),
    );
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
  void info(String message, {bool newParagraph = false}) {
    if (printToStdout) {
      print('log info: $message');
    }

    if (!_somethingLogged.isCompleted) {
      _somethingLogged.complete();
    }

    infoCalls.add(InfoCall(message: message, newParagraph: newParagraph));
  }

  @override
  void line(String line, {LogLevel level = LogLevel.info}) {
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
    Iterable<String> items, {
    LogLevel level = LogLevel.info,
    String? title,
    bool newParagraph = false,
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
    String message,
    Future<bool> Function() runner, {
    String? successMessage,
    int padRight = 0,
    bool newParagraph = false,
  }) async {
    if (printToStdout) {
      print('log progress: $message');
    }

    if (!_somethingLogged.isCompleted) {
      _somethingLogged.complete();
    }

    progressCalls.add(
      ProgressCall(message: message, newParagraph: newParagraph),
    );
    final result = await _logger.progress(message, runner);
    if (result && successMessage != null) {
      progressCalls.add(ProgressCall(message: successMessage));
    }
    return result;
  }

  @override
  Future<T> progressStream<T>(
    String initialMessage,
    Stream<T> stream, {
    String Function(T)? toMessage,
    int padRight = 0,
    bool Function(T)? isSuccess,
    bool newParagraph = false,
  }) async {
    if (printToStdout) {
      print('log progressStream: $initialMessage');
    }

    if (!_somethingLogged.isCompleted) {
      _somethingLogged.complete();
    }

    progressCalls.add(
      ProgressCall(message: initialMessage, newParagraph: newParagraph),
    );
    final lastEvent = await _logger.progressStream(
      initialMessage,
      stream,
      toMessage: toMessage,
      isSuccess: isSuccess,
      newParagraph: newParagraph,
    );
    final lastMessage = toMessage?.call(lastEvent) ?? lastEvent.toString();
    progressCalls.add(
      ProgressCall(message: lastMessage, newParagraph: newParagraph),
    );
    return lastEvent;
  }

  @override
  void success(
    String message, {
    LogLevel level = LogLevel.info,
    bool trailingRocket = false,
    bool newParagraph = false,
    String? followUp,
  }) {
    if (printToStdout) {
      print('log success: $message');
    }

    if (!_somethingLogged.isCompleted) {
      _somethingLogged.complete();
    }

    successCalls.add(
      SuccessCall(
        message: message,
        trailingRocket: trailingRocket,
        newParagraph: newParagraph,
        followUp: followUp,
      ),
    );
  }

  @override
  void terminalCommand(
    String command, {
    String? message,
    LogLevel level = LogLevel.info,
    bool newParagraph = false,
  }) {
    if (printToStdout) {
      print('log terminal command: $command, message: $message');
    }

    if (!_somethingLogged.isCompleted) {
      _somethingLogged.complete();
    }

    terminalCommandCalls.add(
      TerminalCommandCall(
        command: command,
        message: message,
        newParagraph: newParagraph,
      ),
    );
  }

  @override
  void warning(String message, {bool newParagraph = false, String? hint}) {
    if (printToStdout) {
      print('log warning: $message');
    }

    if (!_somethingLogged.isCompleted) {
      _somethingLogged.complete();
    }

    warningCalls.add(
      WarningCall(message: message, newParagraph: newParagraph, hint: hint),
    );
  }

  @override
  void raw(
    String content, {
    AnsiStyle? style,
    LogLevel logLevel = LogLevel.info,
  }) {
    if (printToStdout) {
      print('log raw: $content');
    }

    if (!_somethingLogged.isCompleted) {
      _somethingLogged.complete();
    }

    rawCalls.add(RawCall(content: content, style: style));
  }

  @override
  Future<bool> confirm(String message, {bool? defaultValue}) async {
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

    confirmCalls.add(ConfirmCall(message: message, defaultValue: defaultValue));

    return nextConfirmAnswer;
  }

  @override
  Future<String> input(String message, {String? defaultValue}) async {
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

    inputCalls.add(InputCall(message: message, defaultValue: defaultValue));

    return nextInputAnswer;
  }

  void answerNextConfirmWith(bool answer) {
    _nextConfirmAnswers.add(answer);
  }

  void answerNextConfirmsWith(Iterable<bool> answers) {
    _nextConfirmAnswers.addAll(answers);
  }

  void answerNextInputsWith(Iterable<String> answers) {
    _nextInputAnswers.addAll(answers);
  }
}

class WarningCall {
  final String message;
  final String? hint;
  final bool newParagraph;

  WarningCall({required this.message, this.hint, this.newParagraph = false});

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
  FutureOr<T> Function() runner, {
  List<String> stdinLines = const [],
  MockStdout? stdout,
  MockStdout? stderr,
  MockStdin? stdin,
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
