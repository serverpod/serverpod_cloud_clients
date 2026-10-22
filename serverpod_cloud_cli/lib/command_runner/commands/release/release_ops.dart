import 'package:ground_control_client/ground_control_client.dart'
    show
        Client,
        InvalidValueException,
        NotFoundException,
        UploadTooLargeException;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract class ReleaseOperations {
  /// Requests the upload description for an app archive of [archiveSize]
  /// bytes in project [projectId].
  ///
  /// Throws [FailureException] if the request fails.
  static Future<String> createAppUploadDescription(
    Client cloudApiClient, {
    required String projectId,
    required int archiveSize,
  }) async {
    try {
      return await cloudApiClient.deploy.createAppUploadDescription(
        projectId,
        archiveSize: archiveSize,
      );
    } on UploadTooLargeException catch (e) {
      throw FailureException(
        error: e.message,
        hint:
            'Exclude files from the app with a .scloudignore file, '
            'or release fewer platforms with the --platforms option.',
      );
    } on InvalidValueException catch (e) {
      throw FailureException(error: e.message);
    } on NotFoundException catch (e) {
      throw FailureException(error: e.message);
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(
        e,
        stackTrace,
        'Failed to fetch the app upload description.',
      );
    }
  }
}
