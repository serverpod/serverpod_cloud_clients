import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';

class ProjectBuilder {
  int _id;
  DateTime _createdAt;
  DateTime? _updatedAt;
  DateTime? _archivedAt;
  ProjectLifecycleStatus _status;
  DateTime? _suspendedAt;
  ProjectSuspensionReason? _suspensionReason;
  String _cloudProjectId;
  Owner? _owner;
  List<Role>? _roles;
  List<Capsule>? _capsules;

  ProjectBuilder()
    : _id = 1,
      _createdAt = DateTime.now(),
      _updatedAt = DateTime.now(),
      _archivedAt = null,
      _status = ProjectLifecycleStatus.active,
      _suspendedAt = null,
      _suspensionReason = null,
      _cloudProjectId = 'test-project',
      _roles = [],
      _capsules = [] {
    withUserOwner(UserBuilder().build());
  }

  /// Creates a project with a user as owner and admin role.
  /// Calling this method resets the roles in the builder.
  ProjectBuilder withUserOwner(User user) {
    _owner = OwnerBuilder().withUser(user).build();
    _roles = [RoleBuilder.admin().withUser(user).build()];
    return this;
  }

  ProjectBuilder withDeveloperUser(User user) {
    _roles ??= [];
    _roles?.add(RoleBuilder().withName('Developer').withUser(user).build());
    return this;
  }

  ProjectBuilder withId(int id) {
    _id = id;
    return this;
  }

  ProjectBuilder withCreatedAt(DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  ProjectBuilder withUpdatedAt(DateTime? updatedAt) {
    _updatedAt = updatedAt;
    return this;
  }

  ProjectBuilder withArchivedAt(DateTime? archivedAt) {
    _archivedAt = archivedAt;
    return this;
  }

  /// A project suspended for an overdue payment.
  ProjectBuilder withSuspended() {
    _status = ProjectLifecycleStatus.suspended;
    _suspendedAt = DateTime.now();
    _suspensionReason = ProjectSuspensionReason.paymentOverdue;
    return this;
  }

  /// An archived (deleted) project.
  ProjectBuilder withArchived() {
    _status = ProjectLifecycleStatus.archived;
    _archivedAt = DateTime.now();
    return this;
  }

  ProjectBuilder withCloudProjectId(String cloudProjectId) {
    _cloudProjectId = cloudProjectId;
    return this;
  }

  ProjectBuilder withOwner(Owner? owner) {
    _owner = owner;
    return this;
  }

  ProjectBuilder withRoles(List<Role>? roles) {
    _roles = roles;
    return this;
  }

  ProjectBuilder withCapsules(List<Capsule>? capsules) {
    _capsules = capsules;
    return this;
  }

  Project build() {
    return Project(
      id: _id,
      createdAt: _createdAt,
      updatedAt: _updatedAt,
      archivedAt: _archivedAt,
      status: _status,
      suspendedAt: _suspendedAt,
      suspensionReason: _suspensionReason,
      cloudProjectId: _cloudProjectId,
      owner: _owner,
      ownerId: _owner?.id ?? Uuid().v4obj(),
      roles: _roles,
      capsules: _capsules,
    );
  }
}
