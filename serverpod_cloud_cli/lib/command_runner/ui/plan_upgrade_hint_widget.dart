import 'package:serverpod_cloud_cli/shared/helpers/plan_features.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart';

/// Points a project whose plan lacks [feature] at its plan page.
class PlanUpgradeHintWidget extends OutputWidget {
  final PlanFeature feature;
  final String projectId;

  const PlanUpgradeHintWidget({required this.feature, required this.projectId});

  @override
  OutputWidget build(final OutputContext context) {
    return InfoTextWidget(feature.upgradeHint(projectId));
  }
}
