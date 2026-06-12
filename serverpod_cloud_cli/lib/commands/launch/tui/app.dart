import 'package:nocterm/nocterm.dart';
import 'package:serverpod_cloud_cli/commands/launch/tui/main_screen.dart';
import 'package:serverpod_cloud_cli/commands/launch/tui/state_holder.dart';
import 'package:serverpod_tui/serverpod_tui.dart';

/// Root TUI component for `scloud launch`.
class ScloudLaunchApp extends TuiApp<LaunchAppStateHolder> {
  const ScloudLaunchApp({
    super.key,
    required super.holder,
    required this.onLaunch,
    required this.onQuit,
  });

  final VoidCallback onLaunch;
  final VoidCallback onQuit;

  @override
  TuiAppState createState() => ScloudLaunchAppState();
}

class ScloudLaunchAppState extends TuiAppState<ScloudLaunchApp> {
  final _formScrollController = ScrollController();
  final _logScrollController = ScrollController();

  @override
  void dispose() {
    _formScrollController.dispose();
    _logScrollController.dispose();
    super.dispose();
  }

  @override
  Component buildApp(final BuildContext context) {
    return MainScreen(
      holder: component.holder,
      logScrollController: _logScrollController,
      formScrollController: _formScrollController,
      onLaunch: component.onLaunch,
      onQuit: component.onQuit,
    );
  }
}
