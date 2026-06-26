import 'package:serverpod_cloud_cli/util/inline_tui/src/tui_key.dart';
import 'package:test/test.dart';

void main() {
  group('Given Unix-style escape sequences', () {
    test('when decoding arrow keys then logical arrow keys are produced', () {
      expect(TuiKeyDecoder.decode([0x1b, 0x5b, 0x41]), [
        const TuiKey(TuiKeyType.arrowUp),
      ]);
      expect(TuiKeyDecoder.decode([0x1b, 0x5b, 0x42]), [
        const TuiKey(TuiKeyType.arrowDown),
      ]);
      expect(TuiKeyDecoder.decode([0x1b, 0x5b, 0x43]), [
        const TuiKey(TuiKeyType.arrowRight),
      ]);
      expect(TuiKeyDecoder.decode([0x1b, 0x5b, 0x44]), [
        const TuiKey(TuiKeyType.arrowLeft),
      ]);
    });

    test(
      'when decoding application-mode arrows then arrow keys are produced',
      () {
        expect(TuiKeyDecoder.decode([0x1b, 0x4f, 0x41]), [
          const TuiKey(TuiKeyType.arrowUp),
        ]);
      },
    );

    test('when decoding Home/End/PageUp/PageDown then they are produced', () {
      expect(TuiKeyDecoder.decode([0x1b, 0x5b, 0x48]), [
        const TuiKey(TuiKeyType.home),
      ]);
      expect(TuiKeyDecoder.decode([0x1b, 0x5b, 0x46]), [
        const TuiKey(TuiKeyType.end),
      ]);
      expect(TuiKeyDecoder.decode([0x1b, 0x5b, 0x35, 0x7e]), [
        const TuiKey(TuiKeyType.pageUp),
      ]);
      expect(TuiKeyDecoder.decode([0x1b, 0x5b, 0x36, 0x7e]), [
        const TuiKey(TuiKeyType.pageDown),
      ]);
    });

    test('when decoding a lone escape byte then escape is produced', () {
      expect(TuiKeyDecoder.decode([0x1b]), [const TuiKey(TuiKeyType.escape)]);
    });
  });

  group('Given Windows console special-key encodings', () {
    test('when decoding 0xE0 prefixed arrows then arrow keys are produced', () {
      expect(TuiKeyDecoder.decode([0xe0, 0x48]), [
        const TuiKey(TuiKeyType.arrowUp),
      ]);
      expect(TuiKeyDecoder.decode([0xe0, 0x50]), [
        const TuiKey(TuiKeyType.arrowDown),
      ]);
      expect(TuiKeyDecoder.decode([0xe0, 0x4b]), [
        const TuiKey(TuiKeyType.arrowLeft),
      ]);
      expect(TuiKeyDecoder.decode([0xe0, 0x4d]), [
        const TuiKey(TuiKeyType.arrowRight),
      ]);
    });

    test('when decoding 0x00 prefixed arrows then arrow keys are produced', () {
      expect(TuiKeyDecoder.decode([0x00, 0x48]), [
        const TuiKey(TuiKeyType.arrowUp),
      ]);
    });
  });

  group('Given control and printable bytes', () {
    test('when decoding enter (CR and LF) then enter is produced', () {
      expect(TuiKeyDecoder.decode([0x0d]), [const TuiKey(TuiKeyType.enter)]);
      expect(TuiKeyDecoder.decode([0x0a]), [const TuiKey(TuiKeyType.enter)]);
    });

    test('when decoding space then space is produced', () {
      expect(TuiKeyDecoder.decode([0x20]), [const TuiKey(TuiKeyType.space)]);
    });

    test('when decoding Ctrl+C then ctrlC is produced', () {
      expect(TuiKeyDecoder.decode([0x03]), [const TuiKey(TuiKeyType.ctrlC)]);
    });

    test('when decoding letters then character keys are produced', () {
      expect(TuiKeyDecoder.decode('jkq'.codeUnits), [
        const TuiKey(TuiKeyType.character, character: 'j'),
        const TuiKey(TuiKeyType.character, character: 'k'),
        const TuiKey(TuiKeyType.character, character: 'q'),
      ]);
    });

    test('when decoding a multi-byte UTF-8 character then it is decoded', () {
      // 'é' is 0xC3 0xA9 in UTF-8.
      expect(TuiKeyDecoder.decode([0xc3, 0xa9]), [
        const TuiKey(TuiKeyType.character, character: 'é'),
      ]);
    });
  });

  group('Given a chunk with multiple keys', () {
    test('when decoding then each key is produced in order', () {
      final keys = TuiKeyDecoder.decode([
        0x1b, 0x5b, 0x42, // down
        0x20, // space
        0x0d, // enter
      ]);
      expect(keys, [
        const TuiKey(TuiKeyType.arrowDown),
        const TuiKey(TuiKeyType.space),
        const TuiKey(TuiKeyType.enter),
      ]);
    });
  });
}
