import 'package:cli_tools/logger.dart' as cli show AnsiStyle;
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/duration_formatter.dart';

class AdminOverviewLineWriter {
  static const indent = '  ';
  static const labelWidth = 10;
  static const labelStyle = cli.AnsiStyle.darkGray;
  static const dimStyle = cli.AnsiStyle.darkGray;
  static const orbSubscriptionsBase = 'https://app.withorb.com/subscriptions/';
  static const oscHyperlinkStart = '\x1b]8;;';
  static const oscHyperlinkEnd = '\x1b]8;;\x07';
  static const bell = '\x07';

  final CommandLogger logger;
  final bool utc;
  final List<String> lines = [];

  AdminOverviewLineWriter({required this.logger, required this.utc});

  void writeLifecycle({
    required ProjectLifecycleStatus status,
    DateTime? suspendedAt,
    ProjectSuspensionReason? suspensionReason,
  }) {
    final (cli.AnsiStyle color, String label) = switch (status) {
      ProjectLifecycleStatus.active => (cli.AnsiStyle.lightGreen, 'active'),
      ProjectLifecycleStatus.suspended => (cli.AnsiStyle.yellow, 'suspended'),
      ProjectLifecycleStatus.archived => (cli.AnsiStyle.darkGray, 'archived'),
    };
    writeRow(
      'Phase',
      style(label, color),
      nested: true,
      labelStyleValue: color,
    );

    if (suspendedAt != null) {
      writeRow(
        'Suspended',
        suspendedAt.toLabeledTzString(utc, numTimeStampChars),
        nested: true,
      );
    }

    if (suspensionReason != null) {
      writeRow('Reason', suspensionReason.name, nested: true);
    }
  }

  void writePlan({
    required PlanType? planType,
    required String? planProductId,
  }) {
    final planTypeName = planType?.name;
    final planValue = switch ((planTypeName, planProductId)) {
      (null, null) => style('unknown', dimStyle),
      (final String type, null) => type,
      (null, final String id) => id,
      (final String type, final String id) => '$type · $id',
    };
    writeRow('Plan', planValue, nested: true);
  }

  void writeBilling({
    required String? billingPlanId,
    required String? subscriptionId,
  }) {
    final billingValue = switch ((billingPlanId, subscriptionId)) {
      (null, null) => style('none', dimStyle),
      (final String plan, null) => plan,
      (null, final String sub) => orbSubscriptionLink(sub),
      (final String plan, final String sub) =>
        '$plan · ${orbSubscriptionLink(sub)}',
    };
    writeRow('Billing', billingValue, nested: true);
  }

  void writeCreated(DateTime projectCreatedAt) {
    writeRow(
      'Created',
      projectCreatedAt.toLabeledTzString(utc, numTimeStampChars),
      nested: true,
    );
  }

  void writeLastDeploy(DeployAttempt? attempt) {
    if (attempt == null) {
      writeRow('Deploy', style('none', dimStyle), nested: true);
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
      cli.AnsiStyle? labelStyleValue,
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
    writeRow(
      label,
      '$prefix $time$by',
      nested: true,
      labelStyleValue: labelStyleValue ?? labelStyle,
    );

    final commitHash = attempt.commitHash;
    final commitMessage = attempt.commitMessage;
    if (commitHash == null && commitMessage == null) {
      return;
    }
    final commitLine = [commitHash, commitMessage].nonNulls.join('  ');
    lines.add('$indent${' ' * labelWidth}${style(commitLine, dimStyle)}');
  }

  void writeRow(
    String label,
    String value, {
    bool nested = false,
    cli.AnsiStyle labelStyleValue = labelStyle,
  }) {
    final prefix = nested ? indent : '';
    lines.add(
      '$prefix${style(label.padRight(labelWidth), labelStyleValue)}$value',
    );
  }

  String style(String text, cli.AnsiStyle? styleValue) {
    if (styleValue == null) {
      return text;
    }
    return logger.wrapStyle(text, styleValue);
  }

  String orbSubscriptionLink(String subscriptionId) {
    final url = '$orbSubscriptionsBase$subscriptionId';
    final visible = style(url, cli.AnsiStyle.cyan);
    if (!logger.inlineTerminal.hasTerminal) {
      return visible;
    }
    return '$oscHyperlinkStart$url$bell$visible$oscHyperlinkEnd';
  }
}
