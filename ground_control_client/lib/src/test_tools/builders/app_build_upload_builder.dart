import 'package:ground_control_client/ground_control_client.dart';

class AppBuildUploadBuilder {
  UuidValue _buildId = const Uuid().v4obj();
  String _uploadDescription = '{"type":"resumable"}';

  AppBuildUploadBuilder withBuildId(UuidValue buildId) {
    _buildId = buildId;
    return this;
  }

  AppBuildUploadBuilder withUploadDescription(String uploadDescription) {
    _uploadDescription = uploadDescription;
    return this;
  }

  AppBuildUpload build() {
    return AppBuildUpload(
      buildId: _buildId,
      uploadDescription: _uploadDescription,
    );
  }
}
