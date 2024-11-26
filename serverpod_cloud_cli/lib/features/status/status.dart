import 'package:collection/collection.dart';
import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/table_printer.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';

abstract class StatusFeature {
  static Future<TablePrinter> getBuildsList(
    final Client cloudApiClient, {
    required final String projectId,
    required final int limit,
    final bool inUtc = false,
  }) async {
    final List<BuildStatus> builds;
    builds = await cloudApiClient.status.getBuildStatuses(
      cloudProjectId: projectId,
      limit: limit,
    );

    return BuildStatusTable(inUtc: inUtc)..addRows(builds);
  }

  static Future<String> getDeploymentStatus(
    final Client cloudApiClient, {
    required final String projectId,
    required final String buildId,
    final bool inUtc = false,
  }) async {
    const pendingMark = '⬛';
    const workingMark = '…';
    const successMark = '✅';
    const failureMark = '❌';

    final build = await cloudApiClient.status.getBuildStatus(
      cloudProjectId: projectId,
      buildId: buildId,
    );
    final List<String> rows = [
      'Status of $projectId build $buildId'
          ', started at ${build.startTime?.toTzString(inUtc, _numTimeStampChars)}:',
      ...switch (build.status) {
        'SUCCESS' => [
            '$successMark  Booster liftoff:     Upload successful!',
            '$successMark  Orbit acceleration:  Build successful!',
            '$successMark  Orbital insertion:   Deploy successful!',
            '$successMark  Pod commissioning:   Service running! 🚀',
          ],
        'PENDING' || 'QUEUED' || 'WORKING' => [
            '$successMark  Booster liftoff:     Upload successful!',
            '$workingMark  Orbit acceleration:  Build in progress. See build logs.',
            '$pendingMark  Orbital insertion:   Deploy pending...',
            '$successMark  Pod commissioning:   Service pending...',
          ],
        _ => [
            '$successMark  Booster liftoff:     Upload successful!',
            '$failureMark  Orbit acceleration:  Build failed! 💥 See build logs.',
            '$pendingMark  Orbital insertion:   Unable to deploy.',
          ],
      },
    ];

    return rows.expand((final r) => ['$r\n', '\n']).join();
  }

  static Future<String> getBuildId(
    final Client cloudApiClient, {
    required final String projectId,
    required final int buildNumber,
  }) async {
    return await cloudApiClient.status.getBuildId(
      cloudProjectId: projectId,
      buildNumber: buildNumber,
    );
  }
}

const _numTimeStampChars = 19;

class BuildStatusTable extends TablePrinter {
  final bool inUtc;

  BuildStatusTable({this.inUtc = false})
      : super(headers: [
          '#',
          'Project',
          'Build Id',
          'Status',
          'Started',
          'Finished',
          'Info',
        ]);

  void addRows(final Iterable<BuildStatus> buildes) {
    buildes.mapIndexed(_tableRowFromBuildBuild).forEach(addRow);
  }

  List<String?> _tableRowFromBuildBuild(
      final int index, final BuildStatus build) {
    return [
      index.toString(),
      build.cloudProjectId,
      build.buildId,
      build.status,
      build.startTime?.toTzString(inUtc, _numTimeStampChars),
      build.finishTime?.toTzString(inUtc, _numTimeStampChars),
      build.info,
    ];
  }
}
