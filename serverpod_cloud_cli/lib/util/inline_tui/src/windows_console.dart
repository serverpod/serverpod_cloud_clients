import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

/// The console input and output modes captured before raw mode was enabled, so
/// they can be restored afterwards.
class WindowsConsoleModes {
  /// The original mode of the console input buffer (STD_INPUT_HANDLE).
  final int stdinMode;

  /// The original mode of the console screen buffer (STD_OUTPUT_HANDLE).
  final int stdoutMode;

  /// Captures the [stdinMode] and [stdoutMode] to restore later.
  const WindowsConsoleModes(this.stdinMode, this.stdoutMode);
}

/// Windows console-mode helpers used to put the console into a raw,
/// virtual-terminal mode.
///
/// On Windows the Dart [stdin] byte stream is read with `ReadFile`, which does
/// not report arrow keys, Escape and other special keys unless the console
/// input buffer has `ENABLE_VIRTUAL_TERMINAL_INPUT` set. Setting [stdin.lineMode]
/// and [stdin.echoMode] (as done on Unix) is not enough, so this helper enables
/// virtual-terminal input via the Win32 API. Without it the inline TUI never
/// receives those keys.
///
/// All methods are no-ops on non-Windows platforms.
abstract final class WindowsConsole {
  // GetStdHandle identifiers, as unsigned 32-bit values: STD_INPUT_HANDLE is
  // (DWORD)-10 and STD_OUTPUT_HANDLE is (DWORD)-11.
  static const int _stdInputHandle = 0xFFFFFFF6;
  static const int _stdOutputHandle = 0xFFFFFFF5;

  static const int _enableLineInput = 0x0002;
  static const int _enableEchoInput = 0x0004;
  static const int _enableVirtualTerminalInput = 0x0200;
  static const int _enableVirtualTerminalProcessing = 0x0004;

  static final DynamicLibrary _kernel32 = DynamicLibrary.open('kernel32.dll');

  static final int Function(int nStdHandle) _getStdHandle = _kernel32
      .lookupFunction<IntPtr Function(Uint32), int Function(int)>(
        'GetStdHandle',
      );

  static final int Function(int hConsoleHandle, Pointer<Uint32> lpMode)
  _getConsoleMode = _kernel32
      .lookupFunction<
        Int32 Function(IntPtr, Pointer<Uint32>),
        int Function(int, Pointer<Uint32>)
      >('GetConsoleMode');

  static final int Function(int hConsoleHandle, int dwMode) _setConsoleMode =
      _kernel32.lookupFunction<
        Int32 Function(IntPtr, Uint32),
        int Function(int, int)
      >('SetConsoleMode');

  /// Switches the console into raw, virtual-terminal input mode and ensures the
  /// output supports virtual-terminal processing.
  ///
  /// Returns the previous modes so they can be passed to [restore], or null when
  /// not on Windows or the console mode could not be changed (e.g. output is
  /// redirected), in which case the caller should fall back to other handling.
  static WindowsConsoleModes? enableRawVirtualTerminal() {
    if (!Platform.isWindows) return null;
    try {
      final inHandle = _getStdHandle(_stdInputHandle);
      final outHandle = _getStdHandle(_stdOutputHandle);

      final inMode = _getConsoleModeOrNull(inHandle);
      final outMode = _getConsoleModeOrNull(outHandle);
      if (inMode == null || outMode == null) return null;

      // Disable line buffering and echo (like Unix raw mode) and enable VT input
      // so arrow keys, Escape, etc. arrive as ANSI escape sequences. Leave
      // ENABLE_PROCESSED_INPUT untouched so Ctrl+C keeps raising a signal.
      final newInMode =
          (inMode & ~_enableLineInput & ~_enableEchoInput) |
          _enableVirtualTerminalInput;
      _setConsoleMode(inHandle, newInMode);
      _setConsoleMode(outHandle, outMode | _enableVirtualTerminalProcessing);

      return WindowsConsoleModes(inMode, outMode);
    } on Object {
      return null;
    }
  }

  /// Restores the console [modes] captured by [enableRawVirtualTerminal].
  static void restore(final WindowsConsoleModes modes) {
    if (!Platform.isWindows) return;
    try {
      _setConsoleMode(_getStdHandle(_stdInputHandle), modes.stdinMode);
      _setConsoleMode(_getStdHandle(_stdOutputHandle), modes.stdoutMode);
    } on Object {
      // Best effort; nothing useful to do if restoring fails.
    }
  }

  static int? _getConsoleModeOrNull(final int handle) {
    final modePtr = calloc<Uint32>();
    try {
      if (_getConsoleMode(handle, modePtr) == 0) return null;
      return modePtr.value;
    } finally {
      calloc.free(modePtr);
    }
  }
}
