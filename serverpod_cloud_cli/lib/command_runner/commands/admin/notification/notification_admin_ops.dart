import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract class NotificationAdminOperations {
  static Future<Map<String, Object?>> pushNotification(
    final Client cloudApiClient, {
    required final String notificationType,
  }) async {
    try {
      await cloudApiClient.adminTest.pushNotification(notificationType);
    } on InvalidValueException catch (e) {
      throw FailureException(error: e.message);
    } on ServerpodClientUnauthorized {
      rethrow;
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to push notification');
    }

    return {'notificationType': notificationType};
  }
}
