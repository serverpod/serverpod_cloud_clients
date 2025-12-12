import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';

class ProjectBuilder {
  int _id;
  DateTime _createdAt;
  DateTime? _updatedAt;
  DateTime? _archivedAt;
  String _cloudProjectId;
  Owner? _owner;
  List<Role>? _roles;
  List<Capsule>? _capsules;

  ProjectBuilder()
    : _id = 1,
      _createdAt = DateTime.now(),
      _updatedAt = DateTime.now(),
      _archivedAt = null,
      _cloudProjectId = 'test-project',
      _roles = [],
      _capsules = [] {
    withUserOwner(UserBuilder().build());
  }

  /// Creates a project with a user as owner and admin role.
  /// Calling this method resets the roles in the builder.
  ProjectBuilder withUserOwner(final User user) {
    _owner = OwnerBuilder().withUser(user).build();
    _roles = [RoleBuilder.admin().withUser(user).build()];
    return this;
  }

  ProjectBuilder withDeveloperUser(final User user) {
    _roles ??= [];
    _roles?.add(RoleBuilder().withName('Developer').withUser(user).build());
    return this;
  }

  ProjectBuilder withId(final int id) {
    _id = id;
    return this;
  }

  ProjectBuilder withCreatedAt(final DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  ProjectBuilder withUpdatedAt(final DateTime? updatedAt) {
    _updatedAt = updatedAt;
    return this;
  }

  ProjectBuilder withArchivedAt(final DateTime? archivedAt) {
    _archivedAt = archivedAt;
    return this;
  }

  ProjectBuilder withCloudProjectId(final String cloudProjectId) {
    _cloudProjectId = cloudProjectId;
    return this;
  }

  ProjectBuilder withOwner(final Owner? owner) {
    _owner = owner;
    return this;
  }

  ProjectBuilder withRoles(final List<Role>? roles) {
    _roles = roles;
    return this;
  }

  ProjectBuilder withCapsules(final List<Capsule>? capsules) {
    _capsules = capsules;
    return this;
  }

  Project build() {
    return Project(
      id: _id,
      createdAt: _createdAt,
      updatedAt: _updatedAt,
      archivedAt: _archivedAt,
      cloudProjectId: _cloudProjectId,
      owner: _owner,
      ownerId: _owner?.id ?? Uuid().v4obj(),
      roles: _roles,
      capsules: _capsules,
    );
  }
}
