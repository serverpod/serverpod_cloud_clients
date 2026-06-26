import 'package:serverpod_cloud_cli/util/inline_tui/src/select_list_model.dart';
import 'package:serverpod_cloud_cli/util/inline_tui/src/tui_key.dart';
import 'package:test/test.dart';

SelectListModel<String> _model(
  final List<String> labels, {
  final bool multiSelect = false,
  final int minSelections = 0,
  final int? maxSelections,
  final Set<int> disabled = const {},
}) {
  return SelectListModel<String>(
    items: [
      for (var i = 0; i < labels.length; i++)
        SelectListItem<String>(
          value: labels[i],
          label: labels[i],
          enabled: !disabled.contains(i),
        ),
    ],
    multiSelect: multiSelect,
    minSelections: minSelections,
    maxSelections: maxSelections,
  );
}

void main() {
  group('Given a single-select model', () {
    test('when navigating down then highlight advances without wrapping', () {
      final model = _model(['a', 'b', 'c']);

      model.handleKey(const TuiKey(TuiKeyType.arrowDown));
      expect(model.highlightedIndex, 1);

      model.handleKey(const TuiKey(TuiKeyType.arrowDown));
      model.handleKey(const TuiKey(TuiKeyType.arrowDown));
      expect(model.highlightedIndex, 2, reason: 'should not wrap past the end');
    });

    test('when navigating up at the top then highlight stays at the top', () {
      final model = _model(['a', 'b']);
      model.handleKey(const TuiKey(TuiKeyType.arrowUp));
      expect(model.highlightedIndex, 0);
    });

    test('when pressing j and k then highlight moves down and up', () {
      final model = _model(['a', 'b', 'c']);
      model.handleKey(const TuiKey(TuiKeyType.character, character: 'j'));
      expect(model.highlightedIndex, 1);
      model.handleKey(const TuiKey(TuiKeyType.character, character: 'k'));
      expect(model.highlightedIndex, 0);
    });

    test('when pressing Home/End then highlight jumps to first/last', () {
      final model = _model(['a', 'b', 'c']);
      model.handleKey(const TuiKey(TuiKeyType.end));
      expect(model.highlightedIndex, 2);
      model.handleKey(const TuiKey(TuiKeyType.home));
      expect(model.highlightedIndex, 0);
    });

    test('when pressing Enter then the highlighted value is submitted', () {
      final model = _model(['a', 'b', 'c']);
      model.handleKey(const TuiKey(TuiKeyType.arrowDown));
      final status = model.handleKey(const TuiKey(TuiKeyType.enter));

      expect(status, SelectListStatus.submitted);
      expect(model.selectedValues, ['b']);
    });

    test('when pressing Escape then the interaction is cancelled', () {
      final model = _model(['a', 'b']);
      final status = model.handleKey(const TuiKey(TuiKeyType.escape));
      expect(status, SelectListStatus.cancelled);
      expect(model.selectedValues, isEmpty);
    });

    test('when pressing Ctrl+C then the interaction is aborted', () {
      final model = _model(['a', 'b']);
      final status = model.handleKey(const TuiKey(TuiKeyType.ctrlC));
      expect(status, SelectListStatus.aborted);
      expect(model.selectedValues, isEmpty);
    });

    test('when navigating then disabled items are skipped', () {
      final model = _model(['a', 'b', 'c'], disabled: {1});
      model.handleKey(const TuiKey(TuiKeyType.arrowDown));
      expect(model.highlightedIndex, 2);
    });

    test('when the first item is disabled then highlight starts past it', () {
      final model = _model(['a', 'b', 'c'], disabled: {0});
      expect(model.highlightedIndex, 1);
    });
  });

  group('Given a multi-select model', () {
    test('when pressing Space then the highlighted item toggles', () {
      final model = _model(['a', 'b', 'c'], multiSelect: true);
      model.handleKey(const TuiKey(TuiKeyType.space));
      expect(model.isSelected(0), isTrue);
      model.handleKey(const TuiKey(TuiKeyType.space));
      expect(model.isSelected(0), isFalse);
    });

    test('when selecting several then all are returned on submit', () {
      final model = _model(['a', 'b', 'c'], multiSelect: true);
      model.handleKey(const TuiKey(TuiKeyType.space)); // a
      model.handleKey(const TuiKey(TuiKeyType.arrowDown));
      model.handleKey(const TuiKey(TuiKeyType.arrowDown));
      model.handleKey(const TuiKey(TuiKeyType.space)); // c

      final status = model.handleKey(const TuiKey(TuiKeyType.enter));
      expect(status, SelectListStatus.submitted);
      expect(model.selectedValues, ['a', 'c']);
    });

    test('when below minSelections then Enter does not submit', () {
      final model = _model(['a', 'b'], multiSelect: true, minSelections: 1);
      final status = model.handleKey(const TuiKey(TuiKeyType.enter));
      expect(status, SelectListStatus.active);
      expect(model.canSubmit, isFalse);
    });

    test('when at maxSelections then further selections are ignored', () {
      final model = _model(
        ['a', 'b', 'c'],
        multiSelect: true,
        maxSelections: 1,
      );
      model.handleKey(const TuiKey(TuiKeyType.space)); // a
      model.handleKey(const TuiKey(TuiKeyType.arrowDown));
      model.handleKey(const TuiKey(TuiKeyType.space)); // b ignored

      expect(model.selectedValues, ['a']);
    });
  });

  group('Given an empty model', () {
    test('when pressing Escape then it cancels', () {
      final model = _model([]);
      expect(
        model.handleKey(const TuiKey(TuiKeyType.escape)),
        SelectListStatus.cancelled,
      );
    });

    test('when pressing Ctrl+C then it aborts', () {
      final model = _model([]);
      expect(
        model.handleKey(const TuiKey(TuiKeyType.ctrlC)),
        SelectListStatus.aborted,
      );
    });

    test('when pressing Enter then it stays active', () {
      final model = _model([]);
      expect(
        model.handleKey(const TuiKey(TuiKeyType.enter)),
        SelectListStatus.active,
      );
    });
  });
}
