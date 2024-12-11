import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';

class ErrorCall {
  final String message;
  final String? hint;
  final bool newParagraph;
  final StackTrace? stackTrace;

  ErrorCall({
    required this.message,
    this.hint,
    this.newParagraph = false,
    this.stackTrace,
  });

  @override
  String toString() {
    return {
      'message': message,
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
  final List<ErrorCall> errorCalls = [];
  var flushCallsCount = 0;
  final List<InfoCall> infoCalls = [];
  final List<ListCall> listCalls = [];
  final List<ProgressCall> progressCalls = [];
  final List<SuccessCall> successCalls = [];
  final List<TerminalCommandCall> terminalCommandCalls = [];
  final List<WarningCall> warningCalls = [];

  final Logger _logger;

  TestCommandLogger()
      : _logger = VoidLogger(),
        super(VoidLogger());

  void clear() {
    errorCalls.clear();
    flushCallsCount = 0;
    infoCalls.clear();
    listCalls.clear();
    progressCalls.clear();
    successCalls.clear();
    terminalCommandCalls.clear();
    warningCalls.clear();
  }

  @override
  void debug(
    final String message, {
    final TextLogType type = TextLogType.normal,
    final bool newParagraph = false,
  }) {
    // debug calls should not be asserted in tests
  }

  @override
  void error(
    final String message, {
    final String? hint,
    final bool newParagraph = false,
    final StackTrace? stackTrace,
  }) {
    errorCalls.add(ErrorCall(
      message: message,
      hint: hint,
      newParagraph: newParagraph,
      stackTrace: stackTrace,
    ));
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
    infoCalls.add(InfoCall(message: message, newParagraph: newParagraph));
  }

  @override
  void list(
    final List<String> items, {
    final String? title,
    final bool newParagraph = false,
  }) {
    listCalls
        .add(ListCall(items: items, title: title, newParagraph: newParagraph));
  }

  @override
  Future<bool> progress(
    final String message,
    final Future<bool> Function() runner, {
    final bool newParagraph = false,
  }) async {
    progressCalls
        .add(ProgressCall(message: message, newParagraph: newParagraph));
    return _logger.progress(message, runner);
  }

  @override
  void success(
    final String message, {
    final bool trailingRocket = false,
    final bool newParagraph = false,
    final String? followUp,
  }) {
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
    final bool newParagraph = false,
  }) {
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
    warningCalls.add(WarningCall(
      message: message,
      newParagraph: newParagraph,
      hint: hint,
    ));
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
