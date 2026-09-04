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

  /// Creates a storage with id [storageId] and the given [access].
  ///
  /// Throws [FailureException] if the storage id is taken, the project has no
  /// storage slots left, the project storage is not ready, or the request
  /// fails.
  static Future<BucketResource> createStorage(
    Client cloudApiClient, {
    required String projectId,
    required String storageId,
    required BucketVisibility access,
    required String baseCommand,
  }) async {
    try {
      return await cloudApiClient.bucket.createBucket(
        cloudCapsuleId: projectId,
        storageId: storageId,
        visibility: access,
      );
    } on DuplicateEntryException {
      throw FailureException(
        error:
            'A storage with id "$storageId" already exists '
            'in project "$projectId".',
        hint:
            'Pick another id, or run "$baseCommand storage list" '
            'to see the existing storages.',
      );
    } on ProcurementDeniedException catch (e, s) {
      if (e.reason != ProcurementDeniedReason.productNotAvailable) {
        throw FailureException.nested(e, s, 'Failed to create storage.');
      }
      throw FailureException(
        error: 'This project has no storage slots left on its plan.',
        hint:
            'Remove an existing storage, or upgrade the project plan in '
            'the console.',
      );
    } on BucketStorageIdentityUnavailableException {
      throw FailureException(
        error: 'Storage for this project is still being set up.',
        hint: 'Try again in a moment.',
      );
    } on NotFoundException {
      throw FailureException(
        error: 'Project "$projectId" was not found.',
        hint: 'Run "$baseCommand project list" to see your projects.',
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to create storage.');
    }
  }
}
