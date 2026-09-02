import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:serverpod_cloud_cli/constants.dart' show VersionConstants;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:yaml/yaml.dart';

/// Convenience function to check if a directory is a Serverpod server directory.
///
/// Returns true if the directory is a Serverpod server directory, false otherwise.
bool isServerpodServerDirectory(Directory dir) {
  try {
    return TenantProjectPubspec.fromProjectDir(dir).isServerpodServer();
  } catch (_) {
    return false;
  }
}

/// Convenience function to check if a pubspec.yaml file is a Serverpod server package.
///
/// Returns true if the pubspec.yaml file is a Serverpod server package, false otherwise.
bool isServerpodServerPackage(File pubspecFile) {
  try {
    return TenantProjectPubspec.fromFile(pubspecFile).isServerpodServer();
  } catch (_) {
    return false;
  }
}

/// Represents a parsed pubspec.yaml file of a tenant project.
/// Provides methods to validate its contents.
class TenantProjectPubspec {
  final Pubspec pubspec;
  final String _rawYamlContent;

  TenantProjectPubspec(this.pubspec, [String? rawYamlContent])
    : _rawYamlContent = rawYamlContent ?? '';

  /// Reads and parses the pubspec.yaml file in the given project directory.
  ///
  /// If the pubspec.yaml file is not found or if it cannot be parsed,
  /// error messages are printed to logger if provided,
  /// and [FailureException] is thrown.
  factory TenantProjectPubspec.fromProjectDir(Directory projectDirectory) {
    final pubspecFile = File('${projectDirectory.path}/pubspec.yaml');
    return TenantProjectPubspec.fromFile(pubspecFile);
  }

  /// Reads and parses the given pubspec.yaml file.
  ///
  /// If the pubspec.yaml file is not found or if it cannot be parsed,
  /// error messages are printed to logger if provided,
  /// and [FailureException] is thrown.
  factory TenantProjectPubspec.fromFile(File pubspecFile) {
    if (!pubspecFile.existsSync()) {
      throw FailureException(
        error:
            'Could not find `pubspec.yaml` in directory `${pubspecFile.parent.path}`.',
        hint: "Provide the project's server directory and try again.",
      );
    }

    final String rawContent;
    try {
      rawContent = pubspecFile.readAsStringSync();
    } catch (e) {
      throw FailureException(
        error: 'Failed to read pubspec.yaml: ${e.toString()}',
        hint: 'Please fix the errors and try again.',
      );
    }

    final Pubspec pubspec;
    try {
      pubspec = Pubspec.parse(rawContent);
    } catch (e) {
      throw FailureException(
        error: 'Failed to parse pubspec.yaml: ${e.toString()}',
        hint: 'Please fix the errors and try again.',
      );
    }
    return TenantProjectPubspec(pubspec, rawContent);
  }

  /// Returns true if the pubspec.yaml has a workspace resolution directive.
  bool isWorkspaceResolved() {
    return pubspec.resolution == 'workspace';
  }

  /// Returns true if the pubspec.yaml appears to represent a Serverpod server.
  bool isServerpodServer() {
    return pubspec.workspace == null &&
        pubspec.dependencies['serverpod'] != null;
  }

  /// Returns the Serverpod framework version constraint string,
  /// or null if no Serverpod hosted dependency is found.
  String? get serverpodVersion {
    final serverpodDep = pubspec.dependencies['serverpod'];
    if (serverpodDep is HostedDependency) {
      return serverpodDep.version.toString();
    }
    return null;
  }

  /// Validates the pubspec.yaml dependencies of a customer project
  /// in order to be deployed to Serverpod Cloud.
  ///
  /// The Dart SDK version the project is built with is chosen by
  /// [DartSdkSelector], which validates the declared bound against the
  /// version policy. This method only checks that the bound is declared.
  ///
  /// If the dependencies are not valid,
  /// the returned list will contain the error messages.
  /// If the dependencies are valid, the list will be empty.
  List<String> projectDependencyIssues({bool requireServerpod = true}) {
    final supportedServerpod = VersionConstraint.parse(
      VersionConstants.supportedServerpodConstraint,
    );

    final sdkError = _validateEnvironmentConstraints();

    final serverpodError = _validateHostedDependencyConstraint(
      packageName: 'serverpod',
      supported: supportedServerpod,
      requireDependency: requireServerpod,
    );

    return [?sdkError, ?serverpodError];
  }

  /// The environment constraints are handled differently than other dependencies.
  /// They represent what SDK versions are supported by the project,
  /// including the SDK the deployed project is built with,
  /// and a possible but unsupported Flutter dependency.
  String? _validateEnvironmentConstraints() {
    final sdkConstraint = pubspec.environment['sdk'];
    if (sdkConstraint == null) {
      return 'No sdk constraint found in package ${pubspec.name}';
    }

    final flutterConstraint = pubspec.environment['flutter'];
    if (flutterConstraint != null) {
      return 'A Flutter dependency is not allowed in a server package: ${pubspec.name}';
    }

    return null;
  }

  /// Validates that the given dependency is hosted
  /// and is within the supported range.
  String? _validateHostedDependencyConstraint({
    required String packageName,
    required VersionConstraint supported,
    required bool requireDependency,
  }) {
    final dependency = pubspec.dependencies[packageName];
    if (dependency == null) {
      if (requireDependency) {
        return 'No $packageName dependency found in pubspec.yaml';
      } else {
        return null;
      }
    }
    if (dependency is! HostedDependency) {
      return '$packageName dependency is not a hosted dependency: $dependency';
    }
    if (!supported.allowsAll(dependency.version)) {
      return 'Unsupported $packageName version constraint: ${dependency.version}'
          ' (must adher to: $supported)';
    }
    return null;
  }

  /// The Dart SDK constraint the package declares in `environment.sdk`,
  /// or null if it declares none.
  String? environmentSdkConstraint() {
    final sdk = pubspec.environment['sdk'];
    if (sdk == null || sdk.isEmpty) {
      return null;
    }
    return sdk.toString();
  }

  /// Reads the Dart SDK constraint recorded as `sdks.dart` in [lockfile].
  ///
  /// The constraint is null if the lockfile is missing, cannot be read or
  /// parsed, or records no Dart SDK constraint. The issues describe the
  /// cases where the lockfile itself could not be read.
  static ({String? constraint, List<String> issues}) readLockfileDartSdk(
    File lockfile,
  ) {
    if (!lockfile.existsSync()) {
      return (constraint: null, issues: const []);
    }

    final String rawContent;
    try {
      rawContent = lockfile.readAsStringSync();
    } catch (e) {
      return (
        constraint: null,
        issues: ['Failed to read pubspec.lock: ${e.toString()}'],
      );
    }

    final YamlNode document;
    try {
      document = loadYamlNode(rawContent);
    } catch (e) {
      return (
        constraint: null,
        issues: ['Failed to parse pubspec.lock: ${e.toString()}'],
      );
    }

    if (document is! YamlMap) {
      return (
        constraint: null,
        issues: const ['Failed to parse pubspec.lock: expected a YAML map'],
      );
    }

    final sdks = document.value['sdks'];
    if (sdks is! YamlMap) {
      return (constraint: null, issues: const []);
    }

    final dartSdk = sdks.value['dart']?.toString().trim();
    if (dartSdk == null || dartSdk.isEmpty) {
      return (constraint: null, issues: const []);
    }

    return (constraint: dartSdk, issues: const []);
  }

  /// Returns true if the pubspec.yaml defines a `serverpod.scripts.flutter_build` entry.
  bool hasFlutterBuildScript() {
    if (_rawYamlContent.isEmpty) {
      return false;
    }

    try {
      final yamlDoc = loadYaml(_rawYamlContent);
      if (yamlDoc is! YamlMap) {
        return false;
      }

      final serverpod = yamlDoc['serverpod'];
      if (serverpod is! YamlMap) {
        return false;
      }

      final scripts = serverpod['scripts'];
      if (scripts is! YamlMap) {
        return false;
      }

      return scripts.containsKey('flutter_build');
    } catch (_) {
      return false;
    }
  }
}
