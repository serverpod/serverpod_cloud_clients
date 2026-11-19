import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';

class AdminUserProjectMembershipBuilder {
  List<ProjectRole> _userRoles;
  AdminProjectInfoBuilder _project;

  AdminUserProjectMembershipBuilder()
    : _userRoles = const [ProjectRole.admin],
      _project = AdminProjectInfoBuilder()
          .withProject(
            ProjectBuilder()
                .withCloudProjectId('my-project')
                .withCreatedAt(DateTime.utc(2024, 1, 1)),
          )
          .withPlanProductId('starter:1')
          .withSubscriptionId('orb_sub_test')
          .withBillingPlanId('starter-private')
          .withLatestDeployAttempt(
            DeployAttemptBuilder()
                .withCloudCapsuleId('my-project')
                .withSuccessfulDeployment()
                .withStartedAt(DateTime.utc(2024, 6, 1))
                .withEndedAt(DateTime.utc(2024, 6, 1, 0, 5))
                .build(),
          );

  AdminUserProjectMembershipBuilder withUserRoles(List<ProjectRole> userRoles) {
    _userRoles = userRoles;
    return this;
  }

  AdminUserProjectMembershipBuilder withProject(
    AdminProjectInfoBuilder project,
  ) {
    _project = project;
    return this;
  }

  /// A suspended project, for an overdue payment unless [reason] says
  /// otherwise.
  AdminUserProjectMembershipBuilder withSuspended([
    ProjectSuspensionReason reason = ProjectSuspensionReason.paymentOverdue,
  ]) {
    _project.withSuspended(reason);
    return this;
  }

  AdminUserProjectMembershipBuilder withSuspendedAt(DateTime? suspendedAt) {
    _project.withSuspendedAt(suspendedAt);
    return this;
  }

  AdminUserProjectMembershipBuilder withLatestDeployAttempt(
    DeployAttempt? latestDeployAttempt,
  ) {
    _project.withLatestDeployAttempt(latestDeployAttempt);
    return this;
  }

  AdminUserProjectMembership build() {
    return AdminUserProjectMembership(
      userRoles: _userRoles,
      project: _project.build(),
    );
  }
}
