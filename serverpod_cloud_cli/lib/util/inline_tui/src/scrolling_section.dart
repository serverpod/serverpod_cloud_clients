import 'dart:async';
import 'dart:collection';

import 'bottom_region_renderer.dart';
import 'inline_terminal.dart';

/// Schedules [onTick] to be called every [period], returning a callback that
/// cancels the scheduled ticking.
///
/// Exposed primarily so tests can drive the spinner animation deterministically
/// instead of relying on a real periodic timer.
typedef SpinnerScheduler =
    void Function() Function(Duration period, void Function() onTick);

/// What to do with the section body when [ScrollingSection.finish] is called.
enum RetainSection {
  /// Leave the currently visible lines in place.
  keepCurrent,

  /// Re-display the complete captured output (requires
  /// [ScrollingSection.captureOutput]).
  keepFull,

  /// Remove the scrolling lines. The heading is kept when one is present.
  clear,
}

/// A fixed-height scrolling output region anchored at the bottom of the
/// terminal.
///
/// Lines appended with [appendLine] scroll within at most [rows] visual rows:
/// only the most recent [rows] lines are shown, older lines scroll out of view.
/// The region renders in place and leaves any output above it untouched, so it
/// is well suited for tailing the output of a long-running subprocess.
///
/// When done, call [finish] with a [success] flag. Body retention comes from
/// [successRetention] / [failureRetention], or from [finish]'s
/// [overrideRetention] when one is passed.
///
/// An optional [heading] is rendered immediately above the scrolling lines,
/// prefixed with an animated braille spinner and suffixed with an elapsed-time
/// counter (e.g. `⠹ Building (1.2s)`). When the section is finished, the spinner
/// is replaced with a success (`✓`) or failure (`✗`) icon and the heading is
/// replaced with [successMessage] or [failedMessage] when the relevant message
/// is non-null; otherwise the heading is left in place. The final elapsed time
/// is kept either way.
class ScrollingSection {
  static const String _esc = '\x1b';
  static const String _dimStyle = '$_esc[2m';
  static const String _greenStyle = '$_esc[92m';
  static const String _redStyle = '$_esc[91m';
  static const String _grayStyle = '$_esc[90m';
  static const String _reset = '$_esc[0m';

  /// The braille spinner frames cycled through while a [heading] is shown.
  static const String _brailleFrames = '⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏';

  /// The icon that replaces the spinner when finishing successfully.
  static const String _successIcon = '\u2713';

  /// The icon that replaces the spinner when finishing with a failure.
  static const String _failureIcon = '\u2717';

  static const Duration _defaultSpinnerInterval = Duration(milliseconds: 80);

  final InlineTerminal _terminal;
  final BottomRegionRenderer _renderer;

  /// The maximum number of visual rows the section occupies.
  final int rows;

  /// Whether to render the scrolled lines dimmed (only when the terminal
  /// supports color).
  final bool dim;

  /// An optional heading rendered undimmed immediately above the scrolling
  /// lines.
  ///
  /// Mutable so callers can reflect changing progress in the heading text via
  /// [updateHeading]; use the constructor's `heading` parameter for the
  /// initial value.
  String? _heading;

  /// The message that replaces the [heading] when [finish] is called with
  /// `success: true`. Ignored when null.
  final String? successMessage;

  /// The message that replaces the [heading] when [finish] is called with
  /// `success: false`. Ignored when null.
  final String? failedMessage;

  /// What happens to the body when [finish] is called with `success: true`.
  final RetainSection successRetention;

  /// What happens to the body when [finish] is called with `success: false`.
  final RetainSection failureRetention;

  /// Whether every appended line is retained (in addition to the [rows] visible
  /// ones) so the complete output can be re-displayed, e.g. on failure.
  ///
  /// Disabled by default to avoid unbounded memory use for very long-running
  /// processes; enable it when the full output may be needed.
  final bool captureOutput;

  final Duration _spinnerInterval;
  final Duration Function()? _elapsedOverride;
  final SpinnerScheduler _scheduleTicker;
  final Stopwatch _stopwatch = Stopwatch();

  final ListQueue<String> _visibleLines = ListQueue<String>();
  final List<String> _captured = [];
  bool _spinnerActive = false;
  int _frameIndex = 0;
  void Function()? _cancelTicker;
  String? _finishMessage;
  bool _success = false;
  bool _started = false;
  bool _finished = false;

  /// Creates a scrolling section rendered to [terminal].
  ///
  /// [rows] is the fixed number of visual rows (must be at least 1, default 5).
  ///
  /// [successRetention] and [failureRetention] choose what happens to the body
  /// when [finish] is called, unless that call passes [overrideRetention].
  ///
  /// [spinnerInterval] controls how often the spinner advances. [elapsed] and
  /// [scheduleTicker] are injection points for tests so the animation and
  /// elapsed time can be driven deterministically; production code should leave
  /// them unset.
  ScrollingSection({
    required InlineTerminal terminal,
    this.rows = 5,
    this.dim = true,
    String? heading,
    this.successMessage,
    this.failedMessage,
    final RetainSection? successRetention,
    final RetainSection? failureRetention,
    this.captureOutput = false,
    Duration spinnerInterval = _defaultSpinnerInterval,
    Duration Function()? elapsed,
    SpinnerScheduler? scheduleTicker,
  }) : assert(rows >= 1, 'rows must be at least 1'),
       _heading = heading,
       successRetention = successRetention ?? RetainSection.clear,
       failureRetention = failureRetention ?? RetainSection.keepFull,
       _terminal = terminal,
       _renderer = BottomRegionRenderer(terminal),
       _spinnerInterval = spinnerInterval,
       _elapsedOverride = elapsed,
       _scheduleTicker = scheduleTicker ?? _defaultScheduler {
    // Show the heading immediately, even before any output arrives, and start
    // the spinner/elapsed animation alongside it.
    if (heading != null) {
      _started = true;
      _renderer.hideCursor();
      _spinnerActive = _terminal.hasTerminal;
      if (_spinnerActive) {
        _stopwatch.start();
        _cancelTicker = _scheduleTicker(_spinnerInterval, _tick);
      }
      _render();
    }
  }

  /// Runs a heading-only spinner (no scrolling output lines) while consuming
  /// [stream].
  ///
  /// The heading starts as [heading] and is updated with [toMessage] for each
  /// event. When the stream ends, the spinner is completed with [success]
  /// from [isSuccess] of the last event, or a clean end if [isSuccess] is
  /// omitted. A stream error or an empty stream finishes as a failure; the
  /// error is rethrown, and an empty stream throws [StateError].
  static Future<T> runSpinner<T>(
    InlineTerminal terminal, {
    required String heading,
    required Stream<T> stream,
    String Function(T)? toMessage,
    bool Function(T)? isSuccess,
    String? successMessage,
    String? failedMessage,
    Duration spinnerInterval = _defaultSpinnerInterval,
    Duration Function()? elapsed,
    SpinnerScheduler? scheduleTicker,
  }) async {
    final section = ScrollingSection(
      terminal: terminal,
      rows: 1,
      heading: heading,
      successMessage: successMessage,
      failedMessage: failedMessage,
      spinnerInterval: spinnerInterval,
      elapsed: elapsed,
      scheduleTicker: scheduleTicker,
    );

    T? lastEvent;
    try {
      await for (final event in stream) {
        lastEvent = event;
        final messageForEvent = toMessage;
        if (messageForEvent != null) {
          section.updateHeading(messageForEvent(event));
        }
      }
      final event = lastEvent;
      if (event == null) {
        section.finish(success: false);
        throw StateError('Stream was empty');
      }
      section.finish(success: isSuccess?.call(event) ?? true);
      return event;
    } on Object {
      if (!section.isFinished) {
        section.finish(success: false);
      }
      rethrow;
    }
  }

  static void Function() _defaultScheduler(
    Duration period,
    void Function() onTick,
  ) {
    final timer = Timer.periodic(period, (_) => onTick());
    return timer.cancel;
  }

  Duration get _elapsedTime => _elapsedOverride?.call() ?? _stopwatch.elapsed;

  /// Formats [duration] like the reference spinner: sub-100ms in milliseconds,
  /// otherwise seconds with a single decimal.
  static String _formatElapsed(Duration duration) {
    final ms = duration.inMilliseconds;
    if (ms < 100) return '${ms}ms';
    return '${(ms / 1000).toStringAsFixed(1)}s';
  }

  void _tick() {
    if (_finished) return;
    _frameIndex++;
    _render();
  }

  void _stopSpinner() {
    _stopwatch.stop();
    _cancelTicker?.call();
    _cancelTicker = null;
  }

  /// The lines currently visible in the section, oldest first.
  List<String> get visibleLines => List.unmodifiable(_visibleLines);

  /// All lines appended to the section, oldest first.
  ///
  /// Only populated when [captureOutput] is true; otherwise empty.
  List<String> get capturedOutput => List.unmodifiable(_captured);

  /// Whether the section has been finished with [finish].
  bool get isFinished => _finished;

  /// Updates the heading text and re-renders.
  ///
  /// Has no effect once the section [isFinished]; the completion message
  /// ([successMessage] or [failedMessage]) still takes precedence at that
  /// point, exactly as it did with the heading set at construction time.
  void updateHeading(String newHeading) {
    if (_finished) return;
    _heading = newHeading;
    _render();
  }

  /// Appends [line] to the section and re-renders.
  ///
  /// If [line] itself contains newlines it is split so each part occupies a
  /// single visual row. Once more than [rows] lines have been appended, the
  /// oldest lines scroll out of view.
  void appendLine(String line) {
    if (_finished) {
      throw StateError('Cannot append to a finished ScrollingSection.');
    }

    if (!_started) {
      _started = true;
      _renderer.hideCursor();
    }

    for (final part in line.split('\n')) {
      _visibleLines.addLast(part);
      while (_visibleLines.length > rows) {
        _visibleLines.removeFirst();
      }
      if (captureOutput) _captured.add(part);
    }

    _render();
  }

  /// Finishes the section.
  ///
  /// [success] selects the completion icon (`✓` or `✗`) and which of
  /// [successMessage] / [failedMessage] replaces the heading (when non-null).
  ///
  /// Body retention is [successRetention] or [failureRetention] unless
  /// [overrideRetention] is passed:
  /// * [RetainSection.keepCurrent] leaves the visible lines in place
  /// * [RetainSection.keepFull] re-displays the complete captured output
  ///   (when [captureOutput] was enabled)
  /// * [RetainSection.clear] removes the scrolling lines; the heading is kept
  ///   when one is present, otherwise the region is cleared entirely
  void finish({required bool success, RetainSection? overrideRetention}) {
    if (_finished) return;
    _finished = true;
    _success = success;
    _stopSpinner();
    _finishMessage = success ? successMessage : failedMessage;
    final retention =
        overrideRetention ?? (success ? successRetention : failureRetention);
    switch (retention) {
      case RetainSection.clear:
        final header = _buildHeaderLine(_terminal.columns);
        if (header != null) {
          _renderer.finish(lines: [header]);
        } else {
          _renderer.clear();
        }
      case RetainSection.keepCurrent:
        _renderer.finish(lines: _buildLines());
      case RetainSection.keepFull:
        _renderer.finish(lines: _buildLines(full: true));
    }
  }

  void _render() {
    _renderer.render(_buildLines());
  }

  List<String> _buildLines({bool full = false}) {
    final width = _terminal.columns;
    final header = _buildHeaderLine(width);
    if (full && captureOutput) {
      // Render the complete output untruncated (the terminal wraps long lines)
      // and undimmed, since this is a one-shot final render for inspection.
      return [?header, for (final line in _captured) _formatFull(line)];
    }
    return [
      ?header,
      for (final line in _visibleLines) _format(line, width, dimmed: dim),
    ];
  }

  String _formatFull(String line) {
    if (!_terminal.supportsColor) return line;
    // Keep any color codes but reset at the end so they do not bleed.
    return line.contains(_esc) ? '$line$_reset' : line;
  }

  /// Builds the fully formatted (fitted and colored) header line, or null when
  /// there is no header to show.
  ///
  /// While running this is the green braille spinner, [heading] and gray elapsed
  /// time. Once finished the spinner is replaced with a green `✓` (success) or
  /// red `✗` (failure) icon and [heading] is replaced with the completion
  /// message when one is set, keeping the gray elapsed time. Colors are only
  /// applied when the terminal supports them.
  String? _buildHeaderLine(int width) {
    if (!_finished) {
      final text = _heading;
      if (text == null) return null;
      if (!_spinnerActive) return _format(text, width, dimmed: false);
      final frame = _brailleFrames[_frameIndex % _brailleFrames.length];
      final elapsed = '(${_formatElapsed(_elapsedTime)})';
      return _composeHeader(frame, _greenStyle, text, elapsed, width);
    }

    final base = _finishMessage ?? _heading;
    if (base == null) return null;
    if (!_spinnerActive) return _format(base, width, dimmed: false);
    final icon = _success ? _successIcon : _failureIcon;
    final iconStyle = _success ? _greenStyle : _redStyle;
    final elapsed = '(${_formatElapsed(_elapsedTime)})';
    return _composeHeader(icon, iconStyle, base, elapsed, width);
  }

  /// Composes a header from a leading [marker] (spinner frame or completion
  /// icon) styled with [markerStyle], the [text] label and a gray [elapsed]
  /// segment. Falls back to the plain, fitted text when color is unsupported or
  /// the colored line would not fit.
  String _composeHeader(
    String marker,
    String markerStyle,
    String text,
    String elapsed,
    int width,
  ) {
    final plain = '$marker $text $elapsed';
    final fitted = _fit(plain, width);
    if (!_terminal.supportsColor || fitted != plain) {
      return fitted.contains(_esc) ? '$fitted$_reset' : fitted;
    }
    return '$markerStyle$marker$_reset $text $_grayStyle$elapsed$_reset';
  }

  String _format(String line, int width, {required bool dimmed}) {
    final text = _fit(line, width);
    if (!_terminal.supportsColor) return text;
    // A trailing reset prevents any color codes in the subprocess output (or
    // the dim style) from bleeding into following rows or later output.
    final needsReset = dimmed || text.contains(_esc);
    if (!needsReset) return text;
    return '${dimmed ? _dimStyle : ''}$text$_reset';
  }

  /// Matches a single ANSI escape (CSI) sequence, e.g. `\x1b[2m` or `\x1b[0m`.
  static final RegExp _ansiEscape = RegExp('$_esc\\[[0-9;?]*[a-zA-Z]');

  /// The number of visible columns in [text], ignoring ANSI escape sequences.
  static int _visibleLength(String text) =>
      text.replaceAll(_ansiEscape, '').length;

  /// Truncates [text] to at most [columns] - 1 visible columns, appending an
  /// ellipsis when it is clipped.
  ///
  /// ANSI escape sequences are not counted as visible columns and are never cut
  /// mid-sequence, so colored subprocess output stays well-formed even when it
  /// exceeds the terminal width.
  static String _fit(String text, int columns) {
    final maxWidth = columns - 1;
    if (maxWidth <= 0 || _visibleLength(text) <= maxWidth) return text;
    if (maxWidth <= 1) return _takeVisibleColumns(text, maxWidth);
    return '${_takeVisibleColumns(text, maxWidth - 1)}\u2026';
  }

  /// Returns the prefix of [text] holding its first [maxVisible] visible
  /// columns, copying any ANSI escape sequences verbatim (they do not count
  /// towards the visible width). Escape sequences immediately following the cut
  /// point (e.g. a trailing reset) are kept so colors stay balanced.
  static String _takeVisibleColumns(String text, int maxVisible) {
    final buffer = StringBuffer();
    var visible = 0;
    var i = 0;
    while (i < text.length) {
      final escape = _ansiEscape.matchAsPrefix(text, i);
      if (escape != null) {
        buffer.write(text.substring(i, escape.end));
        i = escape.end;
        continue;
      }
      if (visible >= maxVisible) break;
      buffer.writeCharCode(text.codeUnitAt(i));
      visible++;
      i++;
    }
    return buffer.toString();
  }
}
