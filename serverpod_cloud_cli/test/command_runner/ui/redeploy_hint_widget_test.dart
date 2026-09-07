import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  late TestCommandLogger logger;

  setUp(() {
    logger = TestCommandLogger();
  });

  group('Given a redeploy hint widget', () {
    test(
      'when rendered then the redeploy copy and deploy command are written',
      () {
        const RedeployHintWidget(baseCommand: 'scloud')
            .buildTree(OutputContext(OutputFormat.text))
            .renderTree(logger: logger);

        expect(logger.terminalCommandCalls, [
          equalsTerminalCommandCall(
            command: 'scloud deploy',
            message:
                'The changes will not take effect until your server is '
                're-deployed.',
          ),
        ]);
      },
    );

    test(
      'when the base command is a wrapper then the hinted command uses it',
      () {
        const RedeployHintWidget(baseCommand: 'serverpod cloud')
            .buildTree(OutputContext(OutputFormat.text))
            .renderTree(logger: logger);

        expect(logger.terminalCommandCalls, [
          equalsTerminalCommandCall(
            command: 'serverpod cloud deploy',
            message:
                'The changes will not take effect until your server is '
                're-deployed.',
          ),
        ]);
      },
    );
  });
}
