import 'package:ground_control_client/ground_control_client.dart';

class CapsuleBuilder {
  int? _id;
  String _name;
  String _cloudCapsuleId;
  ServerpodRegion _region;
  int _projectId;
  Project? _project;
  List<EnvironmentVariable>? _environmentVariables;
  List<CustomDomainName>? _domainNames;
  CapsuleResource? _resourceConfig;

  CapsuleBuilder()
    : _id = null,
      _name = 'test-capsule',
      _cloudCapsuleId = 'test-capsule-id',
      _region = ServerpodRegion.europe,
      _projectId = 1,
      _project = null,
      _environmentVariables = [],
      _domainNames = [],
      _resourceConfig = null;

  CapsuleBuilder withId(final int? id) {
    _id = id;
    return this;
  }

  CapsuleBuilder withName(final String name) {
    _name = name;
    return this;
  }

  CapsuleBuilder withCloudCapsuleId(final String cloudCapsuleId) {
    _cloudCapsuleId = cloudCapsuleId;
    return this;
  }

  CapsuleBuilder withRegion(final ServerpodRegion region) {
    _region = region;
    return this;
  }

  CapsuleBuilder withProjectId(final int projectId) {
    _projectId = projectId;
    return this;
  }

  CapsuleBuilder withProject(final Project? project) {
    _project = project;
    if (project != null) {
      _projectId = project.id ?? 1;
    }
    return this;
  }

  CapsuleBuilder withEnvironmentVariables(
    final List<EnvironmentVariable>? environmentVariables,
  ) {
    _environmentVariables = environmentVariables;
    return this;
  }

  CapsuleBuilder withDomainNames(final List<CustomDomainName>? domainNames) {
    _domainNames = domainNames;
    return this;
  }

  CapsuleBuilder withResourceConfig(final CapsuleResource? resourceConfig) {
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
      environmentVariables: _environmentVariables,
      domainNames: _domainNames,
      resourceConfig: _resourceConfig,
    );
  }
}
