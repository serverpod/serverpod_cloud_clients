import 'exit_exceptions.dart';

/// Thrown in `--non-interactive` mode when a command needs a login but has no
/// session.
///
/// The interactive browser login is not started in `--non-interactive` mode.
class NotLoggedInException extends FailureException {
  NotLoggedInException({required String baseCommand})
    : super(
        error: 'Not logged in.',
        hint:
            'Run `$baseCommand auth login`, or set the SERVERPOD_CLOUD_TOKEN '
            'environment variable.',
        reason:
            'Not logged in and --non-interactive prevents the interactive login.',
      );
}

/// Thrown in `--non-interactive` mode when a command reaches a prompt that
/// needs user input.
class UserInputRequiredException extends FailureException {
  UserInputRequiredException._({
    required String what,
    required String prompt,
    required String hint,
  }) : super(
         error:
             '$what is required, but --non-interactive prevents waiting for it.',
         hint: hint,
         reason: '$what required in --non-interactive mode: $prompt',
       );

  /// A `y/n` confirmation prompt, which `--yes` can answer.
  factory UserInputRequiredException.confirmation(String prompt) =>
      UserInputRequiredException._(
        what: 'A confirmation',
        prompt: prompt,
        hint:
            'Pass --yes to accept confirmation prompts, '
            'or drop --non-interactive to answer interactively.',
      );

  /// A free text input prompt, which has no non-interactive answer.
  factory UserInputRequiredException.input(String prompt) =>
      UserInputRequiredException._(
        what: 'User input',
        prompt: prompt,
        hint: 'Drop --non-interactive to answer interactively.',
      );
}
