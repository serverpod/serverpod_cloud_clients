import 'ansi_style.dart';

/// The visual glyphs and color settings used when rendering a select list.
///
/// Defaults use plain ASCII glyphs for maximum compatibility across terminals,
/// including the Windows console where Unicode rendering can be unreliable.
class SelectListStyle {
  static const defaultHighlightStyle = AnsiStyle.cyanBold;
  static const defaultDimStyle = AnsiStyle.gray;

  /// Marker drawn to the left of the highlighted row.
  final String pointer;

  /// Marker drawn to the left of non-highlighted rows.
  final String noPointer;

  /// Glyph for a checked item in a multi-select list.
  final String checkedBox;

  /// Glyph for an unchecked item in a multi-select list.
  final String uncheckedBox;

  /// Glyph for the selected item in a single-select list.
  final String radioOn;

  /// Glyph for non-selected items in a single-select list.
  final String radioOff;

  /// ANSI style for dimmed text, or null if unstyled.
  final String? dimStyle;

  /// ANSI style for highlighted text, or null if unstyled.
  final String? highlightStyle;

  /// Creates a style. See the field docs for the meaning of each glyph.
  SelectListStyle({
    this.pointer = '>',
    this.noPointer = ' ',
    this.checkedBox = '[x]',
    this.uncheckedBox = '[ ]',
    this.radioOn = '(*)',
    this.radioOff = '( )',
    final String? dimStyle,
    final String? highlightStyle,
  }) : dimStyle = dimStyle ?? defaultDimStyle.ansiCode,
       highlightStyle = highlightStyle ?? defaultHighlightStyle.ansiCode;

  /// A style using Unicode glyphs for terminals that render them well.
  SelectListStyle.unicode({
    final String? dimStyle,
    final String? highlightStyle,
  }) : this(
         pointer: '\u276f', // ❯
         checkedBox: '\u25c9', // ◉
         uncheckedBox: '\u25ef', // ◯
         radioOn: '\u25c9',
         radioOff: '\u25ef',
         dimStyle: dimStyle,
         highlightStyle: highlightStyle,
       );
}
