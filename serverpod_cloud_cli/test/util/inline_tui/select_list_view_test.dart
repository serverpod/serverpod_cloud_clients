import 'package:serverpod_cloud_cli/util/inline_tui/src/bottom_region_renderer.dart';
import 'package:serverpod_cloud_cli/util/inline_tui/src/select_list_model.dart';
import 'package:serverpod_cloud_cli/util/inline_tui/src/select_list_style.dart';
import 'package:serverpod_cloud_cli/util/inline_tui/src/select_list_view.dart';
import 'package:serverpod_cloud_cli/util/inline_tui/src/tui_key.dart';
import 'package:test/test.dart';

import 'helpers/fake_terminal.dart';

SelectListModel<String> _model(
  final List<String> labels, {
  final bool multiSelect = false,
}) {
  return SelectListModel<String>(
    items: [for (final l in labels) SelectListItem(value: l, label: l)],
    multiSelect: multiSelect,
  );
}

void main() {
  group('Given buildSelectListLines without color', () {
    const useAnsiStyles = false;
    final style = SelectListStyle();

    test('when single-select then the highlighted row has the pointer', () {
      final model = _model(['Apple', 'Banana']);
      final lines = buildSelectListLines(
        model,
        style: style,
        useAnsiStyles: useAnsiStyles,
        columns: 80,
      );

      expect(lines[0], '> (*) Apple');
      expect(lines[1], '  ( ) Banana');
    });

    test('when multi-select then rows use checkbox glyphs', () {
      final model = _model(['Apple', 'Banana'], multiSelect: true);
      model.handleKey(const TuiKey(TuiKeyType.space));
      final lines = buildSelectListLines(
        model,
        style: style,
        useAnsiStyles: useAnsiStyles,
        columns: 80,
      );

      expect(lines[0], '> [x] Apple');
      expect(lines[1], '  [ ] Banana');
    });

    test('when a header and footer are given then they bracket the rows', () {
      final model = _model(['Apple']);
      final lines = buildSelectListLines(
        model,
        style: style,
        columns: 80,
        header: 'Pick one',
        footer: 'hint',
        useAnsiStyles: useAnsiStyles,
      );

      expect(lines.first, 'Pick one');
      expect(lines.last, 'hint');
      expect(lines.length, 3);
    });

    test('when a row is wider than the terminal then it is truncated', () {
      final model = _model(['A very long label that exceeds the width']);
      final lines = buildSelectListLines(
        model,
        style: style,
        useAnsiStyles: useAnsiStyles,
        columns: 12,
      );

      expect(lines.single.length, lessThanOrEqualTo(12));
      expect(lines.single, endsWith('\u2026'));
    });
  });

  group('Given buildSelectListLines with color', () {
    const useAnsiStyles = true;
    final style = SelectListStyle();

    test('when a row is highlighted then it includes ANSI color codes', () {
      final model = _model(['Apple', 'Banana']);
      final lines = buildSelectListLines(
        model,
        style: style,
        useAnsiStyles: useAnsiStyles,
        columns: 80,
      );

      expect(lines[0], contains('\x1b['));
      expect(lines[0], endsWith('\x1b[0m'));
      expect(lines[1], isNot(contains('\x1b[')));
    });
  });

  group('Given a BottomRegionRenderer', () {
    test('when rendering for the first time then it writes the lines', () {
      final term = FakeTerminal();
      BottomRegionRenderer(term).render(['line 1', 'line 2']);

      expect(term.output, contains('line 1\nline 2'));
      expect(term.output, isNot(contains('\x1b[0J')));
    });

    test('when re-rendering then it moves up and clears the region', () {
      final term = FakeTerminal();
      final renderer = BottomRegionRenderer(term)..render(['a', 'b', 'c']);

      final before = term.output.length;
      renderer.render(['x', 'y', 'z']);
      final update = term.output.substring(before);

      expect(
        update,
        contains('\x1b[2A'),
        reason: 'moves up 2 rows for 3 lines',
      );
      expect(update, contains('\x1b[0J'), reason: 'clears the old region');
      expect(update, contains('x\ny\nz'));
    });

    test('when hiding and showing the cursor then escapes are written', () {
      final term = FakeTerminal();
      final renderer = BottomRegionRenderer(term)..hideCursor();
      expect(term.output, contains('\x1b[?25l'));

      renderer
        ..render(['a'])
        ..finish();
      expect(term.output, contains('\x1b[?25h'));
    });

    test('when finishing by clearing the last line then it clears that line '
        'and leaves the cursor at its start', () {
      final term = FakeTerminal();
      final renderer = BottomRegionRenderer(term)
        ..hideCursor()
        ..render(['a', 'b', 'c']);

      final before = term.output.length;
      renderer.finishClearingLastLine();
      final update = term.output.substring(before);

      // Moves to column 0 of the last line and clears to end of screen, without
      // moving up (the lines above are preserved) and without a trailing
      // newline (output continues at the cleared line).
      expect(update, '\r\x1b[0J\x1b[?25h');
      expect(update, isNot(contains('\x1b[3A')));
      expect(update, isNot(contains('\n')));
    });
  });
}
