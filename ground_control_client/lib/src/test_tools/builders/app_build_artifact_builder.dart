import 'package:ground_control_client/ground_control_client.dart';

/// Builds app artifact data for tests.
class AppBuildArtifactBuilder {
  String _id = 'artifact-id';
  String _name = 'app-release.aab';
  AppBuildArtifactKind _kind = AppBuildArtifactKind.aab;
  int _sizeBytes = 1024;

  AppBuildArtifactBuilder withId(String id) {
    _id = id;
    return this;
  }

  AppBuildArtifactBuilder withName(String name) {
    _name = name;
    return this;
  }

  AppBuildArtifactBuilder withKind(AppBuildArtifactKind kind) {
    _kind = kind;
    return this;
  }

  AppBuildArtifactBuilder withSizeBytes(int sizeBytes) {
    _sizeBytes = sizeBytes;
    return this;
  }

  AppBuildArtifact build() => AppBuildArtifact(
    id: _id,
    name: _name,
    kind: _kind,
    sizeBytes: _sizeBytes,
  );
}
