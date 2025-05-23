// Base LogCall class
import 'package:test/test.dart';

import 'test_command_logger.dart';
import 'package:collection/collection.dart';

/// Test matcher to assert TestCommandLogger.error calls
Matcher equalsErrorCall({
  required final String message,
  final Exception? exception,
  final String? hint,
  final bool newParagraph = false,
}) {
  return _ErrorCallMatcher(ErrorCall(
    message: message,
    exception: exception,
    hint: hint,
    newParagraph: newParagraph,
  ));
}

class _ErrorCallMatcher extends Matcher {
  final ErrorCall errorCall;

  _ErrorCallMatcher(this.errorCall);

  @override
  bool matches(final Object? item, final Map matchState) {
    if (item is! ErrorCall) return false;
    return item.message == errorCall.message &&
        item.exception?.toString() == errorCall.exception?.toString() &&
        item.hint == errorCall.hint &&
        item.newParagraph == errorCall.newParagraph;
  }

  @override
  Description describe(final Description description) {
    return description.add(
      'an error log with message "${errorCall.message}", '
      'exception "${errorCall.exception}", '
      'hint "${errorCall.hint}", '
      'newParagraph ${errorCall.newParagraph}',
    );
  }

  @override
  Description describeMismatch(
    final item,
    final Description mismatchDescription,
    final Map matchState,
    final bool verbose,
  ) {
    if (item is! ErrorCall) {
      return mismatchDescription.add('is not an ErrorCall');
    }
    if (item.message != errorCall.message) {
      return mismatchDescription.add('message is not "${errorCall.message}"');
    }
    if (item.exception?.toString() != errorCall.exception?.toString()) {
      return mismatchDescription
          .add('exception is not "${errorCall.exception}"');
    }
    if (item.hint != errorCall.hint) {
      return mismatchDescription.add('hint is not "${errorCall.hint}"');
    }
    if (item.newParagraph != errorCall.newParagraph) {
      return mismatchDescription
          .add('newParagraph is not ${errorCall.newParagraph}');
    }

    return super
        .describeMismatch(item, mismatchDescription, matchState, verbose);
  }
}

/// Test matcher to assert TestCommandLogger.info calls
Matcher equalsInfoCall({
  required final String message,
  final bool newParagraph = false,
}) {
  return _InfoCallMatcher(InfoCall(
    message: message,
    newParagraph: newParagraph,
  ));
}

class _InfoCallMatcher extends Matcher {
  final InfoCall infoCall;

  _InfoCallMatcher(this.infoCall);

  @override
  bool matches(final Object? item, final Map matchState) {
    if (item is! InfoCall) return false;
    return item.message == infoCall.message &&
        item.newParagraph == infoCall.newParagraph;
  }

  @override
  Description describe(final Description description) {
    return description.add(
      'an info log with message "${infoCall.message}" and newParagraph ${infoCall.newParagraph}',
    );
  }

  @override
  Description describeMismatch(
    final item,
    final Description mismatchDescription,
    final Map matchState,
    final bool verbose,
  ) {
    if (item is! InfoCall) {
      return mismatchDescription.add('is not an InfoCall');
    }
    if (item.message != infoCall.message) {
      return mismatchDescription.add('message is not "${infoCall.message}"');
    }
    if (item.newParagraph != infoCall.newParagraph) {
      return mismatchDescription
          .add('newParagraph is not ${infoCall.newParagraph}');
    }

    return super
        .describeMismatch(item, mismatchDescription, matchState, verbose);
  }
}

/// Test matcher to assert TestCommandLogger.line calls
Matcher equalsLineCall({
  required final String line,
}) {
  return _LineCallMatcher(LineCall(
    line: line,
  ));
}

class _LineCallMatcher extends Matcher {
  final LineCall lineCall;

  _LineCallMatcher(this.lineCall);

  @override
  bool matches(final Object? item, final Map matchState) {
    if (item is! LineCall) return false;
    return item.line == lineCall.line;
  }

  @override
  Description describe(final Description description) {
    return description.add(
      'an info log with line "${lineCall.line}"',
    );
  }

  @override
  Description describeMismatch(
    final item,
    final Description mismatchDescription,
    final Map matchState,
    final bool verbose,
  ) {
    if (item is! LineCall) {
      return mismatchDescription.add('is not a LineCall');
    }
    if (item.line != lineCall.line) {
      return mismatchDescription.add('line is not "${lineCall.line}"');
    }

    return super
        .describeMismatch(item, mismatchDescription, matchState, verbose);
  }
}

/// Test matcher to assert TestCommandLogger.list calls
Matcher equalsListCall({
  required final List<String> items,
  final String? title,
  final bool newParagraph = false,
}) {
  return _ListCallMatcher(ListCall(
    items: items,
    title: title,
    newParagraph: newParagraph,
  ));
}

class _ListCallMatcher extends Matcher {
  final ListCall listCall;

  _ListCallMatcher(this.listCall);

  @override
  bool matches(final Object? item, final Map matchState) {
    if (item is! ListCall) return false;

    return ListEquality().equals(item.items, listCall.items) &&
        item.title == listCall.title &&
        item.newParagraph == listCall.newParagraph;
  }

  @override
  Description describe(final Description description) {
    return description.add(
      'a list log with items "${listCall.items}", title "${listCall.title}", and newParagraph ${listCall.newParagraph}',
    );
  }

  @override
  Description describeMismatch(
    final item,
    final Description mismatchDescription,
    final Map matchState,
    final bool verbose,
  ) {
    if (item is! ListCall) {
      return mismatchDescription.add('is not a ListCall');
    }
    if (item.items != listCall.items) {
      return mismatchDescription.add('items are not "${listCall.items}"');
    }
    if (item.title != listCall.title) {
      return mismatchDescription.add('title is not "${listCall.title}"');
    }
    if (item.newParagraph != listCall.newParagraph) {
      return mismatchDescription
          .add('newParagraph is not ${listCall.newParagraph}');
    }

    return super
        .describeMismatch(item, mismatchDescription, matchState, verbose);
  }
}

/// Test matcher to assert TestCommandLogger.success calls
Matcher equalsSuccessCall({
  required final String message,
  final bool trailingRocket = false,
  final bool newParagraph = false,
  final String? followUp,
}) {
  return _SuccessCallMatcher(SuccessCall(
    message: message,
    trailingRocket: trailingRocket,
    newParagraph: newParagraph,
    followUp: followUp,
  ));
}

class _SuccessCallMatcher extends Matcher {
  final SuccessCall successCall;

  _SuccessCallMatcher(this.successCall);

  @override
  bool matches(final Object? item, final Map matchState) {
    if (item is! SuccessCall) return false;
    return item.message == successCall.message &&
        item.trailingRocket == successCall.trailingRocket &&
        item.newParagraph == successCall.newParagraph &&
        item.followUp == successCall.followUp;
  }

  @override
  Description describe(final Description description) {
    return description.add(
      'a success log with message "${successCall.message}", '
      'trailingRocket ${successCall.trailingRocket}, newParagraph ${successCall.newParagraph}, '
      'and followUp "${successCall.followUp}"',
    );
  }

  @override
  Description describeMismatch(
    final item,
    final Description mismatchDescription,
    final Map matchState,
    final bool verbose,
  ) {
    if (item is! SuccessCall) {
      return mismatchDescription.add('is not a SuccessCall');
    }
    if (item.message != successCall.message) {
      return mismatchDescription.add('message is not "${successCall.message}"');
    }
    if (item.trailingRocket != successCall.trailingRocket) {
      return mismatchDescription
          .add('trailingRocket is not ${successCall.trailingRocket}');
    }
    if (item.newParagraph != successCall.newParagraph) {
      return mismatchDescription
          .add('newParagraph is not ${successCall.newParagraph}');
    }
    if (item.followUp != successCall.followUp) {
      return mismatchDescription
          .add('followUp is not "${successCall.followUp}"');
    }

    return super
        .describeMismatch(item, mismatchDescription, matchState, verbose);
  }
}

/// Test matcher to assert TestCommandLogger.terminalCommand calls
Matcher equalsTerminalCommandCall({
  required final String command,
  final String? message,
  final bool newParagraph = false,
}) {
  return _TerminalCommandCallMatcher(TerminalCommandCall(
    command: command,
    message: message,
    newParagraph: newParagraph,
  ));
}

class _TerminalCommandCallMatcher extends Matcher {
  final TerminalCommandCall terminalCommandCall;

  _TerminalCommandCallMatcher(this.terminalCommandCall);

  @override
  bool matches(final Object? item, final Map matchState) {
    if (item is! TerminalCommandCall) return false;
    return item.command == terminalCommandCall.command &&
        item.message == terminalCommandCall.message &&
        item.newParagraph == terminalCommandCall.newParagraph;
  }

  @override
  Description describe(final Description description) {
    return description.add(
      'a terminal command log with command "${terminalCommandCall.command}", '
      'message "${terminalCommandCall.message}", and newParagraph ${terminalCommandCall.newParagraph}',
    );
  }

  @override
  Description describeMismatch(
    final item,
    final Description mismatchDescription,
    final Map matchState,
    final bool verbose,
  ) {
    if (item is! TerminalCommandCall) {
      return mismatchDescription.add('is not a TerminalCommandCall');
    }
    if (item.command != terminalCommandCall.command) {
      return mismatchDescription
          .add('command is not "${terminalCommandCall.command}"');
    }
    if (item.message != terminalCommandCall.message) {
      return mismatchDescription
          .add('message is not "${terminalCommandCall.message}"');
    }
    if (item.newParagraph != terminalCommandCall.newParagraph) {
      return mismatchDescription
          .add('newParagraph is not ${terminalCommandCall.newParagraph}');
    }

    return super
        .describeMismatch(item, mismatchDescription, matchState, verbose);
  }
}

/// Test matcher to assert TestCommandLogger.warning calls
Matcher equalsWarningCall({
  required final message,
  final String? hint,
  final bool newParagraph = false,
}) {
  return _WarningCallMatcher(WarningCall(
    message: message,
    hint: hint,
    newParagraph: newParagraph,
  ));
}

class _WarningCallMatcher extends Matcher {
  final WarningCall warningCall;

  _WarningCallMatcher(this.warningCall);

  @override
  bool matches(final Object? item, final Map matchState) {
    if (item is! WarningCall) return false;
    return item.message == warningCall.message &&
        item.hint == warningCall.hint &&
        item.newParagraph == warningCall.newParagraph;
  }

  @override
  Description describe(final Description description) {
    return description.add(
      'a warning log with message "${warningCall.message}", '
      'hint "${warningCall.hint}", and newParagraph ${warningCall.newParagraph}',
    );
  }

  @override
  Description describeMismatch(
    final item,
    final Description mismatchDescription,
    final Map matchState,
    final bool verbose,
  ) {
    if (item is! WarningCall) {
      return mismatchDescription.add('is not a WarningCall');
    }
    if (item.message != warningCall.message) {
      return mismatchDescription.add('message is not "${warningCall.message}"');
    }
    if (item.hint != warningCall.hint) {
      return mismatchDescription.add('hint is not "${warningCall.hint}"');
    }
    if (item.newParagraph != warningCall.newParagraph) {
      return mismatchDescription
          .add('newParagraph is not ${warningCall.newParagraph}');
    }

    return super
        .describeMismatch(item, mismatchDescription, matchState, verbose);
  }
}

/// Test matcher to assert TestCommandLogger.progress calls
Matcher equalsProgressCall({
  required final message,
  final bool newParagraph = false,
}) {
  return _ProgressCallMatcher(
    ProgressCall(
      message: message,
      newParagraph: newParagraph,
    ),
  );
}

class _ProgressCallMatcher extends Matcher {
  final ProgressCall progressCall;

  _ProgressCallMatcher(this.progressCall);

  @override
  bool matches(final Object? item, final Map matchState) {
    if (item is! ProgressCall) return false;
    return item.message == progressCall.message &&
        item.newParagraph == progressCall.newParagraph;
  }

  @override
  Description describe(final Description description) {
    return description.add(
      'a progress log with message "${progressCall.message}" and newParagraph ${progressCall.newParagraph}',
    );
  }

  @override
  Description describeMismatch(
    final item,
    final Description mismatchDescription,
    final Map matchState,
    final bool verbose,
  ) {
    if (item is! ProgressCall) {
      return mismatchDescription.add('is not a ProgressCall');
    }
    if (item.message != progressCall.message) {
      return mismatchDescription
          .add('message is not "${progressCall.message}"');
    }
    if (item.newParagraph != progressCall.newParagraph) {
      return mismatchDescription
          .add('newParagraph is not ${progressCall.newParagraph}');
    }

    return super
        .describeMismatch(item, mismatchDescription, matchState, verbose);
  }
}

/// Test matcher to assert TestCommandLogger.confirm calls
equalsConfirmCall({
  required final String message,
  final bool? defaultValue,
}) {
  return _ConfirmCallMatcher(
    ConfirmCall(
      message: message,
      defaultValue: defaultValue,
    ),
  );
}

class _ConfirmCallMatcher extends Matcher {
  final ConfirmCall confirmCall;

  _ConfirmCallMatcher(this.confirmCall);

  @override
  bool matches(final Object? item, final Map matchState) {
    if (item is! ConfirmCall) return false;
    return item.message == confirmCall.message &&
        item.defaultValue == confirmCall.defaultValue;
  }

  @override
  Description describe(final Description description) {
    return description.add(
      'a confirm log with message "${confirmCall.message}" and defaultValue ${confirmCall.defaultValue}',
    );
  }

  @override
  Description describeMismatch(
    final item,
    final Description mismatchDescription,
    final Map matchState,
    final bool verbose,
  ) {
    if (item is! ConfirmCall) {
      return mismatchDescription.add('is not a ConfirmCall');
    }
    if (item.message != confirmCall.message) {
      return mismatchDescription.add('message is not "${confirmCall.message}"');
    }
    if (item.defaultValue != confirmCall.defaultValue) {
      return mismatchDescription
          .add('defaultValue is not ${confirmCall.defaultValue}');
    }

    return super
        .describeMismatch(item, mismatchDescription, matchState, verbose);
  }
}

/// Test matcher to assert TestCommandLogger.input calls
equalsInputCall({
  required final String message,
  final String? defaultValue,
}) {
  return _InputCallMatcher(
    InputCall(
      message: message,
      defaultValue: defaultValue,
    ),
  );
}

class _InputCallMatcher extends Matcher {
  final InputCall inputCall;

  _InputCallMatcher(this.inputCall);

  @override
  bool matches(final Object? item, final Map matchState) {
    if (item is! InputCall) return false;
    return item.message == inputCall.message &&
        item.defaultValue == inputCall.defaultValue;
  }

  @override
  Description describe(final Description description) {
    return description.add(
      'an input log with message "${inputCall.message}" and defaultValue ${inputCall.defaultValue}',
    );
  }

  @override
  Description describeMismatch(
    final item,
    final Description mismatchDescription,
    final Map matchState,
    final bool verbose,
  ) {
    if (item is! InputCall) {
      return mismatchDescription.add('is not an InputCall');
    }
    if (item.message != inputCall.message) {
      return mismatchDescription.add('message is not "${inputCall.message}"');
    }
    if (item.defaultValue != inputCall.defaultValue) {
      return mismatchDescription
          .add('defaultValue is not ${inputCall.defaultValue}');
    }

    return super
        .describeMismatch(item, mismatchDescription, matchState, verbose);
  }
}

Matcher equalsBoxCall({
  required final message,
  final bool newParagraph = false,
}) {
  return _BoxCallMatcher(
    BoxCall(
      message: message,
      newParagraph: newParagraph,
    ),
  );
}

class _BoxCallMatcher extends Matcher {
  final BoxCall boxCall;

  _BoxCallMatcher(this.boxCall);

  @override
  bool matches(final Object? item, final Map matchState) {
    if (item is! BoxCall) return false;
    return item.message == boxCall.message &&
        item.newParagraph == boxCall.newParagraph;
  }

  @override
  Description describe(final Description description) {
    return description.add(
      'a box log with message "${boxCall.message}" and newParagraph ${boxCall.newParagraph}',
    );
  }

  @override
  Description describeMismatch(
    final item,
    final Description mismatchDescription,
    final Map matchState,
    final bool verbose,
  ) {
    if (item is! BoxCall) {
      return mismatchDescription.add('is not a BoxCall');
    }
    if (item.message != boxCall.message) {
      return mismatchDescription.add('message is not "${boxCall.message}"');
    }
    if (item.newParagraph != boxCall.newParagraph) {
      return mismatchDescription
          .add('newParagraph is not ${boxCall.newParagraph}');
    }

    return super
        .describeMismatch(item, mismatchDescription, matchState, verbose);
  }
}
