import 'dart:io';

import 'package:ground_control_client/ground_control_client.dart'
    show AppPlatform, AppPublishingSetup;
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/prepare_project_files.dart'
    show TenantProject;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/shared/helpers/console_urls.dart';
import 'package:serverpod_cloud_cli/util/flutter_app_identifier.dart';
import 'package:serverpod_cloud_cli/util/flutter_platform.dart';
import 'package:serverpod_cloud_cli/util/flutter_release_setup.dart';
import 'package:serverpod_cloud_cli/util/flutter_sdk_selector.dart';
import 'package:serverpod_cloud_cli/util/ios_purpose_strings.dart';
import 'package:serverpod_cloud_cli/util/local_flutter_sdk.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';

import 'app_doctor_check.dart';

/// Checks of the setup of a Flutter app that publishing depends on. Reads
/// the app's project files and the version of the local Flutter SDK; it
/// calls no service.
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
  /// Each platform gets a console setup check, which fails while
  /// [publishingSetup] of project [projectId] lacks a part the platform
  /// needs, and an app identifier check, which reads the identifier from
  /// [configuredAppIdentifiers] or else from the app's project files.
  /// Then each platform gets the checks of its project files, see
  /// [checkProjectFiles]. Messages name the project configuration file
  /// [configFileName].
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
    required String projectId,
    required AppPublishingSetup publishingSetup,
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
          _consoleSetupCheck(platform, projectId, publishingSetup),
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
          ..._projectFileChecks(appDirectory, platform),
        ],
    ];
  }

  /// Checks the project files of the Flutter app in [appDirectory] for each
  /// of [platforms]: the parts of the [check]s that need neither the
  /// console nor the app identifier and Flutter version that publishing
  /// resolves itself.
  ///
  /// Android gets a release signing check. iOS gets an export compliance
  /// check, which warns while the app does not declare whether it uses
  /// encryption, and a check of privacy descriptions, which fails for each
  /// purpose string that the app's code needs and the Info.plist lacks or
  /// leaves empty. Last, each platform gets an app icon check, which warns
  /// while the app has the icon of `flutter create`.
  ///
  /// Returns the checks of each platform in platform order. A failed check
  /// is a result, not an error.
  static List<AppDoctorCheck> checkProjectFiles(
    Directory appDirectory, {
    required Set<FlutterPlatform> platforms,
  }) {
    return [
      for (final platform in FlutterPlatform.values)
        if (platforms.contains(platform))
          ..._projectFileChecks(appDirectory, platform),
    ];
  }

  /// The checks of the project files of [platform] of the app in
  /// [appDirectory]. See [checkProjectFiles].
  static List<AppDoctorCheck> _projectFileChecks(
    Directory appDirectory,
    FlutterPlatform platform,
  ) {
    return [
      if (platform == FlutterPlatform.android)
        releaseSigningCheck(appDirectory),
      if (platform == FlutterPlatform.ios) ...[
        _exportComplianceCheck(appDirectory),
        ..._privacyDescriptionChecks(appDirectory),
      ],
      _appIconCheck(appDirectory, platform),
    ];
  }

  /// Checks whether the iOS app in [appDirectory] answers the export
  /// compliance question of App Store Connect. A warning links to the docs on
  /// export compliance. See [readUsesNonExemptEncryption].
  static AppDoctorCheck _exportComplianceCheck(Directory appDirectory) {
    const kind = AppDoctorCheckKind.exportCompliance;
    final bool usesNonExemptEncryption;
    try {
      usesNonExemptEncryption = readUsesNonExemptEncryption(appDirectory);
    } on FailureException catch (exception) {
      return AppDoctorCheck(
        platform: FlutterPlatform.ios,
        kind: kind,
        status: AppDoctorCheckStatus.warning,
        detail: exception.errors.join(' '),
        hint: exception.hint,
      );
    }

    return AppDoctorCheck(
      platform: FlutterPlatform.ios,
      kind: kind,
      status: AppDoctorCheckStatus.passed,
      detail: usesNonExemptEncryption
          ? 'Uses non-exempt encryption'
          : 'Uses no non-exempt encryption',
    );
  }

  /// Checks whether the iOS app in [appDirectory] has a purpose string in
  /// its Info.plist for each privacy sensitive feature that its code uses:
  /// the packages in its lockfile, the iOS code of its plugins, and its own
  /// native code. See [findIosPurposeStringIssues].
  ///
  /// Returns one failed check for each purpose string that is missing or
  /// empty, a failed check when the Info.plist cannot be read, a warning
  /// when the lockfile cannot be read, or else a single passed check.
  static List<AppDoctorCheck> _privacyDescriptionChecks(
    Directory appDirectory,
  ) {
    const kind = AppDoctorCheckKind.privacyDescriptions;
    final Set<String> packages;
    try {
      packages = _readPackageNames(appDirectory);
    } on FailureException catch (exception) {
      return [
        AppDoctorCheck(
          platform: FlutterPlatform.ios,
          kind: kind,
          status: AppDoctorCheckStatus.warning,
          detail: 'Cannot check: ${exception.errors.join(' ')}',
          hint: exception.hint,
        ),
      ];
    }

    final List<IosPurposeStringIssue> issues;
    try {
      issues = findIosPurposeStringIssues(appDirectory, packages: packages);
    } on FailureException catch (exception) {
      return [_failed(FlutterPlatform.ios, kind, exception)];
    }
    if (issues.isEmpty) {
      return const [
        AppDoctorCheck(
          platform: FlutterPlatform.ios,
          kind: kind,
          status: AppDoctorCheckStatus.passed,
          detail: 'Set for each feature the app uses',
        ),
      ];
    }
    return [
      for (final issue in issues)
        AppDoctorCheck(
          platform: FlutterPlatform.ios,
          kind: kind,
          status: AppDoctorCheckStatus.failed,
          detail: issue.isEmpty
              ? '${issue.key} is empty.'
              : '${issue.key} is missing.',
          hint: [
            issue.isEmpty
                ? 'App Store Connect rejects a build with an empty purpose '
                      'string.'
                : 'App Store Connect rejects the build without it.',
            'Needed for ${issue.feature} by: ${issue.usedBy.join(', ')}.',
            issue.isEmpty
                ? 'Set it in $iosInfoPlistPath to why the app needs it.'
                : 'Add it to $iosInfoPlistPath with why the app needs it.',
          ].join('\n'),
        ),
    ];
  }

  /// Reads the names of the packages in the lockfile of the app in
  /// [appDirectory], or of its workspace when the app is resolved in one.
  ///
  /// Throws [FailureException] if the app's pubspec or the lockfile cannot
  /// be read.
  static Set<String> _readPackageNames(Directory appDirectory) {
    final isWorkspace = TenantProjectPubspec.fromProjectDir(
      appDirectory,
    ).isWorkspaceResolved();
    final rootDirectory = TenantProject.resolveLockfileDirectory(
      appDirectory,
      isWorkspaceResolved: isWorkspace,
    );
    return readLockfilePackageNames(
      File(p.join(rootDirectory.path, 'pubspec.lock')),
    );
  }

  /// Checks whether the Android app in [appDirectory] signs its release
  /// builds on Serverpod Cloud with the keystore the build provides. A
  /// failure links to the docs on release signing. See
  /// [checkAndroidReleaseSigning].
  static AppDoctorCheck releaseSigningCheck(Directory appDirectory) {
    return _check(
      FlutterPlatform.android,
      AppDoctorCheckKind.releaseSigning,
      () => 'Set up in ${checkAndroidReleaseSigning(appDirectory)}',
    );
  }

  /// Checks whether [publishingSetup] of project [projectId] has every part
  /// that publishing for [platform] needs. A failure links to the setup
  /// guide of [platform] in the console.
  static AppDoctorCheck _consoleSetupCheck(
    FlutterPlatform platform,
    String projectId,
    AppPublishingSetup publishingSetup,
  ) {
    const kind = AppDoctorCheckKind.consoleSetup;
    final appPlatform = switch (platform) {
      FlutterPlatform.android => AppPlatform.android,
      FlutterPlatform.ios => AppPlatform.ios,
      FlutterPlatform.linux ||
      FlutterPlatform.macos ||
      FlutterPlatform.windows => null,
    };
    if (appPlatform == null) {
      return AppDoctorCheck(
        platform: platform,
        kind: kind,
        status: AppDoctorCheckStatus.failed,
        detail: 'Publishing for ${platform.name} is not supported yet.',
      );
    }
    final awaitsOnlyGooglePlay =
        appPlatform == AppPlatform.android &&
        publishingSetup.android.signing != null &&
        publishingSetup.android.store == null;
    if (awaitsOnlyGooglePlay) {
      return AppDoctorCheck(
        platform: platform,
        kind: kind,
        status: AppDoctorCheckStatus.failed,
        detail: 'Serverpod Cloud is still creating Google Play access.',
        hint: 'This needs nothing from you.',
      );
    }
    final isSetUp = switch (appPlatform) {
      AppPlatform.ios => publishingSetup.ios.store != null,
      AppPlatform.android =>
        publishingSetup.android.signing != null &&
            publishingSetup.android.store != null,
    };
    if (!isSetUp) {
      return AppDoctorCheck(
        platform: platform,
        kind: kind,
        status: AppDoctorCheckStatus.failed,
        detail: 'Not set up yet.',
        hint: 'Finish it here: ${getAppStoreSetupUrl(projectId, appPlatform)}',
      );
    }
    return AppDoctorCheck(
      platform: platform,
      kind: kind,
      status: AppDoctorCheckStatus.passed,
      detail: 'Set up',
    );
  }

  /// Checks whether the [platform] app in [appDirectory] has its own icon.
  /// It warns while the app has the icon of `flutter create`.
  static AppDoctorCheck _appIconCheck(
    Directory appDirectory,
    FlutterPlatform platform,
  ) {
    const kind = AppDoctorCheckKind.appIcon;
    if (hasDefaultAppIcon(appDirectory, platform)) {
      return AppDoctorCheck(
        platform: platform,
        kind: kind,
        status: AppDoctorCheckStatus.warning,
        detail: 'The app uses the default Flutter icon.',
        hint: 'Learn more: $appIconDocsUrl',
      );
    }
    return AppDoctorCheck(
      platform: platform,
      kind: kind,
      status: AppDoctorCheckStatus.passed,
      detail: 'Not the default Flutter icon',
    );
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
        detail: 'Not pinned, so builds use the latest stable release.',
        hint:
            'Request a version with --flutter-version, or pin one in '
            "environment.flutter of the app's pubspec.yaml.",
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
