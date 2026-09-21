import 'package:ground_control_client/ground_control_client.dart';

class EnvironmentVariableBuilder {
  String _cloudCapsuleId;
  String _name;
  String _value;

  EnvironmentVariableBuilder()
    : _cloudCapsuleId = 'test-capsule',
      _name = 'KEY',
      _value = 'value';

  EnvironmentVariableBuilder withCloudCapsuleId(String cloudCapsuleId) {
    _cloudCapsuleId = cloudCapsuleId;
    return this;
  }

  EnvironmentVariableBuilder withName(String name) {
    _name = name;
    return this;
  }

  EnvironmentVariableBuilder withValue(String value) {
    _value = value;
    return this;
  }

  EnvironmentVariable build() {
    return EnvironmentVariable(
      cloudCapsuleId: _cloudCapsuleId,
      name: _name,
      value: _value,
    );
  }
}
