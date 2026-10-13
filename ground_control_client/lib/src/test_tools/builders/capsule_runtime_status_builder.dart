import 'package:ground_control_client/ground_control_client.dart';

class CapsuleRuntimeStatusBuilder {
  String _cloudCapsuleId;
  CapsuleState _state;
  int _desiredReplicas;
  int _readyReplicas;
  DeployAttemptSummary? _serving;
  DeployAttemptSummary? _latestAttempt;

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

  /// The deployment is serving the revision of a successful [attempt].
  CapsuleRuntimeStatusBuilder withServing(DeployAttempt attempt) {
    _serving = _summaryOf(attempt);

    return this;
  }

  /// The most recent [attempt] is not the one being served.
  CapsuleRuntimeStatusBuilder withLatestAttempt(DeployAttempt attempt) {
    _latestAttempt = _summaryOf(attempt);

    return this;
  }

  DeployAttemptSummary _summaryOf(DeployAttempt attempt) {
    return DeployAttemptSummary(
      attemptId: UuidValue.withValidation(attempt.attemptId ?? attempt.id.uuid),
      status: attempt.status,
      commitHash: attempt.commitHash,
      commitMessage: attempt.commitMessage,
      branch: attempt.branch,
      deployedBy: attempt.deployedBy,
      startedAt: attempt.startedAt ?? attempt.createdAt,
      endedAt: attempt.endedAt,
    );
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
      serving: _serving,
      latestAttempt: _latestAttempt,
    );
  }
}
