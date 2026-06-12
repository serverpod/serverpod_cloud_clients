import 'package:serverpod_tui/serverpod_tui.dart';

/// Form selection configuration for [ScloudLaunchApp].
enum ScloudLaunchSelectionConfig<T extends FormConfigOption>
    implements FormSelectionConfig<T> {
  plan<PlanFormConfigOption>(
    label: 'Plan',
    options: PlanFormConfigOption.values,
    defaultOptions: {PlanFormConfigOption.starter},
  ),
  database<BoolFormConfigOption>(
    label: 'Database',
    options: BoolFormConfigOption.values,
    defaultOptions: {BoolFormConfigOption.enabled},
  ),
  deploy<BoolFormConfigOption>(
    label: 'Immediate deployment',
    options: BoolFormConfigOption.values,
    defaultOptions: {BoolFormConfigOption.enabled},
  ),
  codegen<BoolFormConfigOption>(
    label: 'Code generation (`serverpod generate`) as a pre-deploy hook',
    options: BoolFormConfigOption.values,
    defaultOptions: {BoolFormConfigOption.enabled},
  ),
  flutterBuild<BoolFormConfigOption>(
    label: 'Flutter build (`serverpod run flutter_build`) as a pre-deploy hook',
    options: BoolFormConfigOption.values,
    defaultOptions: {BoolFormConfigOption.disabled},
  );

  const ScloudLaunchSelectionConfig({
    required this.label,
    required this.options,
    required this.defaultOptions,
    this.requirements = const [],
    this.multiSelect = false,
    this.description,
  });

  @override
  final String label;

  @override
  final List<T> options;

  @override
  final Set<T> defaultOptions;

  @override
  final List<FormRequirement> requirements;

  @override
  final bool multiSelect;

  @override
  final FormDescription? description;
}

/// [FormConfigOption] for supported plans.
enum PlanFormConfigOption implements FormConfigOption {
  starter('Starter'),
  growth('Growth');

  const PlanFormConfigOption(this.label);

  @override
  final String label;
}

/// [FormConfigOption] for a project shown in the project selection screen.
class ProjectSelectionOption implements FormConfigOption {
  const ProjectSelectionOption({required this.label, this.projectId});

  @override
  final String label;

  /// Null when this represents "Create new project".
  final String? projectId;
}

/// Shared singleton for the "Create new project" option.
const kCreateNewProjectOption = ProjectSelectionOption(
  label: 'Create new project',
);

/// [FormSelectionConfig] for project selection.
class ProjectSelectionConfig
    implements FormSelectionConfig<ProjectSelectionOption> {
  @override
  final String label = 'Select project';

  @override
  final List<ProjectSelectionOption> options;

  @override
  final Set<ProjectSelectionOption> defaultOptions;

  @override
  final bool multiSelect = false;

  @override
  final List<FormRequirement> requirements = [];

  @override
  final FormDescription? description = null;

  ProjectSelectionConfig({required final List<String> existingProjectIds})
    : options = [
        for (final id in existingProjectIds)
          ProjectSelectionOption(label: id, projectId: id),
        kCreateNewProjectOption,
      ],
      defaultOptions = {kCreateNewProjectOption};
}

/// [FormInputConfig] for the project ID.
///
/// When [selectionConfig] is provided, the input is shown only when the
/// "Create new project" option is selected. When null, the input is always
/// visible (no existing projects to choose from).
class ProjectIdInputConfig implements FormInputConfig {
  ProjectIdInputConfig(final ProjectSelectionConfig? selectionConfig)
    : requirements = [
        if (selectionConfig != null)
          FormRequirement(
            config: selectionConfig,
            configOption: kCreateNewProjectOption,
          ),
      ];

  @override
  final String label = 'Project ID';

  @override
  final int maxLines = 1;

  @override
  final double width = 20;

  @override
  final String? suffixText = '.serverpod.space';

  @override
  final List<FormRequirement> requirements;

  @override
  final FormDescription? description = null;
}
