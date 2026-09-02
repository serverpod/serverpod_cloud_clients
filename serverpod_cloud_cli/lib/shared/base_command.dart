/// The base command name of the CLI when it is invoked directly,
/// and the fallback whenever no other name is configured.
const defaultBaseCommand = 'scloud';

/// The invocation paths of the CLI that telemetry distinguishes.
///
/// A base command name that matches none of the known invocations reports as
/// [other], so that a name a wrapper chose freely is never sent.
enum BaseCommandInvocation {
  scloud(defaultBaseCommand),
  serverpodCloud('serverpod cloud'),
  xcloud('xcloud'),
  other('other');

  const BaseCommandInvocation(this.reportedName);

  /// The name reported to analytics and error reporting.
  final String reportedName;

  /// Returns the invocation that [baseCommand] identifies.
  ///
  /// A null or empty name is the direct [scloud] invocation.
  static BaseCommandInvocation from(String? baseCommand) {
    final name = baseCommand?.trim().toLowerCase();
    if (name == null || name.isEmpty) {
      return BaseCommandInvocation.scloud;
    }
    return values.firstWhere(
      (invocation) => invocation.reportedName == name,
      orElse: () => BaseCommandInvocation.other,
    );
  }
}
