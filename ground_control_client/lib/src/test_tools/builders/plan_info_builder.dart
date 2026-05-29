import 'package:ground_control_client/ground_control_client.dart';

ProjectProductInfo _starterPlanBundledProjectProduct() {
  final computeSmall = ComputeProductInfo(
    size: ComputeSizeOption.small,
    productId: 'compute-starter:0',
    name: 'Compute',
    description: 'Compute for starter',
  );
  final databaseSmall = DatabaseProductInfo(
    size: DatabaseSizeOption.small,
    productId: 'database-starter:0',
    name: 'Database',
    description: 'Database for starter',
  );
  final computeCatalog = ComputeCatalogInfo(
    computes: [computeSmall],
    defaultCompute: computeSmall.size,
    scaling: ComputeScalingInfo(
      defaultMinReplicas: 1,
      defaultMaxReplicas: 1,
      allowedReplicasMin: 1,
      allowedReplicasMax: 1,
    ),
  );
  final databaseCatalog = DatabaseCatalogInfo(
    databases: [databaseSmall],
    defaultDatabase: databaseSmall.size,
  );
  return ProjectProductInfo(
    productId: 'starter:0',
    name: 'Starter',
    description: 'Starter project',
    computeCatalog: computeCatalog,
    databaseCatalog: databaseCatalog,
  );
}

ProjectProductInfo _growthPlanBundledProjectProducts() {
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
  final computeXLarge = ComputeProductInfo(
    size: ComputeSizeOption.xlarge,
    productId: 'compute-growth:0',
    name: 'Compute',
    description: 'Compute for growth',
  );
  final computeXxLarge = ComputeProductInfo(
    size: ComputeSizeOption.xxlarge,
    productId: 'compute-growth:0',
    name: 'Compute',
    description: 'Compute for growth',
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
    computes: [computeMedium, computeLarge, computeXLarge, computeXxLarge],
    defaultCompute: computeMedium.size,
    scaling: ComputeScalingInfo(
      defaultMinReplicas: 2,
      defaultMaxReplicas: 2,
      allowedReplicasMin: 1,
      allowedReplicasMax: 20,
    ),
  );
  final databaseCatalog = DatabaseCatalogInfo(
    databases: [databaseMedium, databaseLarge, databaseLargePlus],
    defaultDatabase: databaseMedium.size,
  );
  return ProjectProductInfo(
    productId: 'growth:0',
    name: 'Growth',
    description: 'Performance & autoscaling',
    computeCatalog: computeCatalog,
    databaseCatalog: databaseCatalog,
  );
}

class PlanInfoBuilder {
  late String _productId;
  late PlanType _planType;
  late ProjectProductInfo _projectProduct;
  late String _displayName;
  String? _description;
  int? _trialLength;
  DateTime? _trialEndDate;
  int? _projectsLimit;
  List<ProjectProductInfo> _projectProductInfo;

  PlanInfoBuilder() : _projectProductInfo = const [] {
    final starterProduct = _starterPlanBundledProjectProduct();
    _productId = 'early-access:0';
    _planType = PlanType.unknown;
    _projectProduct = starterProduct;
    _displayName = 'Early Access';
    _description = 'A test plan description';
    _trialLength = 7;
    _trialEndDate = null;
    _projectsLimit = 3;
    _projectProductInfo = [starterProduct];
  }

  PlanInfoBuilder withHackathon2025() {
    final starterProduct = _starterPlanBundledProjectProduct();
    _productId = 'hackathon-25:0';
    _planType = PlanType.unknown;
    _projectProduct = starterProduct;
    _displayName = 'Hackathon 2025';
    _description = 'A test plan description';
    _trialLength = 91;
    _trialEndDate = DateTime.now().add(Duration(days: 91));
    _projectsLimit = 1;
    _projectProductInfo = [starterProduct];
    return this;
  }

  PlanInfoBuilder withGrowthPlan() {
    final growthProduct = _growthPlanBundledProjectProducts();
    _productId = 'growth:0';
    _planType = PlanType.growth;
    _displayName = 'Growth';
    _description = 'A test plan description';
    _projectProduct = growthProduct;
    _trialLength = 30;
    _trialEndDate = null;
    _projectsLimit = 3;
    _projectProductInfo = [growthProduct];
    return this;
  }

  PlanInfoBuilder withStarterPlan() {
    final starterProduct = _starterPlanBundledProjectProduct();
    _productId = 'starter:0';
    _planType = PlanType.starter;
    _projectProduct = starterProduct;
    _displayName = 'Starter';
    _description = 'A test plan description';
    _trialLength = 30;
    _trialEndDate = null;
    _projectsLimit = 3;
    _projectProductInfo = [starterProduct];
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

  PlanInfoBuilder withPlanType(final PlanType planType) {
    _planType = planType;
    return this;
  }

  PlanInfoBuilder withProjectProduct(final ProjectProductInfo projectProduct) {
    _projectProduct = projectProduct;
    _projectProductInfo = [projectProduct];
    return this;
  }

  PlanInfo build() {
    return PlanInfo(
      planType: _planType,
      projectProduct: _projectProduct,
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
