import 'package:ground_control_client/ground_control_client.dart'
    show ProjectSuspendedException, ProjectSuspensionReason;
import 'package:serverpod_cloud_cli/shared/helpers/console_urls.dart';

/// The user-facing hint for a [ProjectSuspendedException]:
/// why the project is suspended and where to resolve it.
String projectSuspendedHint(ProjectSuspendedException exception) {
  final reason = switch (exception.reason) {
    ProjectSuspensionReason.subscriptionEnded => 'The subscription has ended.',
    ProjectSuspensionReason.paymentOverdue => 'Payment is overdue.',
    ProjectSuspensionReason.usageCapExceeded =>
      'The usage cap for the current billing period has been exceeded.',
    ProjectSuspensionReason.manual =>
      'It was suspended by Serverpod Cloud support.',
    null => null,
  };
  final projectsUrl = '${getConsoleBaseUrl()}/project';
  final resolve = 'To manage your account, visit: $projectsUrl\n';
  return reason == null ? resolve : '$reason $resolve';
}
