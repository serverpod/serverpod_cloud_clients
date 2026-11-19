import 'package:ground_control_client/ground_control_client.dart';

class AppBuildUsageBuilder {
  int _used = 4;
  int? _limit = 30;
  DateTime _resetsAt = DateTime.utc(2026, 12, 1);

  AppBuildUsageBuilder withUsed(int used) {
    _used = used;
    return this;
  }

  AppBuildUsageBuilder withLimit(int? limit) {
    _limit = limit;
    return this;
  }

  AppBuildUsageBuilder withResetsAt(DateTime resetsAt) {
    _resetsAt = resetsAt;
    return this;
  }

  /// An owner who used every build of the plan this month.
  AppBuildUsageBuilder withLimitReached() {
    _used = 30;
    _limit = 30;
    return this;
  }

  AppBuildUsage build() {
    return AppBuildUsage(used: _used, limit: _limit, resetsAt: _resetsAt);
  }
}
