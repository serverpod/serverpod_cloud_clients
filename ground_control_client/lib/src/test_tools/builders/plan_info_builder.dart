import 'package:ground_control_client/ground_control_client.dart';

List<ProjectProductInfo> _standardPlanBundledProjectProducts() {
  final computeSmall = ComputeProductInfo(
    size: ComputeSizeOption.small,
    productId: 'compute-growth:0',
    name: 'Compute',
    description: 'Compute for growth',
  );

  final computeMedium = ComputeProductInfo(
    size: ComputeSizeOption.medium,
    productId: 'compute-growth:0',
    name: 'Compute',
    description: 'Compute for growth',
  );
  final computeLarge = ComputeProductInfo(
    size: ComputeSizeOption.large,
    productId: 'compute-growth:0',
    name: 'Compute',
    description: 'Compute for growth',
  );

  final databaseSmall = DatabaseProductInfo(
    size: DatabaseSizeOption.small,
    productId: 'database-growth:0',
    name: 'Database',
    description: 'Database for growth',
    cuHoursPerMonthLimit: 750,
    storageLimitGB: 2,
  );
  final databaseMedium = DatabaseProductInfo(
    size: DatabaseSizeOption.medium,
    productId: 'database-growth:0',
    name: 'Database',
    description: 'Database for growth',
  );
  final databaseLarge = DatabaseProductInfo(
    size: DatabaseSizeOption.large,
    productId: 'database-growth:0',
    name: 'Database',
    description: 'Database for growth',
  );
  final databaseLargePlus = DatabaseProductInfo(
    size: DatabaseSizeOption.largePlus,
    productId: 'database-growth:0',
    name: 'Database',
    description: 'Database for growth',
    scaling: DatabaseScalingInfo(
      defaultMinCu: 1,
      defaultMaxCu: 1,
      allowedCuValues: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 16],
      maxCuSpread: 8,
    ),
  );
  final computeCatalog = ComputeCatalogInfo(
    computes: [computeSmall, computeMedium, computeLarge],
    defaultCompute: computeSmall.size,
    scaling: ComputeScalingInfo(
      defaultMinReplicas: 1,
      defaultMaxReplicas: 1,
      allowedReplicasMin: 1,
      allowedReplicasMax: 20,
    ),
  );
  final databaseCatalog = DatabaseCatalogInfo(
    databases: [
      databaseSmall,
      databaseMedium,
      databaseLarge,
      databaseLargePlus,
    ],
    defaultDatabase: databaseSmall.size,
  );
  return [
    ProjectProductInfo(
      productId: 'growth:0',
      name: 'Growth',
      description: 'Bundled project product for standard plan fixtures',
      computeCatalog: computeCatalog,
      databaseCatalog: databaseCatalog,
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
