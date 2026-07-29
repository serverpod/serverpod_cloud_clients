import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'package_graph.dart';

/// Thrown when '.dart_tool/package_graph.json' is not found.
class PackageGraphFileNotFoundException implements Exception {
  /// The path to the expected package graph file that was not found.
  /// Typically this is '.dart_tool/package_graph.json' under the project
  /// directory (where the pubspec.yaml file is located).
  final String projectPath;

  PackageGraphFileNotFoundException(this.projectPath);

  @override
  String toString() {
    return '$runtimeType: $projectPath';
  }
}

/// Parses `.dart_tool/package_graph.json` into a [PackageGraph].
final class PackageGraphParser {
  PackageGraphParser._();

  static const _relativePath = '.dart_tool/package_graph.json';
  static const _supportedConfigVersion = 1;

  /// Reads and parses `.dart_tool/package_graph.json` under [projectPath].
  ///
  /// Throws [PackageGraphFileNotFoundException] if the file is not found.
  /// Throws [FormatException] if the file is not a valid package graph file.
  static PackageGraph fromProjectPath(final String projectPath) {
    return fromProjectDirectory(Directory(projectPath));
  }

  /// Reads and parses `.dart_tool/package_graph.json` under [projectDirectory].
  ///
  /// Throws [PackageGraphFileNotFoundException] if the file is not found.
  /// Throws [FormatException] if the file is not a valid package graph file.
  static PackageGraph fromProjectDirectory(final Directory projectDirectory) {
    return fromFile(File(p.join(projectDirectory.path, _relativePath)));
  }

  /// Reads and parses a package graph file.
  ///
  /// Throws [PackageGraphFileNotFoundException] if the file is not found.
  /// Throws [FormatException] if the file is not a valid package graph file.
  static PackageGraph fromFile(final File file) {
    final String contents;
    try {
      contents = file.readAsStringSync();
    } on PathNotFoundException {
      throw PackageGraphFileNotFoundException(file.path);
    } on FileSystemException catch (e) {
      throw FormatException(
        'Failed to read package_graph.json at `${file.path}`: ${e.message}',
      );
    }
    try {
      return fromJson(jsonDecode(contents));
    } on FormatException catch (e) {
      throw FormatException(
        'Failed to parse package_graph.json at `${file.path}`: ${e.message}',
      );
    }
  }

  /// Parses a decoded `package_graph.json` value.
  ///
  /// Throws [FormatException] if the file is not a valid package graph file.
  static PackageGraph fromJson(final Object? json) {
    if (json is! Map) {
      throw const FormatException(
        'Expected package_graph.json top level to be a map',
      );
    }
    final map = Map<String, dynamic>.from(json);

    if (map['configVersion'] != _supportedConfigVersion) {
      throw FormatException(
        'Unsupported package_graph.json configVersion: '
        '${map['configVersion']}',
      );
    }

    final rootNames = _parseStringList(map, 'roots');
    final packagesJson = map['packages'];
    if (packagesJson is! List) {
      throw const FormatException('Expected `packages` to be a list');
    }

    final packagesByName = <String, PgPackage>{};
    final dependencyNamesByPackage = <String, List<String>>{};
    final devDependencyNamesByPackage = <String, List<String>>{};

    for (final entry in packagesJson) {
      if (entry is! Map) {
        throw const FormatException('Expected each package to be a map');
      }
      final packageMap = Map<String, dynamic>.from(entry);
      final name = packageMap['name'];
      if (name is! String) {
        throw const FormatException('Expected package `name` to be a string');
      }
      final version = packageMap['version'];
      if (version is! String) {
        throw const FormatException(
          'Expected package `version` to be a string',
        );
      }

      packagesByName[name] = PgPackage(
        name: name,
        version: version,
        dependencies: [],
        devDependencies: [],
        references: [],
        devReferences: [],
      );
      dependencyNamesByPackage[name] = _parseStringList(
        packageMap,
        'dependencies',
      );
      devDependencyNamesByPackage[name] = _parseStringList(
        packageMap,
        'devDependencies',
      );
    }

    for (final MapEntry(key: name, value: package) in packagesByName.entries) {
      final dependencyNames = dependencyNamesByPackage[name];
      if (dependencyNames == null) {
        throw FormatException('Missing dependency list for package "$name"');
      }
      for (final depName in dependencyNames) {
        final dependency = packagesByName[depName];
        if (dependency == null) {
          throw FormatException(
            'Package "$name" depends on unknown package "$depName"',
          );
        }
        package.dependencies.add(dependency);
        dependency.references.add(package);
      }

      final devDependencyNames = devDependencyNamesByPackage[name];
      if (devDependencyNames == null) {
        throw FormatException('Missing devDependency list for package "$name"');
      }
      for (final depName in devDependencyNames) {
        final dependency = packagesByName[depName];
        if (dependency == null) {
          throw FormatException(
            'Package "$name" has unknown dev dependency "$depName"',
          );
        }
        package.devDependencies.add(dependency);
        dependency.devReferences.add(package);
      }
    }

    final roots = <PgPackage>[];
    for (final rootName in rootNames) {
      final root = packagesByName[rootName];
      if (root == null) {
        throw FormatException('Unknown root package "$rootName"');
      }
      roots.add(root);
    }

    return PackageGraph(roots: roots);
  }

  static List<String> _parseStringList(
    final Map<String, dynamic> map,
    final String key,
  ) {
    final value = map[key];
    if (value == null) {
      return [];
    }
    if (value is! List) {
      throw FormatException('Expected `$key` to be a list of strings');
    }
    final result = <String>[];
    for (final item in value) {
      if (item is! String) {
        throw FormatException('Expected `$key` to be a list of strings');
      }
      result.add(item);
    }
    return result;
  }
}
