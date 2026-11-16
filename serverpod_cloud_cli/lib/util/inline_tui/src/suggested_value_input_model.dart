import 'tui_key.dart';

/// The rows of a [SuggestedValueInputModel].
enum SuggestedValueRow {
  /// The row that accepts the suggested value.
  suggestion,

  /// The row the user types a value into.
  entry,
}

/// Where a [SuggestedValueInputModel] stands.
enum SuggestedValueInputStatus {
  /// The user is still choosing or typing.
  active,

  /// The user confirmed a value with Enter.
  submitted,

  /// The user cancelled with Escape.
  cancelled,

  /// The user aborted with Ctrl+C.
  aborted,
}

/// The state of a prompt that offers [suggestion] or a value the user types:
/// the highlighted row, the text typed, and an error from [validate] for the
/// last value the user tried to confirm.
class SuggestedValueInputModel {
  /// The value the suggestion row confirms.
  final String suggestion;

  /// Returns why a typed value cannot be confirmed, or null when it can.
  final String? Function(String value)? validate;

  SuggestedValueRow _row = SuggestedValueRow.suggestion;
  String _text = '';
  String? _error;
  SuggestedValueInputStatus _status = SuggestedValueInputStatus.active;

  /// Creates a prompt for [suggestion] with the suggestion row highlighted.
  SuggestedValueInputModel({required this.suggestion, this.validate});

  /// The highlighted row.
  SuggestedValueRow get row => _row;

  /// The text typed into the entry row.
  String get text => _text;

  /// Why the typed value could not be confirmed, or null. Cleared when the
  /// user edits the text or moves to another row.
  String? get error => _error;

  /// Where the prompt stands.
  SuggestedValueInputStatus get status => _status;

  /// The confirmed value: [suggestion], or the typed text trimmed. Only
  /// meaningful when [status] is [SuggestedValueInputStatus.submitted].
  String get value =>
      _row == SuggestedValueRow.suggestion ? suggestion : _text.trim();

  /// Applies [key] and returns the resulting status. Keys after the prompt
  /// has ended are ignored.
  ///
  /// Up and Down move between the rows. Typing on either row edits the
  /// entry row and highlights it. Enter confirms the highlighted row; a
  /// typed value that [validate] rejects stays with its error instead.
  SuggestedValueInputStatus handleKey(TuiKey key) {
    if (_status != SuggestedValueInputStatus.active) return _status;
    switch (key.type) {
      case TuiKeyType.arrowUp:
        _moveTo(SuggestedValueRow.suggestion);
      case TuiKeyType.arrowDown || TuiKeyType.tab:
        _moveTo(SuggestedValueRow.entry);
      case TuiKeyType.character:
        _edit('$_text${key.character ?? ''}');
      case TuiKeyType.space:
        _edit('$_text ');
      case TuiKeyType.backspace:
        if (_row == SuggestedValueRow.entry && _text.isNotEmpty) {
          _edit(_text.substring(0, _text.length - 1));
        }
      case TuiKeyType.enter:
        _confirm();
      case TuiKeyType.escape:
        _status = SuggestedValueInputStatus.cancelled;
      case TuiKeyType.ctrlC:
        _status = SuggestedValueInputStatus.aborted;
      case TuiKeyType.arrowLeft ||
          TuiKeyType.arrowRight ||
          TuiKeyType.home ||
          TuiKeyType.end ||
          TuiKeyType.pageUp ||
          TuiKeyType.pageDown ||
          TuiKeyType.unknown:
        break;
    }
    return _status;
  }

  void _moveTo(SuggestedValueRow row) {
    if (_row == row) return;
    _row = row;
    _error = null;
  }

  void _edit(String text) {
    _row = SuggestedValueRow.entry;
    _text = text;
    _error = null;
  }

  void _confirm() {
    if (_row == SuggestedValueRow.suggestion) {
      _status = SuggestedValueInputStatus.submitted;
      return;
    }
    final error = validate?.call(_text.trim());
    if (error != null) {
      _error = error;
      return;
    }
    _status = SuggestedValueInputStatus.submitted;
  }
}
