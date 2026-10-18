import 'package:ground_control_client/ground_control_client.dart';

/// How good or bad a status is, for the output to pick a color from.
enum StatusTone { good, warning, bad, neutral }

/// The glyph, label and tone that a status is displayed with.
typedef StatusLook = ({String glyph, String label, StatusTone tone});

/// The glyph, label and tone that a [CapsuleState] is displayed with.
StatusLook capsuleStateLook(final CapsuleState state) {
  return switch (state) {
    CapsuleState.ready => (glyph: '●', label: 'Running', tone: StatusTone.good),
    CapsuleState.progressing => (
      glyph: '◐',
      label: 'Deploying',
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
