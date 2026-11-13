import 'package:ground_control_client/ground_control_client.dart';

class AppBuildsUploadBuilder {
  UuidValue _uploadId = const Uuid().v4obj();
  List<AppPlatform> _platforms = [AppPlatform.ios];
  String _uploadDescription = '{"type":"resumable"}';
  List<AppIdentifierChange>? _appIdentifierChanges = [];
  bool? _waitsForOtherBuilds = false;

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

  AppBuildsUploadBuilder withAppIdentifierChanges(
    List<AppIdentifierChange>? appIdentifierChanges,
  ) {
    _appIdentifierChanges = appIdentifierChanges;
    return this;
  }

  AppBuildsUploadBuilder withWaitsForOtherBuilds(bool? waitsForOtherBuilds) {
    _waitsForOtherBuilds = waitsForOtherBuilds;
    return this;
  }

  /// An upload whose builds wait in the queue behind other builds of the
  /// project's owner.
  AppBuildsUploadBuilder withBuildsAhead() {
    _waitsForOtherBuilds = true;
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
      appIdentifierChanges: _appIdentifierChanges,
      waitsForOtherBuilds: _waitsForOtherBuilds,
    );
  }
}
