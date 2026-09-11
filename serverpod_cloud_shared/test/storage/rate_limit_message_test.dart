import 'package:serverpod_cloud_shared/serverpod_cloud_shared.dart';
import 'package:test/test.dart';

void main() {
  group('Given a rate limit retry duration', () {
    test('when it is whole minutes then they are shown as-is', () {
      expect(
        RateLimitMessage.tryAgainIn(const Duration(minutes: 37)),
        'Try again in ~37 min.',
      );
    });

    test('when it has a sub-second remainder then it still rounds up', () {
      expect(
        RateLimitMessage.tryAgainIn(const Duration(milliseconds: 60001)),
        'Try again in ~2 min.',
      );
    });

    test('when it has leftover seconds then it rounds up', () {
      expect(
        RateLimitMessage.tryAgainIn(const Duration(seconds: 90)),
        'Try again in ~2 min.',
      );
    });

    test('when it is under a minute then one minute is shown', () {
      expect(
        RateLimitMessage.tryAgainIn(const Duration(seconds: 10)),
        'Try again in ~1 min.',
      );
    });
  });
}
