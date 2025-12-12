import 'package:ground_control_client/ground_control_client.dart'
    show ProjectInfo, Timestamp;

import 'project_builder.dart';

class ProjectInfoBuilder {
  ProjectBuilder projectBuilder;

  Timestamp? _latestDeployAttemptTime;

  ProjectInfoBuilder({final ProjectBuilder? projectBuilder})
    : projectBuilder = projectBuilder ?? ProjectBuilder(),
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

  ProjectInfo build() {
    return ProjectInfo(
      project: projectBuilder.build(),
      latestDeployAttemptTime: _latestDeployAttemptTime,
    );
  }
}
