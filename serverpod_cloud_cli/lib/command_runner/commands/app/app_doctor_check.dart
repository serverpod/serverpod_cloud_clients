import 'package:ground_control_client/ground_control_client.dart'
    show SerializableModel;
import 'package:serverpod_cloud_cli/util/flutter_platform.dart';

/// A part of the app's setup that publishing depends on.
enum AppDoctorCheckKind {
  /// A Flutter release version is requested for the builds, and the app's
  /// packages allow it.
  flutterVersion,

  /// The iOS bundle ID or Android package name is set, and is not
  /// Flutter's `com.example` placeholder.
  appIdentifier,

  /// Android release builds on Serverpod Cloud are signed with the upload
  /// keystore the build provides through environment variables.
  releaseSigning,

  /// The iOS app answers the export compliance question with
  /// `ITSAppUsesNonExemptEncryption`.
  exportCompliance,
}

/// The outcome of a check of `app doctor`.
enum AppDoctorCheckStatus {
  /// The app is set up as publishing needs.
  passed,

  /// The app can be published, but the result may not be what is wanted.
  warning,

  /// Publishing fails, or publishes a broken app, until this is fixed.
  failed,
}

/// The result of one check of `app doctor`.
class AppDoctorCheck implements SerializableModel {
  /// The platform the check is for. Null for a check of the whole app.
  final FlutterPlatform? platform;

  /// What the check looks at.
  final AppDoctorCheckKind kind;

  /// The outcome of the check.
  final AppDoctorCheckStatus status;

  /// What the check found: the setting when it passed, else the problem.
  final String detail;

  /// How to address a warning or a failure. Null when the check passed.
  final String? hint;

  const AppDoctorCheck({
    required this.platform,
    required this.kind,
    required this.status,
    required this.detail,
    this.hint,
  });

  @override
  Map<String, Object?> toJson() {
    return {
      'platform': platform,
      'check': kind,
      'status': status,
      'detail': detail,
      if (hint != null) 'hint': hint,
    };
  }
}
