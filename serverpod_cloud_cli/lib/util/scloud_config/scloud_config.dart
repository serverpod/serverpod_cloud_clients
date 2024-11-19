import 'dart:io';

import 'package:path/path.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/json_to_yaml.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';
import 'package:yaml/yaml.dart';

import 'yaml_schema.dart';

final _schema = YamlMap.wrap({
  'project': YamlMap.wrap({
    'projectId': String,
  }),
});

final _yamlSchema = YamlSchema(_schema);

abstract final class ScloudConfig {
  static Map<String, dynamic> parseConfigYaml(final String path) {
    final yaml = (File(join(path, ConfigFileConstants.fileName))
          ..createSync(exclusive: false))
        .readAsStringSync();
    final data = loadYaml(yaml);

    if (data == null) {
      return {};
    }

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
    final Directory projectDirectory,
  ) {
    final output =
        ScloudConfig.projectConfigToYaml(projectConfig, projectDirectory.path);
    File(join(projectDirectory.path, ConfigFileConstants.fileName))
      ..createSync(recursive: false)
      ..writeAsStringSync(output);
  }

  static String projectConfigToYaml(
    final ProjectConfig projectConfig,
    final String path,
  ) {
    final cloudConfig = parseConfigYaml(path);

    if (cloudConfig['project'] == null) {
      cloudConfig['project'] = {};
    }

    cloudConfig['project'] = {'projectId': projectConfig.projectId};

    return jsonToYaml(cloudConfig);
  }
}
