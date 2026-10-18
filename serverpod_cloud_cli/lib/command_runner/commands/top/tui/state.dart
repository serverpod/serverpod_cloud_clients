import 'package:serverpod_cloud_cli/command_runner/commands/top/top_snapshot.dart';
import 'package:serverpod_tui/serverpod_tui.dart';

/// Central state for [ScloudTopApp] rendered by nocterm.
class TopState extends TuiState {
  TopState({
    required this.baseCommand,
    required this.projectId,
    required this.snapshot,
    required this.utc,
    required this.interval,
  });

  final String baseCommand;
  final String projectId;
  final bool utc;

  /// How often the status refreshes.
  final Duration interval;

  TopSnapshot snapshot;

  @override
  final BoundedQueueList<Object> logHistory = BoundedQueueList<Object>(0);

  @override
  final Map<String, TrackedOperation> activeOperations = {};
}
