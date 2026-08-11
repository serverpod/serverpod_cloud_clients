import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:serverpod_cloud_cli/util/package_graph/package_graph.dart';
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
    final String? hint,
  ]) : super(
         errors: errors,
         hint: hint,
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

class ProjectFilePreparer {
  final bool isWorkspace;
  final Directory rootDirectory;
  final Directory scloudDir;
  final List<String> includedSubPaths;
  final List<String> includedPackagePaths;
  final String projectPackageName;
  PackageGraph? _packageGraph;

  ProjectFilePreparer({
    required this.isWorkspace,
    required this.rootDirectory,
    required this.scloudDir,
    required this.includedSubPaths,
    required this.includedPackagePaths,
    required this.projectPackageName,
    final PackageGraph? packageGraph,
  }) : _packageGraph = packageGraph;

  /// The package dependency graph for lockfile filtering.
  ///
  /// Loaded eagerly for workspace projects. For non-workspace projects it is
  /// loaded lazily on first use (when filtering a `pubspec.lock`).
  PackageGraph get packageGraph {
    final cached = _packageGraph;
    if (cached != null) {
      return cached;
    }
    final loaded = PackageGraphParser.fromProjectDirectory(rootDirectory);
    _packageGraph = loaded;
    return loaded;
  }

  String filterPubspecYaml(final String content) {
    final decoded = yamlDecode(content);
    if (decoded is Map && decoded['workspace'] is List) {
      return WorkspaceProjectLogic.makeScloudRootPubspecContent(
        content,
        includedPackagePaths,
      );
    }

    final filteredContent =
        TenantProject.stripDevDependenciesFromPubspecContent(content);
    return filteredContent ?? content;
  }

  String filterPubspecLock(final String content) {
    final graph = packageGraph;
    final allPackages = graph.allPackageNames();
    final (unreachable, demotedToTransitive) = graph.unreachablePackages([
      projectPackageName,
    ]);
    final expectedRemainingPackages = allPackages.difference(unreachable);

    final (filteredContent, _) = PubspecLockFilter.filter(
      content: content,
      packagesToRemove: unreachable,
      packagesToDemote: demotedToTransitive,
      expectedRemainingPackages: expectedRemainingPackages,
      scriptName: 'scloud',
    );

    return filteredContent;
  }
}

abstract class TenantProject {
  static const _scloudRootPubspecFilename = 'scloud_ws_pubspec.yaml';
  static const _scloudServerDirFilename = 'scloud_server_dir';

  /// Analyzes the tenant project structure, creates bespoke deployment files,
  /// and compiles the list of paths whose contents are to be included.
  ///
  /// Specify [scloudDirPath] to override the default scloud directory path.
  ///
  /// Returns a [ProjectFilePreparer] object to be used to filter project files.
  ///
  /// If no workspace root is found, or the preparation fails,
  /// error messages will be logged and [WorkspaceException] is thrown.
  static ProjectFilePreparer prepare(
    final Directory projectDirectory, {
    required final TenantProjectPubspec tenantProjectPubspec,
    final String? scloudDirPath,
  }) {
    final String projectPackageName = _getPackageName(projectDirectory);

    if (!tenantProjectPubspec.isWorkspaceResolved()) {
      return ProjectFilePreparer(
        isWorkspace: false,
        rootDirectory: projectDirectory,
        scloudDir: Directory(scloudDirPath ?? ScloudIgnore.scloudDirName),
        includedSubPaths: const ['.'],
        includedPackagePaths: [],
        projectPackageName: projectPackageName,
      );
    }

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

    final scloudDir = Directory(
      scloudDirPath ??
          p.join(workspaceRootDir.path, ScloudIgnore.scloudDirName),
    );
    scloudDir.createSync(recursive: true);

    try {
      _writeSCloudFiles(
        workspaceRootDir,
        scloudDir,
        includedPackagePaths,
        projectPackage,
      );

      final includedPaths = [
        ...includedPackagePaths,
        'pubspec.yaml',
        'pubspec.lock',
        ScloudIgnore.scloudDirName,
      ];

      final packageGraph = PackageGraphParser.fromProjectDirectory(
        workspaceRootDir,
      );

      return ProjectFilePreparer(
        isWorkspace: true,
        rootDirectory: workspaceRootDir,
        scloudDir: scloudDir,
        includedSubPaths: includedPaths,
        includedPackagePaths: includedPackagePaths,
        projectPackageName: projectPackageName,
        packageGraph: packageGraph,
      );
    } on PackageGraphFileNotFoundException catch (e) {
      final tailPath = p.relative(e.projectPath, from: workspaceRootDir.path);
      _throwWorkspaceException(
        message: '$tailPath not found.',
        nestedException: null,
        nestedStackTrace: null,
        hint: 'Run "dart pub get"',
      );
    }
  }

  /// Writes the .scloud directory and files,
  /// and creates the .scloudignore file if it doesn't exist.
  static void _writeSCloudFiles(
    final Directory workspaceRootDir,
    final Directory scloudDir,
    final List<String> includedPackagePaths,
    final WorkspacePackage projectPackage,
  ) {
    _writeScloudRootPubspec(workspaceRootDir, scloudDir, includedPackagePaths);
    _writeProjectServerDirFile(scloudDir, projectPackage.dir);

    ScloudIgnore.writeTemplateIfNotExists(rootFolder: workspaceRootDir.path);
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
    final Directory scloudDir,
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
      p.join(scloudDir.path, _scloudRootPubspecFilename),
    );
    scloudRootPubspecFile.writeAsStringSync(scloudRootPubspecContent);

    return p.join(ScloudIgnore.scloudDirName, _scloudRootPubspecFilename);
  }

  /// Writes the project server dir file to the workspace root directory
  /// and returns its path relative to the workspace root.
  static String _writeProjectServerDirFile(
    final Directory scloudDir,
    final Directory projectDir,
  ) {
    final scloudServerDirFile = File(
      p.join(scloudDir.path, _scloudServerDirFilename),
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
      final parentDir = currentDir.parent;
      if (currentDir.path == parentDir.path) break;
      currentDir = parentDir;
    } while (true);

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
    final String? hint,
    final Iterable<String>? messages,
    final Exception? nestedException,
    final StackTrace? nestedStackTrace,
  }) {
    final allMessages = [if (message != null) message, ...?messages];
    throw WorkspaceException(
      allMessages,
      nestedException,
      nestedStackTrace,
      hint,
    );
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
      TenantProject._throwWorkspaceException(messages: issues);
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
      TenantProject._throwWorkspaceException(
        message:
            'Invalid workspace root pubspec.yaml, '
            'type: ${rootPubspecYaml.runtimeType}',
      );
    }

    final originalWorkspacePaths = rootPubspecYaml['workspace'];
    if (originalWorkspacePaths is! List) {
      TenantProject._throwWorkspaceException(
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
