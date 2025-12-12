import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:yaml/yaml.dart';

class DeploymentScripts {
  final List<String> preDeploy;
  final List<String> postDeploy;

  DeploymentScripts._({required this.preDeploy, required this.postDeploy});

  factory DeploymentScripts.fromConfigFile(final String configFilePath) {
    final file = File(configFilePath);
    if (!file.existsSync()) {
      return DeploymentScripts._(preDeploy: const [], postDeploy: const []);
    }

    try {
      final content = file.readAsStringSync();
      final data = loadYaml(content);

      if (data is! YamlMap) {
        return DeploymentScripts._(preDeploy: const [], postDeploy: const []);
      }

      final project = data['project'];
      if (project is! YamlMap) {
        return DeploymentScripts._(preDeploy: const [], postDeploy: const []);
      }

      final scripts = project['scripts'];
      if (scripts is! YamlMap) {
        return DeploymentScripts._(preDeploy: const [], postDeploy: const []);
      }

      final preDeploy = _normalizeScript(scripts['pre_deploy']);
      final postDeploy = _normalizeScript(scripts['post_deploy']);

      return DeploymentScripts._(preDeploy: preDeploy, postDeploy: postDeploy);
    } catch (_) {
      return DeploymentScripts._(preDeploy: const [], postDeploy: const []);
    }
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

  static String getConfigFilePath(final String projectDir) {
    return p.join(projectDir, ProjectConfigFileConstants.defaultFileName);
  }
}
