import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/launch/launch.dart';
import 'package:test/test.dart';

void main() {
  group('Given a project that has never been deployed', () {
    final project = ProjectInfoBuilder()
        .withProject(ProjectBuilder().withCloudProjectId('my-project'))
        .withLatestDeployAttemptTime(null)
        .build();

    test('when building its selection label then it offers a first deploy', () {
      expect(
        Launch.projectSelectionLabel(project, inUtc: false),
        endsWith('available for first deployment'),
      );
    });
  });

  group('Given a deployed project', () {
    final lastDeployed = DateTime.utc(2026, 8, 25, 14, 19);
    final project = ProjectInfoBuilder()
        .withProject(ProjectBuilder().withCloudProjectId('my-project'))
        .withLatestDeployAttemptTime(lastDeployed)
        .build();

    group('when building its selection label in local time', () {
      test('then the deploy time states the local zone', () {
        final local = lastDeployed.toLocal().toString().substring(0, 16);

        expect(
          Launch.projectSelectionLabel(project, inUtc: false),
          endsWith('last deployed $local (local)'),
        );
      });
    });

    group('when building its selection label in UTC', () {
      test('then the deploy time states UTC', () {
        expect(
          Launch.projectSelectionLabel(project, inUtc: true),
          endsWith('last deployed 2026-08-25 14:19 (UTC)'),
        );
      });
    });
  });
}
