import 'dart:io';

import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/json_to_yaml.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:yaml/yaml.dart';

import 'yaml_schema.dart';

final _schema = YamlMap.wrap({
  'project': YamlMap.wrap({
    'projectId': String,
  }),
});

final _yamlSchema = YamlSchema(_schema);

abstract final class ScloudConfigFile {
  static Map<String, dynamic> _parseConfigYaml(final String configYaml) {
    final data = loadYaml(configYaml);

    if (data is! YamlMap) {
      throw Exception('Invalid YAML data');
    }
    _yamlSchema.validate(data);

    return Map<String, dynamic>.fromEntries(
      data.entries
          .map((final entry) => MapEntry(entry.key as String, entry.value)),
    );
  }

  static void writeToFile(
    final ProjectConfig projectConfig,
    final String configFilePath,
  ) {
    final output = _mergeProjectConfigWithCurrentConfigAsYaml(
      projectConfig,
      configFilePath,
    );
    final content = ProjectConfigFileConstants.defaultYamlFileHeader + output;
    File(configFilePath)
      ..createSync(recursive: false)
      ..writeAsStringSync(content);
  }

  static String? _tryReadFile(final String filePath) {
    try {
      return File(filePath).readAsStringSync();
    } catch (e) {
      return null;
    }
  }

  static String _mergeProjectConfigWithCurrentConfigAsYaml(
    final ProjectConfig projectConfig,
    final String filePath,
  ) {
    final yaml = _tryReadFile(filePath);

    final Map<String, dynamic> cloudConfig =
        yaml == null ? {} : _parseConfigYaml(yaml);

    if (cloudConfig['project'] == null) {
      cloudConfig['project'] = {};
    }

    cloudConfig['project'] = {'projectId': projectConfig.projectId};

    return jsonToYaml(cloudConfig);
  }
}
