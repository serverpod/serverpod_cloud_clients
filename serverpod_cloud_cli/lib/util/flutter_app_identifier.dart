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
/// `com.example` placeholder, unless [allowPlaceholder] is true. Its hint
/// says the identifier can be set in the project configuration file
/// [configFileName] instead.
/// Throws [ArgumentError] for a platform that apps cannot be published for.
String readAppIdentifier(
  Directory appDirectory,
  FlutterPlatform platform, {
  String configFileName = ProjectConfigFileConstants.defaultFileName,
  bool allowPlaceholder = false,
}) {
  return switch (platform) {
    FlutterPlatform.ios => _readBundleId(
      appDirectory,
      configFileName,
      allowPlaceholder: allowPlaceholder,
    ),
    FlutterPlatform.android => _readApplicationId(
      appDirectory,
      configFileName,
      allowPlaceholder: allowPlaceholder,
    ),
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
          '$configFileName sets project.app.identifiers.${platform.name} to an '
          'empty value.',
      hint:
          'Set project.app.identifiers.${platform.name} in $configFileName to '
          "the app's own $name, or remove it to use the one the app declares.",
    );
  }
  if (!_isPlaceholder(identifier)) return;
  throw FailureException(
    error: "The $name $identifier is Flutter's placeholder.",
    hint:
        'Set project.app.identifiers.${platform.name} in $configFileName to the '
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

String _readBundleId(
  Directory appDirectory,
  String configFileName, {
  required bool allowPlaceholder,
}) {
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
    allowPlaceholder: allowPlaceholder,
  );
}

String _readApplicationId(
  Directory appDirectory,
  String configFileName, {
  required bool allowPlaceholder,
}) {
  final relativePath = _gradleBuildPath(appDirectory);
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
    allowPlaceholder: allowPlaceholder,
  );
}

String _single(
  Set<String> identifiers, {
  required FlutterPlatform platform,
  required String source,
  required String setting,
  required String configFileName,
  required bool allowPlaceholder,
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
    if (!allowPlaceholder && _isPlaceholder(identifier)) {
      throw FailureException(
        error: "The $name $identifier is Flutter's placeholder.",
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

/// An iOS bundle ID: alphanumeric segments, with hyphens, separated by
/// periods.
final _iosBundleIdPattern = RegExp(r'^[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*$');

/// An Android package name: two or more segments separated by periods, each
/// a letter followed by letters, digits or underscores.
final _androidPackageNamePattern = RegExp(
  r'^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)+$',
);

/// What is wrong with [identifier] as the app identifier of [platform],
/// like "is not valid" or "is Flutter's placeholder", or null when
/// Serverpod Cloud can publish the app with it.
///
/// Throws [ArgumentError] for a platform that apps cannot be published for.
String? appIdentifierProblem(FlutterPlatform platform, String identifier) {
  final pattern = switch (platform) {
    FlutterPlatform.ios => _iosBundleIdPattern,
    FlutterPlatform.android => _androidPackageNamePattern,
    FlutterPlatform.linux ||
    FlutterPlatform.macos ||
    FlutterPlatform.windows => throw ArgumentError.value(
      platform,
      'platform',
      'has no app identifier to publish with',
    ),
  };
  if (identifier.isEmpty) return 'is empty';
  if (!pattern.hasMatch(identifier)) {
    return 'is not valid';
  }
  if (_isPlaceholder(identifier)) {
    return "is Flutter's placeholder";
  }
  return null;
}

/// The app identifier Serverpod Cloud suggests for [platform] in project
/// [projectId]: `space.serverpod.` followed by the project id, with the
/// characters the identifier of [platform] does not allow replaced.
///
/// Throws [ArgumentError] for a platform that apps cannot be published for.
String suggestAppIdentifier(FlutterPlatform platform, String projectId) {
  final name = projectId.toLowerCase();
  final segment = switch (platform) {
    FlutterPlatform.ios => name.replaceAll(RegExp(r'[^a-z0-9-]+'), '-'),
    FlutterPlatform.android => switch (name.replaceAll(
      RegExp(r'[^a-z0-9_]+'),
      '_',
    )) {
      final name when name.startsWith(RegExp('[a-z]')) => name,
      final name => 'app$name',
    },
    FlutterPlatform.linux ||
    FlutterPlatform.macos ||
    FlutterPlatform.windows => throw ArgumentError.value(
      platform,
      'platform',
      'has no app identifier to publish with',
    ),
  };
  return 'space.serverpod.$segment';
}

/// The `PRODUCT_BUNDLE_IDENTIFIER` setting of an Xcode project: the text up
/// to the value, the value, and the text after it.
final _bundleIdSettingParts = RegExp(
  r'(PRODUCT_BUNDLE_IDENTIFIER\s*=\s*"?)([^";]+?)("?\s*;)',
);

/// Replaces the app identifier [from] with [to] in the project files of the
/// [platform] app in [appDirectory], as [readAppIdentifier] reads it: the
/// `applicationId` of the Android app module's Gradle build file, or the
/// `PRODUCT_BUNDLE_IDENTIFIER` of the Xcode project. In the Xcode project,
/// the bundle IDs built on [from], like the one of the test target, get [to]
/// in its place too.
///
/// Returns the path of the file it changed, relative to [appDirectory].
///
/// Throws [FailureException] if the file is missing or does not set the app
/// identifier to [from].
/// Throws [ArgumentError] for a platform that apps cannot be published for.
String writeAppIdentifier(
  Directory appDirectory,
  FlutterPlatform platform, {
  required String from,
  required String to,
}) {
  final relativePath = switch (platform) {
    FlutterPlatform.ios => _xcodeProjectPath,
    FlutterPlatform.android => _gradleBuildPath(appDirectory),
    FlutterPlatform.linux ||
    FlutterPlatform.macos ||
    FlutterPlatform.windows => throw ArgumentError.value(
      platform,
      'platform',
      'has no app identifier to publish with',
    ),
  };
  final name = appIdentifierName(platform);
  final missing = FailureException(
    error: 'The $name could not be changed: its project file is missing.',
  );
  if (relativePath == null) throw missing;
  final file = File(p.join(appDirectory.path, relativePath));
  if (!file.existsSync()) throw missing;
  final content = file.readAsStringSync();
  final changed = switch (platform) {
    FlutterPlatform.ios => content.replaceAllMapped(_bundleIdSettingParts, (
      match,
    ) {
      final value = match.group(2) ?? '';
      if (value != from && !value.startsWith('$from.')) {
        return match.group(0) ?? '';
      }
      return '${match.group(1)}$to${value.substring(from.length)}'
          '${match.group(3)}';
    }),
    _ => _replaceApplicationId(content, from: from, to: to),
  };
  if (changed == content) {
    throw FailureException(
      error:
          'The $name could not be changed: $relativePath does not set it to '
          '$from.',
    );
  }
  file.writeAsStringSync(changed);
  return relativePath;
}

/// The Gradle build file [content] with each `applicationId` setting of
/// the quoted value [from] set to [to] instead. Comment lines stay as they
/// are.
String _replaceApplicationId(
  String content, {
  required String from,
  required String to,
}) {
  final lines = content.split('\n');
  for (final (index, line) in lines.indexed) {
    if (line.trimLeft().startsWith('//')) continue;
    final match = _applicationIdSetting.firstMatch(line);
    final value = match?.group(1);
    if (match == null || value == null) continue;
    final quoted = _quotedValue.firstMatch(value.trim());
    if (quoted == null || quoted.group(1)?.trim() != from) continue;
    final valueStart = match.end - value.length;
    lines[index] =
        line.substring(0, valueStart) +
        value.replaceFirst(from, to) +
        line.substring(valueStart + value.length);
  }
  return lines.join('\n');
}

/// The path of the Gradle build file of the Android app module in
/// [appDirectory], relative to it, or null when there is none.
String? _gradleBuildPath(Directory appDirectory) => _gradleBuildPaths
    .where((path) => File(p.join(appDirectory.path, path)).existsSync())
    .firstOrNull;

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
    '$hint, or set project.app.identifiers.${platform.name} in '
    '$configFileName.';
