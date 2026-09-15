import 'package:ground_control_client/ground_control_client.dart';

import 'project_builder.dart';
import 'project_info_builder.dart';

class AdminProjectInfoBuilder {
  ProjectInfoBuilder projectInfoBuilder;
  String _subscriptionId;
  List<PaymentsStatus> _overduePaymentsStatuses;

  AdminProjectInfoBuilder({final ProjectInfoBuilder? projectInfoBuilder})
    : projectInfoBuilder = projectInfoBuilder ?? ProjectInfoBuilder(),
      _subscriptionId = 'orb_sub_test',
      _overduePaymentsStatuses = const [];

  AdminProjectInfoBuilder withProject(final ProjectBuilder projectBuilder) {
    projectInfoBuilder.withProject(projectBuilder);
    return this;
  }

  AdminProjectInfoBuilder withProjectInfo(
    final ProjectInfoBuilder projectInfoBuilder,
  ) {
    this.projectInfoBuilder = projectInfoBuilder;
    return this;
  }

  AdminProjectInfoBuilder withSubscriptionId(final String subscriptionId) {
    _subscriptionId = subscriptionId;
    return this;
  }

  AdminProjectInfoBuilder withOverduePaymentsStatuses(
    final List<PaymentsStatus> overduePaymentsStatuses,
  ) {
    _overduePaymentsStatuses = overduePaymentsStatuses;
    return this;
  }

  AdminProjectInfo build() {
    return AdminProjectInfo(
      projectInfo: projectInfoBuilder.build(),
      subscriptionId: _subscriptionId,
      overduePaymentsStatuses: _overduePaymentsStatuses,
    );
  }
}
