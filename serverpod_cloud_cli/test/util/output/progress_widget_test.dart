import 'dart:async';

import 'package:serverpod_cloud_cli/util/output/output.dart';
import 'package:test/test.dart';

import '../../../test_utils/test_command_logger.dart';
import '../inline_tui/helpers/fake_terminal.dart';

void main() {
  late TestCommandLogger logger;
  late FakeTerminal terminal;

  setUp(() {
    logger = TestCommandLogger();
    terminal = FakeTerminal();
    logger.inlineTerminal = terminal;
  });

  group('Given a ProgressStreamWidget', () {
    test('when the stream emits events then the heading is updated and the '
        'last event is kept', () async {
      final controller = StreamController<String>();
      final widget = ProgressStreamWidget<String>(
        initialMessage: 'Starting',
        stream: controller.stream,
        toMessage: (event) => event,
      );

      final rendered = widget
          .buildTree(OutputContext(OutputFormat.text))
          .renderTree(logger: logger);
      controller.add('Step one');
      await Future<void>.delayed(Duration.zero);
      expect(terminal.output, contains('Step one'));

      controller.add('Step two');
      await controller.close();
      await rendered;

      expect(terminal.output, contains('Step two'));
      expect(terminal.output, contains('\u2713'));
    });

    test(
      'when the stream is taken from the output context then it is consumed',
      () async {
        final widget = ProgressStreamWidget<String>(
          initialMessage: 'Starting',
          toMessage: (event) => event,
        );

        await widget
            .buildTree(OutputContext(OutputFormat.text, Stream.value('done')))
            .renderTree(logger: logger);

        expect(terminal.output, contains('done'));
        expect(terminal.output, contains('\u2713'));
      },
    );
  });
}
