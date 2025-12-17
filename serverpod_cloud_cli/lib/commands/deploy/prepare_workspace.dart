import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:yaml_codec/yaml_codec.dart';

import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart'
    show FailureException;
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';
import 'package:serverpod_cloud_cli/util/scloudignore.dart';

class WorkspaceException extends FailureException {
  WorkspaceException([
    final Iterable<String>? errors,
    final Exception? nestedException,
    final StackTrace? nestedStackTrace,
  ]) : super(
         errors: errors,
         nestedException: nestedException,
         nestedStackTrace: nestedStackTrace,
       );
}

class WorkspacePackage {
  /// relative path to the package in the workspace
  final Directory dir;

  /// pubspec.yaml of the package
  final Pubspec pubspec;

  WorkspacePackage(this.dir, this.pubspec);
}

abstract class WorkspaceProject {
  static const _scloudRootPubspecFilename = 'scloud_ws_pubspec.yaml';
  static const _scloudServerDirFilename = 'scloud_server_dir';

  /// Analyzes the workspace, creates bespoke deployment files,
  /// and compiles the list of paths whose contents are to be included.
  ///
  /// Returns a tuple with the workspace root directory and the list of
  /// subpaths in the root directory to include.
  ///
  /// If the preparation fails, error messages will be logged
  /// and [WorkspaceException] is thrown.
  static (Directory, Iterable<String>) prepareWorkspacePaths(
    final Directory projectDirectory,
  ) {
    final String projectPackageName = _getPackageName(projectDirectory);

    // Find workspace root directory by traversing up until we find a pubspec.yaml with workspace field
    final (workspaceRootDir, workspacePubspec) = findWorkspaceRoot(
      projectDirectory,
    );

    // create map with all workspace packages, map from package name to [WorkspacePackage]
    final allWorkspacePackages = <String, WorkspacePackage>{};
    for (final packagePath in workspacePubspec.workspace ?? []) {
      final pubspec = Pubspec.parse(
        File(
          p.join(workspaceRootDir.path, packagePath, 'pubspec.yaml'),
        ).readAsStringSync(),
      );
      allWorkspacePackages[pubspec.name] = WorkspacePackage(
        Directory(packagePath),
        pubspec,
      );
    }

    final projectPackage = allWorkspacePackages[projectPackageName];
    if (projectPackage == null) {
      _throwWorkspaceException(
        message:
            "The project's package wasn't found among the workspace's packages.",
      );
    }

    final includedPackages = WorkspaceProjectLogic.getWorkspaceDependencies(
      allWorkspacePackages: allWorkspacePackages,
      package: projectPackage,
      included: <String, WorkspacePackage>{projectPackageName: projectPackage},
    );

    WorkspaceProjectLogic.validateIncludedPackages(
      includedPackages.values.map((final package) => package.pubspec),
    );

    final includedPackagePaths = includedPackages.values
        .map((final package) => package.dir.path)
        .toList();

    _writeSCloudFiles(workspaceRootDir, includedPackagePaths, projectPackage);

    final includedPaths = [...includedPackagePaths, ScloudIgnore.scloudDirName];
    return (workspaceRootDir, includedPaths);
  }

  /// Writes the .scloud directory and files,
  /// and creates the .scloudignore file if it doesn't exist.
  static void _writeSCloudFiles(
    final Directory workspaceRootDir,
    final List<String> includedPackagePaths,
    final WorkspacePackage projectPackage,
  ) {
    final scloudDir = Directory(
      p.join(workspaceRootDir.path, ScloudIgnore.scloudDirName),
    );
    scloudDir.createSync();

    _writeScloudRootPubspec(workspaceRootDir, includedPackagePaths);
    _writeProjectServerDirFile(workspaceRootDir, projectPackage.dir);

    final serverDirPath = p.join(
      workspaceRootDir.path,
      projectPackage.dir.path,
    );
    ScloudIgnore.writeTemplateIfNotExists(rootFolder: serverDirPath);
  }

  static String _getPackageName(final Directory packageDirectory) {
    final pubspecFile = File(p.join(packageDirectory.path, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      _throwWorkspaceException(
        message: "pubspec.yaml not found in $packageDirectory.",
      );
    }
    final pubspec = Pubspec.parse(pubspecFile.readAsStringSync());
    return pubspec.name;
  }

  /// Writes the scloud root pubspec file to the workspace root directory
  /// and returns its path relative to the workspace root.
  static String _writeScloudRootPubspec(
    final Directory workspaceRootDir,
    final Iterable<String> includedPackagePaths,
  ) {
    final rootPubspecFile = File(p.join(workspaceRootDir.path, 'pubspec.yaml'));
    final rootPubspecContent = rootPubspecFile.readAsStringSync();

    final scloudRootPubspecContent =
        WorkspaceProjectLogic.makeScloudRootPubspecContent(
          rootPubspecContent,
          includedPackagePaths,
        );

    final scloudRootPubspecFile = File(
      p.join(
        workspaceRootDir.path,
        ScloudIgnore.scloudDirName,
        _scloudRootPubspecFilename,
      ),
    );
    scloudRootPubspecFile.writeAsStringSync(scloudRootPubspecContent);

    return p.join(ScloudIgnore.scloudDirName, _scloudRootPubspecFilename);
  }

  /// Writes the project server dir file to the workspace root directory
  /// and returns its path relative to the workspace root.
  static String _writeProjectServerDirFile(
    final Directory workspaceRootDir,
    final Directory projectDir,
  ) {
    final scloudServerDirFile = File(
      p.join(
        workspaceRootDir.path,
        ScloudIgnore.scloudDirName,
        _scloudServerDirFilename,
      ),
    );
    scloudServerDirFile.writeAsStringSync(projectDir.path);

    return p.join(ScloudIgnore.scloudDirName, _scloudServerDirFilename);
  }

  /// Finds the workspace root directory above the project directory.
  /// Returns a tuple with the workspace root directory and a [Pubspec] object
  /// for its pubspec.yaml file.
  ///
  /// Throws [WorkspaceException] if no workspace root is found.
  static (Directory, Pubspec) findWorkspaceRoot(final Directory projectDir) {
    var currentDir = projectDir.absolute;
    do {
      currentDir = currentDir.parent;
      final pubspecFile = File(p.join(currentDir.path, 'pubspec.yaml'));
      if (pubspecFile.existsSync()) {
        try {
          final pubspec = Pubspec.parse(pubspecFile.readAsStringSync());
          if (pubspec.workspace != null) {
            return (currentDir, pubspec);
          }
        } on Exception catch (e, s) {
          _throwWorkspaceException(
            message: 'Failed to parse $pubspecFile.',
            nestedException: e,
            nestedStackTrace: s,
          );
        }
      }
    } while (currentDir.path != currentDir.parent.path);

    _throwWorkspaceException(
      messages: [
        'Could not find the workspace root directory.',
        'Ensure the project is part of a valid Dart workspace.',
      ],
    );
  }

  /// Strips dev_dependencies from pubspec.yaml content in memory.
  /// Returns the modified content, or null if no changes were needed.
  static String? stripDevDependenciesFromPubspecContent(
    final String pubspecContent,
  ) {
    try {
      final pubspecYaml = yamlDecode(pubspecContent);
      if (pubspecYaml is! Map) {
        return null;
      }

      if (pubspecYaml.containsKey('dev_dependencies')) {
        final modifiedPubspec = Map.from(pubspecYaml);
        modifiedPubspec.remove('dev_dependencies');
        return yamlEncode(modifiedPubspec);
      }
      return null;
    } on Exception {
      return null;
    }
  }

  /// Throws a [WorkspaceException] with one or more error messages.
  static Never _throwWorkspaceException({
    final String? message,
    final Iterable<String>? messages,
    final Exception? nestedException,
    final StackTrace? nestedStackTrace,
  }) {
    final allMessages = [if (message != null) message, ...?messages];
    throw WorkspaceException(allMessages, nestedException, nestedStackTrace);
  }
}

/// Logic (pure functions) for workspace project preparation.
abstract class WorkspaceProjectLogic {
  /// Recursively gets all workspace dependencies of a package, without duplicates.
  static Map<String, WorkspacePackage> getWorkspaceDependencies({
    required final Map<String, WorkspacePackage> allWorkspacePackages,
    required final WorkspacePackage package,
    required final Map<String, WorkspacePackage> included,
  }) {
    for (final packageDependency in package.pubspec.dependencies.entries) {
      final workspaceDependency = allWorkspacePackages[packageDependency.key];
      if (workspaceDependency != null) {
        if (!included.containsKey(packageDependency.key)) {
          included[packageDependency.key] = workspaceDependency;
          getWorkspaceDependencies(
            allWorkspacePackages: allWorkspacePackages,
            package: workspaceDependency,
            included: included,
          );
        }
      }
    }
    return included;
  }

  /// Validates that the included packages are compatible with Serverpod Cloud.
  /// Throws [WorkspaceException] if any issues are found.
  static void validateIncludedPackages(
    final Iterable<Pubspec> includedPackagePubspecs,
  ) {
    final List<String> issues = [];
    for (final pubspec in includedPackagePubspecs) {
      final includedPackageValidator = TenantProjectPubspec(pubspec);
      issues.addAll(
        includedPackageValidator.projectDependencyIssues(
          requireServerpod: false,
        ),
      );
    }
    if (issues.isNotEmpty) {
      WorkspaceProject._throwWorkspaceException(messages: issues);
    }
  }

  /// Creates the scloud root pubspec content based on
  /// the source root pubspec content.
  static String makeScloudRootPubspecContent(
    final String rootPubspecContent,
    final Iterable<String> includedPackagePaths,
  ) {
    final rootPubspecYaml = yamlDecode(rootPubspecContent);
    if (rootPubspecYaml is! Map) {
      WorkspaceProject._throwWorkspaceException(
        message:
            'Invalid workspace root pubspec.yaml, '
            'type: ${rootPubspecYaml.runtimeType}',
      );
    }

    final originalWorkspacePaths = rootPubspecYaml['workspace'];
    if (originalWorkspacePaths is! List) {
      WorkspaceProject._throwWorkspaceException(
        message:
            'Invalid `workspace` element in workspace root pubspec.yaml, '
            'type: ${originalWorkspacePaths.runtimeType}',
      );
    }

    final scloudRootPubspec = Map.from(rootPubspecYaml);
    scloudRootPubspec['workspace'] = includedPackagePaths;
    scloudRootPubspec.remove('dependencies');
    scloudRootPubspec.remove('dev_dependencies');
    final environment = scloudRootPubspec['environment'];
    if (environment is Map) {
      final newEnvironment = Map.from(environment);
      newEnvironment.remove('flutter');
      scloudRootPubspec['environment'] = newEnvironment;
    }

    return yamlEncode(scloudRootPubspec);
  }
}
