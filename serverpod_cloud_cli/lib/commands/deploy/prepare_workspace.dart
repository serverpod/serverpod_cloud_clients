import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:yaml_codec/yaml_codec.dart';

import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';
import 'package:serverpod_cloud_cli/util/scloudignore.dart';

class _WorkspacePackage {
  /// relative path to the package in the workspace
  final Directory dir;

  /// pubspec.yaml of the package
  final Pubspec pubspec;

  _WorkspacePackage(this.dir, this.pubspec);
}

class WorkspaceProject {
  static const _scloudRootPubspecFilename = 'scloud_ws_pubspec.yaml';
  static const _scloudServerDirFilename = 'scloud_server_dir';

  /// Analyzes the workspace, creates bespoke deployment files,
  /// and compiles the list of paths whose contents are to be included.
  static (Directory, Iterable<String>) prepareWorkspacePaths(
    final CommandLogger logger,
    final Directory projectDirectory,
    final String projectPackageName,
  ) {
    // Find workspace root directory by traversing up until we find a pubspec.yaml with workspace field
    final (workspaceRootDir, workspacePubspec) =
        _findWorkspaceRoot(logger, projectDirectory);

    ScloudIgnore.writeTemplateIfNotExists(
      logger: logger,
      rootFolder: workspaceRootDir.path,
    );

    // create map with all workspace packages, map from package name to [WorkspacePackage]
    final allWorkspacePackages = <String, _WorkspacePackage>{};
    for (final packagePath in workspacePubspec.workspace!) {
      final pubspec = Pubspec.parse(
        File(
          p.join(workspaceRootDir.path, packagePath, 'pubspec.yaml'),
        ).readAsStringSync(),
      );
      allWorkspacePackages[pubspec.name] = _WorkspacePackage(
        Directory(packagePath),
        pubspec,
      );
    }

    final projectPackage = allWorkspacePackages[projectPackageName];
    if (projectPackage == null) {
      _throwErrorExitException(logger,
          "The project's package was not found among the workspace's packages.");
    }

    final includedPackages = _getWorkspaceDependencies(
      allWorkspacePackages: allWorkspacePackages,
      package: projectPackage,
      included: <String, _WorkspacePackage>{
        projectPackageName: projectPackage,
      },
    );

    _validateIncludedPackages(
      logger,
      includedPackages.values.map((final package) => package.pubspec),
    );

    final includedPackagePaths = includedPackages.values
        .map((final package) => package.dir.path)
        .toList();

    final scloudDir =
        Directory(p.join(workspaceRootDir.path, ScloudIgnore.scloudDirName));
    scloudDir.createSync();

    _writeScloudRootPubspec(logger, workspaceRootDir, includedPackagePaths);
    _writeProjectServerDirFile(workspaceRootDir, projectPackage.dir);

    final includedPaths = [
      ...includedPackagePaths,
      ScloudIgnore.scloudDirName,
    ];

    return (workspaceRootDir, includedPaths);
  }

  /// Recursively gets all workspace dependencies of a package, without duplicates.
  static Map<String, _WorkspacePackage> _getWorkspaceDependencies({
    required final Map<String, _WorkspacePackage> allWorkspacePackages,
    required final _WorkspacePackage package,
    required final Map<String, _WorkspacePackage> included,
  }) {
    for (final packageDependency in package.pubspec.dependencies.entries) {
      final workspaceDependency = allWorkspacePackages[packageDependency.key];
      if (workspaceDependency != null) {
        if (!included.containsKey(packageDependency.key)) {
          included[packageDependency.key] = workspaceDependency;
          _getWorkspaceDependencies(
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
  /// Throws [ErrorExitException] if any issues are found.
  static void _validateIncludedPackages(
    final CommandLogger logger,
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
      for (final issue in issues) {
        logger.error(issue);
      }
      throw ErrorExitException(issues.first);
    }
  }

  /// Writes the scloud root pubspec file to the workspace root directory
  /// and returns its path relative to the workspace root.
  static String _writeScloudRootPubspec(
    final CommandLogger logger,
    final Directory workspaceRootDir,
    final Iterable<String> includedPackagePaths,
  ) {
    final rootPubspecFile = File(p.join(workspaceRootDir.path, 'pubspec.yaml'));

    final rootPubspecYaml = yamlDecode(rootPubspecFile.readAsStringSync());
    if (rootPubspecYaml is! Map) {
      _throwErrorExitException(
        logger,
        'Invalid workspace root pubspec.yaml, type: ${rootPubspecYaml.runtimeType}',
      );
    }

    final originalWorkspacePaths = rootPubspecYaml['workspace'];
    if (originalWorkspacePaths is! List) {
      _throwErrorExitException(
        logger,
        'Invalid `workspace` element in workspace root pubspec.yaml, '
        'type: ${originalWorkspacePaths.runtimeType}',
      );
    }

    logger.list(
      title: 'Including workspace packages',
      includedPackagePaths,
    );
    if (originalWorkspacePaths.length > includedPackagePaths.length) {
      logger.list(
        title: 'Excluding workspace packages',
        originalWorkspacePaths
            .where((final p) => !includedPackagePaths.contains(p))
            .toList()
            .cast<String>(),
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

    final scloudRootPubspecFile = File(p.join(
      workspaceRootDir.path,
      ScloudIgnore.scloudDirName,
      _scloudRootPubspecFilename,
    ));
    scloudRootPubspecFile.writeAsStringSync(yamlEncode(scloudRootPubspec));

    return p.join(ScloudIgnore.scloudDirName, _scloudRootPubspecFilename);
  }

  /// Writes the project server dir file to the workspace root directory
  /// and returns its path relative to the workspace root.
  static String _writeProjectServerDirFile(
    final Directory workspaceRootDir,
    final Directory projectDir,
  ) {
    final scloudServerDirFile = File(p.join(
      workspaceRootDir.path,
      ScloudIgnore.scloudDirName,
      _scloudServerDirFilename,
    ));
    scloudServerDirFile.writeAsStringSync(projectDir.path);

    return p.join(ScloudIgnore.scloudDirName, _scloudServerDirFilename);
  }

  /// Finds the workspace root directory above the project directory.
  /// Throws [ErrorExitException] if no workspace root is found.
  static (Directory, Pubspec) _findWorkspaceRoot(
    final CommandLogger logger,
    final Directory projectDir,
  ) {
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
          _throwErrorExitException(logger, 'Failed to parse $pubspecFile.',
              exception: e, stackTrace: s);
        }
      }
    } while (currentDir.path != currentDir.parent.path);

    _throwErrorExitException(
      logger,
      'Could not find the workspace root directory.',
      hint: 'Ensure the project is part of a valid Dart workspace.',
    );
  }

  /// Prints an error message for the user
  /// and throws an [ErrorExitException] with that as the reason.
  static Never _throwErrorExitException(
    final CommandLogger logger,
    final String message, {
    final String? hint,
    final Exception? exception,
    final StackTrace? stackTrace,
  }) {
    logger.error(
      message,
      hint: hint,
      exception: exception,
      stackTrace: stackTrace,
    );
    throw ErrorExitException(message, exception, stackTrace);
  }
}
