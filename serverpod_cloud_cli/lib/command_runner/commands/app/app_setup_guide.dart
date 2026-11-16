import 'dart:io';

import 'package:ground_control_client/ground_control_client.dart' show Client;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/prepare_project_files.dart'
    show TenantProject;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/non_interactive_exceptions.dart';
import 'package:serverpod_cloud_cli/util/flutter_app_identifier.dart';
import 'package:serverpod_cloud_cli/util/flutter_platform.dart';

import 'app_doctor_check.dart';
import 'app_ops.dart';
import 'app_setup.dart';

/// Guides the user through the setup of a Flutter app that publishing
/// depends on. It fixes what it can with the user's answers and records the
/// result on Serverpod Cloud.
abstract class AppSetupGuide {
  /// Sets up the Flutter app in [appDirectory] of project [projectId] to be
  /// published for each of [platforms], or, when [platforms] is null, for
  /// the [defaultPlatforms] it has code for.
  ///
  /// Each platform gets an app identifier check. The identifier comes from
  /// [configuredAppIdentifiers], or else from the app's project files. A
  /// valid identifier in [requestedAppIdentifiers] replaces the one in the
  /// project files. Without one, when the project files declare Flutter's
  /// `com.example` placeholder or an identifier that is not valid, it asks
  /// on [logger] for a new one, suggests `space.serverpod.` followed by
  /// [projectId], and writes the answer into the project files. When
  /// [canPrompt] is false, as with structured output, or the command runs
  /// with `--non-interactive`, the check fails instead, with a hint to pass
  /// `--android-package-name` or `--ios-bundle-id`. A passed check names
  /// the file it changed. It records
  /// a valid identifier on Serverpod Cloud through [cloudApiClient]. Android
  /// also gets a release signing check, which links to the docs when it
  /// fails. Messages name the project configuration file [configFileName].
  ///
  /// Returns the checks of each platform in platform order. A failed check
  /// is a result, not an error.
  ///
  /// Throws [FailureException] if [platforms] is null and the app has code
  /// for none of the [defaultPlatforms], or if an app identifier cannot be
  /// recorded.
  static Future<List<AppDoctorCheck>> setUp(
    Client cloudApiClient, {
    required Directory appDirectory,
    required List<FlutterPlatform> defaultPlatforms,
    Set<FlutterPlatform>? platforms,
    Map<FlutterPlatform, String> requestedAppIdentifiers = const {},
    required Map<FlutterPlatform, String> configuredAppIdentifiers,
    required bool canPrompt,
    required String configFileName,
    required String projectId,
    required CommandLogger logger,
  }) async {
    final requestedPlatforms =
        platforms ??
        TenantProject.presentDefaultPlatforms(appDirectory, defaultPlatforms);
    return [
      for (final platform in FlutterPlatform.values)
        if (requestedPlatforms.contains(platform)) ...[
          await _setUpAppIdentifier(
            cloudApiClient,
            appDirectory: appDirectory,
            platform: platform,
            requested: requestedAppIdentifiers[platform],
            configured: configuredAppIdentifiers[platform],
            canPrompt: canPrompt,
            configFileName: configFileName,
            projectId: projectId,
            logger: logger,
          ),
          if (platform == FlutterPlatform.android)
            AppSetup.releaseSigningCheck(appDirectory),
        ],
    ];
  }

  /// Checks the app identifier of [platform] and records it on Serverpod
  /// Cloud. See [setUp].
  static Future<AppDoctorCheck> _setUpAppIdentifier(
    Client cloudApiClient, {
    required Directory appDirectory,
    required FlutterPlatform platform,
    required String? requested,
    required String? configured,
    required bool canPrompt,
    required String configFileName,
    required String projectId,
    required CommandLogger logger,
  }) async {
    const kind = AppDoctorCheckKind.appIdentifier;
    final String identifier;
    final String? changedPath;
    try {
      (identifier, changedPath) = configured == null
          ? await _declaredAppIdentifier(
              appDirectory,
              platform,
              requested: requested,
              canPrompt: canPrompt,
              configFileName: configFileName,
              projectId: projectId,
              logger: logger,
            )
          : (
              _configuredAppIdentifier(
                platform,
                configured,
                requested: requested,
                configFileName: configFileName,
              ),
              null,
            );
    } on FailureException catch (e) {
      return AppDoctorCheck(
        platform: platform,
        kind: kind,
        status: AppDoctorCheckStatus.failed,
        detail: e.errors.join(' '),
        hint: e.hint,
      );
    }

    await AppOperations.setAppIdentifier(
      cloudApiClient,
      projectId: projectId,
      platform: platform,
      appIdentifier: identifier,
    );
    return AppDoctorCheck(
      platform: platform,
      kind: kind,
      status: AppDoctorCheckStatus.passed,
      detail: changedPath == null
          ? identifier
          : '$identifier (set in $changedPath)',
    );
  }

  /// The app identifier [configured] that the project configuration file
  /// [configFileName] sets for [platform].
  ///
  /// Throws [FailureException] if it is blank, not valid, Flutter's
  /// placeholder, or not the [requested] identifier, with a hint to change
  /// it in [configFileName].
  static String _configuredAppIdentifier(
    FlutterPlatform platform,
    String configured, {
    required String? requested,
    required String configFileName,
  }) {
    checkConfiguredAppIdentifier(
      platform,
      configured,
      configFileName: configFileName,
    );
    final identifier = configured.trim();
    final problem = appIdentifierProblem(platform, identifier);
    if (problem != null) {
      throw FailureException(
        error: _problemMessage(platform, identifier, problem),
        hint:
            'Set project.app.identifiers.${platform.name} in $configFileName '
            'to a valid ${appIdentifierName(platform)}. '
            '${_identifierRules(platform)}',
      );
    }
    if (requested != null && requested != identifier) {
      throw FailureException(
        error:
            '${_optionName(platform)} is $requested, but $configFileName '
            'sets project.app.identifiers.${platform.name} to $identifier.',
        hint:
            'Set project.app.identifiers.${platform.name} in $configFileName '
            'to $requested, or remove it to use the one the app declares.',
      );
    }
    return identifier;
  }

  /// The app identifier of the [platform] app in [appDirectory]: the
  /// [requested] one, or else the one the app declares. When the declared
  /// one is Flutter's placeholder or not valid, the identifier the user
  /// answers on [logger] is used. The identifier used replaces the declared
  /// one in the app's project files.
  ///
  /// Returns the identifier with the path of the file it was written to,
  /// or null when the file already declared it.
  ///
  /// Throws [FailureException] if the identifier cannot be read or changed,
  /// or if a new one is needed and [canPrompt] is false or the command runs
  /// with `--non-interactive`.
  static Future<(String, String?)> _declaredAppIdentifier(
    Directory appDirectory,
    FlutterPlatform platform, {
    required String? requested,
    required bool canPrompt,
    required String configFileName,
    required String projectId,
    required CommandLogger logger,
  }) async {
    final declared = readAppIdentifier(
      appDirectory,
      platform,
      configFileName: configFileName,
      allowPlaceholder: true,
    );
    final problem = appIdentifierProblem(platform, declared);
    final String identifier;
    if (requested != null) {
      identifier = requested;
    } else if (problem == null) {
      return (declared, null);
    } else {
      identifier = await _askAppIdentifier(
        platform,
        problemMessage: _problemMessage(platform, declared, problem),
        suggestion: suggestAppIdentifier(platform, projectId),
        canPrompt: canPrompt,
        logger: logger,
      );
    }
    if (identifier == declared) return (declared, null);
    final changedPath = writeAppIdentifier(
      appDirectory,
      platform,
      from: declared,
      to: identifier,
    );
    return (identifier, changedPath);
  }

  /// Asks on [logger] for the app identifier of [platform]: below
  /// [problemMessage], which says why a new identifier is needed, the user
  /// confirms [suggestion] or types one, with a hint on how to make one
  /// beneath it. A typed identifier that is not valid shows its problem and
  /// the user keeps typing.
  ///
  /// Throws [FailureException] with [problemMessage] and a hint to pass the
  /// identifier as an option if [canPrompt] is false or the command runs
  /// with `--non-interactive`. Throws [UserAbortException] if the user
  /// cancels.
  static Future<String> _askAppIdentifier(
    FlutterPlatform platform, {
    required String problemMessage,
    required String suggestion,
    required bool canPrompt,
    required CommandLogger logger,
  }) async {
    final name = appIdentifierName(platform);
    final shortName = _shortIdentifierName(platform);
    final optionRequired = FailureException(
      error: problemMessage,
      hint:
          'Pass the $name to publish the app with, such as '
          '${_optionName(platform)} $suggestion.',
    );
    if (!canPrompt) throw optionRequired;

    final label = '${shortName[0].toUpperCase()}${shortName.substring(1)}';
    final String? answer;
    try {
      answer = await logger.inputWithSuggestion(
        '$problemMessage\nChoose a new $shortName to publish the app with:',
        suggestion: suggestion,
        suggestionLabel: 'Use $suggestion',
        entryLabel: label,
        entryPlaceholder: 'Enter a different $shortName',
        hint: _identifierGuidance(platform).join('\n'),
        validate: (value) => switch (appIdentifierProblem(platform, value)) {
          null => null,
          final problem => _problemMessage(platform, value, problem),
        },
      );
    } on UserInputRequiredException {
      throw optionRequired;
    }
    if (answer == null) throw UserAbortException();
    return answer;
  }

  /// How to make an app identifier of [platform], one line per sentence.
  static List<String> _identifierGuidance(FlutterPlatform platform) {
    final store = switch (platform) {
      FlutterPlatform.android => 'Google Play',
      FlutterPlatform.ios => 'the App Store',
      FlutterPlatform.linux ||
      FlutterPlatform.macos ||
      FlutterPlatform.windows => throw ArgumentError.value(
        platform,
        'platform',
        'has no app identifier to publish with',
      ),
    };
    return [
      'Use a reverse domain you own, like com.yourcompany.app.',
      'It must be unique on $store and cannot change after the first '
          'publish.',
      _identifierRules(platform),
    ];
  }

  /// The name of the app identifier of [platform] without the platform,
  /// like "bundle ID".
  static String _shortIdentifierName(FlutterPlatform platform) {
    return switch (platform) {
      FlutterPlatform.android => 'package name',
      FlutterPlatform.ios => 'bundle ID',
      FlutterPlatform.linux ||
      FlutterPlatform.macos ||
      FlutterPlatform.windows => throw ArgumentError.value(
        platform,
        'platform',
        'has no app identifier to publish with',
      ),
    };
  }

  /// The option of `app setup` that sets the app identifier of [platform].
  static String _optionName(FlutterPlatform platform) {
    return switch (platform) {
      FlutterPlatform.android => '--android-package-name',
      FlutterPlatform.ios => '--ios-bundle-id',
      FlutterPlatform.linux ||
      FlutterPlatform.macos ||
      FlutterPlatform.windows => throw ArgumentError.value(
        platform,
        'platform',
        'has no app identifier to publish with',
      ),
    };
  }

  /// A sentence saying that [identifier], the app identifier of [platform],
  /// has [problem].
  static String _problemMessage(
    FlutterPlatform platform,
    String identifier,
    String problem,
  ) {
    final name = appIdentifierName(platform);
    return identifier.isEmpty
        ? 'The $name $problem.'
        : 'The $name $identifier $problem.';
  }

  /// What a valid app identifier of [platform] consists of.
  static String _identifierRules(FlutterPlatform platform) {
    return switch (platform) {
      FlutterPlatform.android =>
        'An Android package name has two or more parts separated by '
            'periods. Each part starts with a letter and has only letters, '
            'digits and underscores.',
      FlutterPlatform.ios =>
        'An iOS bundle ID has only letters, digits, hyphens and periods.',
      FlutterPlatform.linux ||
      FlutterPlatform.macos ||
      FlutterPlatform.windows => throw ArgumentError.value(
        platform,
        'platform',
        'has no app identifier to publish with',
      ),
    };
  }
}
