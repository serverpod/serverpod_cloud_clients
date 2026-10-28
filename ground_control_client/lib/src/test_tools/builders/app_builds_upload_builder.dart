import 'package:ground_control_client/ground_control_client.dart';

class AppBuildsUploadBuilder {
  UuidValue _uploadId = const Uuid().v4obj();
  List<AppPlatform> _platforms = [AppPlatform.ios];
  String _uploadDescription = '{"type":"resumable"}';

  AppBuildsUploadBuilder withUploadId(UuidValue uploadId) {
    _uploadId = uploadId;
    return this;
  }

  AppBuildsUploadBuilder withPlatforms(List<AppPlatform> platforms) {
    _platforms = platforms;
    return this;
  }

  AppBuildsUploadBuilder withUploadDescription(String uploadDescription) {
    _uploadDescription = uploadDescription;
    return this;
  }

  AppBuildsUpload build() {
    return AppBuildsUpload(
      uploadId: _uploadId,
      builds: [
        for (final platform in _platforms)
          AppBuildRef(buildId: const Uuid().v4obj(), platform: platform),
      ],
      uploadDescription: _uploadDescription,
    );
  }
}
