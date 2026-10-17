import 'package:cli_tools/logger.dart' as cli show AnsiStyle;
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/admin_overview_line_writer.dart';
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class AdminUserStatusTextUi extends OutputWidget {
  final bool utc;

  AdminUserStatusTextUi({required this.utc});

  @override
  OutputWidget build(OutputContext context) {
    return _AdminUserStatusPanel(
      status: context.get<AdminUserStatus>(),
      utc: utc,
    );
  }
}

class _AdminUserStatusPanel extends OutputWidget {
  final AdminUserStatus status;
  final bool utc;

  const _AdminUserStatusPanel({required this.status, required this.utc});

  @override
  void render({required CommandLogger logger}) {
    for (final line in _AdminUserStatusLines(
      logger: logger,
      status: status,
      utc: utc,
    ).build()) {
      logger.line(line);
    }
  }
}

class _AdminUserStatusLines {
  static const _indent = '  ';
  static const _labelWidth = 10;
  static const _labelStyle = cli.AnsiStyle.darkGray;
  static const _dimStyle = cli.AnsiStyle.darkGray;

  final CommandLogger logger;
  final AdminUserStatus status;
  final bool utc;
  final List<String> _lines = [];

  _AdminUserStatusLines({
    required this.logger,
    required this.status,
    required this.utc,
  });

  List<String> build() {
    _lines.clear();
    _lines.add('');
    _writeOwnerSection();
    _writeProjectsSection();
    return _lines;
  }

  void _writeOwnerSection() {
    final owner = status.owner;
    final email = owner.userEmail ?? '(no email)';
    _writeRow('User', email);

    _writeRow('Owner id', owner.ownerId.toString(), nested: true);

    final billingParts = <String>[
      if (owner.billingInfoRegistered) 'billing info registered',
      if (owner.paymentMethodRegistered) 'payment method on file',
    ];
    if (billingParts.isEmpty) {
      _writeRow('Billing', _style('none', _dimStyle), nested: true);
    } else {
      _writeRow('Billing', billingParts.join(' · '), nested: true);
    }

    final customerType = owner.customerType?.name;
    if (customerType != null) {
      _writeRow('Customer', customerType, nested: true);
    }

    final standing = owner.inGoodStanding
        ? _style('in good standing', cli.AnsiStyle.lightGreen)
        : _style('not in good standing', cli.AnsiStyle.red);
    _writeRow('Standing', standing, nested: true);
  }

  void _writeProjectsSection() {
    final projects = status.projects;
    if (projects.isEmpty) {
      _lines.add('');
      _writeRow('Projects', _style('none', _dimStyle));
      return;
    }

    _lines.add('');
    var isFirst = true;
    for (final project in projects) {
      if (!isFirst) {
        _lines.add('');
      }
      isFirst = false;
      _writeProject(project);
    }
  }

  void _writeProject(AdminUserProjectMembership project) {
    final overview = AdminOverviewLineWriter(logger: logger, utc: utc);
    overview.writeRow('Project', project.cloudProjectId);
    overview.writeLifecycle(
      status: project.status,
      suspendedAt: project.suspendedAt,
      suspensionReason: project.suspensionReason,
    );

    final roles = project.userRoles.map((role) => role.name).join(', ');
    overview.writeRow('Roles', roles.isEmpty ? '—' : roles, nested: true);
    overview.writePlan(
      planType: project.planType,
      planProductId: project.planProductId,
    );
    overview.writeBilling(
      billingPlanId: project.billingPlanId,
      subscriptionId: project.billingSubscriptionId,
    );
    overview.writeCreated(project.projectCreatedAt);
    overview.writeLastDeploy(project.latestDeployAttempt);
    _lines.addAll(overview.lines);
  }

  void _writeRow(
    String label,
    String value, {
    bool nested = false,
    cli.AnsiStyle labelStyle = _labelStyle,
  }) {
    final prefix = nested ? _indent : '';
    _lines.add(
      '$prefix${_style(label.padRight(_labelWidth), labelStyle)}$value',
    );
  }

  String _style(String text, cli.AnsiStyle? style) {
    if (style == null) {
      return text;
    }
    return logger.wrapStyle(text, style);
  }
}

class AdminUserListTextUi extends OutputWidget {
  final bool utc;

  AdminUserListTextUi({required this.utc});

  @override
  OutputWidget build(OutputContext context) {
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter(
        columns: [
          TableColumnFormatter.forKey('User', key: 'email'),
          TableColumnFormatter.forKey('Account status', key: 'accountStatus'),
          TableColumnFormatter.forTimestampKey('Created at', key: 'createdAt'),
          TableColumnFormatter.forTimestampKey(
            'Archived at',
            key: 'archivedAt',
          ),
          TableColumnFormatter.forKey(
            'Subscribed Plans',
            key: 'subscribedPlans',
          ),
        ],
        utc: utc,
      ),
    );
  }
}

class AdminInviteUserTextUi extends OutputWidget {
  const AdminInviteUserTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    return const SuccessTextWidget(
      'User invited to Serverpod Cloud.',
      newParagraph: true,
    );
  }
}

class AdminUserAttachTextUi extends OutputWidget {
  const AdminUserAttachTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final roles = result['roles'];
    final roleNames = roles is List ? roles.join(', ') : '';
    return SuccessTextWidget(
      'User attached to the project with roles: $roleNames.',
      newParagraph: true,
    );
  }
}

class AdminUserDetachTextUi extends OutputWidget {
  final bool unassignAllRoles;

  const AdminUserDetachTextUi({required this.unassignAllRoles});

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final unassigned = result['unassigned'];
    final names = unassigned is List
        ? unassigned.cast<String>()
        : const <String>[];

    if (names.isEmpty) {
      return InfoTextWidget(
        unassignAllRoles
            ? 'The user has no access roles to detach from the project.'
            : 'The user does not have any of the specified project roles.',
      );
    }

    final message = unassignAllRoles
        ? 'Detached all access roles of the user from the project: ${names.join(', ')}'
        : 'Detached access roles of the user from the project: ${names.join(', ')}';

    return SuccessTextWidget(message, newParagraph: true);
  }
}
