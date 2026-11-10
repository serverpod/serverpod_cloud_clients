import 'package:serverpod_cloud_cli/util/flutter_platform.dart';

class ScloudConfig {
  final String projectId;
  final String? dartSdk;

  /// The path to the Flutter app directory, relative to the directory of
  /// the configuration file.
  final String? appDir;

  /// The app identifier to publish the app with by platform, the iOS
  /// bundle ID or Android package name. A platform without one takes it
  /// from the app's project files.
  final Map<FlutterPlatform, String> appIdentifiers;
  final ScloudScripts scripts;

  const ScloudConfig({
    required this.projectId,
    this.dartSdk,
    this.appDir,
    this.appIdentifiers = const {},
    required this.scripts,
  });

  factory ScloudConfig.fromMap(Map<String, dynamic> map) {
    final project = map['project'] as Map<String, dynamic>? ?? {};

    return ScloudConfig(
      projectId: project['projectId'] as String? ?? '',
      dartSdk: project['dartSdk'] as String?,
      appDir: project['appDir'] as String?,
      appIdentifiers: switch (project['appIdentifiers']) {
        final Map<String, dynamic> identifiers => {
          for (final platform in FlutterPlatform.values)
            if (identifiers[platform.name] case final String identifier)
              platform: identifier,
        },
        _ => const {},
      },
      scripts: ScloudScripts.fromMap(project['scripts'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'project': {
        'projectId': projectId,
        if (dartSdk != null) 'dartSdk': dartSdk,
        if (appDir != null) 'appDir': appDir,
        if (appIdentifiers.isNotEmpty)
          'appIdentifiers': {
            for (final MapEntry(key: platform, value: identifier)
                in appIdentifiers.entries)
              platform.name: identifier,
          },
        'scripts': scripts.toMap(),
      },
    };
  }

  ScloudConfig copyWith({
    String? projectId,
    String? dartSdk,
    String? appDir,
    Map<FlutterPlatform, String>? appIdentifiers,
    ScloudScripts? scripts,
  }) {
    return ScloudConfig(
      projectId: projectId ?? this.projectId,
      dartSdk: dartSdk ?? this.dartSdk,
      appDir: appDir ?? this.appDir,
      appIdentifiers: appIdentifiers ?? this.appIdentifiers,
      scripts: scripts ?? this.scripts,
    );
  }
}

class ScloudScripts {
  final List<String> preDeploy;
  final List<String> postDeploy;

  const ScloudScripts({required this.preDeploy, required this.postDeploy});

  factory ScloudScripts.fromMap(dynamic map) {
    if (map is! Map) throw ArgumentError.value(map, 'map', 'Must be a map');

    return ScloudScripts(
      preDeploy: _normalizeScript(map['pre_deploy']),
      postDeploy: _normalizeScript(map['post_deploy']),
    );
  }

  factory ScloudScripts.empty() {
    return const ScloudScripts(preDeploy: [], postDeploy: []);
  }

  ScloudScripts copyWith({List<String>? preDeploy, List<String>? postDeploy}) {
    return ScloudScripts(
      preDeploy: preDeploy ?? this.preDeploy,
      postDeploy: postDeploy ?? this.postDeploy,
    );
  }

  Map<String, dynamic> toMap() {
    return {'pre_deploy': preDeploy, 'post_deploy': postDeploy};
  }

  static List<String> _normalizeScript(dynamic script) {
    if (script == null) {
      return const [];
    }

    if (script is String) {
      return [script];
    }

    if (script is List) {
      return script.whereType<String>().where((s) => s.isNotEmpty).toList();
    }

    return const [];
  }
}
