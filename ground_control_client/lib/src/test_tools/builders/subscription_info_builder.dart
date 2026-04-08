import 'package:ground_control_client/ground_control_client.dart';

class SubscriptionInfoBuilder {
  DateTime _createdAt;
  DateTime _startDate;
  DateTime? _trialEndDate;
  DateTime? _endDate;
  bool _cancelled;
  String _subscriptionId;
  String _planProductId;
  String _planDisplayName;
  String? _planDescription;
  int? _projectsLimit;

  SubscriptionInfoBuilder()
    : _createdAt = DateTime.now(),
      _startDate = DateTime.now(),
      _trialEndDate = DateTime.now().add(Duration(days: 7)),
      _endDate = null,
      _cancelled = false,
      _subscriptionId = 'test-subscription-id',
      _planProductId = 'early-access:0',
      _planDisplayName = 'Early Access',
      _planDescription = 'A test plan description',
      _projectsLimit = 1;

  SubscriptionInfoBuilder withCreatedAt(final DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  SubscriptionInfoBuilder withStartDate(final DateTime startDate) {
    _startDate = startDate;
    return this;
  }

  SubscriptionInfoBuilder withTrialEndDate(final DateTime? trialEndDate) {
    _trialEndDate = trialEndDate;
    return this;
  }

  SubscriptionInfoBuilder withEndDate(final DateTime? endDate) {
    _endDate = endDate;
    return this;
  }

  SubscriptionInfoBuilder withCancelled(final bool cancelled) {
    _cancelled = cancelled;
    return this;
  }

  SubscriptionInfoBuilder withSubscriptionId(final String subscriptionId) {
    _subscriptionId = subscriptionId;
    return this;
  }

  SubscriptionInfoBuilder withPlanProductId(final String planProductId) {
    assert(planProductId.contains(':'), 'Plan product ID must contain a colon');
    _planProductId = planProductId;
    return this;
  }

  SubscriptionInfoBuilder withPlanDisplayName(final String planDisplayName) {
    _planDisplayName = planDisplayName;
    return this;
  }

  SubscriptionInfoBuilder withPlanDescription(final String? planDescription) {
    _planDescription = planDescription;
    return this;
  }

  SubscriptionInfoBuilder withProjectsLimit(final int? projectsLimit) {
    _projectsLimit = projectsLimit;
    return this;
  }

  SubscriptionInfo build() {
    return SubscriptionInfo(
      createdAt: _createdAt,
      startDate: _startDate,
      trialEndDate: _trialEndDate,
      endDate: _endDate,
      cancelled: _cancelled,
      subscriptionId: _subscriptionId,
      planProductId: _planProductId,
      planName: _planDisplayName,
      planDisplayName: _planDisplayName,
      planDescription: _planDescription,
      projectsLimit: _projectsLimit,
    );
  }
}
