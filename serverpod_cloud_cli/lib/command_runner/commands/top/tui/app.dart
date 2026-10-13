import 'package:nocterm/nocterm.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/top/tui/main_screen.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/top/tui/state_holder.dart';
import 'package:serverpod_tui/serverpod_tui.dart';

/// Root TUI component for `scloud top`.
class ScloudTopApp extends TuiApp<TopAppStateHolder> {
  const ScloudTopApp({super.key, required super.holder, required this.onQuit});

  final VoidCallback onQuit;

  @override
  TuiAppState createState() {
    return ScloudTopAppState();
  }
}

class ScloudTopAppState extends TuiAppState<ScloudTopApp> {
  final ScrollController _logScrollController = ScrollController();

  @override
  void dispose() {
    _logScrollController.dispose();
    super.dispose();
  }

  @override
  void onExit() {
    component.onQuit();
  }

  @override
  Component buildApp(BuildContext context) {
    return MainScreen(
      state: component.holder.state,
      logScrollController: _logScrollController,
      onQuit: component.onQuit,
    );
  }
}
