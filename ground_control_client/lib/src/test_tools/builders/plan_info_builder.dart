import 'package:ground_control_client/ground_control_client.dart';

List<ProjectProductInfo> _standardPlanBundledProjectProducts() {
  final smallDbSize = DatabaseSizeInfo(name: 'small');
  final mediumDbSize = DatabaseSizeInfo(name: 'medium');
  final largeDbSize = DatabaseSizeInfo(name: 'large');
  final largePlusDbSize = DatabaseSizeInfo(
    name: 'large+',
    scaling: DatabaseScalingInfo(
      defaultMinCu: 1,
      defaultMaxCu: 1,
      allowedCuValues: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 16],
      maxCuSpread: 8,
    ),
  );
  return [
    ProjectProductInfo(
      productId: 'growth:0',
      name: 'Growth',
      description: 'Bundled project product for standard plan fixtures',
      compute: ComputeProductInfo(
        productId: 'compute-growth:0',
        name: 'Compute',
        description: 'Compute for growth',
        defaultInstanceType: 'small',
        defaultMinReplicas: 1,
        defaultMaxReplicas: 1,
        allowedInstanceTypes: const ['small', 'medium', 'large'],
        allowedReplicasMin: 1,
        allowedReplicasMax: 20,
      ),
      database: DatabaseProductInfo(
        productId: 'database-growth:0',
        name: 'Database',
        description: 'Database for growth',
        defaultSize: smallDbSize,
        allowedSizes: [smallDbSize, mediumDbSize, largeDbSize, largePlusDbSize],
      ),
    ),
  ];
}

class PlanInfoBuilder {
  String _productId;
  String _displayName;
  String? _description;
  int? _trialLength;
  DateTime? _trialEndDate;
  int? _projectsLimit;
  List<ProjectProductInfo> _projectProductInfo;

  PlanInfoBuilder()
    : _productId = 'early-access:0',
      _displayName = 'Early Access',
      _description = 'A test plan description',
      _trialLength = 7,
      _trialEndDate = null,
      _projectsLimit = 3,
      _projectProductInfo = const [];

  PlanInfoBuilder withHackathon2025() {
    _productId = 'hackathon-25:0';
    _displayName = 'Hackathon 2025';
    _description = 'A test plan description';
    _trialLength = 91;
    _trialEndDate = DateTime.now().add(Duration(days: 91));
    _projectsLimit = 1;
    return this;
  }

  PlanInfoBuilder withStandardPlan() {
    _productId = 'standard:0';
    _displayName = 'Standard';
    _description = 'A test plan description';
    _trialLength = 30;
    _trialEndDate = null;
    _projectsLimit = 3;
    _projectProductInfo = _standardPlanBundledProjectProducts();
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

  PlanInfoBuilder withDisplayName(final String displayName) {
    _displayName = displayName;
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

  PlanInfoBuilder withProjectProductInfo(final List<ProjectProductInfo> info) {
    _projectProductInfo = info;
    return this;
  }

  PlanInfo build() {
    return PlanInfo(
      productId: _productId,
      name: _displayName,
      displayName: _displayName,
      description: _description,
      trialLength: _trialLength,
      trialEndDate: _trialEndDate,
      projectsLimit: _projectsLimit,
      projectProductInfo: _projectProductInfo,
    );
  }
}
