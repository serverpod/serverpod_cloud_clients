import 'package:characters/characters.dart';

/// Matches a single ANSI escape (CSI) sequence, e.g. `\x1b[2m` or `\x1b[0m`.
final RegExp _ansiEscape = RegExp('\x1b\\[[0-9;?]*[a-zA-Z]');

/// Truncates [text] to at most [columns] - 1 visible columns, appending an
/// ellipsis when it is clipped.
///
/// Each grapheme cluster counts as one column and is never split, so wide
/// characters may take more terminal cells than counted. ANSI escape sequences
/// do not count as columns and are never cut mid-sequence. With [closeStyles],
/// clipped text that holds escape sequences ends with a reset, so a style cut
/// off before its own reset does not bleed into later output.
String fitAnsiToColumns(String text, int columns, {bool closeStyles = false}) {
  final maxWidth = columns - 1;
  if (maxWidth <= 0 || _visibleLength(text) <= maxWidth) return text;
  final clipped = maxWidth <= 1
      ? _takeVisibleColumns(text, maxWidth)
      : '${_takeVisibleColumns(text, maxWidth - 1)}…';
  if (closeStyles && clipped.contains(_ansiEscape)) {
    return '$clipped$_ansiReset';
  }
  return clipped;
}

const String _ansiReset = '\x1b[0m';

/// The number of grapheme clusters in [text], ignoring ANSI escape sequences.
int _visibleLength(String text) =>
    text.replaceAll(_ansiEscape, '').characters.length;

/// Returns the prefix of [text] holding its first [maxVisible] grapheme
/// clusters, copying any ANSI escape sequences verbatim. Escape sequences
/// immediately following the cut point (e.g. a trailing reset) are kept so
/// colors stay balanced.
String _takeVisibleColumns(String text, int maxVisible) {
  final buffer = StringBuffer();
  var visible = 0;
  var plainStart = 0;
  for (final escape in <RegExpMatch?>[..._ansiEscape.allMatches(text), null]) {
    final plainEnd = escape?.start ?? text.length;
    for (final grapheme in text.substring(plainStart, plainEnd).characters) {
      if (visible >= maxVisible) return buffer.toString();
      buffer.write(grapheme);
      visible++;
    }
    if (escape == null) break;
    buffer.write(escape[0]);
    plainStart = escape.end;
  }
  return buffer.toString();
}
