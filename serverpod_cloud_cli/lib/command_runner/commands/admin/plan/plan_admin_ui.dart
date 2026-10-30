import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class PlanUpdateTextUi extends OutputWidget {
  const PlanUpdateTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final externalPlanId = result['externalPlanId'];
    final appliedVersion = result['appliedVersion'];
    if (appliedVersion is String && appliedVersion.isNotEmpty) {
      return SuccessTextWidget(
        'Orb plan "$externalPlanId" successfully updated to version $appliedVersion.',
        newParagraph: true,
      );
    }
    return InfoTextWidget(
      'Orb plan "$externalPlanId" already up to date.',
      newParagraph: true,
    );
  }
}
