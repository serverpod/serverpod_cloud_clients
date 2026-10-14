import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';

class AdminUserProjectMembershipBuilder {
  String _cloudProjectId;
  List<ProjectRole> _userRoles;
  PlanType? _planType;
  String? _planProductId;
  String? _billingPlanId;
  String? _billingSubscriptionId;
  DateTime _projectCreatedAt;
  DeployAttempt? _latestDeployAttempt;

  AdminUserProjectMembershipBuilder()
    : _cloudProjectId = 'my-project',
      _userRoles = const [ProjectRole.admin],
      _planType = PlanType.starter,
      _planProductId = 'starter:1',
      _billingPlanId = 'starter-private',
      _billingSubscriptionId = 'orb_sub_test',
      _projectCreatedAt = DateTime.utc(2024, 1, 1),
      _latestDeployAttempt = DeployAttemptBuilder()
          .withCloudCapsuleId('my-project')
          .withSuccessfulDeployment()
          .withStartedAt(DateTime.utc(2024, 6, 1))
          .withEndedAt(DateTime.utc(2024, 6, 1, 0, 5))
          .build();

  AdminUserProjectMembershipBuilder withCloudProjectId(String cloudProjectId) {
    _cloudProjectId = cloudProjectId;
    return this;
  }

  AdminUserProjectMembershipBuilder withUserRoles(List<ProjectRole> userRoles) {
    _userRoles = userRoles;
    return this;
  }

  AdminUserProjectMembershipBuilder withPlanType(PlanType? planType) {
    _planType = planType;
    return this;
  }

  AdminUserProjectMembershipBuilder withPlanProductId(String? planProductId) {
    _planProductId = planProductId;
    return this;
  }

  AdminUserProjectMembershipBuilder withBillingPlanId(String? billingPlanId) {
    _billingPlanId = billingPlanId;
    return this;
  }

  AdminUserProjectMembershipBuilder withBillingSubscriptionId(
    String? billingSubscriptionId,
  ) {
    _billingSubscriptionId = billingSubscriptionId;
    return this;
  }

  AdminUserProjectMembershipBuilder withProjectCreatedAt(
    DateTime projectCreatedAt,
  ) {
    _projectCreatedAt = projectCreatedAt;
    return this;
  }

  AdminUserProjectMembershipBuilder withLatestDeployAttempt(
    DeployAttempt? latestDeployAttempt,
  ) {
    _latestDeployAttempt = latestDeployAttempt;
    return this;
  }

  AdminUserProjectMembership build() {
    return AdminUserProjectMembership(
      cloudProjectId: _cloudProjectId,
      userRoles: _userRoles,
      planType: _planType,
      planProductId: _planProductId,
      billingPlanId: _billingPlanId,
      billingSubscriptionId: _billingSubscriptionId,
      projectCreatedAt: _projectCreatedAt,
      latestDeployAttempt: _latestDeployAttempt,
    );
  }
}
