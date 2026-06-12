import 'package:nocterm/nocterm.dart';
import 'package:serverpod_cloud_cli/commands/launch/tui/state.dart';
import 'package:serverpod_cloud_cli/commands/launch/tui/state_holder.dart';
import 'package:serverpod_tui/serverpod_tui.dart';

class MainScreen extends StatelessComponent {
  const MainScreen({
    super.key,
    required this.holder,
    required this.formScrollController,
    required this.logScrollController,
    required this.onLaunch,
    required this.onQuit,
  });

  final LaunchAppStateHolder holder;
  final ScrollController formScrollController;
  final ScrollController logScrollController;
  final VoidCallback onLaunch;
  final VoidCallback onQuit;

  @override
  Component build(final BuildContext context) {
    final state = holder.state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: BorderedBox(
            child: Column(
              children: [
                _buildHeader(state),
                Expanded(child: _buildBody(state)),
              ],
            ),
          ),
        ),
        _buildButtonBar(state),
      ],
    );
  }

  Component _buildHeader(final LaunchConfigState state) {
    final title = switch (state.phase) {
      LaunchPhase.projectSelection => 'Select project',
      LaunchPhase.configuration => 'Configure project',
      LaunchPhase.launching => 'Launching project',
    };

    return Container(
      padding: const EdgeInsets.only(bottom: 1),
      child: Text(
        title,
        style: const TextStyle(
          color: Color.defaultColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Component _buildBody(final LaunchConfigState state) {
    return switch (state.phase) {
      LaunchPhase.projectSelection => _buildProjectSelectionForm(),
      LaunchPhase.configuration => _buildConfigurationForm(state),
      LaunchPhase.launching => _buildLogView(),
    };
  }

  Component _buildProjectSelectionForm() {
    return Form(
      state: holder.state.projectSelectionFormState,
      scrollController: formScrollController,
      rebuild: holder.markDirty,
      onSubmit: () {
        holder.state.goToConfiguration();
        holder.markDirty();
      },
    );
  }

  Component _buildConfigurationForm(final LaunchConfigState state) {
    final formState = state.configurationFormState;
    if (formState == null) return const SizedBox.shrink();

    return Form(
      state: formState,
      scrollController: formScrollController,
      rebuild: holder.markDirty,
    );
  }

  Component _buildButtonBar(final LaunchConfigState state) {
    return switch (state.phase) {
      LaunchPhase.projectSelection => _buildProjectSelectionButtonBar(state),
      LaunchPhase.configuration ||
      LaunchPhase.launching => _buildConfigurationButtonBar(state),
    };
  }

  Component _buildProjectSelectionButtonBar(final LaunchConfigState state) {
    final formState = state.projectSelectionFormState;
    return ButtonBar(
      buttons: [
        Button(
          name: 'Continue',
          activationChar: 'Enter',
          enabled: true,
          activationKeys: const [LogicalKey.enter],
          onActivate: (_) {
            state.goToConfiguration();
            holder.markDirty();
          },
        ),
        _buildNavigateButton(
          form: formState,
          enabled: true,
          scrollOnUpDown: false,
        ),
        Button(
          name: 'Select',
          activationChar: 'Space',
          enabled: true,
          activationKeys: const [LogicalKey.space],
          onActivate: (_) {
            formState.selectConfigOption();
            holder.markDirty();
          },
        ),
        Button(
          name: 'Quit',
          activationChar: 'Esc',
          activationKeys: const [LogicalKey.escape],
          onActivate: (_) {
            onQuit.call();
          },
        ),
        const Tip('Click to select'),
      ],
    );
  }

  Component _buildConfigurationButtonBar(final LaunchConfigState state) {
    final enabled = state.phase != LaunchPhase.launching;
    final form = state.configurationFormState!;
    return ButtonBar(
      buttons: [
        Button(
          name: 'Continue',
          activationChar: 'Enter',
          enabled: enabled,
          activationKeys: const [LogicalKey.enter],
          onActivate: (_) {
            state.markLaunchingProject();
            holder.markDirty();
            onLaunch.call();
          },
        ),
        Button(
          name: 'Back',
          activationChar: 'B',
          enabled: enabled,
          activationKeys: const [LogicalKey.keyB],
          onActivate: (_) {
            state.goBackToProjectSelection();
            holder.markDirty();
          },
        ),
        _buildNavigateButton(
          form: form,
          enabled: enabled,
          scrollOnUpDown: true,
        ),
        Button(
          name: 'Select',
          activationChar: 'Space',
          enabled: enabled,
          activationKeys: const [LogicalKey.space],
          onActivate: (_) {
            form.selectConfigOption();
            holder.markDirty();
          },
        ),
        Button(
          name: 'Quit',
          activationChar: 'Esc',
          enabled: true,
          activationKeys: const [LogicalKey.escape],
          onActivate: (_) {
            onQuit.call();
          },
        ),
        const Tip('Click to select'),
      ],
    );
  }

  Component _buildNavigateButton({
    required final FormState form,
    required final bool enabled,
    required final bool scrollOnUpDown,
  }) {
    return Button(
      name: 'Navigate',
      activationChar: '←↑↓→',
      enabled: enabled,
      activationKeys: const [
        LogicalKey.arrowUp,
        LogicalKey.arrowDown,
        LogicalKey.arrowLeft,
        LogicalKey.arrowRight,
      ],
      onActivate: (final key) {
        switch (key) {
          case LogicalKey.arrowLeft:
            form.updateFocusedConfigOption(-1);
            break;
          case LogicalKey.arrowRight:
            form.updateFocusedConfigOption(1);
            break;
          case LogicalKey.arrowUp:
            form.updateFocusedConfig(-1);
            if (scrollOnUpDown &&
                form.focusedConfigIndex == form.maxFocusedConfigIndex) {
              formScrollController.scrollToEnd();
            } else if (scrollOnUpDown) {
              formScrollController.scrollUp(3);
            }
            break;
          case LogicalKey.arrowDown:
            form.updateFocusedConfig(1);
            if (scrollOnUpDown && form.focusedConfigIndex == 0) {
              formScrollController.scrollToStart();
            } else if (scrollOnUpDown) {
              formScrollController.scrollDown(3);
            }
            break;
        }
        holder.markDirty();
      },
    );
  }

  Component _buildLogView() {
    return LogViewerWidget(
      state: holder.state,
      scrollController: logScrollController,
      keyboardScrollable: true,
    );
  }
}
