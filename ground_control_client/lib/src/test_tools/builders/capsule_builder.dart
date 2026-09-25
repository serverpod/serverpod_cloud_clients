import 'package:ground_control_client/ground_control_client.dart';

class CapsuleBuilder {
  int? _id;
  String _name;
  String _cloudCapsuleId;
  ServerpodRegion _region;
  int _projectId;
  Project? _project;
  CapsuleResource? _resourceConfig;

  CapsuleBuilder()
    : _id = null,
      _name = 'test-capsule',
      _cloudCapsuleId = 'test-capsule-id',
      _region = ServerpodRegion.europe,
      _projectId = 1,
      _project = null,
      _resourceConfig = null;

  CapsuleBuilder withId(int? id) {
    _id = id;
    return this;
  }

  CapsuleBuilder withName(String name) {
    _name = name;
    return this;
  }

  CapsuleBuilder withCloudCapsuleId(String cloudCapsuleId) {
    _cloudCapsuleId = cloudCapsuleId;
    return this;
  }

  CapsuleBuilder withRegion(ServerpodRegion region) {
    _region = region;
    return this;
  }

  CapsuleBuilder withProjectId(int projectId) {
    _projectId = projectId;
    return this;
  }

  CapsuleBuilder withProject(Project? project) {
    _project = project;
    if (project != null) {
      _projectId = project.id ?? 1;
    }
    return this;
  }

  CapsuleBuilder withResourceConfig(CapsuleResource? resourceConfig) {
    _resourceConfig = resourceConfig;
    return this;
  }

  Capsule build() {
    return Capsule(
      id: _id,
      name: _name,
      cloudCapsuleId: _cloudCapsuleId,
      region: _region,
      projectId: _projectId,
      project: _project,
      resourceConfig: _resourceConfig,
    );
  }
}
