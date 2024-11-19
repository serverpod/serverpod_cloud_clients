import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

bool isServerpodServerDirectory(final String path) {
  final pubspecFile = File(join(path, 'pubspec.yaml'));
  if (!pubspecFile.existsSync()) {
    return false;
  }

  final pubspec = loadYaml(pubspecFile.readAsStringSync());
  if (pubspec is! YamlMap) {
    return false;
  }

  final dependencies = pubspec['dependencies'];
  if (dependencies is! YamlMap) {
    return false;
  }

  if (dependencies['serverpod'] == null) {
    return false;
  }

  final name = pubspec['name'];
  if (name is String && name.endsWith('server')) {
    return true;
  }

  return false;
}
