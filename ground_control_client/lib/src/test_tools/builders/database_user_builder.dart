import 'package:ground_control_client/ground_control_client.dart';

class DatabaseUserBuilder {
  String _username;
  DateTime _createdAt;
  DateTime? _updatedAt;
  bool _passwordReset;

  DatabaseUserBuilder()
    : _username = 'wernher',
      _createdAt = DateTime.utc(2026, 1, 15, 10, 30),
      _updatedAt = null,
      _passwordReset = false;

  DatabaseUserBuilder withUsername(String username) {
    _username = username;
    return this;
  }

  DatabaseUserBuilder withCreatedAt(DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  DatabaseUserBuilder withUpdatedAt(DateTime updatedAt) {
    _updatedAt = updatedAt;
    return this;
  }

  DatabaseUserBuilder withPasswordReset() {
    _passwordReset = true;
    return this;
  }

  DatabaseUser build() {
    final updatedAt =
        _updatedAt ??
        (_passwordReset ? _createdAt.add(const Duration(days: 1)) : _createdAt);
    return DatabaseUser(
      username: _username,
      createdAt: _createdAt,
      updatedAt: updatedAt,
    );
  }
}
