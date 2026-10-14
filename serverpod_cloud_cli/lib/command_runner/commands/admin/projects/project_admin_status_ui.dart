import 'package:cli_tools/logger.dart' as cli show AnsiStyle;
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/admin_overview_line_writer.dart';
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class AdminProjectStatusTextUi extends OutputWidget {
  final bool utc;

  AdminProjectStatusTextUi({required this.utc});

  @override
  OutputWidget build(OutputContext context) {
    return _AdminProjectStatusPanel(
      info: context.get<AdminProjectInfo>(),
      utc: utc,
    );
  }
}

class _AdminProjectStatusPanel extends OutputWidget {
  final AdminProjectInfo info;
  final bool utc;

  const _AdminProjectStatusPanel({required this.info, required this.utc});

  @override
  void render({required CommandLogger logger}) {
    for (final line in _AdminProjectStatusLines(
      logger: logger,
      info: info,
      utc: utc,
    ).build()) {
      logger.line(line);
    }
  }
}

class _AdminProjectStatusLines {
  static const _dimStyle = cli.AnsiStyle.darkGray;

  final CommandLogger logger;
  final AdminProjectInfo info;
  final bool utc;
  final List<String> _lines = [];

  _AdminProjectStatusLines({
    required this.logger,
    required this.info,
    required this.utc,
  });

  List<String> build() {
    _lines.clear();
    _lines.add('');

    final projectInfo = info.projectInfo;
    final project = projectInfo.project;
    final overview = AdminOverviewLineWriter(logger: logger, utc: utc);
    overview.writeRow('Project', project.cloudProjectId);
    _writeRoleMemberships(overview, project);
    overview.writePlan(
      planType: projectInfo.planType,
      planProductId: info.planProductId.isEmpty ? null : info.planProductId,
    );
    overview.writeBilling(
      billingPlanId: info.billingPlanId,
      subscriptionId: info.subscriptionId.isEmpty ? null : info.subscriptionId,
    );
    overview.writeCreated(project.createdAt);
    overview.writeLastDeploy(info.latestDeployAttempt);
    _lines.addAll(overview.lines);
    return _lines;
  }

  void _writeRoleMemberships(
    AdminOverviewLineWriter overview,
    Project project,
  ) {
    final roles = project.roles ?? const [];
    if (roles.isEmpty) {
      overview.writeRow(
        'Roles',
        overview.style('none', _dimStyle),
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
