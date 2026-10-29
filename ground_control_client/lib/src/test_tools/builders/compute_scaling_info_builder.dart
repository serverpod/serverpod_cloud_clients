import 'package:ground_control_client/ground_control_client.dart';

class ComputeScalingInfoBuilder {
  int _defaultMinReplicas;
  int _defaultMaxReplicas;
  int _allowedReplicasMin;
  int _allowedReplicasMax;

  ComputeScalingInfoBuilder()
    : _defaultMinReplicas = 1,
      _defaultMaxReplicas = 1,
      _allowedReplicasMin = 0,
      _allowedReplicasMax = 20;

  ComputeScalingInfoBuilder withDefaultMinReplicas(int defaultMinReplicas) {
    _defaultMinReplicas = defaultMinReplicas;
    return this;
  }

  ComputeScalingInfoBuilder withDefaultMaxReplicas(int defaultMaxReplicas) {
    _defaultMaxReplicas = defaultMaxReplicas;
    return this;
  }

  ComputeScalingInfoBuilder withAllowedReplicasMin(int allowedReplicasMin) {
    _allowedReplicasMin = allowedReplicasMin;
    return this;
  }

  ComputeScalingInfoBuilder withAllowedReplicasMax(int allowedReplicasMax) {
    _allowedReplicasMax = allowedReplicasMax;
    return this;
  }

  ComputeScalingInfo build() {
    return ComputeScalingInfo(
      defaultMinReplicas: _defaultMinReplicas,
      defaultMaxReplicas: _defaultMaxReplicas,
      allowedReplicasMin: _allowedReplicasMin,
      allowedReplicasMax: _allowedReplicasMax,
    );
  }
}
