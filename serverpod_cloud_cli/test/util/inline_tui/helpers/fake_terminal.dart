import 'dart:async';

import 'package:serverpod_cloud_cli/util/inline_tui/src/inline_terminal.dart';

/// A [FakeTerminal] for tests that records output and lets tests feed input.
class FakeTerminal implements InlineTerminal {
  /// The byte sequence a terminal sends for the Down arrow key.
  static const List<int> arrowDown = [0x1b, 0x5b, 0x42];

  /// The byte sequence a terminal sends for the Up arrow key.
  static const List<int> arrowUp = [0x1b, 0x5b, 0x41];

  /// The byte sequence a terminal sends for the Enter/Return key.
  static const List<int> enter = [0x0d];

  /// The byte a terminal sends for the Space key.
  static const List<int> space = [0x20];

  /// The byte a terminal sends for the Escape key.
  static const List<int> escape = [0x1b];

  // Modeled as a broadcast stream so that, like a real [StdioTerminal], the
  // input can be subscribed to by several components in sequence.
  late final StreamController<List<int>> _input =
      StreamController<List<int>>.broadcast(onListen: _flushQueuedInput);
  final StreamController<void> _interrupts = StreamController<void>.broadcast();
  final StringBuffer _output = StringBuffer();

  // Input chunks queued before a component has subscribed. They are delivered
  // once a listener attaches, which lets tests pre-program input even when the
  // component (e.g. a SelectList) only subscribes later during an async run.
  final List<List<int>> _queuedInput = [];

  @override
  final bool supportsColor;

  @override
  final bool hasTerminal;

  @override
  final int columns;

  bool rawModeEnabled = false;
  int enableRawModeCount = 0;
  int disableRawModeCount = 0;

  FakeTerminal({
    this.supportsColor = false,
    this.hasTerminal = true,
    this.columns = 80,
  });

  /// Everything written to the terminal so far.
  String get output => _output.toString();

  /// Feeds raw [bytes] as a single input chunk.
  void sendBytes(final List<int> bytes) => _input.add(bytes);

  /// Queues [bytes] to be delivered as a single input chunk once a component
  /// subscribes (or immediately if one already has).
  ///
  /// Use this from integration tests where the component reading the input only
  /// starts listening later during an asynchronous command run.
  void queueInput(final List<int> bytes) {
    _queuedInput.add(bytes);
    if (_input.hasListener) _flushQueuedInput();
  }

  /// Queues the key presses needed to highlight the option at [index] (moving
  /// from [fromIndex], the list's initial selection) and confirm it with Enter.
  ///
  /// The whole sequence is delivered as one chunk; the key decoder and selection
  /// model process the presses in order, so this selects the option as if the
  /// user navigated to it and pressed Enter.
  void queueSelectIndex(final int index, {final int fromIndex = 0}) {
    final steps = index - fromIndex;
    final keys = <int>[
      for (var i = 0; i < steps.abs(); i++)
        ...(steps > 0 ? arrowDown : arrowUp),
      ...enter,
    ];
    queueInput(keys);
  }

  void _flushQueuedInput() {
    if (_queuedInput.isEmpty) return;
    final chunks = List<List<int>>.from(_queuedInput);
    _queuedInput.clear();
    for (final chunk in chunks) {
      scheduleMicrotask(() {
        if (!_input.isClosed) _input.add(chunk);
      });
    }
  }

  /// Simulates a Ctrl+C / SIGINT interrupt.
  void sendInterrupt() => _interrupts.add(null);

  bool _closed = false;

  /// Closes the input and interrupt streams.
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _input.close();
    await _interrupts.close();
  }

  @override
  Future<void> dispose() => close();

  @override
  Stream<List<int>> get input => _input.stream;

  @override
  Stream<void> get interruptSignals => _interrupts.stream;

  @override
  void write(final String text) => _output.write(text);

  @override
  void enableRawMode() {
    rawModeEnabled = true;
    enableRawModeCount++;
  }

  @override
  void disableRawMode() {
    rawModeEnabled = false;
    disableRawModeCount++;
  }
}
