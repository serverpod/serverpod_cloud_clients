import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/prepare_project_files.dart'
    show TenantProject;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/flutter_app_identifier.dart';
import 'package:serverpod_cloud_cli/util/flutter_platform.dart';
import 'package:serverpod_cloud_cli/util/flutter_release_setup.dart';
import 'package:serverpod_cloud_cli/util/flutter_sdk_selector.dart';
import 'package:serverpod_cloud_cli/util/local_flutter_sdk.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';

import 'app_doctor_check.dart';

/// Checks of the local setup of a Flutter app that publishing depends on.
/// Reads the app's project files and the version of the local Flutter SDK;
/// it calls no service.
abstract class AppSetup {
  /// Selects the Flutter release version to build the app in
  /// [appDirectory] with, from [commandLineVersion], the app's pubspec,
  /// [configuredVersion], or the Flutter SDK installed on this machine,
  /// checked against the Flutter SDK constraint in the lockfile of
  /// [rootDirectory].
  /// [configuredVersion] comes from the project configuration file
  /// [configFileName]. See
  /// [FlutterSdkSelector.selectFlutterVersionWithSource].
  ///
  /// The local Flutter SDK is read with [readLocalFlutterVersion] only when
  /// no other source requests a version. Why it cannot be read is logged to
  /// [logger].
  ///
  /// [rootDirectory] is the workspace root when the app is resolved in a
  /// Dart workspace, or else [appDirectory].
  ///
  /// Returns the version with the source it was requested in, or null if
  /// none is requested.
  ///
  /// Throws [FailureException] if the lockfile or the app's pubspec cannot
  /// be read, or if the requested version is not a release version or is
  /// below the lockfile's Flutter SDK constraint.
  static Future<({String version, String source})?> selectFlutterVersion(
    Directory appDirectory, {
    required Directory rootDirectory,
    required String? commandLineVersion,
    required String? configuredVersion,
    required String configFileName,
    required LocalFlutterVersionReader readLocalFlutterVersion,
    required CommandLogger logger,
  }) async {
    final lockfileFlutterSdk = TenantProjectPubspec.readLockfileFlutterSdk(
      File(p.join(rootDirectory.path, 'pubspec.lock')),
    );
    if (lockfileFlutterSdk.issues.isNotEmpty) {
      throw FailureException(errors: lockfileFlutterSdk.issues);
    }

    final pubspecVersionConstraint = TenantProjectPubspec.fromProjectDir(
      appDirectory,
    ).environmentFlutterConstraint();

    ({String version, String source})? select({String? localVersion}) =>
        FlutterSdkSelector.selectFlutterVersionWithSource(
          commandLineVersion: commandLineVersion,
          scloudVersion: configuredVersion,
          scloudFileName: configFileName,
          pubspecVersionConstraint: pubspecVersionConstraint,
          localVersion: localVersion,
          lockVersionConstraint: lockfileFlutterSdk.constraint,
        );

    return select() ??
        select(
          localVersion: await readLocalFlutterVersion(appDirectory, logger),
        );
  }

  /// Checks whether the Flutter app in [appDirectory] is set up to be
  /// published for each of [platforms], or, when [platforms] is null, for
  /// the [defaultPlatforms] it has code for.
  ///
  /// The whole app gets a Flutter version check, which selects the version
  /// as publishing does, from [flutterVersionOverride], then the app's
  /// project files, then [configuredFlutterVersion], then the local Flutter
  /// SDK read with [readLocalFlutterVersion]. It warns when no
  /// version is requested. Why the local Flutter SDK cannot be read is
  /// logged to [logger].
  ///
  /// Each platform gets an app identifier check, which reads the identifier
  /// from [configuredAppIdentifiers] or else from the app's project files.
  /// Android also gets a release signing check and iOS an export compliance
  /// check. Messages name the project configuration file [configFileName].
  ///
  /// Returns the check of the whole app first, then the checks of each
  /// platform in platform order. A failed check is a result, not an error.
  ///
  /// Throws [FailureException] if [platforms] is null and the app has code
  /// for none of the [defaultPlatforms].
  static Future<List<AppDoctorCheck>> check(
    Directory appDirectory, {
    required List<FlutterPlatform> defaultPlatforms,
    Set<FlutterPlatform>? platforms,
    required Map<FlutterPlatform, String> configuredAppIdentifiers,
    required String configFileName,
    String? flutterVersionOverride,
    String? configuredFlutterVersion,
    required LocalFlutterVersionReader readLocalFlutterVersion,
    required CommandLogger logger,
  }) async {
    final requestedPlatforms =
        platforms ??
        TenantProject.presentDefaultPlatforms(appDirectory, defaultPlatforms);
    return [
      await _flutterVersionCheck(
        appDirectory,
        commandLineVersion: flutterVersionOverride,
        configuredVersion: configuredFlutterVersion,
        configFileName: configFileName,
        readLocalFlutterVersion: readLocalFlutterVersion,
        logger: logger,
      ),
      for (final platform in FlutterPlatform.values)
        if (requestedPlatforms.contains(platform)) ...[
          _check(
            platform,
            AppDoctorCheckKind.appIdentifier,
            () => resolveAppIdentifier(
              appDirectory,
              platform,
              configured: configuredAppIdentifiers[platform],
              configFileName: configFileName,
            ),
          ),
          if (platform == FlutterPlatform.android)
            _check(
              platform,
              AppDoctorCheckKind.releaseSigning,
              () =>
                  '${checkAndroidReleaseSigning(appDirectory)} signs release '
                  'builds on Serverpod Cloud with the release signing config',
            ),
          if (platform == FlutterPlatform.ios)
            _check(
              platform,
              AppDoctorCheckKind.exportCompliance,
              () =>
                  'ITSAppUsesNonExemptEncryption is '
                  '${readUsesNonExemptEncryption(appDirectory)}',
            ),
        ],
    ];
  }

  /// Checks the Flutter version the app in [appDirectory] would be built
  /// with. See [selectFlutterVersion].
  static Future<AppDoctorCheck> _flutterVersionCheck(
    Directory appDirectory, {
    required String? commandLineVersion,
    required String? configuredVersion,
    required String configFileName,
    required LocalFlutterVersionReader readLocalFlutterVersion,
    required CommandLogger logger,
  }) async {
    const kind = AppDoctorCheckKind.flutterVersion;
    final ({String version, String source})? selected;
    try {
      final isWorkspace = TenantProjectPubspec.fromProjectDir(
        appDirectory,
      ).isWorkspaceResolved();
      final rootDirectory = TenantProject.resolveLockfileDirectory(
        appDirectory,
        isWorkspaceResolved: isWorkspace,
      );
      selected = await selectFlutterVersion(
        appDirectory,
        rootDirectory: rootDirectory,
        commandLineVersion: commandLineVersion,
        configuredVersion: configuredVersion,
        configFileName: configFileName,
        readLocalFlutterVersion: readLocalFlutterVersion,
        logger: logger,
      );
    } on FailureException catch (e) {
      return _failed(null, kind, e);
    }
    if (selected == null) {
      return AppDoctorCheck(
        platform: null,
        kind: kind,
        status: AppDoctorCheckStatus.warning,
        detail:
            'No Flutter version is requested, so the builds use the latest '
            'stable release.',
        hint:
            'Set project.flutterSdk in $configFileName to the Flutter version '
            'the app is developed with.',
      );
    }
    return AppDoctorCheck(
      platform: null,
      kind: kind,
      status: AppDoctorCheckStatus.passed,
      detail: '${selected.version} (from ${selected.source})',
    );
  }

  /// Runs the check [kind] of [platform] with [inspect], which returns what
  /// it found, or throws [FailureException] with the problem and its fix.
  static AppDoctorCheck _check(
    FlutterPlatform platform,
    AppDoctorCheckKind kind,
    String Function() inspect,
  ) {
    try {
      return AppDoctorCheck(
        platform: platform,
        kind: kind,
        status: AppDoctorCheckStatus.passed,
        detail: inspect(),
      );
    } on FailureException catch (e) {
      return _failed(platform, kind, e);
    }
  }

  /// The failed check [kind] of [platform], with the problem and fix that
  /// [exception] describes.
  static AppDoctorCheck _failed(
    FlutterPlatform? platform,
    AppDoctorCheckKind kind,
    FailureException exception,
  ) {
    return AppDoctorCheck(
      platform: platform,
      kind: kind,
      status: AppDoctorCheckStatus.failed,
      detail: exception.errors.join(' '),
      hint: exception.hint,
    );
  }
}
