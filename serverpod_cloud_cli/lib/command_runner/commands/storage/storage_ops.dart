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

  /// Deletes the storage with id [storageId] and every file in it.
  ///
  /// Throws [FailureException] if the storage is not found
  /// or the request fails.
  static Future<void> deleteStorage(
    Client cloudApiClient, {
    required String projectId,
    required String storageId,
    required String baseCommand,
  }) async {
    try {
      await cloudApiClient.bucket.deleteBucket(
        cloudCapsuleId: projectId,
        storageId: storageId,
      );
    } on NotFoundException {
      throw FailureException(
        error: 'Storage "$storageId" was not found in project "$projectId".',
        hint:
            'Run "$baseCommand storage list" to see the storages of '
            'the project.',
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to delete storage.');
    }
  }

  /// Normalizes a user-provided folder [path] into a listing prefix.
  ///
  /// Returns null when [path] is null or blank, otherwise the path without
  /// leading slashes and with exactly one trailing slash.
  static String? normalizePrefix(final String? path) {
    final trimmed = path?.trim() ?? '';
    final stripped = trimmed.replaceAll(RegExp(r'^/+'), '');
    if (stripped.isEmpty) {
      return null;
    }

    return '${stripped.replaceAll(RegExp(r'/+$'), '')}/';
  }

  /// Lists every file in the storage [storageId], sorted by name.
  ///
  /// Only files under the folder [path] are listed if it is given.
  ///
  /// Throws [FailureException] if the storage is not found
  /// or the request fails.
  static Future<List<BucketFile>> listFiles(
    Client cloudApiClient, {
    required String projectId,
    required String storageId,
    final String? path,
    required String baseCommand,
  }) async {
    final prefix = normalizePrefix(path);
    final files = <BucketFile>[];

    try {
      String? pageToken;
      do {
        final listing = await cloudApiClient.bucketObjects.listFiles(
          cloudCapsuleId: projectId,
          storageId: storageId,
          prefix: prefix,
          pageToken: pageToken,
        );
        files.addAll(listing.files);
        pageToken = listing.nextPageToken;
      } while (pageToken != null);
    } on NotFoundException {
      throw FailureException(
        error: 'Storage "$storageId" was not found in project "$projectId".',
        hint:
            'Run "$baseCommand storage list" to see the storages of '
            'the project.',
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to list files.');
    }

    return files.sorted((a, b) => a.name.compareTo(b.name));
  }
}
