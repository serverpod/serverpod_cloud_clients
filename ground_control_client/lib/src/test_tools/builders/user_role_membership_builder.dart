import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';

class UserRoleMembershipBuilder {
  DateTime _createdAt;
  DateTime? _updatedAt;
  DateTime? _archivedAt;
  User? _user;
  Role? _role;

  UserRoleMembershipBuilder()
    : _createdAt = DateTime.now(),
      _updatedAt = DateTime.now(),
      _archivedAt = null,
      _user = UserBuilder().build(),
      _role = RoleBuilder().build();

  UserRoleMembershipBuilder withCreatedAt(final DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  UserRoleMembershipBuilder withUpdatedAt(final DateTime? updatedAt) {
    _updatedAt = updatedAt;
    return this;
  }

  UserRoleMembershipBuilder withArchivedAt(final DateTime? archivedAt) {
    _archivedAt = archivedAt;
    return this;
  }

  UserRoleMembershipBuilder withUser(final User? user) {
    _user = user;
    return this;
  }

  UserRoleMembershipBuilder withRole(final Role? role) {
    _role = role;
    return this;
  }

  UserRoleMembership build() {
    return UserRoleMembership(
      createdAt: _createdAt,
      updatedAt: _updatedAt,
      archivedAt: _archivedAt,
      user: _user,
      role: _role,
      userId: _user?.id ?? 1,
      roleId: _role?.id ?? 1,
    );
  }
}
