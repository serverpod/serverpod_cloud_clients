import 'package:serverpod_cloud_cli/util/flutter_platform.dart';

class ScloudConfig {
  final String projectId;
  final String? dartSdk;

  /// The Flutter release version to build the app with, from
  /// `project.app.flutterSdk`.
  final String? flutterSdk;

  /// The path to the Flutter app directory, relative to the directory of
  /// the configuration file, from `project.app.dir`.
  final String? appDir;

  /// The app identifier to publish the app with by platform, the iOS
  /// bundle ID or Android package name, from `project.app.identifiers`. A
  /// platform without one takes it from the app's project files.
  final Map<FlutterPlatform, String> appIdentifiers;

  /// The paths of the files with the dart defines to build the app with,
  /// relative to the directory of the configuration file, in the order
  /// they are read, from `project.app.dartDefineFromFile`.
  final List<String> dartDefineFromFile;
  final ScloudScripts scripts;

  const ScloudConfig({
    required this.projectId,
    this.dartSdk,
    this.flutterSdk,
    this.appDir,
    this.appIdentifiers = const {},
    this.dartDefineFromFile = const [],
    required this.scripts,
  });

  factory ScloudConfig.fromMap(Map<String, dynamic> map) {
    final project = map['project'] as Map<String, dynamic>? ?? {};
    final app = project['app'] as Map<String, dynamic>? ?? {};

    return ScloudConfig(
      projectId: project['projectId'] as String? ?? '',
      dartSdk: project['dartSdk'] as String?,
      flutterSdk: app['flutterSdk'] as String?,
      appDir: app['dir'] as String?,
      appIdentifiers: switch (app['identifiers']) {
        final Map<String, dynamic> identifiers => {
          for (final platform in FlutterPlatform.values)
            if (identifiers[platform.name] case final String identifier)
              platform: identifier,
        },
        _ => const {},
      },
      dartDefineFromFile: switch (app['dartDefineFromFile']) {
        final String path => [path],
        final List<dynamic> paths => paths.cast<String>(),
        _ => const [],
      },
      scripts: ScloudScripts.fromMap(project['scripts'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    final app = {
      if (appDir != null) 'dir': appDir,
      if (flutterSdk != null) 'flutterSdk': flutterSdk,
      if (appIdentifiers.isNotEmpty)
        'identifiers': {
          for (final MapEntry(key: platform, value: identifier)
              in appIdentifiers.entries)
            platform.name: identifier,
        },
      if (dartDefineFromFile.isNotEmpty)
        'dartDefineFromFile': dartDefineFromFile,
    };
    return {
      'project': {
        'projectId': projectId,
        if (dartSdk != null) 'dartSdk': dartSdk,
        if (app.isNotEmpty) 'app': app,
        'scripts': scripts.toMap(),
      },
    };
  }

  ScloudConfig copyWith({
    String? projectId,
    String? dartSdk,
    String? flutterSdk,
    String? appDir,
    Map<FlutterPlatform, String>? appIdentifiers,
    List<String>? dartDefineFromFile,
    ScloudScripts? scripts,
  }) {
    return ScloudConfig(
      projectId: projectId ?? this.projectId,
      dartSdk: dartSdk ?? this.dartSdk,
      flutterSdk: flutterSdk ?? this.flutterSdk,
      appDir: appDir ?? this.appDir,
      appIdentifiers: appIdentifiers ?? this.appIdentifiers,
      dartDefineFromFile: dartDefineFromFile ?? this.dartDefineFromFile,
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
