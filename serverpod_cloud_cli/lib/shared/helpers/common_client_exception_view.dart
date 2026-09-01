import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/shared/helpers/console_urls.dart';

/// A command the user should run after a common client exception.
final class CommonClientExceptionCommandHint {
  final String command;
  final String? message;

  const CommonClientExceptionCommandHint({required this.command, this.message});
}

/// User-facing copy for a Ground Control client exception that every CLI
/// command presents the same way.
///
/// [tryDescribe] returns a view for [ServerpodClientUnauthorized],
/// [UnauthorizedException], [ProcurementDeniedException], and
/// [NotFoundException]. It returns `null` for any other exception. This does
/// not unwrap nested causes. A caller holding a wrapper exception must unwrap
/// before calling.
///
/// [ProcurementDeniedException] has three display branches:
/// * message contains `no valid payment method` — payment-method copy and a
///   `/project/create` hint
/// * [ProcurementDeniedReason.productNotAvailable] and message contains
///   `backup` (case-insensitive) — the exception message and a Growth-plan
///   upgrade hint
/// * otherwise — the exception message and a `/project` hint
///
/// [exitReason] is the process-exit reason. For procurement it is always
/// [_procurementDeniedExitReason], not the display [message], and
/// [attachCauseToExit] is false.
final class CommonClientExceptionView {
  static const _credentialsInvalidMessage =
      'The credentials for this session seem to no longer be valid.';
  static const _unauthorizedMessage =
      'You are not authorized to perform this action.';
  static const _notFoundMessage = 'The requested resource did not exist.';
  static const _procurementDeniedExitReason =
      'The procurement was not allowed.';
  static const _paymentMethodRequiredMessage = 'You need a payment method!';

  final String message;
  final String exitReason;
  final String? hint;
  final bool newParagraph;
  final bool attachCauseToExit;
  final List<CommonClientExceptionCommandHint> commandHints;

  const CommonClientExceptionView({
    required this.message,
    final String? exitReason,
    this.hint,
    this.newParagraph = false,
    this.attachCauseToExit = true,
    this.commandHints = const [],
  }) : exitReason = exitReason ?? message;

  /// `null` if [e] is not a common client exception.
  static CommonClientExceptionView? tryDescribe(
    final Exception e, {
    required final String baseCommand,
  }) {
    return switch (e) {
      ServerpodClientUnauthorized() => CommonClientExceptionView(
        message: _credentialsInvalidMessage,
        commandHints: [
          CommonClientExceptionCommandHint(
            message: 'Run the following commands to re-authenticate:',
            command: '$baseCommand auth logout',
          ),
          CommonClientExceptionCommandHint(command: '$baseCommand auth login'),
        ],
      ),
      UnauthorizedException() => const CommonClientExceptionView(
        message: _unauthorizedMessage,
      ),
      final ProcurementDeniedException denied => _procurement(denied),
      final NotFoundException missing => CommonClientExceptionView(
        message: _notFoundMessage,
        hint: missing.message,
      ),
      _ => null,
    };
  }

  static CommonClientExceptionView _procurement(
    final ProcurementDeniedException e,
  ) {
    final baseUrl = getConsoleBaseUrl();
    if (e.message.contains('no valid payment method')) {
      return CommonClientExceptionView(
        message: _paymentMethodRequiredMessage,
        exitReason: _procurementDeniedExitReason,
        hint: 'To set up your account, visit: $baseUrl/project/create\n',
        newParagraph: true,
        attachCauseToExit: false,
      );
    }

    if (e.reason == ProcurementDeniedReason.productNotAvailable &&
        e.message.toLowerCase().contains('backup')) {
      return CommonClientExceptionView(
        message: e.message,
        exitReason: _procurementDeniedExitReason,
        hint:
            'Database backups are available on the Growth plan. '
            'To upgrade the plan, visit: $baseUrl/project\n',
        newParagraph: true,
        attachCauseToExit: false,
      );
    }

    return CommonClientExceptionView(
      message: e.message,
      exitReason: _procurementDeniedExitReason,
      hint: 'To see your account, visit: $baseUrl/project\n',
      newParagraph: true,
      attachCauseToExit: false,
    );
  }
}
