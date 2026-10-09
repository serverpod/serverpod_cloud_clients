import 'package:ground_control_client/ground_control_client.dart';

class MetricSampleBuilder {
  DateTime _timestamp;
  double _value;

  MetricSampleBuilder() : _timestamp = DateTime.now(), _value = 1;

  MetricSampleBuilder withTimestamp(DateTime timestamp) {
    _timestamp = timestamp;

    return this;
  }

  MetricSampleBuilder withValue(double value) {
    _value = value;

    return this;
  }

  MetricSample build() {
    return MetricSample(timestamp: _timestamp, value: _value);
  }
}
