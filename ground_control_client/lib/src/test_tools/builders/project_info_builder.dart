import 'package:ground_control_client/ground_control_client.dart'
    show ProjectInfo, Timestamp;

import 'project_builder.dart';

class ProjectInfoBuilder {
  ProjectBuilder projectBuilder;

  String _productId;
  Timestamp? _latestDeployAttemptTime;

  ProjectInfoBuilder({final ProjectBuilder? projectBuilder})
    : projectBuilder = projectBuilder ?? ProjectBuilder(),
      _productId = 'closed-beta-project:0',
      _latestDeployAttemptTime = null;

  ProjectInfoBuilder withProject(ProjectBuilder projectBuilder) {
    this.projectBuilder = projectBuilder;
    return this;
  }

  ProjectInfoBuilder withLatestDeployAttemptTime(
    DateTime? latestDeployAttemptTime,
  ) {
    _latestDeployAttemptTime = Timestamp(timestamp: latestDeployAttemptTime);
    return this;
  }

  ProjectInfoBuilder withProductId(String productId) {
    _productId = productId;
    return this;
  }

  ProjectInfo build() {
    return ProjectInfo(
      project: projectBuilder.build(),
      productId: _productId,
      latestDeployAttemptTime: _latestDeployAttemptTime,
    );
  }
}
