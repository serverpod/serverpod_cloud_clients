import 'package:collection/collection.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract final class StorageOperations {
  /// Lists the storages of the project, sorted by storage id.
  ///
  /// Throws [FailureException] if the project is not found
  /// or the request fails.
  static Future<List<BucketResource>> listStorages(
    Client cloudApiClient, {
    required String projectId,
    required String baseCommand,
  }) async {
    final List<BucketResource> storages;
    try {
      storages = await cloudApiClient.bucket.listBuckets(
        cloudCapsuleId: projectId,
      );
    } on NotFoundException {
      throw FailureException(
        error: 'Project "$projectId" was not found.',
        hint: 'Run "$baseCommand project list" to see your projects.',
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to list storages.');
    }

    return storages.sorted((a, b) => a.storageId.compareTo(b.storageId));
  }
}
