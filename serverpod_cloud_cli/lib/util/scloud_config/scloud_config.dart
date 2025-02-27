import 'dart:io';

import 'package:path/path.dart';
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

abstract final class ScloudConfig {
  static Map<String, dynamic> parseConfigYaml(final String configYaml) {
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

  static String getProjectIdFromConfig(final String path) {
    final yaml = tryReadFile(path);
    if (yaml == null) {
      throw Exception('No configuration found.');
    }

    final cloudConfig = parseConfigYaml(yaml);

    final project = cloudConfig['project'] as YamlMap?;
    return project?['projectId'];
  }

  static void writeToFile(
    final ProjectConfig projectConfig,
    final Directory projectDirectory,
  ) {
    final output = mergeProjectConfigWithCurrentConfigAsYaml(
      projectConfig,
      projectDirectory.path,
    );
    final fileContent = ConfigFileConstants.defaultYamlFileHeader + output;
    File(join(projectDirectory.path, ConfigFileConstants.fileName))
      ..createSync(recursive: false)
      ..writeAsStringSync(fileContent);
  }

  static String? tryReadFile(final String path) {
    try {
      return File(join(path, ConfigFileConstants.fileName)).readAsStringSync();
    } catch (e) {
      return null;
    }
  }

  static String mergeProjectConfigWithCurrentConfigAsYaml(
    final ProjectConfig projectConfig,
    final String path,
  ) {
    final yaml = tryReadFile(path);

    final Map<String, dynamic> cloudConfig =
        yaml == null ? {} : parseConfigYaml(yaml);

    if (cloudConfig['project'] == null) {
      cloudConfig['project'] = {};
    }

    cloudConfig['project'] = {'projectId': projectConfig.projectId};

    return jsonToYaml(cloudConfig);
  }
}
