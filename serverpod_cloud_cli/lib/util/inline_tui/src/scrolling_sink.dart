import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'scrolling_section.dart';

/// Bridges byte output written to an [IOSink] into a [ScrollingSection].
///
/// Bytes are decoded as UTF-8 and split into lines, each appended to the
/// section. This adapts subprocess runners that write their output to
/// [IOSink]s (such as `package:cli_tools`'s `execute`) so the output scrolls
/// within the section instead of taking over the screen.
///
/// Call [close] once the producing stream is finished to flush any trailing
/// partial line and await the section being fully updated.
class ScrollingSink {
  final ScrollingSection _section;
  final StreamController<List<int>> _controller = StreamController<List<int>>();
  late final Future<void> _done;
  late final IOSink sink = IOSink(_controller.sink);
  bool _closed = false;

  /// Creates a sink that appends decoded lines to [section].
  ScrollingSink(this._section) {
    _done = _controller.stream
        .transform(const Utf8Decoder(allowMalformed: true))
        .transform(const LineSplitter())
        .forEach(_section.appendLine);
  }

  /// Flushes any buffered output and completes once all lines have been
  /// appended to the section.
  ///
  /// Closes through [sink] so any data still buffered in it is written before
  /// the underlying stream is closed.
  Future<void> close() async {
    if (_closed) {
      await _done;
      return;
    }
    _closed = true;
    await sink.close();
    await _done;
  }
}
