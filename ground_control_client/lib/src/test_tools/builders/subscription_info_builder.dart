import 'package:ground_control_client/ground_control_client.dart';

class SubscriptionInfoBuilder {
  DateTime _createdAt;
  DateTime _startDate;
  DateTime? _trialEndDate;
  String _subscriptionId;
  String _planProductId;
  String _planName;
  String? _planDescription;
  int? _projectsLimit;

  SubscriptionInfoBuilder()
      : _createdAt = DateTime.now(),
        _startDate = DateTime.now(),
        _trialEndDate = DateTime.now().add(Duration(days: 7)),
        _subscriptionId = 'test-subscription-id',
        _planProductId = 'early-access:0',
        _planName = 'Early Access',
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

  SubscriptionInfoBuilder withSubscriptionId(final String subscriptionId) {
    _subscriptionId = subscriptionId;
    return this;
  }

  SubscriptionInfoBuilder withPlanProductId(final String planProductId) {
    _planProductId = planProductId;
    return this;
  }

  SubscriptionInfoBuilder withPlanName(final String planName) {
    _planName = planName;
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
      subscriptionId: _subscriptionId,
      planProductId: _planProductId,
      planName: _planName,
      planDescription: _planDescription,
      projectsLimit: _projectsLimit,
    );
  }
}
