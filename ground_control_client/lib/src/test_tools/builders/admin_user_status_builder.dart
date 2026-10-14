import 'package:ground_control_client/ground_control_client.dart';

import 'admin_user_owner_status_builder.dart';
import 'admin_user_project_membership_builder.dart';

class AdminUserStatusBuilder {
  AdminUserOwnerStatusBuilder _ownerBuilder;
  List<AdminUserProjectMembershipBuilder> _projectBuilders;

  AdminUserStatusBuilder()
    : _ownerBuilder = AdminUserOwnerStatusBuilder(),
      _projectBuilders = [AdminUserProjectMembershipBuilder()];

  AdminUserStatusBuilder withOwner(AdminUserOwnerStatusBuilder ownerBuilder) {
    _ownerBuilder = ownerBuilder;
    return this;
  }

  AdminUserStatusBuilder withProjects(
    List<AdminUserProjectMembershipBuilder> projectBuilders,
  ) {
    _projectBuilders = projectBuilders;
    return this;
  }

  AdminUserStatusBuilder withNoProjects() {
    _projectBuilders = [];
    return this;
  }

  AdminUserStatus build() {
    return AdminUserStatus(
      owner: _ownerBuilder.build(),
      projects: [for (final builder in _projectBuilders) builder.build()],
    );
  }
}
