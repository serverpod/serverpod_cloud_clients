import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/status/status_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/dio_failure.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/file_downloader.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/file_uploader_factory.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

/// A local file queued for upload, with the path it gets inside the storage.
class UploadItem {
  final File file;
  final String remotePath;
  final int sizeBytes;

  UploadItem({
    required this.file,
    required this.remotePath,
    required this.sizeBytes,
  });
}

/// The files to upload, and the symbolic links skipped while collecting them.
class UploadPlan {
  final List<UploadItem> items;
  final List<String> skippedLinks;

  UploadPlan({required this.items, required this.skippedLinks});
}

/// The files a delete removes, and the storage path they were resolved from.
///
/// [path] is the file name for a single file, or the folder prefix ending
/// with "/" when [isFolder] is set.
class DeletePlan {
  final String path;
  final List<BucketFile> files;
  final bool isFolder;

  DeletePlan({required this.path, required this.files, required this.isFolder});
}

const _ignoredFileNames = {'.DS_Store'};

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
    final files = await _listFiles(
      cloudApiClient,
      projectId: projectId,
      storageId: storageId,
      prefix: normalizePrefix(path),
      baseCommand: baseCommand,
    );

    return files.sorted((a, b) => a.name.compareTo(b.name));
  }

  static Future<List<BucketFile>> _listFiles(
    Client cloudApiClient, {
    required String projectId,
    required String storageId,
    required String? prefix,
    required String baseCommand,
  }) async {
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

    return files;
  }

  /// Splits a user-provided delete [path] into the storage name it targets
  /// and whether a trailing slash restricts it to a folder.
  static ({String name, bool folderOnly}) _deleteTarget(final String path) {
    final trimmed = path.trim().replaceAll(RegExp(r'^/+'), '');

    return (
      name: trimmed.replaceAll(RegExp(r'/+$'), ''),
      folderOnly: trimmed.endsWith('/'),
    );
  }

  /// Picks the files a delete of [path] removes from [files].
  ///
  /// A [path] that ends with "/" names a folder. Otherwise a file with exactly
  /// that name is the single match, and failing that the files under "[path]/"
  /// are the folder contents, sorted by name.
  ///
  /// Returns a plan with no files when nothing matches.
  static DeletePlan matchDeleteItems({
    required String path,
    required List<BucketFile> files,
  }) {
    final (:name, :folderOnly) = _deleteTarget(path);

    if (!folderOnly) {
      final file = files.firstWhereOrNull((f) => f.name == name);
      if (file != null) {
        return DeletePlan(path: name, files: [file], isFolder: false);
      }
    }

    final folder = '$name/';
    final contents = files
        .where((f) => f.name.startsWith(folder))
        .sorted((a, b) => a.name.compareTo(b.name));

    return DeletePlan(path: folder, files: contents, isFolder: true);
  }

  /// Resolves the storage path a single uploaded file gets.
  ///
  /// A blank [path] or one that ends with a slash uploads [fileName] into that
  /// folder, any other [path] is the full path of the uploaded file.
  static String resolveUploadPath(final String? path, final String fileName) {
    final trimmed = path?.trim() ?? '';
    final stripped = trimmed.replaceAll(RegExp(r'^/+'), '');
    if (stripped.isEmpty) {
      return fileName;
    }
    if (stripped.endsWith('/')) {
      return '$stripped$fileName';
    }

    return stripped;
  }

  /// Resolves the storage path a file inside an uploaded directory gets.
  ///
  /// A blank [path] or one that ends with a slash keeps [folderName] as the
  /// destination folder, any other [path] renames it.
  static String resolveFolderUploadPath(
    final String? path,
    final String folderName,
    final String relativePath,
  ) {
    final trimmed = path?.trim() ?? '';
    final stripped = trimmed.replaceAll(RegExp(r'^/+'), '');
    if (stripped.isEmpty) {
      return '$folderName/$relativePath';
    }
    if (stripped.endsWith('/')) {
      return '$stripped$folderName/$relativePath';
    }

    return '$stripped/$relativePath';
  }

  /// Collects the files to upload from [source] and the storage path each of
  /// them gets under [path], with the symbolic links that were skipped.
  ///
  /// A directory [source] is collected recursively, sorted by storage path.
  /// Symbolic links are skipped unless [followSymlinks] is set, and
  /// `.DS_Store` files are always skipped.
  ///
  /// Throws [FailureException] if a directory [source] holds no files, or if
  /// [source] is a symbolic link and [followSymlinks] is not set.
  static Future<UploadPlan> collectUploadItems({
    required FileSystemEntity source,
    required String? path,
    required bool followSymlinks,
  }) async {
    if (!followSymlinks && await FileSystemEntity.isLink(source.path)) {
      throw FailureException(
        error: '"${source.path}" is a symbolic link.',
        hint:
            'Symbolic links are not uploaded. Pass "--follow-symlinks" to '
            'upload what it points to.',
      );
    }

    if (source is File) {
      return UploadPlan(
        items: [
          UploadItem(
            file: source,
            remotePath: resolveUploadPath(path, p.basename(source.path)),
            sizeBytes: await source.length(),
          ),
        ],
        skippedLinks: const [],
      );
    }

    if (source is! Directory) {
      throw FailureException(
        error: '"${source.path}" is not a file or a directory.',
      );
    }

    final folderName = p.basename(
      source.path.replaceAll(RegExp(r'[\\/]+$'), ''),
    );
    final items = <UploadItem>[];
    final skippedLinks = <String>[];
    await for (final entity in source.list(
      recursive: true,
      followLinks: followSymlinks,
    )) {
      final relativePath = p
          .relative(entity.path, from: source.path)
          .split(p.separator)
          .join('/');
      if (entity is Link) {
        skippedLinks.add(relativePath);
        continue;
      }
      if (entity is! File) {
        continue;
      }
      if (_ignoredFileNames.contains(p.basename(entity.path))) {
        continue;
      }
      items.add(
        UploadItem(
          file: entity,
          remotePath: resolveFolderUploadPath(path, folderName, relativePath),
          sizeBytes: await entity.length(),
        ),
      );
    }

    if (items.isEmpty) {
      final linkCount = skippedLinks.length;
      throw FailureException(
        error: linkCount == 0
            ? 'The directory "${source.path}" contains no files.'
            : 'The directory "${source.path}" contains no files to upload, '
                  'only $linkCount symbolic '
                  '${linkCount == 1 ? 'link' : 'links'}.',
        hint: linkCount == 0
            ? null
            : 'Symbolic links are not uploaded. Pass "--follow-symlinks" to '
                  'upload what they point to.',
      );
    }

    return UploadPlan(
      items: items.sorted((a, b) => a.remotePath.compareTo(b.remotePath)),
      skippedLinks: skippedLinks.sorted((a, b) => a.compareTo(b)),
    );
  }

  /// Uploads every item in [items] to the storage [storageId],
  /// reporting [skippedLinks] in the result.
  ///
  /// Throws [FailureException] if the storage is not found, a file already
  /// exists at its storage path, or a transfer fails. The upload stops at the
  /// first failure.
  static Future<Map<String, Object?>> uploadFiles(
    Client cloudApiClient,
    FileUploaderFactory fileUploaderFactory,
    CommandLogger logger, {
    required String projectId,
    required String storageId,
    required List<UploadItem> items,
    required List<String> skippedLinks,
    required String baseCommand,
  }) async {
    final uploaded = <UploadItem>[];
    for (final item in items) {
      try {
        await _uploadFile(
          cloudApiClient,
          fileUploaderFactory,
          logger,
          projectId: projectId,
          storageId: storageId,
          item: item,
          baseCommand: baseCommand,
        );
      } on FailureException catch (e) {
        if (items.length == 1 || uploaded.isEmpty) {
          rethrow;
        }
        throw FailureException(
          errors: [
            ...e.errors,
            '${uploaded.length} of ${items.length} files were uploaded '
                'before the failure.',
          ],
          hint: e.hint,
          reason: e.reason,
          nestedException: e.nestedException,
          nestedStackTrace: e.nestedStackTrace,
        );
      }
      uploaded.add(item);
    }

    return {
      'storageId': storageId,
      'fileCount': uploaded.length,
      'sizeBytes': uploaded.fold<int>(
        0,
        (final sum, final i) => sum + i.sizeBytes,
      ),
      'files': [
        for (final item in uploaded)
          {'path': item.remotePath, 'sizeBytes': item.sizeBytes},
      ],
      'skippedLinks': skippedLinks,
    };
  }

  static Future<void> _uploadFile(
    Client cloudApiClient,
    FileUploaderFactory fileUploaderFactory,
    CommandLogger logger, {
    required String projectId,
    required String storageId,
    required UploadItem item,
    required String baseCommand,
  }) async {
    final String description;
    try {
      description = await cloudApiClient.bucketObjects.createUploadDescription(
        cloudCapsuleId: projectId,
        storageId: storageId,
        path: item.remotePath,
      );
    } on NotFoundException {
      throw FailureException(
        error: 'Storage "$storageId" was not found in project "$projectId".',
        hint:
            'Run "$baseCommand storage list" to see the storages of '
            'the project.',
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to prepare the upload.');
    }

    final success = await logger.progress(
      'Uploading "${item.remotePath}"',
      successMessage: 'Uploaded "${item.remotePath}".',
      padRight: StatusCommands.progressMessagePadLength,
      () async {
        try {
          return await fileUploaderFactory(
            description,
          ).upload(item.file.openRead(), item.sizeBytes);
        } on DioException catch (e) {
          if (e.response?.statusCode == 412) {
            throw FailureException(
              error:
                  'A file already exists at "${item.remotePath}" '
                  'in storage "$storageId".',
              hint:
                  'Delete it first with "$baseCommand storage file delete '
                  '$storageId ${item.remotePath}", then upload again.',
            );
          }
          throw failureFromDioException(e, action: 'upload the file');
        } on Exception catch (e, s) {
          throw FailureException.nested(e, s, 'Failed to upload the file.');
        }
      },
    );

    if (!success) {
      throw FailureException(
        error: 'Failed to upload "${item.remotePath}".',
        hint: 'Please try again.',
      );
    }
  }

  /// Resolves the local file a download of [remotePath] is written to.
  ///
  /// A null [output] saves the file under its own name in the current
  /// directory, an [output] that is a directory saves it inside that
  /// directory, and an [output] that is a file is the file itself.
  static File resolveDownloadPath(
    final FileSystemEntity? output,
    final String remotePath,
  ) {
    final fileName = p.basename(remotePath);
    if (output == null) {
      return File(fileName);
    }
    if (output is Directory) {
      return File(p.join(output.path, fileName));
    }

    return File(output.path);
  }

  /// Downloads [path] from the storage [storageId] into [destination].
  ///
  /// Throws [FailureException] if the destination directory is missing, the
  /// storage or file is not found, or the transfer fails.
  static Future<Map<String, Object?>> downloadFile(
    Client cloudApiClient,
    FileDownloaderFactory fileDownloaderFactory,
    CommandLogger logger, {
    required String projectId,
    required String storageId,
    required String path,
    required File destination,
    required String baseCommand,
  }) async {
    final directory = destination.parent;
    if (!directory.existsSync()) {
      throw FailureException(
        error: 'The directory "${directory.path}" does not exist.',
        hint:
            'Create it, or pass --output with a path inside an existing '
            'directory.',
      );
    }

    final String url;
    try {
      url = await cloudApiClient.bucketObjects.getDownloadUrl(
        cloudCapsuleId: projectId,
        storageId: storageId,
        path: path,
      );
    } on NotFoundException {
      throw FailureException(
        error: 'Storage "$storageId" was not found in project "$projectId".',
        hint:
            'Run "$baseCommand storage list" to see the storages of '
            'the project.',
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to prepare the download.');
    }

    var sizeBytes = 0;
    final success = await logger.progress(
      'Downloading "$path"',
      successMessage: 'Download successful.',
      padRight: StatusCommands.progressMessagePadLength,
      () async {
        try {
          sizeBytes = await fileDownloaderFactory().download(
            Uri.parse(url),
            destination,
          );
          return true;
        } on DioException catch (e) {
          if (e.response?.statusCode == 404) {
            throw FailureException(
              error: 'File "$path" was not found in storage "$storageId".',
              hint:
                  'Run "$baseCommand storage file list $storageId" '
                  'to see the files.',
            );
          }
          throw failureFromDioException(e, action: 'download the file');
        } on Exception catch (e, s) {
          throw FailureException.nested(e, s, 'Failed to download the file.');
        }
      },
    );

    if (!success) {
      throw FailureException(
        error: 'Failed to download "$path".',
        hint: 'Please try again.',
      );
    }

    return {
      'storageId': storageId,
      'path': path,
      'file': destination.path,
      'sizeBytes': sizeBytes,
    };
  }

  /// Resolves the files a delete of [path] removes from the storage
  /// [storageId], see [matchDeleteItems].
  ///
  /// Throws [FailureException] if [path] is blank, nothing matches it,
  /// the storage is not found, or the request fails.
  static Future<DeletePlan> collectDeleteItems(
    Client cloudApiClient, {
    required String projectId,
    required String storageId,
    required String path,
    required String baseCommand,
  }) async {
    final (:name, folderOnly: _) = _deleteTarget(path);
    if (name.isEmpty) {
      throw FailureException(
        error: 'The path must name a file or a folder in the storage.',
        hint:
            'Run "$baseCommand storage delete $storageId" to delete '
            'the whole storage.',
      );
    }

    final files = await _listFiles(
      cloudApiClient,
      projectId: projectId,
      storageId: storageId,
      prefix: name,
      baseCommand: baseCommand,
    );

    final plan = matchDeleteItems(path: path, files: files);
    if (plan.files.isEmpty) {
      throw FailureException(
        error:
            'Nothing to delete: "${path.trim()}" was not found '
            'in storage "$storageId".',
        hint:
            'Run "$baseCommand storage file list $storageId" '
            'to see the files.',
      );
    }

    return plan;
  }

  /// Deletes every file in [files] from the storage [storageId],
  /// reporting [path] as the deleted path in the result.
  ///
  /// Throws [FailureException] if the storage is not found or a request
  /// fails. The deletion stops at the first failure.
  static Future<Map<String, Object?>> deleteFiles(
    Client cloudApiClient, {
    required String projectId,
    required String storageId,
    required String path,
    required List<BucketFile> files,
    required String baseCommand,
  }) async {
    final deleted = <BucketFile>[];
    for (final file in files) {
      try {
        await deleteFile(
          cloudApiClient,
          projectId: projectId,
          storageId: storageId,
          path: file.name,
          baseCommand: baseCommand,
        );
      } on FailureException catch (e) {
        if (deleted.isEmpty) {
          rethrow;
        }
        throw FailureException(
          errors: [
            ...e.errors,
            '${deleted.length} of ${files.length} files were deleted '
                'before the failure.',
          ],
          hint: e.hint,
          reason: e.reason,
          nestedException: e.nestedException,
          nestedStackTrace: e.nestedStackTrace,
        );
      }
      deleted.add(file);
    }

    return {
      'storageId': storageId,
      'path': path,
      'fileCount': deleted.length,
      'sizeBytes': deleted.fold<int>(
        0,
        (final sum, final f) => sum + (f.sizeBytes ?? 0),
      ),
      'files': [
        for (final file in deleted)
          {'path': file.name, 'sizeBytes': file.sizeBytes},
      ],
    };
  }

  /// Deletes the file at [path] from the storage [storageId].
  ///
  /// The server is idempotent, so deleting a file that does not exist
  /// completes.
  ///
  /// Throws [FailureException] if the storage is not found
  /// or the request fails.
  static Future<void> deleteFile(
    Client cloudApiClient, {
    required String projectId,
    required String storageId,
    required String path,
    required String baseCommand,
  }) async {
    try {
      await cloudApiClient.bucketObjects.deleteFile(
        cloudCapsuleId: projectId,
        storageId: storageId,
        path: path,
      );
    } on NotFoundException {
      throw FailureException(
        error: 'Storage "$storageId" was not found in project "$projectId".',
        hint:
            'Run "$baseCommand storage list" to see the storages of '
            'the project.',
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to delete "$path".');
    }
  }
}
