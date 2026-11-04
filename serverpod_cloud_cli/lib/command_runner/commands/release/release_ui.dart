import 'dart:convert';

import 'package:ground_control_client/ground_control_client.dart'
    show AppBuildStatus, AppBuildStepStatus, AppBuildSummary, AppPlatform;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/util/duration_formatter.dart'
    show friendlyPastTimeFormat;
import 'package:serverpod_cloud_cli/util/output/output.dart';

import 'app_build_step_log.dart';
import 'app_upload_row.dart';

/// Lists app uploads, one row per upload with the platforms it was built
/// for.
class ReleaseUploadListTextUi extends OutputWidget {
  final bool utc;

  const ReleaseUploadListTextUi({required this.utc});

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

/// Lists the app builds of [platforms], one row per build, with a Platform
/// column when there are several platforms.
class ReleaseBuildListTextUi extends OutputWidget {
  final bool utc;
  final List<AppPlatform> platforms;

  const ReleaseBuildListTextUi({required this.utc, required this.platforms});

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

/// Prints the log of each step of an app build as the step ends.
class ReleaseLogTextUi extends OutputWidget {
  const ReleaseLogTextUi();

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
      final step = stepLog.step;
      logger.line('--- ${step.name} (${_statusName(step.status)}) ---');

      final log = stepLog.log;
      if (log != null) {
        for (final line in LineSplitter.split(log)) {
          logger.line(line);
        }
      }
    }
  }

  static String _statusName(AppBuildStepStatus status) {
    return switch (status) {
      AppBuildStepStatus.pending => 'Pending',
      AppBuildStepStatus.running => 'Running',
      AppBuildStepStatus.succeeded => 'Succeeded',
      AppBuildStepStatus.failed => 'Failed',
      AppBuildStepStatus.cancelled => 'Cancelled',
      AppBuildStepStatus.skipped => 'Skipped',
    };
  }
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
    AppBuildStatus.failed => 'Failed',
    AppBuildStatus.cancelled => 'Cancelled',
  };
}
