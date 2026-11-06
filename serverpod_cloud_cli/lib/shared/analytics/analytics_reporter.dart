import 'package:cli_tools/analytics.dart';

typedef PostHogAnalyticsFactory = Analytics Function(String distinctId);

/// Reports the analytics events of the CLI to PostHog.
///
/// Events are sent under the user auth id of the logged in user when it is
/// known, and under the Serverpod CLI id otherwise. Every event carries the
/// Serverpod CLI id in the `serverpod_cli_id` property.
class AnalyticsReporter {
  static const _serverpodCliIdProperty = 'serverpod_cli_id';

  /// The persistent, anonymous id of the Serverpod CLI installation, shared
  /// with the Serverpod CLI.
  final String serverpodCliId;

  final PostHogAnalyticsFactory _createPostHogAnalytics;
  final Map<String, Analytics> _postHogAnalyticsByDistinctId = {};

  AnalyticsReporter({
    required this.serverpodCliId,
    required PostHogAnalyticsFactory createPostHogAnalytics,
  }) : _createPostHogAnalytics = createPostHogAnalytics;

  void track(
    String event,
    Map<String, dynamic> properties, {
    String? userAuthId,
  }) {
    final distinctId = userAuthId ?? serverpodCliId;
    final postHogAnalytics = _postHogAnalyticsByDistinctId.putIfAbsent(
      distinctId,
      () => _createPostHogAnalytics(distinctId),
    );
    postHogAnalytics.track(
      event: event,
      properties: {...properties, _serverpodCliIdProperty: serverpodCliId},
    );
  }
}
