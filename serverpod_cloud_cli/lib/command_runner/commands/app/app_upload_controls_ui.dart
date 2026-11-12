import 'package:ground_control_client/ground_control_client.dart'
    show UuidValue;
import 'package:serverpod_cloud_cli/util/output/output.dart';

import 'app_artifact_row.dart';
import 'app_build_status_formatter.dart';

/// Reports the app builds whose cancellation was requested.
class AppCancelTextUi extends OutputWidget {
  const AppCancelTextUi();

  @override
  OutputWidget build(OutputContext context) {
    final ids = context.get<List<UuidValue>>();
    return InfoTextWidget(
      ids.isEmpty
          ? 'There are no active builds to cancel.'
          : 'Cancellation requested for ${ids.length} app build(s).',
    );
  }
}

/// Lists the files produced by an app upload with temporary download links.
class AppArtifactsTextUi extends OutputWidget {
  const AppArtifactsTextUi();

  @override
  OutputWidget build(OutputContext context) {
    final artifacts = context.get<List<AppArtifactRow>>();
    if (artifacts.isEmpty) {
      return const InfoTextWidget(
        'No artifacts are available yet, or they have expired.',
      );
    }
    return FormattedTableWidget(
      formatter: TextTableOutputFormatter<AppArtifactRow>(
        columns: [
          TableColumnFormatter.forElement(
            'Platform',
            getter: (row) => AppBuildStatusFormatter.platformName(row.platform),
          ),
          TableColumnFormatter.forElement(
            'File',
            getter: (row) => row.artifact.name,
          ),
          TableColumnFormatter.forElement(
            'Bytes',
            getter: (row) => row.artifact.sizeBytes,
          ),
          TableColumnFormatter.forElement(
            'Download URL (expires in 10 minutes)',
            getter: (row) => row.downloadUrl,
          ),
        ],
        utc: false,
      ),
    );
  }
}
