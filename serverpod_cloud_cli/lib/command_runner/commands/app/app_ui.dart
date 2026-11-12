import 'dart:convert';

import 'package:cli_tools/logger.dart' as cli show AnsiStyle;
import 'package:ground_control_client/ground_control_client.dart'
    show AppBuildStatus, AppBuildSummary, AppPlatform;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/util/duration_formatter.dart'
    show friendlyPastTimeFormat;
import 'package:serverpod_cloud_cli/util/flutter_platform.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart';

import 'app_build_status_formatter.dart';
import 'app_build_output.dart';
import 'app_build_step_log.dart';
import 'app_doctor_check.dart';
import 'app_status_row.dart';
import 'app_upload_row.dart';

/// Lists app uploads, one row per upload with its ID and the platforms it
/// was built for.
class AppUploadListTextUi extends OutputWidget {
  final bool utc;

  const AppUploadListTextUi({required this.utc});

  @override
  OutputWidget build(final OutputContext context) {
    final uploads = context.get<List<AppUploadRow>>();
    if (uploads.isEmpty) {
      return const InfoTextWidget('No publishes yet.');
    }
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter<AppUploadRow>(
        columns: [
          TableColumnFormatter.forElement(
            'ID',
            getter: (upload) => upload.uploadId.toString(),
          ),
          TableColumnFormatter.forElement(
            'Version',
            getter: (upload) => _version(
              upload.versionName,
              upload.builds.map((build) => build.buildNumber),
            ),
          ),
          TableColumnFormatter.forElement(
            'Platforms',
            getter: (upload) => upload.platforms.map(_platformName).join(', '),
          ),
          TableColumnFormatter.forElement(
            'State',
            getter: (upload) => _statusName(upload.status),
          ),
          TableColumnFormatter.forElement(
            'Started',
            getter: (upload) =>
                friendlyPastTimeFormat(upload.createdAt, inUtc: utc),
          ),
        ],
        utc: utc,
      ),
    );
  }
}

/// Lists the app builds of [platforms], one row per build with the ID of
/// its upload, and a Platform column when there are several platforms.
class AppBuildListTextUi extends OutputWidget {
  final bool utc;
  final List<AppPlatform> platforms;

  const AppBuildListTextUi({required this.utc, required this.platforms});

  @override
  OutputWidget build(final OutputContext context) {
    final builds = context.get<List<AppBuildSummary>>();
    if (builds.isEmpty) {
      return InfoTextWidget('No ${_platformNames(platforms)} publishes yet.');
    }
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter<AppBuildSummary>(
        columns: [
          TableColumnFormatter.forElement(
            'ID',
            getter: (build) => build.uploadId.toString(),
          ),
          TableColumnFormatter.forElement(
            'Version',
            getter: (build) => _version(build.versionName, [build.buildNumber]),
          ),
          if (platforms.length > 1)
            TableColumnFormatter.forElement(
              'Platform',
              getter: (build) => _platformName(build.platform),
            ),
          TableColumnFormatter.forElement(
            'State',
            getter: (build) => _statusName(build.status),
          ),
          TableColumnFormatter.forElement(
            'Started',
            getter: (build) =>
                friendlyPastTimeFormat(build.createdAt, inUtc: utc),
          ),
        ],
        utc: utc,
      ),
    );
  }
}

/// Shows each platform with a connected store and the version and state of
/// its latest build. Below the table, a latest build that has not ended
/// shows the command to follow it, and one that failed or was cancelled
/// shows why, with the command to read its log when it started. The
/// commands are invoked through [baseCommand]. With `--format csv`, only
/// the table is shown.
class AppStatusTextUi extends OutputWidget {
  final bool utc;
  final String baseCommand;

  final String projectId;

  const AppStatusTextUi({
    required this.utc,
    required this.baseCommand,
    required this.projectId,
  });

  @override
  OutputWidget build(final OutputContext context) {
    final rows = context.get<List<AppStatusRow>>();
    if (rows.isEmpty) {
      return const InfoTextWidget('No store is connected to the project yet.');
    }
    if (context.format == OutputFormat.csv) {
      return _statusTable(rows);
    }
    final followedUploads = <Object>{};
    return OutputWidgetList([
      _statusTable(rows),
      for (final row in rows)
        if (row.latestBuild case final build?)
          if (_hasEnded(build.status) || followedUploads.add(build.uploadId))
            ?_buildHint(build),
    ]);
  }

  OutputWidget _statusTable(List<AppStatusRow> rows) {
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter<AppStatusRow>(
        columns: [
          TableColumnFormatter.forElement(
            'Platform',
            getter: (row) => _platformName(row.platform),
          ),
          TableColumnFormatter.forElement(
            'Store',
            getter: (row) => _storeName(row.store),
          ),
          TableColumnFormatter.forElement(
            'Version',
            getter: (row) => switch (row.latestBuild) {
              final build? => _version(build.versionName, [build.buildNumber]),
              null => '',
            },
          ),
          TableColumnFormatter.forElement(
            'State',
            getter: (row) => switch (row.latestBuild) {
              final build? => _latestBuildState(build, utc: utc),
              null => 'No builds yet',
            },
          ),
        ],
        utc: utc,
      ),
    );
  }

  /// The command to follow [build] while it has not ended, or the reason it
  /// did not succeed, with the command to read its log when it started.
  /// Null for a build that succeeded.
  OutputWidget? _buildHint(AppBuildSummary build) {
    final reason = AppBuildStatusFormatter.summaryError(build.platform, build);
    if (reason == null) return null;
    return switch (build.status) {
      AppBuildStatus.queued ||
      AppBuildStatus.waiting ||
      AppBuildStatus.running => CommandHintTextWidget(
        'Follow the ${_platformName(build.platform)} build:',
        command: '$baseCommand app show ${build.uploadId} --project $projectId',
        newParagraph: true,
      ),
      AppBuildStatus.failed || AppBuildStatus.cancelled
          when build.startedAt == null =>
        InfoTextWidget(reason, newParagraph: true),
      AppBuildStatus.builtNotUploaded ||
      AppBuildStatus.failed ||
      AppBuildStatus.cancelled => CommandHintTextWidget(
        reason,
        command:
            '$baseCommand app log ${build.uploadId} '
            '--platform ${build.platform.name} --project $projectId',
        newParagraph: true,
      ),
      AppBuildStatus.succeeded => null,
    };
  }
}

bool _hasEnded(AppBuildStatus status) {
  return switch (status) {
    AppBuildStatus.queued ||
    AppBuildStatus.waiting ||
    AppBuildStatus.running => false,
    AppBuildStatus.succeeded ||
    AppBuildStatus.builtNotUploaded ||
    AppBuildStatus.failed ||
    AppBuildStatus.cancelled => true,
  };
}

String _storeName(AppStore store) {
  return switch (store) {
    AppStore.appStore => 'App Store',
    AppStore.googlePlay => 'Google Play',
  };
}

/// The state of [build] with when it reached it, like "Uploaded · 2h ago".
String _latestBuildState(AppBuildSummary build, {required bool utc}) {
  final state = switch (build.status) {
    AppBuildStatus.succeeded => 'Uploaded',
    final status => _statusName(status),
  };
  final reachedAt = build.endedAt ?? build.startedAt ?? build.createdAt;
  return '$state · ${friendlyPastTimeFormat(reachedAt, inUtc: utc, short: true)}';
}

/// Prints the log of each step of an app build as the step ends.
class AppLogTextUi extends OutputWidget {
  const AppLogTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    return _StepLogsWidget(stream: context.get<Stream<AppBuildStepLog>>());
  }
}

class _StepLogsWidget extends OutputWidget {
  final Stream<AppBuildStepLog> stream;

  const _StepLogsWidget({required this.stream});

  @override
  Future<void> renderAsync({required final CommandLogger logger}) async {
    await for (final stepLog in stream) {
      logger.line(AppBuildStatusFormatter.stepLogHeading(stepLog.step));

      final log = stepLog.log;
      if (log != null) {
        for (final line in LineSplitter.split(log)) {
          logger.line(line);
        }
      }
    }
  }
}

/// Shows the checks of `app doctor`, those of the whole app first and then
/// those of each platform, each with what it found and how to address a
/// warning or a failure, followed by a summary of the failures and
/// warnings.
class AppDoctorTextUi extends OutputWidget {
  const AppDoctorTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final checks = context.get<List<AppDoctorCheck>>();
    final failed = _count(checks, AppDoctorCheckStatus.failed);
    final warnings = _count(checks, AppDoctorCheckStatus.warning);
    final sections = [
      for (final platform in <FlutterPlatform?>[
        null,
        ...FlutterPlatform.values,
      ])
        if (checks.any((check) => check.platform == platform))
          (
            heading: platform == null ? 'App' : _flutterPlatformName(platform),
            checks: checks.where((check) => check.platform == platform),
          ),
    ];
    return OutputWidgetList([
      for (final (index, section) in sections.indexed) ...[
        if (index > 0) const LineTextWidget(),
        LineTextWidget(section.heading),
        for (final check in section.checks) ...[
          _DoctorCheckLineWidget(check),
          if (check.hint case final hint?)
            for (final line in LineSplitter.split(hint))
              LineTextWidget('    $line'),
        ],
      ],
      if (failed > 0)
        WarningTextWidget(
          '${_checks(failed)} failed. '
          'Fix ${failed == 1 ? 'it' : 'them'} before you publish the app.',
          newParagraph: true,
        )
      else if (warnings > 0)
        InfoTextWidget(
          '${warnings == 1 ? '1 warning' : '$warnings warnings'} found',
          newParagraph: true,
        )
      else
        const SuccessTextWidget('No issues found.', newParagraph: true),
    ]);
  }
}

int _count(List<AppDoctorCheck> checks, AppDoctorCheckStatus status) =>
    checks.where((check) => check.status == status).length;

String _checks(int count) => count == 1 ? '1 check' : '$count checks';

/// Renders one check of `app doctor` as a line with a mark coloured by its
/// status, its name, and what it found.
class _DoctorCheckLineWidget extends OutputWidget {
  final AppDoctorCheck check;

  const _DoctorCheckLineWidget(this.check);

  @override
  void render({required final CommandLogger logger}) {
    final (mark, style) = switch (check.status) {
      AppDoctorCheckStatus.passed => ('✓', cli.AnsiStyle.lightGreen),
      AppDoctorCheckStatus.warning => ('!', cli.AnsiStyle.yellow),
      AppDoctorCheckStatus.failed => ('✗', cli.AnsiStyle.red),
    };
    logger.line(
      '  ${logger.wrapStyle(mark, style)} ${_checkName(check)}: '
      '${check.detail}',
    );
  }
}

String _checkName(AppDoctorCheck check) {
  return switch (check.kind) {
    AppDoctorCheckKind.flutterVersion => 'Flutter version',
    AppDoctorCheckKind.appIdentifier => switch (check.platform) {
      FlutterPlatform.ios => 'Bundle ID',
      FlutterPlatform.android => 'Package name',
      null ||
      FlutterPlatform.linux ||
      FlutterPlatform.macos ||
      FlutterPlatform.windows => 'App identifier',
    },
    AppDoctorCheckKind.releaseSigning => 'Release signing',
    AppDoctorCheckKind.exportCompliance => 'Export compliance',
  };
}

String _flutterPlatformName(FlutterPlatform platform) {
  return switch (platform) {
    FlutterPlatform.android => 'Android',
    FlutterPlatform.ios => 'iOS',
    FlutterPlatform.linux => 'Linux',
    FlutterPlatform.macos => 'macOS',
    FlutterPlatform.windows => 'Windows',
  };
}

/// The [versionName] followed by the distinct [buildNumbers] in
/// parentheses, like "1.4.2 (38)".
String _version(String? versionName, Iterable<String?> buildNumbers) {
  final numbers = buildNumbers.nonNulls.toSet();
  return [
    ?versionName,
    if (numbers.isNotEmpty) '(${numbers.join(', ')})',
  ].join(' ');
}

String _platformNames(List<AppPlatform> platforms) {
  final names = platforms.map(_platformName).toList();
  if (names.length == 1) {
    return names.single;
  }
  return '${names.take(names.length - 1).join(', ')} or ${names.last}';
}

String _platformName(AppPlatform platform) {
  return switch (platform) {
    AppPlatform.ios => 'iOS',
    AppPlatform.android => 'Android',
  };
}

String _statusName(AppBuildStatus status) {
  return switch (status) {
    AppBuildStatus.queued => 'Queued',
    AppBuildStatus.waiting => 'Waiting',
    AppBuildStatus.running => 'Running',
    AppBuildStatus.succeeded => 'Succeeded',
    AppBuildStatus.builtNotUploaded => 'Built, not uploaded',
    AppBuildStatus.failed => 'Failed',
    AppBuildStatus.cancelled => 'Cancelled',
  };
}

/// Serializes app builds with requester display information for JSON or YAML.
class AppBuildListStructuredUi extends OutputWidget {
  const AppBuildListStructuredUi();

  @override
  OutputWidget build(OutputContext context) {
    final builds = context
        .get<List<AppBuildSummary>>()
        .map(appBuildOutput)
        .toList();
    final formatter = context.format == OutputFormat.yaml
        ? const YamlOutputFormatter<List<Map<String, Object?>>>()
        : const JsonOutputFormatter<List<Map<String, Object?>>>();
    return RawStringWidget(formatter.format(builds));
  }
}
