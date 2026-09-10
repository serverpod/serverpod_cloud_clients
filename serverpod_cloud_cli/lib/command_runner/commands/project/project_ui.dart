import 'package:cli_tools/logger.dart' as cli show AnsiStyle;
import 'package:ground_control_client/ground_control_client.dart'
    show ProjectInfo, ServerpodRegion;
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/util/common.dart';

class ProjectListTextUi extends OutputWidget {
  final bool utc;

  late final List<TableColumnFormatter<ProjectInfo>> _projectTableColumns;

  ProjectListTextUi({required this.utc, required bool showArchived}) {
    _projectTableColumns = [
      TableColumnFormatter.forElement(
        'Project Id',
        getter: (project) => project.project.cloudProjectId,
      ),
      TableColumnFormatter.forElement(
        'Created At',
        getter: (project) => project.project.createdAt,
      ),
      TableColumnFormatter.forElement(
        'Last Deploy Attempt',
        getter: (project) => project.latestDeployAttemptTime?.timestamp,
      ),
      if (showArchived)
        TableColumnFormatter.forElement(
          'Deleted At',
          getter: (project) => project.project.archivedAt,
        ),
    ];
  }

  @override
  OutputWidget build(OutputContext context) {
    final object = context.get<List<ProjectInfo>>();
    if (object.isEmpty) {
      return InfoTextWidget('No projects available.');
    } else {
      return FormattedTableWidget(
        formatter: TextTableOutputFormatter(
          columns: _projectTableColumns,
          utc: utc,
        ),
      );
    }
  }
}

class ProjectCreateTextUi extends OutputWidget {
  final String planDisplayName;
  final bool includeSuccess;

  const ProjectCreateTextUi({
    required this.planDisplayName,
    this.includeSuccess = true,
  });

  @override
  OutputWidget build(final OutputContext context) {
    return OutputWidgetList([
      InfoTextWidget('On plan: $planDisplayName'),
      ProgressStreamWidget<Map<String, Object?>>(
        initialMessage: 'Registering Serverpod Cloud project',
        successMessage: 'Project registration successful.',
        newParagraph: true,
      ),
      if (includeSuccess)
        const SuccessTextWidget(
          'Serverpod Cloud project created.',
          newParagraph: true,
        ),
    ]);
  }
}

class ProjectCreateDatabaseTextUi extends OutputWidget {
  const ProjectCreateDatabaseTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    return OutputWidgetList([
      ProgressStreamWidget<Map<String, Object?>>(
        initialMessage: 'Requesting database creation',
        successMessage: 'Database creation request sent.',
      ),
      const SuccessTextWidget(
        'Serverpod Cloud project created.',
        newParagraph: true,
      ),
    ]);
  }
}

class ProjectLinkTextUi extends OutputWidget {
  const ProjectLinkTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    return OutputWidgetList([
      ProgressStreamWidget<Map<String, Object?>>(
        initialMessage: 'Writing cloud configuration files',
        successMessage: 'Configuration files written.',
      ),
      const SuccessTextWidget(
        'Linked Serverpod Cloud project.',
        newParagraph: true,
      ),
    ]);
  }
}

class ProjectDeleteTextUi extends OutputWidget {
  const ProjectDeleteTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    return SuccessTextWidget(
      'Deleted the project "${result['projectId']}".',
      newParagraph: true,
    );
  }
}

class ProjectShowTextUi extends OutputWidget {
  static const _labelStyle = cli.AnsiStyle.darkGray;
  static const _groupSeparator = ['', ''];

  final bool utc;

  const ProjectShowTextUi({required this.utc});

  @override
  OutputWidget build(final OutputContext context) {
    final profile = context.get<Map<String, Object?>>();

    return OutputWidgetList([
      const LineTextWidget(),
      TextTableWidget(
        TextTableData(const [], _profileRows(profile)),
        indent: '  ',
        columnSeparator: '  ',
        columnStyles: const [_labelStyle],
      ),
    ]);
  }

  List<List<String>> _profileRows(final Map<String, Object?> profile) {
    final region = profile['region'];

    return [
      ['Project', '${profile['projectId']}'],
      ['Created', _timestamp(profile['createdAt']) ?? '-'],
      if (region is ServerpodRegion) ['Region', _regionName(region)],
      ['Deployed', _timestamp(profile['latestDeployAttemptAt']) ?? 'never'],
      _groupSeparator,
      ..._planRows(profile['plan']),
      _groupSeparator,
      ['Compute', _computeSummary(profile['compute'])],
      ['Database', _databaseSummary(profile['database'])],
    ];
  }

  List<List<String>> _planRows(final Object? plan) {
    if (plan is! Map<String, Object?>) {
      return [
        ['Plan', 'none'],
      ];
    }

    final trialEndsAt = _timestamp(plan['trialEndsAt']);
    final endsAt = _timestamp(plan['endsAt']);
    final endsLead = plan['cancelled'] == true ? 'cancelled, ends' : 'ends';

    return [
      ['Plan', '${plan['displayName']}'],
      if (trialEndsAt != null) ['Trial', 'ends $trialEndsAt'],
      if (endsAt != null) ['Ending', '$endsLead $endsAt'],
    ];
  }

  String _computeSummary(final Object? compute) {
    if (compute is! Map<String, Object?>) {
      return 'not configured';
    }

    final minInstances = compute['minInstances'];
    final maxInstances = compute['maxInstances'];
    final podlets = minInstances == maxInstances
        ? '$minInstances podlet${minInstances == 1 ? '' : 's'}'
        : '$minInstances-$maxInstances podlets';

    return '${_sizeName(compute['size'])} — '
        '${compute['memoryMb']} MB, $podlets';
  }

  String _databaseSummary(final Object? database) {
    if (database is! Map<String, Object?>) {
      return 'not enabled';
    }

    final minCu = database['minCu'];
    final maxCu = database['maxCu'];
    final storageLimitGb = database['storageLimitGb'];
    final computeHoursLimit = database['computeHoursLimit'];

    final details = [
      '${database['memoryMb']} MB',
      if (minCu is num && maxCu is num)
        minCu == maxCu ? '${_cu(minCu)} CU' : '${_cu(minCu)}-${_cu(maxCu)} CU',
      if (storageLimitGb != null) '$storageLimitGb GB storage',
      if (computeHoursLimit != null) '$computeHoursLimit h compute',
    ];

    return '${_sizeName(database['size'])} — ${details.join(', ')}';
  }

  String? _timestamp(final Object? value) {
    if (value is! DateTime) {
      return null;
    }
    return value.toTzString(utc, numTimeStampChars);
  }

  String _sizeName(final Object? size) => size is Enum ? size.name : '$size';

  String _cu(final num value) {
    return value == value.roundToDouble() ? '${value.round()}' : '$value';
  }

  String _regionName(final ServerpodRegion region) {
    return switch (region) {
      ServerpodRegion.usEast => 'US East',
      ServerpodRegion.usWest => 'US West',
      ServerpodRegion.europe => 'Europe',
      ServerpodRegion.asia => 'Asia',
    };
  }
}
