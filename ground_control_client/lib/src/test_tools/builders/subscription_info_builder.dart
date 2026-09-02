import 'package:ground_control_client/ground_control_client.dart';

class SubscriptionInfoBuilder {
  DateTime _createdAt;
  DateTime _startDate;
  DateTime? _trialEndDate;
  DateTime? _endDate;
  bool _cancelled;
  UuidValue _subscriptionId;
  String _planProductId;
  PlanType _planType;
  String _planDisplayName;
  String? _planDescription;
  int? _projectsLimit;

  SubscriptionInfoBuilder()
    : _createdAt = DateTime.now(),
      _startDate = DateTime.now(),
      _trialEndDate = DateTime.now().add(Duration(days: 7)),
      _endDate = null,
      _cancelled = false,
      _subscriptionId = Uuid().v4obj(),
      _planProductId = 'early-access:0',
      _planType = PlanType.unknown,
      _planDisplayName = 'Early Access',
      _planDescription = 'A test plan description',
      _projectsLimit = 1;

  SubscriptionInfoBuilder withCreatedAt(DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  SubscriptionInfoBuilder withStartDate(DateTime startDate) {
    _startDate = startDate;
    return this;
  }

  SubscriptionInfoBuilder withTrialEndDate(DateTime? trialEndDate) {
    _trialEndDate = trialEndDate;
    return this;
  }

  SubscriptionInfoBuilder withEndDate(DateTime? endDate) {
    _endDate = endDate;
    return this;
  }

  SubscriptionInfoBuilder withCancelled(bool cancelled) {
    _cancelled = cancelled;
    return this;
  }

  SubscriptionInfoBuilder withSubscriptionId(UuidValue subscriptionId) {
    _subscriptionId = subscriptionId;
    return this;
  }

  SubscriptionInfoBuilder withPlanProductId(String planProductId) {
    assert(planProductId.contains(':'), 'Plan product ID must contain a colon');
    _planProductId = planProductId;
    return this;
  }

  SubscriptionInfoBuilder withPlanType(PlanType planType) {
    _planType = planType;
    return this;
  }

  SubscriptionInfoBuilder withPlanDisplayName(String planDisplayName) {
    _planDisplayName = planDisplayName;
    return this;
  }

  SubscriptionInfoBuilder withPlanDescription(String? planDescription) {
    _planDescription = planDescription;
    return this;
  }

  SubscriptionInfoBuilder withProjectsLimit(int? projectsLimit) {
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
      planType: _planType,
      planName: _planDisplayName,
      planDisplayName: _planDisplayName,
      planDescription: _planDescription,
      projectsLimit: _projectsLimit,
    );
  }
}
