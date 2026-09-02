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
  String? _name;
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

  UserBuilder withId(int? id) {
    _id = id;
    return this;
  }

  UserBuilder withCreatedAt(DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  UserBuilder withUpdatedAt(DateTime updatedAt) {
    _updatedAt = updatedAt;
    return this;
  }

  UserBuilder withArchivedAt(DateTime? archivedAt) {
    _archivedAt = archivedAt;
    return this;
  }

  UserBuilder withAccountStatus(UserAccountStatus accountStatus) {
    _accountStatus = accountStatus;
    return this;
  }

  UserBuilder withUserAuthId(String? userAuthId) {
    _userAuthId = userAuthId;
    return this;
  }

  UserBuilder withEmail(String email) {
    _email = email;
    return this;
  }

  UserBuilder withName(String? name) {
    _name = name;
    return this;
  }

  UserBuilder withMemberships(List<UserRoleMembership>? memberships) {
    _memberships = memberships;
    return this;
  }

  UserBuilder withOwnerId(_i1.UuidValue? ownerId) {
    _ownerId = ownerId;
    return this;
  }

  UserBuilder withOwner(Owner? owner) {
    _owner = owner;
    return this;
  }

  UserBuilder withLabels(List<UserLabel> labels) {
    _labels = labels
        .map((label) => UserLabelMapping(userId: _id ?? 1, label: label))
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
      name: _name,
      memberships: _memberships,
      labels: _labels,
      ownerId: _owner?.id ?? _ownerId,
      owner: _owner,
    );
  }
}
