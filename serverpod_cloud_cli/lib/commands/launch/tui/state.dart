import 'dart:io';

import 'package:serverpod_cloud_cli/commands/launch/launch.dart';
import 'package:serverpod_cloud_cli/commands/launch/tui/config.dart';
import 'package:serverpod_cloud_cli/commands/project/project.dart';
import 'package:serverpod_cloud_cli/util/project_id_validator.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';
import 'package:serverpod_tui/serverpod_tui.dart';

/// Phases of the launch TUI.
enum LaunchPhase { projectSelection, configuration, launching }

/// Central state for [ScloudLaunchApp] rendered by nocterm.
class LaunchConfigState extends TuiState {
  LaunchConfigState({
    required this.projectDir,
    required this.defaultProjectId,
    required final ProjectLaunch projectSetup,
    final List<String> existingProjectIds = const [],
  }) : _projectSetup = projectSetup,
       _existingProjectIds = existingProjectIds {
    _initializeProjectSelectionFormState();
  }

  /// Resolved path to the serverpod project directory (always non-null when
  /// the TUI is shown).
  final String projectDir;

  /// Default project ID derived from pubspec, or null.
  final String? defaultProjectId;

  /// IDs of existing undeployed projects fetched before the TUI starts.
  final List<String> _existingProjectIds;

  @override
  final logHistory = BoundedQueueList<Object>(1000);

  @override
  final Map<String, TrackedOperation> activeOperations = {};

  ProjectLaunch _projectSetup;
  ProjectLaunch get projectSetup => _projectSetup;

  LaunchPhase _phase = LaunchPhase.projectSelection;
  LaunchPhase get phase => _phase;

  bool get isProjectSelection => _phase == LaunchPhase.projectSelection;
  bool get isConfiguration => _phase == LaunchPhase.configuration;
  bool get isLaunching => _phase == LaunchPhase.launching;

  late FormState _projectSelectionFormState;

  ProjectSelectionConfig? _projectSelectionConfig;
  ProjectIdInputConfig? _projectIdInputConfig;

  FormState get projectSelectionFormState => _projectSelectionFormState;

  FormState? _configurationFormState;
  FormState? get configurationFormState => _configurationFormState;

  bool _hasFlutterBuildScript = false;

  /// True when an existing project is not selected.
  bool get _isNewProject {
    final config = _projectSelectionConfig;
    if (config == null) return true;
    final selected = _projectSelectionFormState
        .getSelectedOptionFor<ProjectSelectionOption>(config);
    return selected?.projectId == null;
  }

  /// The project ID when an existing project was selected, or null.
  String? get _selectedProjectId {
    final config = _projectSelectionConfig;
    if (config == null) return null;
    final selected = _projectSelectionFormState
        .getSelectedOptionFor<ProjectSelectionOption>(config);
    return selected?.projectId;
  }

  /// The project ID the user typed when creating a new project, or null
  /// when an existing project is selected.
  String? get _newProjectIdValue {
    final config = _projectIdInputConfig;
    if (config == null) return null;
    return _projectSelectionFormState.getInputFor(config);
  }

  void _initializeProjectSelectionFormState() {
    final selectionConfig = _existingProjectIds.isNotEmpty
        ? ProjectSelectionConfig(existingProjectIds: _existingProjectIds)
        : null;
    _projectSelectionConfig = selectionConfig;
    _projectIdInputConfig = ProjectIdInputConfig(selectionConfig);

    final configs = <FormConfig>[
      if (selectionConfig != null) selectionConfig,
      _projectIdInputConfig!,
    ];
    _projectSelectionFormState = FormState(configs);

    // Select the first existing project by default.
    if (selectionConfig != null) {
      _projectSelectionFormState.updateSelectedOption(
        selectionConfig,
        selectionConfig.options.first,
      );
    }

    // Pre-fill the default project ID for new projects.
    final defaultId = defaultProjectId;
    if (defaultId != null) {
      _projectSelectionFormState.updateInput(_projectIdInputConfig!, defaultId);
    }

    _setProjectIdValidator();
  }

  void _setProjectIdValidator() {
    final config = _projectIdInputConfig;
    if (config == null) return;

    _projectSelectionFormState.setValidator(config, (final text) {
      if (!isValidProjectIdFormat(text.trim())) {
        return 'Invalid project ID. Must be 6-32 characters long '
            'and contain only lowercase letters, numbers, and hyphens.';
      }
      return null;
    });
  }

  void goToConfiguration() {
    if (!_validateProjectSelection()) return;
    _hasFlutterBuildScript = _checkHasFlutterBuildScript();

    _configurationFormState?.dispose();
    final formState = FormState([
      if (_isNewProject) ScloudLaunchSelectionConfig.plan,
      if (_isNewProject) ScloudLaunchSelectionConfig.database,
      ScloudLaunchSelectionConfig.codegen,
      if (_hasFlutterBuildScript) ScloudLaunchSelectionConfig.flutterBuild,
    ]);

    _configurationFormState = formState;
    _configurePreDeployHooks();
    _phase = LaunchPhase.configuration;

    // Compute required delta to focus the first config in the form
    final delta =
        formState.maxFocusedConfigIndex - formState.focusedConfigIndex + 1;
    formState.updateFocusedConfig(delta);
  }

  bool _checkHasFlutterBuildScript() {
    try {
      final pubspec = TenantProjectPubspec.fromProjectDir(
        Directory(projectDir),
      );
      return pubspec.hasFlutterBuildScript();
    } catch (_) {
      return false;
    }
  }

  void _configurePreDeployHooks() {
    final form = _configurationFormState;
    if (form == null) return;

    // Default flutter build to enabled only when
    // flutter build script is present.
    if (_hasFlutterBuildScript) {
      form.updateSelectedOption(
        ScloudLaunchSelectionConfig.flutterBuild,
        BoolFormConfigOption.enabled,
      );
    }
  }

  void goBackToProjectSelection() {
    _configurationFormState?.dispose();
    _configurationFormState = null;
    _phase = LaunchPhase.projectSelection;
  }

  /// Validates the project ID when new project is selected.
  bool _validateProjectSelection() {
    if (!_isNewProject) return true;

    final projectId = _newProjectIdValue ?? '';
    if (!isValidProjectIdFormat(projectId.trim())) {
      return false;
    }
    return true;
  }

  void markLaunchingProject() {
    _projectSetup = _buildProjectSetup();
    _phase = LaunchPhase.launching;
  }

  ProjectLaunch _buildProjectSetup() {
    final form = _configurationFormState;
    if (form == null) {
      throw StateError('Configuration form must be set before building setup.');
    }

    if (_isNewProject) {
      final projectId = _newProjectIdValue;
      if (projectId != null && projectId.isNotEmpty) {
        _projectSetup.projectId = projectId;
      }
      _projectSetup.preexistingProject = false;

      final planOption = form.getSelectedOptionFor<PlanFormConfigOption>(
        ScloudLaunchSelectionConfig.plan,
      );
      if (planOption != null) {
        _projectSetup.plan = PlanProfile.values.firstWhere(
          (final p) => p.name == planOption.name,
        );
      }

      final database = form.getSelectedOptionFor<BoolFormConfigOption>(
        ScloudLaunchSelectionConfig.database,
      );
      _projectSetup.enableDb = database == BoolFormConfigOption.enabled;
    } else {
      _projectSetup.projectId = _selectedProjectId;
      _projectSetup.preexistingProject = true;
    }

    final codegenOption = form.getSelectedOptionFor<BoolFormConfigOption>(
      ScloudLaunchSelectionConfig.codegen,
    );
    final codegenScript = 'serverpod generate';
    if (codegenOption == BoolFormConfigOption.enabled &&
        !_projectSetup.suggestedPreDeployScripts.contains(codegenScript)) {
      _projectSetup.suggestedPreDeployScripts.add(codegenScript);
    }

    final flutterBuild = form.getSelectedOptionFor<BoolFormConfigOption>(
      ScloudLaunchSelectionConfig.flutterBuild,
    );
    final flutterBuildScript = 'serverpod run flutter_build';
    if (flutterBuild == BoolFormConfigOption.enabled &&
        !_projectSetup.suggestedPreDeployScripts.contains(flutterBuildScript)) {
      _projectSetup.suggestedPreDeployScripts.add(flutterBuildScript);
    }

    return _projectSetup;
  }
}
