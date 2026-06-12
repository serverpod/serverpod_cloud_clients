import 'package:serverpod_cloud_cli/commands/launch/tui/app.dart';
import 'package:serverpod_cloud_cli/commands/launch/tui/state.dart';
import 'package:serverpod_tui/serverpod_tui.dart';

/// State holder for [ScloudLaunchApp].
class LaunchAppStateHolder extends TuiAppStateHolder<LaunchConfigState> {
  LaunchAppStateHolder(this._state);

  final LaunchConfigState _state;

  ScloudLaunchAppState? _widgetState;

  @override
  LaunchConfigState get state => _state;

  @override
  TuiAppState? get widgetState => _widgetState;

  @override
  void attach(final ScloudLaunchAppState widgetState) {
    _widgetState = widgetState;
  }

  @override
  void detach(final ScloudLaunchAppState widgetState) {
    if (_widgetState == widgetState) _widgetState = null;
  }
}
