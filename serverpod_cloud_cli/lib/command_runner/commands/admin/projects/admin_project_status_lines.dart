import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/admin_overview_line_writer.dart';

/// Text lines for one admin project status overview.
class AdminProjectStatusLines {
  final CommandLogger logger;
  final AdminProjectInfo info;
  final bool utc;

  AdminProjectStatusLines({
    required this.logger,
    required this.info,
    required this.utc,
  });

  List<String> build() {
    final projectInfo = info.projectInfo;
    final project = projectInfo.project;
    final overview = AdminOverviewLineWriter(
      logger: logger,
      utc: utc,
      labelWidth: 14,
    );
    overview.writeRow('Project', project.cloudProjectId);
    overview.writeLifecycle(
      status: info.status,
      suspendedAt: info.suspendedAt,
      suspensionReason: info.suspensionReason,
    );
    _writeRoleMemberships(overview, project);
    overview.writePlan(
      planType: projectInfo.planType,
      planProductId: info.planProductId.isEmpty ? null : info.planProductId,
    );
    overview.writeBilling(
      billingPlanId: info.billingPlanId,
      subscriptionId: info.subscriptionId.isEmpty ? null : info.subscriptionId,
    );
    overview.writeSubscriptionFacts(
      trialEndDate: info.trialEndDate,
      firstPaidAt: info.firstInvoicePaidAt,
      firstPaidInvoiceId: info.firstPaidInvoiceId,
      gracePeriodInvoiceId: info.gracePeriodInvoiceId,
      gracePeriodSuspendAt: info.gracePeriodSuspendAt,
      gracePeriodConcludedAt: info.gracePeriodConcludedAt,
    );
    overview.writeCreated(project.createdAt);
    overview.writeLastDeploy(info.latestDeployAttempt);
    return overview.lines;
  }

  void _writeRoleMemberships(
    AdminOverviewLineWriter overview,
    Project project,
  ) {
    final roles = project.roles ?? const [];
    if (roles.isEmpty) {
      overview.writeRow(
        'Roles',
        overview.style('none', AdminOverviewLineWriter.dimStyle),
        nested: true,
      );
      return;
    }

    final sortedRoles = [...roles]
      ..sort((a, b) => a.roleName.name.compareTo(b.roleName.name));

    var isFirst = true;
    for (final role in sortedRoles) {
      final emails =
          (role.memberships ?? const [])
              .map((membership) => membership.user?.email)
              .nonNulls
              .toList()
            ..sort();
      final users = emails.join(', ');
      final value = users.isEmpty
          ? '${role.roleName.name}: —'
          : '${role.roleName.name}: $users';
      if (isFirst) {
        overview.writeRow('Roles', value, nested: true);
        isFirst = false;
      } else {
        overview.writeRow('', value, nested: true);
      }
    }
  }
}
