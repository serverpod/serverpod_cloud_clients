import 'package:serverpod_cloud_cli/util/output/output.dart';

class PushNotificationTextUi extends OutputWidget {
  const PushNotificationTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final notificationType = result['notificationType'];
    return SuccessTextWidget(
      'Pushed an example $notificationType notification.',
      newParagraph: true,
    );
  }
}
