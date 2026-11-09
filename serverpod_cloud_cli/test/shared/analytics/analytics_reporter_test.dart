import 'package:cli_tools/analytics.dart';
import 'package:serverpod_cloud_cli/shared/analytics/analytics_reporter.dart';
import 'package:test/test.dart';

const _serverpodCliId = 'serverpod-cli-id';

void main() {
  late List<_TrackedEvent> postHogEvents;
  late AnalyticsReporter reporter;

  setUp(() {
    postHogEvents = [];
    reporter = AnalyticsReporter(
      serverpodCliId: _serverpodCliId,
      createPostHogAnalytics: (distinctId) =>
          _RecordingAnalytics(distinctId, postHogEvents),
    );
  });

  group('Given no user auth id', () {
    setUp(() {
      reporter.track('deploy', {'cloud_user_id': '1'});
    });

    test('when tracking an event'
        ' then PostHog receives it under the Serverpod CLI id', () {
      expect(postHogEvents.single.distinctId, _serverpodCliId);
      expect(postHogEvents.single.event, 'deploy');
    });

    test('when tracking an event'
        ' then the PostHog event carries the Serverpod CLI id', () {
      expect(
        postHogEvents.single.properties,
        containsPair('serverpod_cli_id', _serverpodCliId),
      );
    });

    test('when tracking an event'
        ' then the PostHog event keeps the given properties', () {
      expect(
        postHogEvents.single.properties,
        containsPair('cloud_user_id', '1'),
      );
    });
  });

  group('Given a user auth id', () {
    setUp(() {
      reporter.track('deploy', {
        'cloud_user_id': '1',
      }, userAuthId: 'user-auth-id');
    });

    test('when tracking an event'
        ' then PostHog receives it under the user auth id', () {
      expect(postHogEvents.single.distinctId, 'user-auth-id');
      expect(postHogEvents.single.event, 'deploy');
    });

    test('when tracking an event'
        ' then the PostHog event carries the Serverpod CLI id', () {
      expect(
        postHogEvents.single.properties,
        containsPair('serverpod_cli_id', _serverpodCliId),
      );
    });
  });

  group('Given an event tracked without a user auth id', () {
    setUp(() {
      reporter.track('auth login', {});
    });

    test('when tracking an event with a user auth id'
        ' then each PostHog event is sent under its own distinct id', () {
      reporter.track('deploy', {}, userAuthId: 'user-auth-id');

      expect(postHogEvents.map((e) => (e.distinctId, e.event)), [
        (_serverpodCliId, 'auth login'),
        ('user-auth-id', 'deploy'),
      ]);
    });
  });
}

typedef _TrackedEvent = ({
  String distinctId,
  String event,
  Map<String, dynamic> properties,
});

class _RecordingAnalytics extends Analytics {
  final String distinctId;
  final List<_TrackedEvent> trackedEvents;

  _RecordingAnalytics(this.distinctId, this.trackedEvents);

  @override
  void track({
    required String event,
    Map<String, dynamic> properties = const {},
  }) {
    trackedEvents.add((
      distinctId: distinctId,
      event: event,
      properties: properties,
    ));
  }

  @override
  Future<void> sendEvent({
    required String event,
    Map<String, dynamic> properties = const {},
  }) async {}
}
