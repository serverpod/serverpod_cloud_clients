import 'package:serverpod_cloud_cli/commands/launch/launch.dart';
import 'package:serverpod_cloud_cli/commands/launch/tui/config.dart';
import 'package:serverpod_cloud_cli/commands/launch/tui/state.dart';
import 'package:serverpod_cloud_cli/commands/project/project.dart';
import 'package:serverpod_tui/serverpod_tui.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  group('Given a LaunchConfigState with no existing project IDs', () {
    late LaunchConfigState state;
    late ProjectIdInputConfig projectIdInput;

    setUp(() {
      state = LaunchConfigState(
        projectDir: d.sandbox,
        defaultProjectId: 'my-default-id',
        projectSetup: ProjectLaunch(),
        existingProjectIds: [],
      );
      projectIdInput = state.projectSelectionFormState.configurations
          .whereType<ProjectIdInputConfig>()
          .first;
    });

    group('When initialized', () {
      test('then only the project ID input is shown', () {
        final form = state.projectSelectionFormState;
        expect(
          form.configurations.whereType<ProjectSelectionConfig>(),
          isEmpty,
        );
        expect(
          form.configurations.whereType<ProjectIdInputConfig>(),
          hasLength(1),
        );
      });

      test(
        'then the defaultProjectId is pre-filled in the project ID input',
        () {
          final input = state.projectSelectionFormState.configurations
              .whereType<ProjectIdInputConfig>()
              .first;
          expect(
            state.projectSelectionFormState.getInputFor(input),
            'my-default-id',
          );
        },
      );
    });

    group('When goToConfiguration is called', () {
      test(
        'then the launch phase remains in project selection if the project ID is '
        'invalid',
        () {
          state.projectSelectionFormState.updateInput(projectIdInput, '');
          state.goToConfiguration();

          expect(state.phase, LaunchPhase.projectSelection);
          expect(state.configurationFormState, isNull);
        },
      );

      test(
        'then the launch phase is updated to configuration if the project ID is '
        'valid',
        () {
          state.projectSelectionFormState.updateInput(
            projectIdInput,
            'valid-project-id',
          );
          state.goToConfiguration();

          expect(state.phase, LaunchPhase.configuration);
          expect(state.configurationFormState, isNotNull);
        },
      );

      test('then plan and database are included for a new project', () {
        state.projectSelectionFormState.updateInput(
          projectIdInput,
          'valid-project-id',
        );
        state.goToConfiguration();

        expect(state.phase, LaunchPhase.configuration);
        final form = state.configurationFormState!;
        expect(
          form.configurations.contains(ScloudLaunchSelectionConfig.plan),
          isTrue,
        );
        expect(
          form.configurations.contains(ScloudLaunchSelectionConfig.database),
          isTrue,
        );
      });

      test('then the flutter build config is included when a flutter_build '
          'script exists', () async {
        await d.dir('project', [
          d.file('pubspec.yaml', '''
name: test_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ^3.4.0
serverpod:
  scripts:
    flutter_build: dart run tool/build_web.dart
'''),
        ]).create();

        final localState = LaunchConfigState(
          projectDir: d.path('project'),
          defaultProjectId: null,
          projectSetup: ProjectLaunch(),
          existingProjectIds: [],
        );
        final input = localState.projectSelectionFormState.configurations
            .whereType<ProjectIdInputConfig>()
            .first;
        localState.projectSelectionFormState.updateInput(
          input,
          'flutter-test-proj',
        );
        localState.goToConfiguration();

        expect(
          localState.configurationFormState!.configurations.contains(
            ScloudLaunchSelectionConfig.flutterBuild,
          ),
          isTrue,
        );
      });
    });

    group('When goBackToProjectSelection is called', () {
      test(
        'then the launch phase returns to project selection and disposes the '
        'configuration form',
        () {
          state.projectSelectionFormState.updateInput(
            projectIdInput,
            'valid-project-id',
          );
          state.goToConfiguration();
          expect(state.phase, LaunchPhase.configuration);

          state.goBackToProjectSelection();

          expect(state.phase, LaunchPhase.projectSelection);
          expect(state.configurationFormState, isNull);
        },
      );
    });

    group('When markLaunchingProject is called', () {
      test('then the state transitions to the launching phase', () {
        state.projectSelectionFormState.updateInput(
          projectIdInput,
          'valid-project-id',
        );
        state.goToConfiguration();
        state.markLaunchingProject();

        expect(state.phase, LaunchPhase.launching);
      });

      test('then the project setup includes the expected plan and database for '
          'a new project', () {
        state.projectSelectionFormState.updateInput(
          projectIdInput,
          'my-new-project',
        );
        state.goToConfiguration();
        state.configurationFormState!.updateSelectedOption(
          ScloudLaunchSelectionConfig.plan,
          PlanFormConfigOption.starter,
        );
        state.configurationFormState!.updateSelectedOption(
          ScloudLaunchSelectionConfig.database,
          BoolFormConfigOption.enabled,
        );
        state.markLaunchingProject();

        expect(state.projectSetup.projectId, 'my-new-project');
        expect(state.projectSetup.preexistingProject, isFalse);
        expect(state.projectSetup.plan, PlanProfile.starter);
        expect(state.projectSetup.enableDb, isTrue);
      });

      test(
        'then the codegen pre-deploy script is added when enabled by default',
        () {
          state.projectSelectionFormState.updateInput(
            projectIdInput,
            'my-project',
          );
          state.goToConfiguration();
          state.markLaunchingProject();

          expect(
            state.projectSetup.suggestedPreDeployScripts,
            contains('serverpod generate'),
          );
        },
      );

      test('then the codegen pre-deploy script is not added when disabled', () {
        state.projectSelectionFormState.updateInput(
          projectIdInput,
          'my-project',
        );
        state.goToConfiguration();
        state.configurationFormState!.updateSelectedOption(
          ScloudLaunchSelectionConfig.codegen,
          BoolFormConfigOption.disabled,
        );
        state.markLaunchingProject();

        expect(
          state.projectSetup.suggestedPreDeployScripts,
          isNot(contains('serverpod generate')),
        );
      });

      test('then the flutter_build pre-deploy script is added when a '
          'flutter_build script exists', () async {
        await d.dir('project', [
          d.file('pubspec.yaml', '''
name: test_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ^3.4.0
serverpod:
  scripts:
    flutter_build: dart run tool/build_web.dart
'''),
        ]).create();

        final localState = LaunchConfigState(
          projectDir: d.path('project'),
          defaultProjectId: null,
          projectSetup: ProjectLaunch(projectDir: d.path('project')),
          existingProjectIds: [],
        );
        final input = localState.projectSelectionFormState.configurations
            .whereType<ProjectIdInputConfig>()
            .first;
        localState.projectSelectionFormState.updateInput(input, 'my-project');
        localState.goToConfiguration();
        localState.markLaunchingProject();

        expect(
          localState.projectSetup.suggestedPreDeployScripts,
          contains('serverpod run flutter_build'),
        );
      });

      test('then pre-deploy scripts that already exist are not duplicated', () {
        state.projectSelectionFormState.updateInput(
          projectIdInput,
          'my-project',
        );
        state.goToConfiguration();
        state.projectSetup.suggestedPreDeployScripts.add('serverpod generate');
        state.markLaunchingProject();

        expect(
          state.projectSetup.suggestedPreDeployScripts
              .where((final s) => s == 'serverpod generate')
              .length,
          1,
        );
      });
    });
  });

  group('Given a LaunchConfigState with existing project IDs', () {
    late LaunchConfigState state;

    setUp(() {
      state = LaunchConfigState(
        projectDir: d.sandbox,
        defaultProjectId: null,
        projectSetup: ProjectLaunch(),
        existingProjectIds: ['project', 'another-project'],
      );
    });

    group('When initialized', () {
      test('then a ProjectSelectionConfig is created and the first project is '
          'selected', () {
        final form = state.projectSelectionFormState;
        expect(
          form.configurations.whereType<ProjectSelectionConfig>(),
          hasLength(1),
        );

        final config = form.configurations
            .whereType<ProjectSelectionConfig>()
            .first;
        final selected = form.getSelectedOptionFor<ProjectSelectionOption>(
          config,
        );
        expect(selected?.projectId, 'project');
      });
    });

    group('When goToConfiguration is called', () {
      test(
        'then plan and database are excluded from the configuration form',
        () {
          state.goToConfiguration();

          expect(state.phase, LaunchPhase.configuration);
          final form = state.configurationFormState;
          expect(form, isNotNull);
          expect(
            form!.configurations.contains(ScloudLaunchSelectionConfig.plan),
            isFalse,
          );
          expect(
            form.configurations.contains(ScloudLaunchSelectionConfig.database),
            isFalse,
          );
          expect(
            form.configurations.contains(ScloudLaunchSelectionConfig.deploy),
            isTrue,
          );
          expect(
            form.configurations.contains(ScloudLaunchSelectionConfig.codegen),
            isTrue,
          );
        },
      );
    });

    group('When markLaunchingProject is called', () {
      test('then the project setup reflects the existing project', () {
        state.goToConfiguration();
        state.markLaunchingProject();

        expect(state.projectSetup.projectId, 'project');
        expect(state.projectSetup.preexistingProject, isTrue);
        expect(state.projectSetup.plan, isNull);
        expect(state.projectSetup.enableDb, isNull);
      });
    });
  });
}
