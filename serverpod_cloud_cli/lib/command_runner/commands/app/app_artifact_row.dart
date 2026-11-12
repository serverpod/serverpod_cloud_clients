import 'package:ground_control_client/ground_control_client.dart';

/// An app artifact with its platform and temporary download link.
class AppArtifactRow implements SerializableModel {
  final AppPlatform platform;
  final AppBuildArtifact artifact;
  final String downloadUrl;

  const AppArtifactRow({
    required this.platform,
    required this.artifact,
    required this.downloadUrl,
  });

  @override
  Map<String, Object?> toJson() => {
    'platform': platform,
    'artifact': artifact,
    'downloadUrl': downloadUrl,
  };
}
