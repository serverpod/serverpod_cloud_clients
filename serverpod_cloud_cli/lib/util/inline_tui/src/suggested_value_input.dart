import 'dart:async';

import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

import 'ansi_style.dart';
import 'ansi_text.dart';
import 'bottom_region_renderer.dart';
import 'inline_terminal.dart';
import 'select_list_style.dart';
import 'suggested_value_input_model.dart';
import 'tui_key.dart';

/// A bottom-anchored prompt that offers a suggested value or a value the
/// user types, in one region that updates in place.
///
/// The first row confirms the suggestion; the second row is a text input.
/// Up and Down move between them, and typing moves to the input. While the
/// input is highlighted, a hint shows beneath it after a blank line. A typed
/// value that fails validation shows its error in the region and the user
/// keeps typing. When the user confirms, the region is replaced with one
/// line that shows the value.
abstract final class SuggestedValueInput {
  /// Shows the prompt on [terminal] and returns the confirmed value, or null
  /// if the user cancelled with Escape.
  ///
  /// [prompt] is printed once above the region; it may contain newlines.
  /// [suggestionLabel] is the text of the suggestion row, which confirms
  /// [suggestion]. [entryLabel] names the typed value, as in `Bundle ID:
  /// com.acme.app`, and [entryPlaceholder] is the text of the input row
  /// while it is empty and not highlighted. [hint] is shown dimmed beneath
  /// the input row while it is highlighted; it may contain newlines and is
  /// wrapped to the terminal width. [validate] returns why a typed value
  /// cannot be confirmed, or null when it can.
  ///
  /// [terminal] is supplied by the caller, which owns its lifecycle.
  ///
  /// Throws a [UserAbortException] if the user aborts with Ctrl+C.
  static Future<String?> read({
    required InlineTerminal terminal,
    required String suggestion,
    required String suggestionLabel,
    required String entryLabel,
    required String entryPlaceholder,
    String? prompt,
    String? hint,
    String? Function(String value)? validate,
    SelectListStyle? style,
  }) async {
    final model = SuggestedValueInputModel(
      suggestion: suggestion,
      validate: validate,
    );
    final resolvedStyle = style ?? SelectListStyle();
    final renderer = BottomRegionRenderer(terminal);
    final completer = Completer<String?>();
    StreamSubscription<List<int>>? inputSubscription;
    StreamSubscription<void>? interruptSubscription;

    List<String> lines() => buildSuggestedValueInputLines(
      model,
      suggestionLabel: suggestionLabel,
      entryLabel: entryLabel,
      entryPlaceholder: entryPlaceholder,
      hint: hint,
      style: resolvedStyle,
      useAnsiStyles: terminal.supportsColor,
      columns: terminal.columns,
    );

    void finish(SuggestedValueInputStatus status) {
      if (status == SuggestedValueInputStatus.submitted) {
        renderer.finish(
          lines: [
            fitAnsiToColumns('$entryLabel: ${model.value}', terminal.columns),
          ],
        );
      } else {
        renderer.clear();
      }
      terminal.disableRawMode();
      unawaited(inputSubscription?.cancel());
      unawaited(interruptSubscription?.cancel());
      if (completer.isCompleted) return;
      switch (status) {
        case SuggestedValueInputStatus.aborted:
          completer.completeError(UserAbortException());
        case SuggestedValueInputStatus.submitted:
          completer.complete(model.value);
        case SuggestedValueInputStatus.cancelled ||
            SuggestedValueInputStatus.active:
          completer.complete(null);
      }
    }

    terminal.enableRawMode();
    renderer.hideCursor();
    if (prompt != null) {
      terminal.write('$prompt\n');
    }
    renderer.render(lines());

    interruptSubscription = terminal.interruptSignals.listen((_) {
      finish(SuggestedValueInputStatus.aborted);
    });

    inputSubscription = terminal.input.listen(
      (data) {
        var status = model.status;
        for (final key in TuiKeyDecoder.decode(data)) {
          status = model.handleKey(key);
          if (status != SuggestedValueInputStatus.active) break;
        }
        if (status == SuggestedValueInputStatus.active) {
          renderer.render(lines());
          return;
        }
        finish(status);
      },
      onError: (Object error, StackTrace stackTrace) {
        renderer.clear();
        terminal.disableRawMode();
        unawaited(inputSubscription?.cancel());
        unawaited(interruptSubscription?.cancel());
        if (!completer.isCompleted) completer.completeError(error, stackTrace);
      },
      onDone: () => finish(SuggestedValueInputStatus.cancelled),
      cancelOnError: true,
    );

    return completer.future;
  }
}

/// Builds the lines of a [SuggestedValueInput] for [model]: the suggestion
/// row and the input row, then, while the input row is highlighted, the
/// error of [model] and [hint] after a blank line, then the key hint row
/// after a blank line. The input row shows [entryPlaceholder] while it is
/// empty and not highlighted, and else `entryLabel: text`, with a cursor
/// while highlighted. Each line fits within [columns].
List<String> buildSuggestedValueInputLines(
  SuggestedValueInputModel model, {
  required String suggestionLabel,
  required String entryLabel,
  required String entryPlaceholder,
  required String? hint,
  required SelectListStyle style,
  required bool useAnsiStyles,
  required int columns,
}) {
  String styled(String text, String? ansiCode) =>
      useAnsiStyles && ansiCode != null
      ? '$ansiCode$text${AnsiStyle.reset.ansiCode}'
      : text;

  String row(SuggestedValueRow row, String text) {
    final highlighted = model.row == row;
    final line = fitAnsiToColumns(
      '${highlighted ? style.pointer : style.noPointer} '
      '${highlighted ? style.radioOn : style.radioOff} $text',
      columns - 1,
    );
    return highlighted ? styled(line, style.highlightStyle) : line;
  }

  final onEntry = model.row == SuggestedValueRow.entry;
  final cursor = useAnsiStyles ? '\x1B[7m \x1B[27m' : '_';
  final entryText = !onEntry && model.text.isEmpty
      ? entryPlaceholder
      : '$entryLabel: ${model.text}';
  final indent = ' ' * '${style.noPointer} ${style.radioOff} '.length;
  final error = model.error;

  return [
    row(SuggestedValueRow.suggestion, suggestionLabel),
    '${row(SuggestedValueRow.entry, entryText)}${onEntry ? cursor : ''}',
    if (onEntry && error != null) ...[
      '',
      styled(
        fitAnsiToColumns('$indent$error', columns - 1),
        AnsiStyle.red.ansiCode,
      ),
    ],
    if (onEntry && hint != null) ...[
      '',
      for (final line in wrapText(hint, columns - 1 - indent.length))
        styled('$indent$line', style.dimStyle),
    ],
    '',
    styled('up/down move, enter confirm, esc cancel', style.dimStyle),
  ];
}

/// Splits [text] into lines of at most [width] characters, breaking at
/// spaces and keeping the line breaks of [text]. A word longer than [width]
/// gets a line of its own.
List<String> wrapText(String text, int width) {
  final lines = <String>[];
  for (final paragraph in text.split('\n')) {
    var line = '';
    for (final word in paragraph.split(' ').where((word) => word.isNotEmpty)) {
      if (line.isEmpty) {
        line = word;
      } else if (line.length + 1 + word.length <= width) {
        line = '$line $word';
      } else {
        lines.add(line);
        line = word;
      }
    }
    lines.add(line);
  }
  return lines;
}
