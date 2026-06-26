import 'inline_terminal.dart';

/// Renders and updates a block of text lines anchored at the bottom of the
/// terminal, without taking over the full screen.
///
/// The renderer only ever writes to and clears the lines it owns, so any output
/// above the rendered region (e.g. previous command output) is left untouched.
/// It relies on ANSI cursor-movement escape codes, which are supported by
/// modern Windows consoles as well as macOS and Linux terminals.
class BottomRegionRenderer {
  static const String _esc = '\x1b';

  final InlineTerminal _terminal;
  int _renderedLineCount = 0;
  bool _cursorHidden = false;

  /// Creates a renderer that writes to [terminal].
  BottomRegionRenderer(this._terminal);

  /// Hides the terminal cursor while the region is interactive.
  void hideCursor() {
    if (_cursorHidden) return;
    _cursorHidden = true;
    _terminal.write('$_esc[?25l');
  }

  /// Shows the terminal cursor again.
  void showCursor() {
    if (!_cursorHidden) return;
    _cursorHidden = false;
    _terminal.write('$_esc[?25h');
  }

  /// Draws [lines], replacing any previously rendered region in place.
  ///
  /// Each entry should fit within a single terminal row so the in-place updates
  /// stay aligned; fitting the visible text to the terminal width is the
  /// responsibility of the caller (so that ANSI color codes are preserved).
  void render(final List<String> lines) {
    final buffer = StringBuffer();

    if (_renderedLineCount > 0) {
      buffer.write('\r');
      if (_renderedLineCount > 1) {
        buffer.write('$_esc[${_renderedLineCount - 1}A');
      }
      // Clear from the start of the region to the end of the screen.
      buffer.write('$_esc[0J');
    }

    for (var i = 0; i < lines.length; i++) {
      buffer.write(lines[i]);
      if (i < lines.length - 1) buffer.write('\n');
    }

    _terminal.write(buffer.toString());
    _renderedLineCount = lines.length;
  }

  /// Finishes rendering by optionally drawing a final set of [lines], then
  /// moving the cursor below the region and restoring the cursor visibility.
  void finish({final List<String>? lines}) {
    if (lines != null) {
      render(lines);
    }
    if (_renderedLineCount > 0) {
      _terminal.write('\n');
    }
    showCursor();
    _renderedLineCount = 0;
  }

  /// Finishes by clearing only the last rendered line, preserving the lines
  /// above it and leaving the cursor at the start of the cleared line.
  ///
  /// Subsequent output therefore begins where the last line was. Relies on the
  /// cursor being at the end of the last rendered line, which is the case right
  /// after a [render].
  void finishClearingLastLine() {
    if (_renderedLineCount > 0) {
      // Move to the start of the (current) last line and clear from there to
      // the end of the screen.
      _terminal.write('\r$_esc[0J');
    }
    showCursor();
    _renderedLineCount = 0;
  }

  /// Clears the rendered region entirely, leaving the cursor at the region
  /// start and restoring cursor visibility.
  void clear() {
    if (_renderedLineCount > 0) {
      final buffer = StringBuffer('\r');
      if (_renderedLineCount > 1) {
        buffer.write('$_esc[${_renderedLineCount - 1}A');
      }
      buffer.write('$_esc[0J');
      _terminal.write(buffer.toString());
      _renderedLineCount = 0;
    }
    showCursor();
  }
}
