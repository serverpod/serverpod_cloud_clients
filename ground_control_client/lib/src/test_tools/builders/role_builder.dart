import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';

class RoleBuilder {
  int _id;
  DateTime _createdAt;
  DateTime _updatedAt;
  DateTime? _archivedAt;
  int _projectId;
  Project? _project;
  String _name;
  List<String> _projectScopes;
  List<UserRoleMembership>? _memberships;

  RoleBuilder()
    : _id = 1,
      _createdAt = DateTime.now(),
      _updatedAt = DateTime.now(),
      _archivedAt = null,
      _projectId = 1,
      _project = null,
      _name = 'Admin',
      _projectScopes = ['P0-all'],
      _memberships = [];

  RoleBuilder.admin()
    : _id = 1,
      _createdAt = DateTime.now(),
      _updatedAt = DateTime.now(),
      _archivedAt = null,
      _projectId = 1,
      _project = null,
      _name = 'Admin',
      _projectScopes = ['P0-all'],
      _memberships = [];

  RoleBuilder withId(final int id) {
    _id = id;
    return this;
  }

  RoleBuilder withCreatedAt(final DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  RoleBuilder withUpdatedAt(final DateTime updatedAt) {
    _updatedAt = updatedAt;
    return this;
  }

  RoleBuilder withArchivedAt(final DateTime? archivedAt) {
    _archivedAt = archivedAt;
    return this;
  }

  RoleBuilder withProjectId(final int projectId) {
    _projectId = projectId;
    return this;
  }

  RoleBuilder withProject(final Project? project) {
    _project = project;
    if (project != null) {
      _projectId = project.id ?? 1;
    }
    return this;
  }

  RoleBuilder withName(final String name) {
    _name = name;
    return this;
  }

  RoleBuilder withProjectScopes(final List<String> projectScopes) {
    _projectScopes = projectScopes;
    return this;
  }

  RoleBuilder withProjectScope(final String scope) {
    _projectScopes.add(scope);
    return this;
  }

  RoleBuilder withMemberships(final List<UserRoleMembership>? memberships) {
    _memberships = memberships;
    return this;
  }

  RoleBuilder withMembership(final UserRoleMembership membership) {
    _memberships ??= [];
    _memberships!.add(membership);
    return this;
  }

  RoleBuilder withUser(final User user) {
    _memberships ??= [];
    _memberships!.add(UserRoleMembershipBuilder().withUser(user).build());
    return this;
  }

  Role build() {
    return Role(
      id: _id,
      createdAt: _createdAt,
      updatedAt: _updatedAt,
      archivedAt: _archivedAt,
      projectId: _projectId,
      project: _project,
      name: _name,
      projectScopes: _projectScopes,
      memberships: _memberships,
    );
  }
}
