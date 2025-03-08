import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';

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

  TenantProjectPubspec(
    this.pubspec,
  );

  /// Reads and parses the pubspec.yaml file in the given project directory.
  ///
  /// If the pubspec.yaml file is not found or if it cannot be parsed,
  /// error messages are printed to logger if provided,
  /// and [ErrorExitException] is thrown.
  factory TenantProjectPubspec.fromProjectDir(
    final Directory projectDirectory, {
    final CommandLogger? logger,
  }) {
    final pubspecFile = File('${projectDirectory.path}/pubspec.yaml');
    return TenantProjectPubspec.fromFile(pubspecFile, logger: logger);
  }

  /// Reads and parses the given pubspec.yaml file.
  ///
  /// If the pubspec.yaml file is not found or if it cannot be parsed,
  /// error messages are printed to logger if provided,
  /// and [ErrorExitException] is thrown.
  factory TenantProjectPubspec.fromFile(
    final File pubspecFile, {
    final CommandLogger? logger,
  }) {
    if (!pubspecFile.existsSync()) {
      logger?.error(
        'Could not find pubspec.yaml in the project directory.',
        hint: "Provide the project's server directory and try again.",
      );
      throw ErrorExitException();
    }

    final Pubspec pubspec;
    try {
      pubspec = Pubspec.parse(pubspecFile.readAsStringSync());
    } catch (e) {
      logger?.error('Failed to parse pubspec.yaml: ${e.toString()}');
      throw ErrorExitException();
    }
    return TenantProjectPubspec(pubspec);
  }

  /// Returns true if the pubspec.yaml appears to represent a Serverpod server.
  bool isServerpodServer() {
    return pubspec.dependencies['serverpod'] != null;
  }

  /// Validates the pubspec.yaml dependencies of a customer project
  /// in order to be deployed to Serverpod Cloud.
  ///
  /// If the dependencies are not valid,
  /// the returned list will contain the error messages.
  /// If the dependencies are valid, the list will be empty.
  List<String> projectDependencyIssues() {
    final supportedSdk = VersionConstraint.parse('>=3.6.0 <3.7.0');
    final supportedServerpod = VersionConstraint.parse('>=2.3.0');

    final sdkError = _validateSdkConstraint(supportedSdk);

    final serverpodError = _validateHostedDependencyConstraint(
      'serverpod',
      supportedServerpod,
    );

    return [
      if (sdkError != null) sdkError,
      if (serverpodError != null) serverpodError,
    ];
  }

  /// The SDK constraint is handled differently than other dependencies.
  /// It represents what SDK versions are supported by the project,
  /// including the SDK the deployed project is built with.
  String? _validateSdkConstraint(
    final VersionConstraint supportedSdk,
  ) {
    final sdkConstraint = pubspec.environment['sdk'];
    if (sdkConstraint == null) {
      return 'No sdk constraint found in pubspec.yaml';
    }
    if (!sdkConstraint.allowsAll(supportedSdk)) {
      return 'Unsupported sdk version constraint: $sdkConstraint'
          ' (must accept: $supportedSdk)';
    }
    return null;
  }

  /// Validates that the given dependency is hosted
  /// and is within the supported range.
  String? _validateHostedDependencyConstraint(
    final String packageName,
    final VersionConstraint supported,
  ) {
    final dependency = pubspec.dependencies[packageName];
    if (dependency == null) {
      return 'No $packageName dependency found in pubspec.yaml';
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
}
