import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract class BillingAdminOperations {
  /// Starts the subscription state backfill on the server.
  ///
  /// The server returns as soon as the backfill is started, so this reports
  /// only that it was requested.
  static Future<Map<String, Object?>> backfillSubscriptionStates(
    final Client cloudApiClient,
  ) async {
    try {
      await cloudApiClient.adminBilling.backfillSubscriptionStates();
    } on ServerpodClientUnauthorized {
      rethrow;
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Failed to start the subscription state backfill',
      );
    }

    return {'started': true};
  }
}
