import 'dart:async';

import 'package:serverpod_cloud_cli/command_runner/commands/top/top_snapshot.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/top/tui/app.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/top/tui/state.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/top/tui/state_holder.dart';
import 'package:serverpod_tui/serverpod_tui.dart';

/// Shows the `top` screen with [initial] and redraws it for each of
/// [snapshots], until the user quits.
///
/// If [snapshots] ends with an error, closes the screen and throws that error.
Future<void> runTopTui({
  required final String baseCommand,
  required final String projectId,
  required final TopSnapshot initial,
  required final Stream<TopSnapshot> snapshots,
  required final bool utc,
  required final Duration interval,
}) async {
  final TopState state = TopState(
    baseCommand: baseCommand,
    projectId: projectId,
    snapshot: initial,
    utc: utc,
    interval: interval,
  );
  final TopAppStateHolder holder = TopAppStateHolder(state);
  (Object, StackTrace)? failure;
  final StreamSubscription<TopSnapshot> subscription = snapshots.listen(
    (final TopSnapshot snapshot) {
      state.snapshot = snapshot;
      holder.markDirty();
    },
    onError: (final Object error, final StackTrace stackTrace) {
      failure = (error, stackTrace);
      shutdownTuiApp();
    },
    cancelOnError: true,
  );

  await runTuiApp(
    ScloudTopApp(
      holder: holder,
      onQuit: () {
        unawaited(subscription.cancel());
        shutdownTuiApp();
      },
    ),
    enableHotReload: false,
  );

  final (Object, StackTrace)? ended = failure;
  if (ended != null) {
    Error.throwWithStackTrace(ended.$1, ended.$2);
  }
}
