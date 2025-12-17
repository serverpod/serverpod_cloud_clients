import 'dart:io';

import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/json_to_yaml.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config_model.dart';
import 'package:yaml/yaml.dart';

import 'yaml_schema.dart';

final _schema = YamlMap.wrap({
  'project': YamlMap.wrap({
    'projectId': String,
    'scripts': YamlOptional(
      YamlMap.wrap({
        'pre_deploy': YamlOptional(
          YamlUnion({
            [String],
            String,
          }),
        ),
        'post_deploy': YamlOptional(
          YamlUnion({
            [String],
            String,
          }),
        ),
      }),
    ),
  }),
});

final _yamlSchema = YamlSchema(_schema);

abstract final class ScloudConfigIO {
  static Map<String, dynamic> _parseConfigYaml(final String configYaml) {
    final data = loadYaml(configYaml);

    if (data is! YamlMap) {
      throw Exception('Invalid YAML data');
    }
    _yamlSchema.validate(data);

    return _convertYamlToMap(data);
  }

  static Map<String, dynamic> _convertYamlToMap(final YamlMap yamlMap) {
    return Map<String, dynamic>.fromEntries(
      yamlMap.entries.map(
        (final entry) =>
            MapEntry(entry.key as String, _convertYamlValue(entry.value)),
      ),
    );
  }

  static dynamic _convertYamlValue(final dynamic value) {
    if (value is YamlMap) {
      return _convertYamlToMap(value);
    } else if (value is YamlList) {
      return value.map(_convertYamlValue).toList();
    } else {
      return value;
    }
  }

  static void writeToFile(
    final ScloudConfig config,
    final String configFilePath,
  ) {
    final output = _mergeProjectConfigWithCurrentConfigAsYaml(
      config,
      configFilePath,
    );
    final content = ProjectConfigFileConstants.defaultYamlFileHeader + output;
    File(configFilePath)
      ..createSync(recursive: true)
      ..writeAsStringSync(content);
  }

  static ScloudConfig? readFromFile(final String configFilePath) {
    final yaml = _tryReadFile(configFilePath);
    if (yaml == null) {
      return null;
    }

    return ScloudConfig.fromMap(_parseConfigYaml(yaml));
  }

  static String? _tryReadFile(final String filePath) {
    try {
      return File(filePath).readAsStringSync();
    } catch (e) {
      return null;
    }
  }

  static String _mergeProjectConfigWithCurrentConfigAsYaml(
    final ScloudConfig config,
    final String filePath,
  ) {
    final yaml = _tryReadFile(filePath);

    if (yaml == null) {
      return jsonToYaml(config.toMap());
    }

    final Map<String, dynamic> cloudConfig = _parseConfigYaml(yaml);
    final scloudConfig = ScloudConfig.fromMap(cloudConfig);

    return jsonToYaml(
      scloudConfig
          .copyWith(projectId: config.projectId, scripts: config.scripts)
          .toMap(),
    );
  }
}
