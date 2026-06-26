import 'ansi_style.dart';
import 'select_list_model.dart';
import 'select_list_style.dart';

/// Builds the lines that visually represent the [model].
///
/// An optional [header] is shown above the rows and an optional [footer] (such
/// as a key hint) below them. A [footer] containing newlines is split into one
/// entry per line so each returned entry occupies a single terminal row.
/// [columns] is used to fit each row to the terminal width while keeping any
/// color codes intact.
List<String> buildSelectListLines<T>(
  final SelectListModel<T> model, {
  required final SelectListStyle style,
  required final bool useAnsiStyles,
  required final int columns,
  final String? header,
  final String? footer,
}) {
  final lines = <String>[];
  if (header != null) lines.add(_fit(header, columns));

  for (var i = 0; i < model.items.length; i++) {
    final item = model.items[i];
    final highlighted = i == model.highlightedIndex;
    final pointer = highlighted ? style.pointer : style.noPointer;

    final String marker;
    if (model.multiSelect) {
      marker = model.isSelected(i) ? style.checkedBox : style.uncheckedBox;
    } else {
      // In single-select the highlighted row is the prospective choice.
      marker = highlighted ? style.radioOn : style.radioOff;
    }

    final text = _fit('$pointer $marker ${item.label}', columns);
    lines.add(
      _decorate(
        text,
        highlighted: highlighted,
        enabled: item.enabled,
        style: style,
        useAnsiStyles: useAnsiStyles,
      ),
    );
  }

  if (footer != null) {
    for (final footerLine in footer.split('\n')) {
      final line = useAnsiStyles ? _dimText(footerLine, style) : footerLine;
      lines.add(_fit(line, columns));
    }
  }
  return lines;
}

String _decorate(
  final String text, {
  required final bool highlighted,
  required final bool enabled,
  required final SelectListStyle style,
  required final bool useAnsiStyles,
}) {
  if (!useAnsiStyles) return text;
  if (!enabled) return _dimText(text, style);
  if (highlighted) return _highlightText(text, style);
  return text;
}

String _dimText(final String text, final SelectListStyle style) {
  final dimStyle = style.dimStyle;
  if (dimStyle == null) return text;
  return dimStyle + text + AnsiStyle.reset.ansiCode;
}

String _highlightText(final String text, final SelectListStyle style) {
  final highlightStyle = style.highlightStyle;
  if (highlightStyle == null) return text;
  return highlightStyle + text + AnsiStyle.reset.ansiCode;
}

String _fit(final String text, final int columns) {
  final maxWidth = columns - 1;
  if (maxWidth <= 0 || text.length <= maxWidth) return text;
  if (maxWidth <= 1) return text.substring(0, maxWidth);
  return '${text.substring(0, maxWidth - 1)}\u2026';
}
