import 'package:ground_control_client/ground_control_client.dart'
    show AppBuildStatus, AppBuildSummary, AppPlatform;
import 'package:serverpod_cloud_cli/util/duration_formatter.dart'
    show friendlyPastTimeFormat;
import 'package:serverpod_cloud_cli/util/output/output.dart';

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
