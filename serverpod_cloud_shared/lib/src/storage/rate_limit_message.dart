import 'dart:math' as math;

/// User-facing retry copy for storage operations rejected by the
/// per-capsule rate limit, shared so the CLI and the console word the
/// wait the same way.
abstract final class RateLimitMessage {
  /// Renders the time until the budget refreshes, rounded up to whole
  /// minutes and never below one.
  static String tryAgainIn(final Duration retryAfter) {
    final minutes = math.max(
      1,
      (retryAfter.inMicroseconds / Duration.microsecondsPerMinute).ceil(),
    );
    return 'Try again in ~$minutes min.';
  }
}
