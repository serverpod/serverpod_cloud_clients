import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/constants.dart'
    show ProjectConfigFileConstants;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/flutter_platform.dart';

/// Reads the app identifier the Flutter app in [appDirectory] declares for
/// [platform]: the iOS bundle ID of the Xcode project's Runner app target,
/// or the Android application ID of the app module's Gradle build file.
///
/// Throws [FailureException] if the file holding it is missing, declares no
/// identifier, declares more than one, as an app with flavors does, takes it
/// from a variable or another unquoted value, or declares Flutter's
/// `com.example` placeholder. Its hint says the identifier can be set in the
/// project configuration file [configFileName] instead.
/// Throws [ArgumentError] for a platform that apps cannot be published for.
String readAppIdentifier(
  Directory appDirectory,
  FlutterPlatform platform, {
  String configFileName = ProjectConfigFileConstants.defaultFileName,
}) {
  return switch (platform) {
    FlutterPlatform.ios => _readBundleId(appDirectory, configFileName),
    FlutterPlatform.android => _readApplicationId(appDirectory, configFileName),
    FlutterPlatform.linux ||
    FlutterPlatform.macos ||
    FlutterPlatform.windows => throw ArgumentError.value(
      platform,
      'platform',
      'has no app identifier to publish with',
    ),
  };
}

/// Returns the app identifier of [platform]: [configured] when the project
/// configuration file [configFileName] sets one, or else the one the app in
/// [appDirectory] declares.
///
/// Throws [FailureException] if it cannot be read, is blank, or is
/// Flutter's `com.example` placeholder. See [readAppIdentifier] and
/// [checkConfiguredAppIdentifier].
String resolveAppIdentifier(
  Directory appDirectory,
  FlutterPlatform platform, {
  required String? configured,
  required String configFileName,
}) {
  if (configured == null) {
    return readAppIdentifier(
      appDirectory,
      platform,
      configFileName: configFileName,
    );
  }
  checkConfiguredAppIdentifier(
    platform,
    configured,
    configFileName: configFileName,
  );
  return configured;
}

/// Checks the app identifier [identifier] that the project configuration
/// file [configFileName] sets for [platform].
///
/// Throws [FailureException] if it is blank or Flutter's `com.example`
/// placeholder, with a hint to set it to the app's own identifier.
void checkConfiguredAppIdentifier(
  FlutterPlatform platform,
  String identifier, {
  required String configFileName,
}) {
  final name = appIdentifierName(platform);
  if (identifier.trim().isEmpty) {
    throw FailureException(
      error:
          '$configFileName sets project.appIdentifiers.${platform.name} to an '
          'empty value.',
      hint:
          'Set project.appIdentifiers.${platform.name} in $configFileName to '
          "the app's own $name, or remove it to use the one the app declares.",
    );
  }
  if (!_isPlaceholder(identifier)) return;
  throw FailureException(
    error:
        "The $name $identifier is Flutter's placeholder: $configFileName sets "
        'project.appIdentifiers.${platform.name} to it.',
    hint:
        'Set project.appIdentifiers.${platform.name} in $configFileName to the '
        "app's own $name.",
  );
}

const _xcodeProjectPath = 'ios/Runner.xcodeproj/project.pbxproj';

const _gradleBuildPaths = [
  'android/app/build.gradle.kts',
  'android/app/build.gradle',
];

/// A `buildSettings` block, up to the `};` that closes it.
final _buildSettings = RegExp(
  r'buildSettings\s*=\s*\{(.*?)\}\s*;',
  dotAll: true,
);

/// The Info.plist of the Runner app target. Extensions and the test target
/// that share the Xcode project have their own, or none.
final _appTargetInfoPlist = RegExp(
  r'INFOPLIST_FILE\s*=\s*"?Runner/Info\.plist"?\s*;',
);

final _bundleIdSetting = RegExp(
  r'PRODUCT_BUNDLE_IDENTIFIER\s*=\s*"?([^";]+?)"?\s*;',
);

/// An `applicationId` setting and its value, but not a quoted key of the
/// same name, as in `manifestPlaceholders["applicationId"]`, nor a read or a
/// comparison of the property.
final _applicationIdSetting = RegExp(
  r'''(?<![\w."'\[$])applicationId(?:\s*=(?!=)\s*|\s+(?![=\s+\-*/.,)]))(.+)''',
);

/// A quoted value at the start of a setting value.
final _quotedValue = RegExp(r'''^["']([^"']*)["']''');

/// A variable reference in a setting: `$(NAME)` in Xcode, `${name}` or
/// `$name` in Gradle.
final _variableReference = RegExp(r'\$[({A-Za-z_]');

String _readBundleId(Directory appDirectory, String configFileName) {
  final file = File(p.join(appDirectory.path, _xcodeProjectPath));
  if (!file.existsSync()) {
    throw FailureException(
      error: 'The iOS bundle ID was not found: $_xcodeProjectPath is missing.',
      hint: _withConfigHint(
        _regenerateHint('ios'),
        FlutterPlatform.ios,
        configFileName,
      ),
    );
  }
  final bundleIds = {
    for (final block in _buildSettings.allMatches(file.readAsStringSync()))
      if (block.group(1) case final settings?)
        if (_appTargetInfoPlist.hasMatch(settings))
          ?_bundleIdSetting.firstMatch(settings)?.group(1)?.trim(),
  };
  return _single(
    bundleIds,
    platform: FlutterPlatform.ios,
    source: _xcodeProjectPath,
    setting: 'PRODUCT_BUNDLE_IDENTIFIER',
    configFileName: configFileName,
  );
}

String _readApplicationId(Directory appDirectory, String configFileName) {
  final relativePath = _gradleBuildPaths
      .where((path) => File(p.join(appDirectory.path, path)).existsSync())
      .firstOrNull;
  if (relativePath == null) {
    throw FailureException(
      error:
          'The Android package name was not found: '
          '${_gradleBuildPaths.join(' and ')} are missing.',
      hint: _withConfigHint(
        _regenerateHint('android'),
        FlutterPlatform.android,
        configFileName,
      ),
    );
  }
  final lines = File(
    p.join(appDirectory.path, relativePath),
  ).readAsLinesSync().where((line) => !line.trimLeft().startsWith('//'));
  final applicationIds = <String>{};
  final expressions = <String>{};
  for (final line in lines) {
    for (final match in _applicationIdSetting.allMatches(line)) {
      final value = match.group(1)?.trim();
      if (value == null) continue;
      final quoted = _quotedValue.firstMatch(value)?.group(1)?.trim();
      if (quoted != null) {
        applicationIds.add(quoted);
      } else {
        final expression = value.split('//').first.trim();
        applicationIds.add(expression);
        expressions.add(expression);
      }
    }
  }
  if (applicationIds.length == 1 && expressions.length == 1) {
    final expression = expressions.single;
    throw FailureException(
      error:
          'The Android package name could not be read: $relativePath sets '
          'applicationId to $expression, which is not a quoted value.',
      hint: _withConfigHint(
        'Set applicationId in $relativePath to the Android package name '
        'itself',
        FlutterPlatform.android,
        configFileName,
      ),
    );
  }
  return _single(
    applicationIds,
    platform: FlutterPlatform.android,
    source: relativePath,
    setting: 'applicationId',
    configFileName: configFileName,
  );
}

String _single(
  Set<String> identifiers, {
  required FlutterPlatform platform,
  required String source,
  required String setting,
  required String configFileName,
}) {
  final name = appIdentifierName(platform);
  if (identifiers.length == 1) {
    final identifier = identifiers.single;
    if (_variableReference.hasMatch(identifier)) {
      throw FailureException(
        error:
            'The $name could not be read: $source sets $setting to '
            '"$identifier", which comes from a variable.',
        hint: _withConfigHint(
          'Set $setting in $source to the $name itself',
          platform,
          configFileName,
        ),
      );
    }
    if (_isPlaceholder(identifier)) {
      throw FailureException(
        error:
            "The $name $identifier is Flutter's placeholder: $source sets "
            '$setting to it.',
        hint: _withConfigHint(
          "Set $setting in $source to the app's own $name",
          platform,
          configFileName,
        ),
      );
    }
    return identifier;
  }
  if (identifiers.isEmpty) {
    throw FailureException(
      error: 'The $name was not found: $source sets no $setting.',
      hint: _withConfigHint(
        'Set $setting for the app in $source',
        platform,
        configFileName,
      ),
    );
  }
  throw FailureException(
    error:
        'The $name is ambiguous: $source sets $setting to '
        '${identifiers.join(', ')}.',
    hint: _withConfigHint(
      'Publishing needs one $name for the app',
      platform,
      configFileName,
    ),
  );
}

/// Whether [identifier] is Flutter's `com.example` placeholder, or one built
/// on it.
bool _isPlaceholder(String identifier) =>
    identifier == 'com.example' || identifier.startsWith('com.example.');

/// The name of the app identifier of [platform], like "iOS bundle ID".
String appIdentifierName(FlutterPlatform platform) => switch (platform) {
  FlutterPlatform.ios => 'iOS bundle ID',
  FlutterPlatform.android => 'Android package name',
  FlutterPlatform.linux ||
  FlutterPlatform.macos ||
  FlutterPlatform.windows => '${platform.name} app identifier',
};

String _regenerateHint(String platform) =>
    'Recreate the $platform project with '
    '"flutter create --platforms=$platform ." in the app directory';

/// The [hint] followed by the alternative of setting the app identifier of
/// [platform] in the project configuration file [configFileName].
String _withConfigHint(
  String hint,
  FlutterPlatform platform,
  String configFileName,
) =>
    '$hint, or set project.appIdentifiers.${platform.name} in '
    '$configFileName.';
