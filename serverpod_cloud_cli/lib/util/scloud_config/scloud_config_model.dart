class ScloudConfig {
  final String projectId;
  final String? dartVersion;
  final ScloudScripts scripts;

  const ScloudConfig({
    required this.projectId,
    this.dartVersion,
    required this.scripts,
  });

  factory ScloudConfig.fromMap(final Map<String, dynamic> map) {
    final project = map['project'] as Map<String, dynamic>? ?? {};

    return ScloudConfig(
      projectId: project['projectId'] as String? ?? '',
      dartVersion: project['dartVersion'] as String?,
      scripts: ScloudScripts.fromMap(project['scripts'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'project': {
        'projectId': projectId,
        if (dartVersion != null) 'dartVersion': dartVersion,
        'scripts': scripts.toMap(),
      },
    };
  }

  ScloudConfig copyWith({
    final String? projectId,
    final Object? dartVersion = _unset,
    final ScloudScripts? scripts,
  }) {
    return ScloudConfig(
      projectId: projectId ?? this.projectId,
      dartVersion: dartVersion == _unset
          ? this.dartVersion
          : dartVersion as String?,
      scripts: scripts ?? this.scripts,
    );
  }
}

const _unset = Object();

class ScloudScripts {
  final List<String> preDeploy;
  final List<String> postDeploy;

  const ScloudScripts({required this.preDeploy, required this.postDeploy});

  factory ScloudScripts.fromMap(final dynamic map) {
    if (map is! Map) throw ArgumentError.value(map, 'map', 'Must be a map');

    return ScloudScripts(
      preDeploy: _normalizeScript(map['pre_deploy']),
      postDeploy: _normalizeScript(map['post_deploy']),
    );
  }

  factory ScloudScripts.empty() {
    return const ScloudScripts(preDeploy: [], postDeploy: []);
  }

  ScloudScripts copyWith({
    final List<String>? preDeploy,
    final List<String>? postDeploy,
  }) {
    return ScloudScripts(
      preDeploy: preDeploy ?? this.preDeploy,
      postDeploy: postDeploy ?? this.postDeploy,
    );
  }

  Map<String, dynamic> toMap() {
    return {'pre_deploy': preDeploy, 'post_deploy': postDeploy};
  }

  static List<String> _normalizeScript(final dynamic script) {
    if (script == null) {
      return const [];
    }

    if (script is String) {
      return [script];
    }

    if (script is List) {
      return script
          .whereType<String>()
          .where((final s) => s.isNotEmpty)
          .toList();
    }

    return const [];
  }
}
