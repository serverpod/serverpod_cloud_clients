import 'dart:convert';

/// The logical type of a key press read from the terminal.
enum TuiKeyType {
  /// The up arrow key (or an equivalent navigation key).
  arrowUp,

  /// The down arrow key (or an equivalent navigation key).
  arrowDown,

  /// The left arrow key.
  arrowLeft,

  /// The right arrow key.
  arrowRight,

  /// The Enter/Return key.
  enter,

  /// The space bar.
  space,

  /// The Escape key.
  escape,

  /// The Tab key.
  tab,

  /// The Backspace/Delete key.
  backspace,

  /// The Home key.
  home,

  /// The End key.
  end,

  /// The Page Up key.
  pageUp,

  /// The Page Down key.
  pageDown,

  /// Ctrl+C.
  ctrlC,

  /// A printable character. The value is available in [TuiKey.character].
  character,

  /// An unrecognized key or byte sequence.
  unknown,
}

/// A single key press decoded from terminal input.
class TuiKey {
  /// The logical type of this key.
  final TuiKeyType type;

  /// The printable character, set only when [type] is [TuiKeyType.character].
  final String? character;

  /// Creates a key of the given [type] with an optional [character].
  const TuiKey(this.type, {this.character});

  @override
  bool operator ==(final Object other) =>
      other is TuiKey && other.type == type && other.character == character;

  @override
  int get hashCode => Object.hash(type, character);

  @override
  String toString() => character != null
      ? 'TuiKey(${type.name}, "$character")'
      : 'TuiKey(${type.name})';
}

/// Decodes raw terminal input bytes into a list of [TuiKey]s.
///
/// Handles the escape sequences used by Unix-like terminals as well as the
/// special-key encodings emitted by the Windows console, so the same logical
/// keys are produced on all platforms.
abstract final class TuiKeyDecoder {
  static const int _esc = 0x1b;
  static const int _bracket = 0x5b; // '['
  static const int _letterO = 0x4f; // 'O'

  /// Decodes a single chunk of input [data] into logical keys.
  ///
  /// Terminals deliver complete escape sequences within a single read in raw
  /// mode, so a lone escape byte at the end of a chunk is interpreted as the
  /// Escape key.
  static List<TuiKey> decode(final List<int> data) {
    final keys = <TuiKey>[];
    var i = 0;
    while (i < data.length) {
      final byte = data[i];

      if (byte == _esc) {
        i = _decodeEscapeSequence(data, i, keys);
        continue;
      }

      // Windows console prefixes special keys with 0x00 or 0xE0.
      if ((byte == 0x00 || byte == 0xe0) && i + 1 < data.length) {
        final key = _windowsSpecialKey(data[i + 1]);
        if (key != null) {
          keys.add(key);
          i += 2;
          continue;
        }
      }

      final controlKey = _controlKey(byte);
      if (controlKey != null) {
        keys.add(controlKey);
        i += 1;
        continue;
      }

      // Printable characters, including multi-byte UTF-8 sequences.
      if (byte > 0x20 && byte != 0x7f) {
        final end = _printableRunEnd(data, i);
        final text = utf8.decode(data.sublist(i, end), allowMalformed: true);
        for (final rune in text.runes) {
          keys.add(
            TuiKey(TuiKeyType.character, character: String.fromCharCode(rune)),
          );
        }
        i = end;
        continue;
      }

      keys.add(const TuiKey(TuiKeyType.unknown));
      i += 1;
    }
    return keys;
  }

  static int _decodeEscapeSequence(
    final List<int> data,
    final int start,
    final List<TuiKey> keys,
  ) {
    // CSI sequences: ESC [ ... and application mode: ESC O ...
    final next = start + 1 < data.length ? data[start + 1] : null;
    if (next == _bracket || next == _letterO) {
      final code = start + 2 < data.length ? data[start + 2] : null;
      final key = _csiKey(code);
      if (key != null) {
        // Some sequences (Home/End/PageUp/PageDown) end with '~'.
        final tilde = start + 3 < data.length ? data[start + 3] : null;
        if (tilde == 0x7e) {
          keys.add(key);
          return start + 4;
        }
        keys.add(key);
        return start + 3;
      }
      keys.add(const TuiKey(TuiKeyType.unknown));
      return _escapeSequenceEnd(data, start + 2);
    }

    // A bare escape byte is the Escape key.
    keys.add(const TuiKey(TuiKeyType.escape));
    return start + 1;
  }

  static int _escapeSequenceEnd(final List<int> data, final int start) {
    var i = start;
    while (i < data.length) {
      final byte = data[i];
      if (byte >= 0x40 && byte <= 0x7e) return i + 1;
      i++;
    }
    return data.length;
  }

  static TuiKey? _csiKey(final int? code) {
    switch (code) {
      case 0x41: // 'A'
        return const TuiKey(TuiKeyType.arrowUp);
      case 0x42: // 'B'
        return const TuiKey(TuiKeyType.arrowDown);
      case 0x43: // 'C'
        return const TuiKey(TuiKeyType.arrowRight);
      case 0x44: // 'D'
        return const TuiKey(TuiKeyType.arrowLeft);
      case 0x48: // 'H'
        return const TuiKey(TuiKeyType.home);
      case 0x46: // 'F'
        return const TuiKey(TuiKeyType.end);
      case 0x35: // '5' -> Page Up (ESC [ 5 ~)
        return const TuiKey(TuiKeyType.pageUp);
      case 0x36: // '6' -> Page Down (ESC [ 6 ~)
        return const TuiKey(TuiKeyType.pageDown);
      default:
        return null;
    }
  }

  static TuiKey? _windowsSpecialKey(final int code) {
    switch (code) {
      case 0x48: // Up
        return const TuiKey(TuiKeyType.arrowUp);
      case 0x50: // Down
        return const TuiKey(TuiKeyType.arrowDown);
      case 0x4b: // Left
        return const TuiKey(TuiKeyType.arrowLeft);
      case 0x4d: // Right
        return const TuiKey(TuiKeyType.arrowRight);
      case 0x47: // Home
        return const TuiKey(TuiKeyType.home);
      case 0x4f: // End
        return const TuiKey(TuiKeyType.end);
      case 0x49: // Page Up
        return const TuiKey(TuiKeyType.pageUp);
      case 0x51: // Page Down
        return const TuiKey(TuiKeyType.pageDown);
      default:
        return null;
    }
  }

  static TuiKey? _controlKey(final int byte) {
    switch (byte) {
      case 0x0d: // CR
      case 0x0a: // LF
        return const TuiKey(TuiKeyType.enter);
      case 0x20:
        return const TuiKey(TuiKeyType.space);
      case 0x09:
        return const TuiKey(TuiKeyType.tab);
      case 0x7f: // DEL
      case 0x08: // BS
        return const TuiKey(TuiKeyType.backspace);
      case 0x03:
        return const TuiKey(TuiKeyType.ctrlC);
      default:
        return null;
    }
  }

  static int _printableRunEnd(final List<int> data, final int start) {
    var end = start;
    while (end < data.length) {
      final byte = data[end];
      final isPrintable = byte > 0x20 && byte != 0x7f;
      if (!isPrintable) break;
      end++;
    }
    return end;
  }
}
