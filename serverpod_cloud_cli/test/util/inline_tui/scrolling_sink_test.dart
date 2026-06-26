import 'dart:convert';

import 'package:serverpod_cloud_cli/util/inline_tui/inline_tui.dart';
import 'package:test/test.dart';

import 'helpers/fake_terminal.dart';

void main() {
  group('Given a ScrollingSink', () {
    test('when bytes are written then they are decoded into lines and appended '
        'to the section', () async {
      final term = FakeTerminal();
      final section = ScrollingSection(terminal: term, rows: 5);
      final sink = ScrollingSink(section);

      sink.sink.add(utf8.encode('one\ntwo\n'));
      sink.sink.add(utf8.encode('thr'));
      sink.sink.add(utf8.encode('ee'));
      await sink.close();

      expect(section.visibleLines, ['one', 'two', 'three']);
    });

    test('when more lines than rows are written then only the last rows remain '
        'visible', () async {
      final term = FakeTerminal();
      final section = ScrollingSection(terminal: term, rows: 2);
      final sink = ScrollingSink(section);

      sink.sink.add(utf8.encode('a\nb\nc\nd\n'));
      await sink.close();

      expect(section.visibleLines, ['c', 'd']);
    });
  });
}
