import 'package:serverpod_cloud_cli/command_runner/commands/top/tui/app.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/top/tui/state.dart';
import 'package:serverpod_tui/serverpod_tui.dart';

/// State holder for [ScloudTopApp].
class TopAppStateHolder extends TuiAppStateHolder<TopState> {
  TopAppStateHolder(this._state);

  final TopState _state;

  ScloudTopAppState? _widgetState;

  @override
  TopState get state {
    return _state;
  }

  @override
  TuiAppState? get widgetState {
    return _widgetState;
  }

  @override
  void attach(ScloudTopAppState widgetState) {
    _widgetState = widgetState;
  }

  @override
  void detach(ScloudTopAppState widgetState) {
    if (_widgetState == widgetState) {
      _widgetState = null;
    }
  }
}
