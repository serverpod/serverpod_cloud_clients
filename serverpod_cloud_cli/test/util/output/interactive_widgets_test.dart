import 'package:serverpod_cloud_cli/util/output/interactive_widgets.dart';
import 'package:test/test.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  late TestCommandLogger logger;

  setUp(() {
    logger = TestCommandLogger();
  });

  group('Given a confirmation widget', () {
    test(
      'when the user confirms then the completer completes with true',
      () async {
        logger.answerNextConfirmWith(true);
        final widget = ConfirmationWidget('Continue?', defaultValue: false);

        widget.render(logger: logger);

        expect(await widget.completer.future, isTrue);
        expect(logger.confirmCalls, [
          equalsConfirmCall(message: 'Continue?', defaultValue: false),
        ]);
      },
    );

    test(
      'when the user declines then the completer completes with false',
      () async {
        logger.answerNextConfirmWith(false);
        final widget = ConfirmationWidget('Delete the bucket?');

        widget.render(logger: logger);

        expect(await widget.completer.future, isFalse);
        expect(logger.confirmCalls, [
          equalsConfirmCall(message: 'Delete the bucket?', defaultValue: null),
        ]);
      },
    );
  });
}
