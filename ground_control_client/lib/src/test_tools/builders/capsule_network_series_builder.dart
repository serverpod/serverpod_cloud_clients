import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';

class CapsuleNetworkSeriesBuilder {
  List<MetricSample> _requestsPerSecond;
  List<ResponseClassSeries> _responses;

  CapsuleNetworkSeriesBuilder()
    : _requestsPerSecond = [MetricSampleBuilder().withValue(10).build()],
      _responses = [
        ResponseClassSeries(
          responseClass: HttpResponseClass.successful,
          responsesPerSecond: [MetricSampleBuilder().withValue(10).build()],
        ),
      ];

  CapsuleNetworkSeriesBuilder withRequestsPerSecond(
    List<MetricSample> requestsPerSecond,
  ) {
    _requestsPerSecond = requestsPerSecond;

    return this;
  }

  /// Replaces the response series of [responseClass].
  CapsuleNetworkSeriesBuilder withResponses(
    HttpResponseClass responseClass,
    List<MetricSample> responsesPerSecond,
  ) {
    _responses = [
      for (final ResponseClassSeries series in _responses)
        if (series.responseClass != responseClass) series,
      ResponseClassSeries(
        responseClass: responseClass,
        responsesPerSecond: responsesPerSecond,
      ),
    ];
    return this;
  }

  CapsuleNetworkSeries build() {
    return CapsuleNetworkSeries(
      requestsPerSecond: _requestsPerSecond,
      responses: _responses,
    );
  }
}
