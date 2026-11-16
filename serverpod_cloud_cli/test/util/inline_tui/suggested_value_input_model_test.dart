import 'package:serverpod_cloud_cli/util/inline_tui/src/suggested_value_input_model.dart';
import 'package:serverpod_cloud_cli/util/inline_tui/src/tui_key.dart';
import 'package:test/test.dart';

const _enter = TuiKey(TuiKeyType.enter);
const _up = TuiKey(TuiKeyType.arrowUp);
const _down = TuiKey(TuiKeyType.arrowDown);

TuiKey _type(String text) => TuiKey(TuiKeyType.character, character: text);

void main() {
  group('Given a suggested value prompt', () {
    late SuggestedValueInputModel model;

    setUp(() {
      model = SuggestedValueInputModel(
        suggestion: 'space.serverpod.app',
        validate: (value) => value.contains('-') ? 'Not valid.' : null,
      );
    });

    test('when it starts then the suggestion row is highlighted', () {
      expect(model.row, SuggestedValueRow.suggestion);
    });

    test('when pressing Enter then the suggestion is confirmed', () {
      model.handleKey(_enter);

      expect(
        (model.status, model.value),
        (SuggestedValueInputStatus.submitted, 'space.serverpod.app'),
      );
    });

    test('when typing then the entry row is highlighted with the text', () {
      model.handleKey(_type('com.acme'));

      expect((model.row, model.text), (SuggestedValueRow.entry, 'com.acme'));
    });

    test(
      'when typing and pressing Enter then the trimmed text is confirmed',
      () {
        model.handleKey(_type(' com.acme '));
        model.handleKey(_enter);

        expect(
          (model.status, model.value),
          (SuggestedValueInputStatus.submitted, 'com.acme'),
        );
      },
    );

    test('when typing and pressing Up then the suggestion row is highlighted '
        'and the text is kept', () {
      model.handleKey(_type('com.acme'));
      model.handleKey(_up);

      expect(
        (model.row, model.text),
        (SuggestedValueRow.suggestion, 'com.acme'),
      );
    });

    test('when typing, pressing Up and Enter then the suggestion is '
        'confirmed', () {
      model.handleKey(_type('com.acme'));
      model.handleKey(_up);
      model.handleKey(_enter);

      expect(model.value, 'space.serverpod.app');
    });

    test('when confirming a value that fails validation '
        'then the prompt stays active with the error', () {
      model.handleKey(_type('com.my-app'));
      model.handleKey(_enter);

      expect(
        (model.status, model.error),
        (SuggestedValueInputStatus.active, 'Not valid.'),
      );
    });

    test('when editing after a validation error then the error is cleared', () {
      model.handleKey(_type('com.my-app'));
      model.handleKey(_enter);
      model.handleKey(const TuiKey(TuiKeyType.backspace));

      expect(model.error, isNull);
    });

    test('when pressing Down then the entry row is highlighted', () {
      model.handleKey(_down);

      expect(model.row, SuggestedValueRow.entry);
    });

    test('when pressing Backspace on the suggestion row '
        'then the text is unchanged', () {
      model.handleKey(_type('ab'));
      model.handleKey(_up);
      model.handleKey(const TuiKey(TuiKeyType.backspace));

      expect(model.text, 'ab');
    });

    test('when pressing Escape then the prompt is cancelled', () {
      expect(
        model.handleKey(const TuiKey(TuiKeyType.escape)),
        SuggestedValueInputStatus.cancelled,
      );
    });

    test('when pressing Ctrl+C then the prompt is aborted', () {
      expect(
        model.handleKey(const TuiKey(TuiKeyType.ctrlC)),
        SuggestedValueInputStatus.aborted,
      );
    });
  });
}
