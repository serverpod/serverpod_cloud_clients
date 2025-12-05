import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class UserBuilder {
  int? _id;
  DateTime _createdAt;
  DateTime _updatedAt;
  DateTime? _archivedAt;
  UserAccountStatus _accountStatus;
  String? _userAuthId;
  String _email;
  List<UserRoleMembership>? _memberships;
  List<UserLabelMapping>? _labels;
  _i1.UuidValue? _ownerId;
  Owner? _owner;

  UserBuilder()
      : _id = 1,
        _createdAt = DateTime.now(),
        _updatedAt = DateTime.now(),
        _archivedAt = null,
        _accountStatus = UserAccountStatus.registered,
        _userAuthId = 'auth-user-123',
        _email = 'test@example.com',
        _memberships = [] {
    _ownerId = Uuid().v4obj();
  }

  UserBuilder withId(final int? id) {
    _id = id;
    return this;
  }

  UserBuilder withCreatedAt(final DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  UserBuilder withUpdatedAt(final DateTime updatedAt) {
    _updatedAt = updatedAt;
    return this;
  }

  UserBuilder withArchivedAt(final DateTime? archivedAt) {
    _archivedAt = archivedAt;
    return this;
  }

  UserBuilder withAccountStatus(final UserAccountStatus accountStatus) {
    _accountStatus = accountStatus;
    return this;
  }

  UserBuilder withUserAuthId(final String? userAuthId) {
    _userAuthId = userAuthId;
    return this;
  }

  UserBuilder withEmail(final String email) {
    _email = email;
    return this;
  }

  UserBuilder withMemberships(final List<UserRoleMembership>? memberships) {
    _memberships = memberships;
    return this;
  }

  UserBuilder withOwnerId(final _i1.UuidValue? ownerId) {
    _ownerId = ownerId;
    return this;
  }

  UserBuilder withOwner(final Owner? owner) {
    _owner = owner;
    return this;
  }

  UserBuilder withLabels(final List<UserLabel> labels) {
    _labels = labels
        .map(
          (final label) => UserLabelMapping(
            userId: _id ?? 1,
            label: label,
          ),
        )
        .toList();
    return this;
  }

  User build() {
    return User(
      id: _id,
      createdAt: _createdAt,
      updatedAt: _updatedAt,
      archivedAt: _archivedAt,
      accountStatus: _accountStatus,
      userAuthId: _userAuthId,
      email: _email,
      memberships: _memberships,
      labels: _labels,
      ownerId: _owner?.id ?? _ownerId,
      owner: _owner,
    );
  }
}
