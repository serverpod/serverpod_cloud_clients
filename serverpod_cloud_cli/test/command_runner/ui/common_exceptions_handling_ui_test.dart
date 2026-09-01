import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/ui/common_exceptions_handling_ui.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/shared/base_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/output/output_context.dart';
import 'package:serverpod_cloud_cli/util/output/output_format.dart';
import 'package:serverpod_cloud_cli/util/output/widgets.dart';
import 'package:test/test.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();

  tearDown(logger.clear);

  const widget = CommonClientExceptionsWidget(
    baseCommand: defaultBaseCommand,
    elseWidget: InfoTextWidget('fallback'),
  );

  test('Given an UnauthorizedException '
      'when the widget is rendered '
      'then the shared unauthorized copy is written', () {
    widget
        .buildTree(
          OutputContext.exception(
            OutputFormat.text,
            UnauthorizedException(message: 'some error'),
            StackTrace.current,
          ),
        )
        .renderTree(logger: logger);

    expect(
      logger.errorCalls.single,
      equalsErrorCall(
        message: 'You are not authorized to perform this action.',
      ),
    );
  });

  test('Given a FailureException wrapping an UnauthorizedException '
      'when the widget is rendered '
      'then the nested exception is described', () {
    widget
        .buildTree(
          OutputContext.exception(
            OutputFormat.text,
            FailureException.nested(
              UnauthorizedException(message: 'some error'),
            ),
            StackTrace.current,
          ),
        )
        .renderTree(logger: logger);

    expect(
      logger.errorCalls.single,
      equalsErrorCall(
        message: 'You are not authorized to perform this action.',
      ),
    );
  });

  test('Given a ProcurementDeniedException '
      'when the widget is rendered '
      'then the exception message, hint, and paragraph break are written', () {
    widget
        .buildTree(
          OutputContext.exception(
            OutputFormat.text,
            ProcurementDeniedException(
              message:
                  "Database backup is not available for this project's plan.",
              reason: ProcurementDeniedReason.productNotAvailable,
            ),
            StackTrace.current,
          ),
        )
        .renderTree(logger: logger);

    expect(
      logger.errorCalls.single,
      equalsErrorCall(
        message: "Database backup is not available for this project's plan.",
        hint:
            'Database backups are available on the Growth plan. '
            'To upgrade the plan, visit: '
            '${HostConstants.serverpodCloudConsole}/project\n',
        newParagraph: true,
      ),
    );
  });

  test('Given an exception that is not commonly handled '
      'when the widget is rendered '
      'then the else widget is written', () {
    widget
        .buildTree(
          OutputContext.exception(
            OutputFormat.text,
            Exception('other'),
            StackTrace.current,
          ),
        )
        .renderTree(logger: logger);

    expect(logger.infoCalls.single, equalsInfoCall(message: 'fallback'));
  });
}
