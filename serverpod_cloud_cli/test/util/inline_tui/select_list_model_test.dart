import 'package:serverpod_cloud_cli/util/inline_tui/src/select_list_model.dart';
import 'package:serverpod_cloud_cli/util/inline_tui/src/tui_key.dart';
import 'package:test/test.dart';

SelectListModel<String> _model(
  List<String> labels, {
  bool multiSelect = false,
  int minSelections = 0,
  int? maxSelections,
  String? selectAllLabel,
  Iterable<int> initiallySelected = const [],
  Set<int> disabled = const {},
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
    selectAllLabel: selectAllLabel,
    initiallySelected: initiallySelected,
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

  group('Given a multi-select model with a select-all row', () {
    test('when created then the select-all row is highlighted and '
        'highlightedItem is null', () {
      final model = _model(
        ['a', 'b', 'c'],
        multiSelect: true,
        selectAllLabel: 'All',
      );
      expect(model.selectAllHighlighted, isTrue);
      expect(model.highlightedItem, isNull);
      expect(model.allSelected, isFalse);
    });

    test('when pressing Space on the row then every item is selected', () {
      final model = _model(
        ['a', 'b', 'c'],
        multiSelect: true,
        selectAllLabel: 'All',
      );
      model.handleKey(const TuiKey(TuiKeyType.space));
      expect(model.selectedValues, ['a', 'b', 'c']);
      expect(model.allSelected, isTrue);
    });

    test(
      'when pressing Space twice on the row then the selection is cleared',
      () {
        final model = _model(
          ['a', 'b', 'c'],
          multiSelect: true,
          selectAllLabel: 'All',
        );
        model.handleKey(const TuiKey(TuiKeyType.space));
        model.handleKey(const TuiKey(TuiKeyType.space));
        expect(model.selectedValues, isEmpty);
      },
    );

    test(
      'when some items are selected then Space on the row selects the rest',
      () {
        final model = _model(
          ['a', 'b', 'c'],
          multiSelect: true,
          selectAllLabel: 'All',
        );
        model.handleKey(const TuiKey(TuiKeyType.arrowDown));
        model.handleKey(const TuiKey(TuiKeyType.space)); // a
        model.handleKey(const TuiKey(TuiKeyType.arrowUp));
        model.handleKey(const TuiKey(TuiKeyType.space));
        expect(model.selectedValues, ['a', 'b', 'c']);
      },
    );

    test(
      'when pressing Space on the row then disabled items stay unselected',
      () {
        final model = _model(
          ['a', 'b', 'c'],
          multiSelect: true,
          selectAllLabel: 'All',
          disabled: {1},
        );
        model.handleKey(const TuiKey(TuiKeyType.space));
        expect(model.selectedValues, ['a', 'c']);
        expect(model.allSelected, isTrue);
      },
    );

    test('when every item starts selected then the row is checked and Space '
        'clears the selection', () {
      final model = _model(
        ['a', 'b', 'c'],
        multiSelect: true,
        selectAllLabel: 'All',
        initiallySelected: const [0, 1, 2],
      );
      expect(model.allSelected, isTrue);

      model.handleKey(const TuiKey(TuiKeyType.space));
      expect(model.selectedValues, isEmpty);
    });

    test('when navigating down then the first item is highlighted', () {
      final model = _model(
        ['a', 'b', 'c'],
        multiSelect: true,
        selectAllLabel: 'All',
      );
      model.handleKey(const TuiKey(TuiKeyType.arrowDown));
      expect(model.selectAllHighlighted, isFalse);
      expect(model.highlightedIndex, 0);
    });

    test(
      'when navigating up from the first item then the row is highlighted',
      () {
        final model = _model(
          ['a', 'b', 'c'],
          multiSelect: true,
          selectAllLabel: 'All',
        );
        model.handleKey(const TuiKey(TuiKeyType.arrowDown));
        model.handleKey(const TuiKey(TuiKeyType.arrowUp));
        expect(model.selectAllHighlighted, isTrue);
      },
    );

    test('when pressing End and Home then highlight jumps to last item and '
        'back to the row', () {
      final model = _model(
        ['a', 'b', 'c'],
        multiSelect: true,
        selectAllLabel: 'All',
      );
      model.handleKey(const TuiKey(TuiKeyType.end));
      expect(model.selectAllHighlighted, isFalse);
      expect(model.highlightedIndex, 2);
      model.handleKey(const TuiKey(TuiKeyType.home));
      expect(model.selectAllHighlighted, isTrue);
    });

    test(
      'when pressing Enter on the row then the current set is submitted',
      () {
        final model = _model(
          ['a', 'b', 'c'],
          multiSelect: true,
          selectAllLabel: 'All',
        );
        final status = model.handleKey(const TuiKey(TuiKeyType.enter));
        expect(status, SelectListStatus.submitted);
        expect(model.selectedValues, isEmpty);
      },
    );

    test(
      'when no item is enabled then the row is absent and not highlighted',
      () {
        final model = _model(
          ['a', 'b'],
          multiSelect: true,
          selectAllLabel: 'All',
          disabled: {0, 1},
        );
        expect(model.hasSelectAll, isFalse);
        expect(model.selectAllHighlighted, isFalse);
      },
    );

    test('when combined with single-select then it throws ArgumentError', () {
      expect(
        () => _model(['a'], selectAllLabel: 'All'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('when combined with maxSelections then it throws ArgumentError', () {
      expect(
        () => _model(
          ['a'],
          multiSelect: true,
          maxSelections: 1,
          selectAllLabel: 'All',
        ),
        throwsA(isA<ArgumentError>()),
      );
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
