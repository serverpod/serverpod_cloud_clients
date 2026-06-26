import 'dart:async';
import 'dart:io';

import 'windows_console.dart';

/// Abstraction over the terminal used by the inline TUI components.
///
/// This indirection keeps the components testable: production code uses
/// [StdioTerminal], while tests can supply a fake implementation that records
/// output and feeds synthetic input.
abstract interface class InlineTerminal {
  /// Whether the terminal supports ANSI color escape codes.
  ///
  /// Cursor-movement escapes are assumed to be available on all supported
  /// platforms (modern Windows consoles, macOS and Linux); this flag only
  /// gates the use of colors so the output degrades gracefully.
  bool get supportsColor;

  /// Whether the process is attached to an interactive terminal (both input
  /// and output).
  bool get hasTerminal;

  /// The current width of the terminal in columns, or a sensible default when
  /// the width cannot be determined.
  int get columns;

  /// Raw input bytes from the terminal.
  ///
  /// Implementations must allow this stream to be listened to multiple times in
  /// sequence (one listener at a time), so several components can read input
  /// one after another.
  Stream<List<int>> get input;

  /// Emits an event when the user requests an interrupt (Ctrl+C / SIGINT).
  ///
  /// On most platforms a Ctrl+C in raw mode is delivered as a process signal
  /// rather than an input byte, and the default action terminates the process
  /// before the terminal can be restored. While a component is listening to
  /// this stream the default termination is suppressed, so the component can
  /// restore the terminal and abort gracefully.
  Stream<void> get interruptSignals;

  /// Writes [text] to the terminal without adding a trailing newline.
  void write(final String text);

  /// Switches the terminal into raw mode, disabling line buffering and echo so
  /// individual key presses can be read immediately.
  void enableRawMode();

  /// Restores the terminal modes that were active before [enableRawMode].
  void disableRawMode();

  /// Releases any resources held by the terminal.
  ///
  /// Individual components clean up after themselves before returning (e.g. by
  /// releasing their input subscription), so this only needs to be called once,
  /// towards the end of the process, by whoever owns the terminal's lifecycle.
  Future<void> dispose();
}

/// A [InlineTerminal] backed by the process standard input and output.
///
/// [stdin] is a single-subscription stream that can only ever be listened to
/// once for the lifetime of the process, and cancelling that subscription makes
/// it impossible to listen again. To allow several components to read input in
/// sequence, this class subscribes to the input source exactly once and
/// re-publishes its events through a long-lived broadcast stream.
///
/// Because the underlying subscription keeps the Dart VM alive, call [dispose]
/// once the program is completely finished reading terminal input so the
/// process can exit cleanly.
class StdioTerminal implements InlineTerminal {
  final Stdin _stdin;
  final Stdout _stdout;
  final Stream<List<int>> _inputSource;

  bool? _previousLineMode;
  bool? _previousEchoMode;
  WindowsConsoleModes? _previousWindowsModes;

  StreamController<List<int>>? _inputController;
  StreamSubscription<List<int>>? _inputSubscription;
  Stream<void>? _interruptSignals;

  /// Creates a terminal using the global [stdin] and [stdout] by default.
  ///
  /// [inputOverride] replaces the input source (intended for tests); it must be
  /// a single-subscription stream, mirroring the behavior of [stdin].
  StdioTerminal({
    final Stdin? stdinOverride,
    final Stdout? stdoutOverride,
    final Stream<List<int>>? inputOverride,
  }) : _stdin = stdinOverride ?? stdin,
       _stdout = stdoutOverride ?? stdout,
       _inputSource = inputOverride ?? stdinOverride ?? stdin;

  @override
  bool get supportsColor => _stdout.supportsAnsiEscapes;

  @override
  bool get hasTerminal => _stdout.hasTerminal && _stdin.hasTerminal;

  @override
  int get columns => _stdout.hasTerminal ? _stdout.terminalColumns : 80;

  @override
  Stream<List<int>> get input {
    final existing = _inputController;
    if (existing != null) return existing.stream;

    // The source subscription is paused whenever no component is listening, so
    // it does not drain input between components. Draining would both discard
    // bytes meant for other readers and, on the real stdin, make a synchronous
    // `readLineSync` (used by other prompt logic) block forever. Resuming on the
    // first listener and pausing again when the last one leaves keeps stdin
    // available for non-inline-tui input in between.
    final controller = StreamController<List<int>>.broadcast(
      onListen: () => _inputSubscription?.resume(),
      onCancel: () => _inputSubscription?.pause(),
    );
    // Listen to the single-subscription source exactly once and forward every
    // event to the broadcast controller. The controller stays open as listeners
    // come and go, so each component can subscribe in turn. It starts paused
    // until the first listener subscribes (see above).
    _inputSubscription = _inputSource.listen(
      controller.add,
      onError: controller.addError,
      onDone: () => unawaited(controller.close()),
    )..pause();
    _inputController = controller;
    return controller.stream;
  }

  @override
  Stream<void> get interruptSignals =>
      _interruptSignals ??= ProcessSignal.sigint.watch().map((final _) {});

  /// Cancels the input subscription and releases resources.
  ///
  /// Must be called when the program is done reading terminal input; otherwise
  /// the live input subscription keeps the process from exiting.
  @override
  Future<void> dispose() async {
    final subscription = _inputSubscription;
    final controller = _inputController;
    _inputSubscription = null;
    _inputController = null;
    await subscription?.cancel();
    if (controller != null && !controller.isClosed) {
      await controller.close();
    }
  }

  @override
  void write(final String text) => _stdout.write(text);

  @override
  void enableRawMode() {
    if (!_stdin.hasTerminal) return;
    // On Windows, Dart's stdin does not deliver arrow keys, Escape, etc. unless
    // the console is put into virtual-terminal input mode. Manage the console
    // mode directly there; fall back to the line/echo toggles if that fails.
    if (Platform.isWindows) {
      final previous = WindowsConsole.enableRawVirtualTerminal();
      if (previous != null) {
        _previousWindowsModes = previous;
        return;
      }
    }
    _previousEchoMode = _stdin.echoMode;
    _previousLineMode = _stdin.lineMode;
    // Disabling line mode also disables echo on Windows; set echo first to
    // avoid a transient state where input is echoed.
    _stdin.echoMode = false;
    _stdin.lineMode = false;
  }

  @override
  void disableRawMode() {
    if (!_stdin.hasTerminal) return;
    final previousWindowsModes = _previousWindowsModes;
    if (previousWindowsModes != null) {
      WindowsConsole.restore(previousWindowsModes);
      _previousWindowsModes = null;
      return;
    }
    final previousLineMode = _previousLineMode;
    final previousEchoMode = _previousEchoMode;
    if (previousLineMode != null) {
      _stdin.lineMode = previousLineMode;
    }
    if (previousEchoMode != null) {
      _stdin.echoMode = previousEchoMode;
    }
    _previousLineMode = null;
    _previousEchoMode = null;
  }
}
