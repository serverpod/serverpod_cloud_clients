import 'package:ground_control_client/ground_control_client.dart';

class PlanInfoBuilder {
  String _productId;
  String _name;
  String? _description;
  int? _trialLength;
  DateTime? _trialEndDate;
  int? _projectsLimit;

  PlanInfoBuilder()
      : _productId = 'early-access:0',
        _name = 'Early Access',
        _description = 'A test plan description',
        _trialLength = 7,
        _trialEndDate = null,
        _projectsLimit = 3;

  PlanInfoBuilder withHackathon2025() {
    _productId = 'hackathon-25:0';
    _name = 'Hackathon 2025';
    _description = 'A test plan description';
    _trialLength = 91;
    _trialEndDate = DateTime.now().add(Duration(days: 91));
    _projectsLimit = 1;
    return this;
  }

  PlanInfoBuilder withStaticTrailOf30Days() {
    _trialEndDate = DateTime.now().add(Duration(days: 30));
    _trialEndDate = null;
    return this;
  }

  PlanInfoBuilder withDynamicTrailOf30Days() {
    _trialEndDate = null;
    _trialLength = 30;
    return this;
  }

  PlanInfoBuilder withProductId(final String productId) {
    _productId = productId;
    return this;
  }

  PlanInfoBuilder withName(final String name) {
    _name = name;
    return this;
  }

  PlanInfoBuilder withDescription(final String? description) {
    _description = description;
    return this;
  }

  PlanInfoBuilder withTrialLength(final int? trialLength) {
    _trialLength = trialLength;
    return this;
  }

  PlanInfoBuilder withTrialEndDate(final DateTime? trialEndDate) {
    _trialEndDate = trialEndDate;
    return this;
  }

  PlanInfoBuilder withProjectsLimit(final int? projectsLimit) {
    _projectsLimit = projectsLimit;
    return this;
  }

  PlanInfo build() {
    return PlanInfo(
      productId: _productId,
      name: _name,
      description: _description,
      trialLength: _trialLength,
      trialEndDate: _trialEndDate,
      projectsLimit: _projectsLimit,
    );
  }
}
