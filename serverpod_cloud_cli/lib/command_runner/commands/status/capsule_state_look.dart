import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/status/status_ops.dart'
    show FinalDeployProgressStatus;

/// How good or bad a status is, for the output to pick a color from.
enum StatusTone { good, warning, bad, neutral }

/// The glyph, label and tone that a status is displayed with.
typedef StatusLook = ({String glyph, String label, StatusTone tone});

/// The glyph, label and tone that a [CapsuleState] is displayed with.
///
/// A progressing [state] reads "Deploying" when [deploying] is true and
/// "Starting" otherwise. [deploying] does not affect any other state.
StatusLook capsuleStateLook(
  final CapsuleState state, {
  final bool deploying = false,
}) {
  return switch (state) {
    CapsuleState.ready => (glyph: '●', label: 'Running', tone: StatusTone.good),
    CapsuleState.progressing => (
      glyph: '◐',
      label: deploying ? 'Deploying' : 'Starting',
      tone: StatusTone.warning,
    ),
    CapsuleState.degraded => (
      glyph: '◑',
      label: 'Degraded',
      tone: StatusTone.warning,
    ),
    CapsuleState.unavailable => (
      glyph: '✖',
      label: 'Down',
      tone: StatusTone.bad,
    ),
    CapsuleState.suspended => (
      glyph: '⏸',
      label: 'Suspended',
      tone: StatusTone.neutral,
    ),
    CapsuleState.idle => (
      glyph: '☾',
      label: 'Idling',
      tone: StatusTone.neutral,
    ),
    CapsuleState.notProvisioned => (
      glyph: '○',
      label: 'Not deployed',
      tone: StatusTone.neutral,
    ),
    CapsuleState.unknown => (
      glyph: '?',
      label: 'Unknown',
      tone: StatusTone.warning,
    ),
  };
}

/// Whether a rollout is in flight for [runtime]: the deployment reports an
/// incoming revision, an incoming deploy attempt is known, or the newest
/// deploy attempt has not reached a final status. The newest attempt is the
/// latest attempt, or the serving attempt when no other attempt is newer.
bool isDeploying(final CapsuleRuntimeStatus runtime) {
  if (runtime.status.deployment?.incoming != null) return true;
  if (runtime.incoming != null) return true;
  final status = runtime.latestAttempt?.status ?? runtime.serving?.status;
  return status?.isFinal == false;
}
