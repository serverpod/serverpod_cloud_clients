import 'package:cli_tools/logger.dart' as cli show AnsiStyle;
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/duration_formatter.dart';

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
  static const _orbSubscriptionsBase = 'https://app.withorb.com/subscriptions/';
  static const _oscHyperlinkStart = '\x1b]8;;';
  static const _oscHyperlinkEnd = '\x1b]8;;\x07';
  static const _bell = '\x07';

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
    _writeRow('Project', project.cloudProjectId);

    final roles = project.userRoles.map((role) => role.name).join(', ');
    _writeRow('Roles', roles.isEmpty ? '—' : roles, nested: true);

    final planType = project.planType?.name;
    final planProductId = project.planProductId;
    final planValue = switch ((planType, planProductId)) {
      (null, null) => _style('unknown', _dimStyle),
      (final String type, null) => type,
      (null, final String id) => id,
      (final String type, final String id) => '$type · $id',
    };
    _writeRow('Plan', planValue, nested: true);

    final billingPlanId = project.billingPlanId;
    final subscriptionId = project.billingSubscriptionId;
    final billingValue = switch ((billingPlanId, subscriptionId)) {
      (null, null) => _style('none', _dimStyle),
      (final String plan, null) => plan,
      (null, final String sub) => _orbSubscriptionLink(sub),
      (final String plan, final String sub) =>
        '$plan · ${_orbSubscriptionLink(sub)}',
    };
    _writeRow('Billing', billingValue, nested: true);

    _writeRow(
      'Created',
      project.projectCreatedAt.toLabeledTzString(utc, numTimeStampChars),
      nested: true,
    );

    _writeLastDeploy(project.latestDeployAttempt);
  }

  void _writeLastDeploy(DeployAttempt? attempt) {
    if (attempt == null) {
      _writeRow('Deploy', _style('none', _dimStyle), nested: true);
      return;
    }

    final startedAt = attempt.startedAt;
    final endedAt = attempt.endedAt;
    final when = endedAt ?? startedAt;
    if (when == null) {
      return;
    }

    final status = attempt.status;
    final (
      String label,
      String prefix,
      cli.AnsiStyle? labelStyle,
    ) = switch (status) {
      DeployProgressStatus.success => (
        'Deployed',
        'Deployed',
        cli.AnsiStyle.lightGreen,
      ),
      DeployProgressStatus.failure => (
        'Failed',
        'Deployment',
        cli.AnsiStyle.red,
      ),
      DeployProgressStatus.awaiting || DeployProgressStatus.running => (
        'Building',
        'Started',
        cli.AnsiStyle.yellow,
      ),
      DeployProgressStatus.cancelled => (
        'Cancelled',
        'Deployment',
        cli.AnsiStyle.red,
      ),
      _ => ('Deploy', 'Started', null),
    };

    final deployedBy = attempt.deployedBy;
    final deployerName = deployedBy?.email ?? deployedBy?.name;
    final by = deployerName != null ? ' by $deployerName' : '';
    final time = friendlyPastTimeFormat(when, inUtc: utc);
    _writeRow(
      label,
      '$prefix $time$by',
      nested: true,
      labelStyle: labelStyle ?? _labelStyle,
    );

    final commitHash = attempt.commitHash;
    final commitMessage = attempt.commitMessage;
    if (commitHash == null && commitMessage == null) {
      return;
    }
    final commitLine = [commitHash, commitMessage].nonNulls.join('  ');
    _lines.add('$_indent${' ' * _labelWidth}${_style(commitLine, _dimStyle)}');
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

  String _orbSubscriptionUrl(String subscriptionId) {
    return '$_orbSubscriptionsBase$subscriptionId';
  }

  String _orbSubscriptionLink(String subscriptionId) {
    final url = _orbSubscriptionUrl(subscriptionId);
    if (!logger.inlineTerminal.hasTerminal) {
      return url;
    }
    final label = _style(subscriptionId, cli.AnsiStyle.cyan);
    return '$_oscHyperlinkStart$url$_bell$label$_oscHyperlinkEnd';
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
