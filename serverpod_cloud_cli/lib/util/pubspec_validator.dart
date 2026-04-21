import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:serverpod_cloud_cli/constants.dart' show VersionConstants;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/dart_version_util.dart';
import 'package:serverpod_cloud_cli/util/tool_versions_io.dart';
import 'package:yaml/yaml.dart';

/// Convenience function to check if a directory is a Serverpod server directory.
///
/// Returns true if the directory is a Serverpod server directory, false otherwise.
bool isServerpodServerDirectory(final Directory dir) {
  try {
    return TenantProjectPubspec.fromProjectDir(dir).isServerpodServer();
  } catch (_) {
    return false;
  }
}

/// Convenience function to check if a pubspec.yaml file is a Serverpod server package.
///
/// Returns true if the pubspec.yaml file is a Serverpod server package, false otherwise.
bool isServerpodServerPackage(final File pubspecFile) {
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

  TenantProjectPubspec(this.pubspec, [final String? rawYamlContent])
    : _rawYamlContent = rawYamlContent ?? '';

  /// Reads and parses the pubspec.yaml file in the given project directory.
  ///
  /// If the pubspec.yaml file is not found or if it cannot be parsed,
  /// error messages are printed to logger if provided,
  /// and [ErrorExitException] is thrown.
  factory TenantProjectPubspec.fromProjectDir(
    final Directory projectDirectory,
  ) {
    final pubspecFile = File('${projectDirectory.path}/pubspec.yaml');
    return TenantProjectPubspec.fromFile(pubspecFile);
  }

  /// Reads and parses the given pubspec.yaml file.
  ///
  /// If the pubspec.yaml file is not found or if it cannot be parsed,
  /// error messages are printed to logger if provided,
  /// and [ErrorExitException] is thrown.
  factory TenantProjectPubspec.fromFile(final File pubspecFile) {
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
  /// If the dependencies are not valid,
  /// the returned list will contain the error messages.
  /// If the dependencies are valid, the list will be empty.
  List<String> projectDependencyIssues({final bool requireServerpod = true}) {
    final supportedSdk = VersionConstraint.parse(
      VersionConstants.supportedSdkConstraint,
    );
    final supportedServerpod = VersionConstraint.parse(
      VersionConstants.supportedServerpodConstraint,
    );

    final sdkError = _validateEnvironmentConstraints(supportedSdk);

    final serverpodError = _validateHostedDependencyConstraint(
      packageName: 'serverpod',
      supported: supportedServerpod,
      requireDependency: requireServerpod,
    );

    return [
      if (sdkError != null) sdkError,
      if (serverpodError != null) serverpodError,
    ];
  }

  /// The environment constraints are handled differently than other dependencies.
  /// They represent what SDK versions are supported by the project,
  /// including the SDK the deployed project is built with,
  /// and a possible but unsupported Flutter dependency.
  String? _validateEnvironmentConstraints(
    final VersionConstraint supportedSdk,
  ) {
    final sdkConstraint = pubspec.environment['sdk'];
    if (sdkConstraint == null) {
      return 'No sdk constraint found in package ${pubspec.name}';
    }
    if (!supportedSdk.allowsAny(sdkConstraint)) {
      return 'Unsupported sdk version constraint in package ${pubspec.name}: $sdkConstraint'
          ' (must accept: $supportedSdk)';
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
    required final String packageName,
    required final VersionConstraint supported,
    required final bool requireDependency,
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

  String? environmentSdkConstraint() {
    final sdk = pubspec.environment['sdk'];
    if (sdk == null || sdk.isEmpty) {
      return null;
    }
    return sdk.toString();
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

/// Resolves the Dart SDK version to use for the project in [rootDir].
///
/// Resolution order:
/// `.tool-versions` in [rootDir] → `environment.sdk` from
/// [rootDir]/pubspec.yaml → [VersionConstants.minSupportedSdkVersion].
///
/// Throws [FailureException] if a version found in `.tool-versions` is invalid.
String resolveProjectDartSdkVersion(final Directory rootDir) {
  final fromToolVersions = ToolVersionsIO.readDartVersionFromToolVersions([
    rootDir,
  ]);
  if (fromToolVersions != null) {
    ensureValidVersionConstraint(
      fromToolVersions,
      sourceDescription: '(from .tool-versions)',
    );
    return fromToolVersions;
  }

  final pubspecFile = File('${rootDir.path}/pubspec.yaml');
  if (pubspecFile.existsSync()) {
    final fromPubspec = TenantProjectPubspec.fromFile(
      pubspecFile,
    ).environmentSdkConstraint();
    if (fromPubspec != null) {
      ensureValidVersionConstraint(
        fromPubspec,
        sourceDescription: '(from pubspec.yaml)',
      );
      return fromPubspec;
    }
  }

  return VersionConstants.minSupportedSdkVersion;
}
