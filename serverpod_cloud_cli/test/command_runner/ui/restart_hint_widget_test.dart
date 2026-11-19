import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  late TestCommandLogger logger;

  setUp(() {
    logger = TestCommandLogger();
  });

  group('Given a restart hint widget', () {
    test(
      'when rendered then the restart copy and deploy --restart command are written',
      () async {
        await const RestartHintWidget(baseCommand: 'scloud')
            .buildTree(OutputContext(OutputFormat.text))
            .renderTree(logger: logger);

        expect(logger.terminalCommandCalls, [
          equalsTerminalCommandCall(
            command: 'scloud deploy --restart',
            message:
                'The changes will not take effect until your server is '
                'restarted.',
          ),
        ]);
      },
    );

    test(
      'when the base command is a wrapper then the hinted command uses it',
      () async {
        await const RestartHintWidget(baseCommand: 'serverpod cloud')
            .buildTree(OutputContext(OutputFormat.text))
            .renderTree(logger: logger);

        expect(
          logger.terminalCommandCalls.single.command,
          'serverpod cloud deploy --restart',
        );
      },
    );
  });
}
