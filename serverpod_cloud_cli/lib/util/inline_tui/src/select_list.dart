import 'dart:async';

import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

import 'bottom_region_renderer.dart';
import 'select_list_model.dart';
import 'select_list_style.dart';
import 'select_list_view.dart';
import 'inline_terminal.dart';
import 'tui_key.dart';

/// A keyboard-navigated, bottom-anchored selection list.
///
/// The list renders only its own rows at the bottom of the terminal and updates
/// them in place as the user navigates with the arrow keys (or `j`/`k`).
/// It works on modern Windows consoles as well as macOS and Linux terminals.
///
/// Example:
/// ```dart
/// final fruit = await SelectList.choose<String>(
///   prompt: 'Pick a fruit',
///   options: ['Apple', 'Banana', 'Cherry'],
/// );
/// ```
abstract final class SelectList {
  /// Shows a single-choice list and returns the chosen value, or null if the
  /// user cancelled with Escape or `q`.
  ///
  /// Throws a [UserAbortException] if the user aborts with Ctrl+C.
  ///
  /// [terminal] is supplied by the caller, which owns its lifecycle; this prompt
  /// cleans up after itself before returning but does not dispose [terminal].
  ///
  /// [label] maps each option to its displayed text (defaults to `toString`).
  static Future<T?> choose<T>({
    required final List<T> options,
    required final InlineTerminal terminal,
    final String? prompt,
    final String Function(T option)? label,
    final int initialIndex = 0,
    final bool Function(T option)? isEnabled,
    final SelectListStyle? style,
  }) async {
    final model = SelectListModel<T>(
      items: _itemsFor(options, label, isEnabled),
      multiSelect: false,
      initialIndex: initialIndex,
    );

    final result = await _run(
      model,
      terminal: terminal,
      style: style,
      prompt: prompt,
    );
    if (result.status != SelectListStatus.submitted) return null;
    return result.selectedValues.isEmpty ? null : result.selectedValues.first;
  }

  /// Shows a multi-choice list and returns the chosen values, or null if the
  /// user cancelled with Escape or `q`.
  ///
  /// Throws a [UserAbortException] if the user aborts with Ctrl+C.
  ///
  /// [minSelections] and [maxSelections] constrain how many items may be
  /// selected. Enter only confirms once at least [minSelections] are selected.
  static Future<List<T>?> chooseMultiple<T>({
    required final List<T> options,
    required final InlineTerminal terminal,
    final String? prompt,
    final String Function(T option)? label,
    final Iterable<T> initiallySelected = const [],
    final int minSelections = 0,
    final int? maxSelections,
    final bool Function(T option)? isEnabled,
    final SelectListStyle? style,
  }) async {
    final initialIndices = <int>[
      for (var i = 0; i < options.length; i++)
        if (initiallySelected.contains(options[i])) i,
    ];
    final model = SelectListModel<T>(
      items: _itemsFor(options, label, isEnabled),
      multiSelect: true,
      minSelections: minSelections,
      maxSelections: maxSelections,
      initiallySelected: initialIndices,
    );

    final result = await _run(
      model,
      terminal: terminal,
      style: style,
      prompt: prompt,
    );
    if (result.status != SelectListStatus.submitted) return null;
    return result.selectedValues;
  }

  static List<SelectListItem<T>> _itemsFor<T>(
    final List<T> options,
    final String Function(T option)? label,
    final bool Function(T option)? isEnabled,
  ) {
    return [
      for (final option in options)
        SelectListItem<T>(
          value: option,
          label: label?.call(option) ?? option.toString(),
          enabled: isEnabled?.call(option) ?? true,
        ),
    ];
  }

  static Future<SelectListModel<T>> _run<T>(
    final SelectListModel<T> model, {
    required final InlineTerminal terminal,
    required final SelectListStyle? style,
    required final String? prompt,
  }) async {
    final resolvedStyle = style ?? SelectListStyle();
    final runner = SelectListRunner<T>(
      model: model,
      terminal: terminal,
      style: resolvedStyle,
      prompt: prompt,
    );
    await runner.run();
    return model;
  }
}

/// Drives a [SelectListModel] against a [InlineTerminal], wiring keyboard input
/// to the model and rendering updates via a [BottomRegionRenderer].
///
/// Exposed for advanced use and testing; most callers should use [SelectList].
class SelectListRunner<T> {
  final SelectListModel<T> _model;
  final InlineTerminal _terminal;
  final SelectListStyle _style;
  final String? _prompt;

  /// Creates a runner for [model] rendered to [terminal] using [style].
  SelectListRunner({
    required final SelectListModel<T> model,
    required final InlineTerminal terminal,
    required final SelectListStyle style,
    final String? prompt,
  }) : _model = model,
       _terminal = terminal,
       _style = style,
       _prompt = prompt;

  /// Runs the interaction until the user submits, cancels, or aborts.
  Future<void> run() async {
    final renderer = BottomRegionRenderer(_terminal);
    final completer = Completer<void>();
    StreamSubscription<List<int>>? inputSubscription;
    StreamSubscription<void>? interruptSubscription;

    void restoreTerminal() {
      // Clear the hint row and leave the cursor at its start, keeping the menu
      // and the blank line above it so subsequent output begins there.
      renderer.finishClearingLastLine();
      _terminal.disableRawMode();
    }

    // Restores the terminal and resolves the run with the given [status],
    // throwing [UserAbortException] when aborted. Used for every exit path so
    // Ctrl+C is cleaned up exactly like a cancel.
    void finish(final SelectListStatus status) {
      restoreTerminal();
      unawaited(inputSubscription?.cancel());
      unawaited(interruptSubscription?.cancel());
      if (completer.isCompleted) return;
      if (status == SelectListStatus.aborted) {
        completer.completeError(UserAbortException());
      } else {
        completer.complete();
      }
    }

    _terminal.enableRawMode();
    renderer.hideCursor();
    // The prompt is printed once, above the re-rendered region. It is excluded
    // from re-renders because it may span several terminal rows (e.g. when it
    // contains newlines), which would otherwise break the region's row math.
    final prompt = _prompt;
    if (prompt != null) {
      _terminal.write('$prompt\n');
    }
    renderer.render(_buildLines());

    // A Ctrl+C in raw mode usually arrives as an interrupt signal rather than
    // an input byte, so handle it here and abort with the same cleanup.
    interruptSubscription = _terminal.interruptSignals.listen((final _) {
      finish(SelectListStatus.aborted);
    });

    inputSubscription = _terminal.input.listen(
      (final data) {
        var status = _model.status;
        for (final key in TuiKeyDecoder.decode(data)) {
          status = _model.handleKey(key);
          if (status != SelectListStatus.active) break;
        }

        if (status == SelectListStatus.active) {
          renderer.render(_buildLines());
          return;
        }

        finish(status);
      },
      onError: (final Object error, final StackTrace stackTrace) {
        restoreTerminal();
        unawaited(inputSubscription?.cancel());
        unawaited(interruptSubscription?.cancel());
        if (!completer.isCompleted) completer.completeError(error, stackTrace);
      },
      onDone: () {
        finish(SelectListStatus.cancelled);
      },
      cancelOnError: true,
    );

    return completer.future;
  }

  List<String> _buildLines() {
    // The prompt/header is intentionally not included here; it is printed once
    // above the region so it is never part of an in-place re-render.
    return buildSelectListLines<T>(
      _model,
      style: _style,
      useAnsiStyles: _terminal.supportsColor,
      columns: _terminal.columns,
      footer: _hint(),
    );
  }

  String _hint() {
    const navigate = 'up/down move';
    final select = _model.multiSelect
        ? 'space select, enter confirm'
        : 'enter select';
    const cancel = 'esc cancel';
    final hint = '$navigate, $select, $cancel';
    return '\n$hint';
  }
}
