import 'package:ground_control_client/ground_control_client.dart';

class StoreConnectionBuilder {
  UuidValue _id = const Uuid().v4obj();
  UuidValue _ownerId = const Uuid().v4obj();
  StoreType _store = StoreType.appStoreConnect;
  String _name = 'Acme team';
  StoreCredentialInfo? _credential = AppStoreConnectCredentialInfo(
    issuerId: '69a6de7e-03c1-47e3-e053-5b8c7c11a4d1',
    keyId: 'ABC123DEFG',
  );
  List<String>? _projectIds;

  StoreConnectionBuilder withId(UuidValue id) {
    _id = id;
    return this;
  }

  StoreConnectionBuilder withOwnerId(UuidValue ownerId) {
    _ownerId = ownerId;
    return this;
  }

  StoreConnectionBuilder withName(String name) {
    _name = name;
    return this;
  }

  StoreConnectionBuilder withAppStoreConnectKey({
    required String keyId,
    String issuerId = '69a6de7e-03c1-47e3-e053-5b8c7c11a4d1',
  }) {
    _store = StoreType.appStoreConnect;
    _credential = AppStoreConnectCredentialInfo(
      issuerId: issuerId,
      keyId: keyId,
    );
    return this;
  }

  StoreConnectionBuilder withProjectIds(List<String>? projectIds) {
    _projectIds = projectIds;
    return this;
  }

  StoreConnection build() {
    return StoreConnection(
      id: _id,
      ownerId: _ownerId,
      store: _store,
      name: _name,
      credential: _credential,
      projectIds: _projectIds,
    );
  }
}
