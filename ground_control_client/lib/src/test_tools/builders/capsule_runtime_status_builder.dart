import 'package:ground_control_client/ground_control_client.dart';

class CapsuleRuntimeStatusBuilder {
  String _cloudCapsuleId;
  CapsuleState _state;
  int _desiredReplicas;
  int _readyReplicas;

  CapsuleRuntimeStatusBuilder()
    : _cloudCapsuleId = 'test-capsule-id',
      _state = CapsuleState.ready,
      _desiredReplicas = 2,
      _readyReplicas = 2;

  CapsuleRuntimeStatusBuilder withCloudCapsuleId(String cloudCapsuleId) {
    _cloudCapsuleId = cloudCapsuleId;
    return this;
  }

  /// One of two podlets is not ready.
  CapsuleRuntimeStatusBuilder withDegradedPodlets() {
    _state = CapsuleState.degraded;
    _desiredReplicas = 2;
    _readyReplicas = 1;
    return this;
  }

  CapsuleRuntimeStatus build() {
    return CapsuleRuntimeStatus(
      status: CapsuleStatus(
        cloudCapsuleId: _cloudCapsuleId,
        status: _state,
        deployment: CapsuleDeploymentStatus(
          name: 'app',
          state: _state,
          desiredReplicas: _desiredReplicas,
          readyReplicas: _readyReplicas,
        ),
      ),
    );
  }
}
