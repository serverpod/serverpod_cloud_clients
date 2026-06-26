import 'tui_key.dart';

/// A single selectable row in a [SelectListModel].
class SelectListItem<T> {
  /// The value returned when this item is selected.
  final T value;

  /// The text displayed for this item.
  final String label;

  /// Whether this item can be highlighted and selected.
  final bool enabled;

  /// Creates an item wrapping [value] displayed as [label].
  const SelectListItem({
    required this.value,
    required this.label,
    this.enabled = true,
  });
}

/// The result of handling a key in a [SelectListModel].
enum SelectListStatus {
  /// The list is still active and awaiting further input.
  active,

  /// The user confirmed their selection.
  submitted,

  /// The user cancelled the selection (e.g. with Escape or `q`).
  cancelled,

  /// The user aborted the selection with Ctrl+C.
  aborted,
}

/// The interaction state machine for a keyboard-navigated selection list.
///
/// This class holds no terminal or rendering concerns, which makes the
/// navigation and selection logic straightforward to unit test.
class SelectListModel<T> {
  /// The items shown in the list.
  final List<SelectListItem<T>> items;

  /// Whether multiple items can be selected at once.
  final bool multiSelect;

  /// The minimum number of items that must be selected before the selection can
  /// be submitted. Only relevant when [multiSelect] is true.
  final int minSelections;

  /// The maximum number of items that can be selected, or null for no limit.
  /// Only relevant when [multiSelect] is true.
  final int? maxSelections;

  final Set<int> _selectedIndices = <int>{};
  int _highlightedIndex = 0;
  SelectListStatus _status = SelectListStatus.active;

  /// Creates a model for [items].
  ///
  /// When [multiSelect] is false the list behaves as a single-choice list where
  /// Enter confirms the highlighted item. When true, Space toggles the
  /// highlighted item and Enter confirms the current set.
  SelectListModel({
    required this.items,
    this.multiSelect = false,
    this.minSelections = 0,
    this.maxSelections,
    final int initialIndex = 0,
    final Iterable<int> initiallySelected = const [],
  }) {
    if (items.isNotEmpty) {
      final safeInitialIndex = initialIndex < 0
          ? 0
          : (initialIndex >= items.length ? items.length - 1 : initialIndex);
      _highlightedIndex =
          _firstEnabledFrom(safeInitialIndex, 1) ??
          _firstEnabledFrom(safeInitialIndex, -1) ??
          safeInitialIndex;
    }
    for (final index in initiallySelected) {
      if (index >= 0 && index < items.length && items[index].enabled) {
        if (maxSelections != null &&
            _selectedIndices.length >= maxSelections!) {
          break;
        }
        _selectedIndices.add(index);
      }
    }
  }

  /// The index of the currently highlighted item.
  int get highlightedIndex => _highlightedIndex;

  /// The indices of the currently selected items, in ascending order.
  List<int> get selectedIndices => _selectedIndices.toList()..sort();

  /// The currently highlighted item, or null when the list is empty.
  SelectListItem<T>? get highlightedItem =>
      items.isEmpty ? null : items[_highlightedIndex];

  /// The current status of the interaction.
  SelectListStatus get status => _status;

  /// Whether the index [i] is currently selected.
  bool isSelected(final int i) => _selectedIndices.contains(i);

  /// Whether the current selection satisfies the configured constraints and may
  /// be submitted.
  bool get canSubmit {
    if (!multiSelect) return items.isNotEmpty;
    if (_selectedIndices.length < minSelections) return false;
    if (maxSelections != null && _selectedIndices.length > maxSelections!) {
      return false;
    }
    return true;
  }

  /// The values of the selected items.
  ///
  /// For a single-select list with nothing explicitly toggled, this is the
  /// highlighted item once [status] is [SelectListStatus.submitted].
  List<T> get selectedValues =>
      selectedIndices.map((final i) => items[i].value).toList();

  /// Processes a [key] press and returns the resulting status.
  SelectListStatus handleKey(final TuiKey key) {
    if (_status != SelectListStatus.active) return _status;
    if (items.isEmpty) {
      if (key.type == TuiKeyType.ctrlC) {
        _status = SelectListStatus.aborted;
      } else if (_isCancel(key)) {
        _status = SelectListStatus.cancelled;
      }
      return _status;
    }

    switch (key.type) {
      case TuiKeyType.arrowUp:
        _moveHighlight(-1);
      case TuiKeyType.arrowDown:
        _moveHighlight(1);
      case TuiKeyType.home:
        _moveHighlightTo(_firstEnabledFrom(0, 1));
      case TuiKeyType.end:
        _moveHighlightTo(_firstEnabledFrom(items.length - 1, -1));
      case TuiKeyType.space:
        _toggleHighlighted();
      case TuiKeyType.enter:
        _submit();
      case TuiKeyType.ctrlC:
        _status = SelectListStatus.aborted;
      case TuiKeyType.escape:
        _status = SelectListStatus.cancelled;
      case TuiKeyType.character:
        _handleCharacter(key.character);
      default:
        break;
    }
    return _status;
  }

  void _handleCharacter(final String? character) {
    switch (character) {
      case 'k':
      case 'w':
        _moveHighlight(-1);
      case 'j':
      case 's':
        _moveHighlight(1);
      case 'q':
        _status = SelectListStatus.cancelled;
      default:
        break;
    }
  }

  void _moveHighlight(final int direction) {
    final next = _firstEnabledFrom(_highlightedIndex + direction, direction);
    if (next != null) {
      _highlightedIndex = next;
    }
  }

  void _moveHighlightTo(final int? index) {
    if (index != null) _highlightedIndex = index;
  }

  void _toggleHighlighted() {
    final item = items[_highlightedIndex];
    if (!item.enabled) return;

    if (!multiSelect) {
      _selectedIndices
        ..clear()
        ..add(_highlightedIndex);
      return;
    }

    if (_selectedIndices.contains(_highlightedIndex)) {
      _selectedIndices.remove(_highlightedIndex);
      return;
    }

    final max = maxSelections;
    if (max != null && _selectedIndices.length >= max) return;
    _selectedIndices.add(_highlightedIndex);
  }

  void _submit() {
    if (!multiSelect) {
      final item = items[_highlightedIndex];
      if (!item.enabled) return;
      _selectedIndices
        ..clear()
        ..add(_highlightedIndex);
      _status = SelectListStatus.submitted;
      return;
    }

    if (!canSubmit) return;
    _status = SelectListStatus.submitted;
  }

  bool _isCancel(final TuiKey key) =>
      key.type == TuiKeyType.escape ||
      (key.type == TuiKeyType.character && key.character == 'q');

  /// Returns the first enabled index starting at [from] moving by [step], or
  /// null when no enabled item exists in that direction.
  int? _firstEnabledFrom(final int from, final int step) {
    var index = from;
    while (index >= 0 && index < items.length) {
      if (items[index].enabled) return index;
      index += step;
    }
    return null;
  }
}
