import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart'
    show FailureException;
import 'package:serverpod_cloud_cli/shared/helpers/console_urls.dart';
import 'package:serverpod_cloud_cli/util/output/output_context.dart';
import 'package:serverpod_cloud_cli/util/output/output_widget.dart';
import 'package:serverpod_cloud_cli/util/output/widgets.dart';

/// Displays text errors for common Ground Control client exceptions.
/// For other exceptions it renders [elseWidget] if provided.
class CommonClientExceptionsWidget extends OutputWidget {
  final String baseCommand;
  final OutputWidget? elseWidget;

  const CommonClientExceptionsWidget({
    required this.baseCommand,
    this.elseWidget,
  });

  @override
  OutputWidget build(final OutputContext context) {
    final error = context.find<QualifiedException>();
    if (error?.exception case final Exception exc) {
      final e = _unwrapException(exc);

      return switch (e) {
        ServerpodClientUnauthorized() => ServerpodClientUnauthorizedWidget(
          e,
          baseCommand: baseCommand,
        ),
        UnauthorizedException() => UnauthorizedExceptionWidget(e),
        ProcurementDeniedException() => ProcurementDeniedExceptionWidget(e),
        NotFoundException() => NotFoundExceptionWidget(e),
        _ => elseWidget ?? this,
      };
    }
    return elseWidget ?? this;
  }

  Exception _unwrapException(final Exception exc) {
    final exception = switch (exc) {
      FailureException(:final nestedException) when nestedException != null =>
        nestedException,
      _ => exc,
    };
    return exception;
  }
}

/// Displays the session-credentials error for [ServerpodClientUnauthorized].
class ServerpodClientUnauthorizedWidget extends OutputWidget {
  static const message =
      'The credentials for this session seem to no longer be valid.';
  final ServerpodClientUnauthorized exception;
  final String baseCommand;

  const ServerpodClientUnauthorizedWidget(
    this.exception, {
    required this.baseCommand,
  });

  @override
  OutputWidget build(final OutputContext context) {
    return OutputWidgetList([
      TextErrorOutputWidget(message),
      CommandHintTextWidget(
        'Run the following commands to re-authenticate:',
        command: '$baseCommand auth logout',
      ),
      CommandHintTextWidget.command('$baseCommand auth login'),
    ]);
  }
}

/// Displays the authorization error for [UnauthorizedException].
class UnauthorizedExceptionWidget extends OutputWidget {
  static const message = 'You are not authorized to perform this action.';
  final UnauthorizedException exception;

  const UnauthorizedExceptionWidget(this.exception);

  @override
  OutputWidget build(final OutputContext context) {
    return TextErrorOutputWidget(message);
  }
}

/// Displays the procurement error for [ProcurementDeniedException].
class ProcurementDeniedExceptionWidget extends OutputWidget {
  static const exitReason = 'The procurement was not allowed.';
  final ProcurementDeniedException exception;

  const ProcurementDeniedExceptionWidget(this.exception);

  @override
  OutputWidget build(final OutputContext context) {
    final baseUrl = getConsoleBaseUrl();
    if (exception.message.contains('no valid payment method')) {
      final setupUrl = '$baseUrl/project/create';
      return TextErrorOutputWidget(
        exception,
        message: 'You need a payment method!',
        hint: 'To set up your account, visit: $setupUrl\n',
        newParagraph: true,
      );
    }

    if (exception.reason == ProcurementDeniedReason.productNotAvailable &&
        exception.message.toLowerCase().contains('backup')) {
      final projectsUrl = '$baseUrl/project';
      return TextErrorOutputWidget(
        exception,
        message: exception.message,
        hint:
            'Database backups are available on the Growth plan. '
            'To upgrade the plan, visit: $projectsUrl\n',
        newParagraph: true,
      );
    }

    final projectsUrl = '$baseUrl/project';
    return TextErrorOutputWidget(
      exception,
      message: exception.message,
      hint: 'To see your account, visit: $projectsUrl\n',
      newParagraph: true,
    );
  }
}

/// Displays the missing-resource error for [NotFoundException].
class NotFoundExceptionWidget extends OutputWidget {
  static const message = 'The requested resource did not exist.';
  final NotFoundException exception;

  const NotFoundExceptionWidget(this.exception);

  @override
  OutputWidget build(final OutputContext context) {
    return TextErrorOutputWidget(
      exception,
      message: NotFoundExceptionWidget.message,
      hint: exception.message,
    );
  }
}
