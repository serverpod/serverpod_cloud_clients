import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:serverpod_cloud_cli/util/package_graph/package_graph.dart';
import 'package:yaml_codec/yaml_codec.dart';

import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart'
    show FailureException;
import 'package:serverpod_cloud_cli/util/flutter_platform.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/file_finder.dart';
import 'package:serverpod_cloud_cli/util/scloudignore.dart';

class WorkspaceException extends FailureException {
  WorkspaceException([
    Iterable<String>? errors,
    Exception? nestedException,
    StackTrace? nestedStackTrace,
    String? hint,
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

  /// Whether the filtered workspace root pubspec keeps its Flutter SDK
  /// constraint.
  final bool keepFlutterEnvironment;

  /// Paths below the included sub paths, relative to [rootDirectory], whose
  /// files are left out.
  final List<String> excludedSubPaths;
  PackageGraph? _packageGraph;

  ProjectFilePreparer({
    required this.isWorkspace,
    required this.rootDirectory,
    required this.scloudDir,
    required this.includedSubPaths,
    required this.includedPackagePaths,
    required this.projectPackageName,
    this.keepFlutterEnvironment = false,
    this.excludedSubPaths = const [],
    PackageGraph? packageGraph,
  }) : _packageGraph = packageGraph;

  /// Whether the file at [relativePath], relative to [rootDirectory],
  /// is left out by [excludedSubPaths].
  bool isExcluded(String relativePath) {
    return excludedSubPaths.any(
      (excluded) =>
          p.equals(excluded, relativePath) ||
          p.isWithin(excluded, relativePath),
    );
  }

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

  String filterPubspecYaml(String content) {
    final decoded = yamlDecode(content);
    if (decoded is Map && decoded['workspace'] is List) {
      return WorkspaceProjectLogic.makeScloudRootPubspecContent(
        content,
        includedPackagePaths,
        keepFlutterEnvironment: keepFlutterEnvironment,
      );
    }

    final filteredContent =
        TenantProject.stripDevDependenciesFromPubspecContent(content);
    return filteredContent ?? content;
  }

  String filterPubspecLock(String content) {
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
  static const _scloudAppDirFilename = 'scloud_app_dir';
  static const _selectAppDirectoryHint =
      'Select the Flutter app directory with the --app-dir option, '
      'or with project.appDir in scloud.yaml.';

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
    Directory projectDirectory, {
    required TenantProjectPubspec tenantProjectPubspec,
    String? scloudDirPath,
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

    return _prepareWorkspace(
      projectDirectory,
      projectPackageName: projectPackageName,
      projectDirFilename: _scloudServerDirFilename,
      validateIncludedPackages: WorkspaceProjectLogic.validateIncludedPackages,
      pubGetCommand: 'dart pub get',
      keepFlutterEnvironment: false,
      scloudDirPath: scloudDirPath,
    );
  }

  /// Analyzes the Flutter app in [appDirectory] and compiles the list of
  /// paths whose contents are to be included.
  ///
  /// For an app resolved in a Dart workspace, bespoke deployment files are
  /// created, and the app, the workspace packages it depends on, and the
  /// workspace root files are included. Otherwise only the app directory is
  /// included.
  ///
  /// When [platforms] is given, the code of the other platforms is left out.
  ///
  /// Specify [scloudDirPath] to override the default scloud directory path.
  ///
  /// Returns a [ProjectFilePreparer] object to be used to filter project files.
  ///
  /// Throws [WorkspaceException] if [appDirectory] is not a Flutter app,
  /// if its package graph is missing, or if the preparation fails.
  /// Throws [FailureException] if the app has no code for one of [platforms].
  static ProjectFilePreparer prepareApp(
    Directory appDirectory, {
    Set<FlutterPlatform>? platforms,
    String? scloudDirPath,
  }) {
    final appPubspec = TenantProjectPubspec.fromProjectDir(appDirectory);
    if (!appPubspec.isFlutterApp()) {
      _throwWorkspaceException(
        message: 'The directory ${appDirectory.path} is not a Flutter app.',
        hint: 'A Flutter app depends on the Flutter SDK.',
      );
    }

    final excludedPlatformPaths = platforms == null
        ? const <String>[]
        : _excludedPlatformPaths(appDirectory, platforms);

    if (!appPubspec.isWorkspaceResolved()) {
      WorkspaceProjectLogic.validateIncludedAppPackages([appPubspec.pubspec]);

      return ProjectFilePreparer(
        isWorkspace: false,
        rootDirectory: appDirectory,
        scloudDir: Directory(scloudDirPath ?? ScloudIgnore.scloudDirName),
        includedSubPaths: const ['.'],
        includedPackagePaths: [],
        projectPackageName: appPubspec.pubspec.name,
        keepFlutterEnvironment: true,
        excludedSubPaths: excludedPlatformPaths,
        packageGraph: _loadAppPackageGraph(appDirectory),
      );
    }

    return _prepareWorkspace(
      appDirectory,
      projectPackageName: appPubspec.pubspec.name,
      excludedProjectSubPaths: excludedPlatformPaths,
      projectDirFilename: _scloudAppDirFilename,
      validateIncludedPackages:
          WorkspaceProjectLogic.validateIncludedAppPackages,
      pubGetCommand: 'flutter pub get',
      keepFlutterEnvironment: true,
      scloudDirPath: scloudDirPath,
    );
  }

  /// Loads the package graph of the non-workspace app in [appDirectory].
  ///
  /// Throws [WorkspaceException] if the package graph is missing.
  static PackageGraph _loadAppPackageGraph(Directory appDirectory) {
    try {
      return PackageGraphParser.fromProjectDirectory(appDirectory);
    } on PackageGraphFileNotFoundException {
      _throwWorkspaceException(
        message: 'The package graph of the app was not found.',
        hint: 'Run "flutter pub get" in the app directory.',
      );
    }
  }

  /// Finds the Flutter app of the Serverpod project in [serverDirectory].
  ///
  /// For a server resolved in a Dart workspace, the app is looked for among
  /// the packages of the workspace. Otherwise it is looked for in the server
  /// directory and in the directory above it, a few levels down.
  ///
  /// Throws [WorkspaceException] if no or several Flutter apps are found.
  static Directory findAppDirectory(Directory serverDirectory) {
    final serverPubspec = TenantProjectPubspec.fromProjectDir(serverDirectory);
    final isWorkspace = serverPubspec.isWorkspaceResolved();

    final Directory searchRootDir;
    if (isWorkspace) {
      final (workspaceRootDir, _) = findWorkspaceRoot(serverDirectory);
      searchRootDir = workspaceRootDir;
    } else {
      searchRootDir = Directory(
        p.normalize(serverDirectory.absolute.path),
      ).parent;
    }

    final findAppPubspec = scloudFileFinder<void>(
      fileBaseName: 'pubspec',
      supportedExtensions: ['yaml'],
      startingDirectory: (_) =>
          isWorkspace ? searchRootDir.path : serverDirectory.path,
      searchLevelsUp: isWorkspace ? 0 : 1,
      fileContentCondition: (filePath) =>
          _isFlutterApp(Directory(p.dirname(filePath))),
    );

    final String? appPubspecPath;
    try {
      appPubspecPath = findAppPubspec(null);
    } on AmbiguousSearchException catch (e) {
      final appPaths =
          e.matches
              .map(
                (match) =>
                    p.relative(p.dirname(match), from: searchRootDir.path),
              )
              .toList()
            ..sort();
      _throwWorkspaceException(
        messages: ['Found several Flutter apps:', ...appPaths],
        hint: _selectAppDirectoryHint,
      );
    }

    if (appPubspecPath == null) {
      _throwWorkspaceException(
        message: 'No Flutter app found.',
        hint: _selectAppDirectoryHint,
      );
    }
    return Directory(p.dirname(appPubspecPath));
  }

  static bool _isFlutterApp(Directory directory) {
    try {
      return TenantProjectPubspec.fromProjectDir(directory).isFlutterApp();
    } on Exception {
      return false;
    }
  }

  /// Returns the platform directories of the app in [appDirectory] that do
  /// not belong to [platforms], relative to the app.
  ///
  /// Throws [FailureException] if the app has no code for one of [platforms].
  static List<String> _excludedPlatformPaths(
    Directory appDirectory,
    Set<FlutterPlatform> platforms,
  ) {
    final presentPlatforms = {
      for (final platform in FlutterPlatform.values)
        if (Directory(
          p.join(appDirectory.path, platform.directoryName),
        ).existsSync())
          platform,
    };

    final missingPlatforms = FlutterPlatform.values.where(
      (platform) =>
          platforms.contains(platform) && !presentPlatforms.contains(platform),
    );
    if (missingPlatforms.isNotEmpty) {
      final names = missingPlatforms.map((platform) => platform.name);
      throw FailureException(
        error: 'The app has no code for the platforms: ${names.join(', ')}.',
        hint:
            'Add them with "flutter create --platforms=${names.join(',')} ." '
            'in the app directory, or leave them out of --platforms.',
      );
    }

    return [
      for (final platform in presentPlatforms.difference(platforms))
        platform.directoryName,
    ];
  }

  static ProjectFilePreparer _prepareWorkspace(
    Directory projectDirectory, {
    required String projectPackageName,
    List<String> excludedProjectSubPaths = const [],
    required String projectDirFilename,
    required void Function(Iterable<Pubspec>) validateIncludedPackages,
    required String pubGetCommand,
    required bool keepFlutterEnvironment,
    String? scloudDirPath,
  }) {
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

    validateIncludedPackages(
      includedPackages.values.map((package) => package.pubspec),
    );

    final includedPackagePaths = includedPackages.values
        .map((package) => package.dir.path)
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
        projectPackage,
        projectDirFilename: projectDirFilename,
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
        keepFlutterEnvironment: keepFlutterEnvironment,
        excludedSubPaths: [
          for (final subPath in excludedProjectSubPaths)
            p.join(projectPackage.dir.path, subPath),
        ],
        packageGraph: packageGraph,
      );
    } on PackageGraphFileNotFoundException catch (e) {
      final tailPath = p.relative(e.projectPath, from: workspaceRootDir.path);
      _throwWorkspaceException(
        message: '$tailPath not found.',
        nestedException: null,
        nestedStackTrace: null,
        hint: 'Run "$pubGetCommand"',
      );
    }
  }

  /// Writes the .scloud directory and files,
  /// and creates the .scloudignore file if it doesn't exist.
  static void _writeSCloudFiles(
    Directory workspaceRootDir,
    Directory scloudDir,
    WorkspacePackage projectPackage, {
    required String projectDirFilename,
  }) {
    _deleteOldScloudRootPubspec(scloudDir);

    _writeProjectDirFile(scloudDir, projectPackage.dir, projectDirFilename);

    ScloudIgnore.writeTemplateIfNotExists(rootFolder: workspaceRootDir.path);
  }

  static String _getPackageName(Directory packageDirectory) {
    final pubspecFile = File(p.join(packageDirectory.path, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      _throwWorkspaceException(
        message: "pubspec.yaml not found in $packageDirectory.",
      );
    }
    final pubspec = Pubspec.parse(pubspecFile.readAsStringSync());
    return pubspec.name;
  }

  /// Deletes obsolete scloud root pubspec file if it exists.
  static void _deleteOldScloudRootPubspec(Directory scloudDir) {
    final scloudRootPubspecFile = File(
      p.join(scloudDir.path, _scloudRootPubspecFilename),
    );
    if (scloudRootPubspecFile.existsSync()) {
      scloudRootPubspecFile.deleteSync();
    }
  }

  /// Writes the file [filename] holding the project package directory to
  /// the scloud directory and returns its path relative to the workspace root.
  static String _writeProjectDirFile(
    Directory scloudDir,
    Directory projectDir,
    String filename,
  ) {
    final projectDirFile = File(p.join(scloudDir.path, filename));
    projectDirFile.writeAsStringSync(projectDir.path);

    return p.join(ScloudIgnore.scloudDirName, filename);
  }

  /// Finds the workspace root directory above the project directory.
  /// Returns a tuple with the workspace root directory and a [Pubspec] object
  /// for its pubspec.yaml file.
  ///
  /// Throws [WorkspaceException] if no workspace root is found.
  static (Directory, Pubspec) findWorkspaceRoot(Directory projectDir) {
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

  /// Returns the directory that holds the tenant project's `pubspec.lock`.
  static Directory resolveLockfileDirectory(
    Directory projectDirectory, {
    required bool isWorkspaceResolved,
  }) {
    if (!isWorkspaceResolved) {
      return projectDirectory;
    }
    final (workspaceRootDir, _) = findWorkspaceRoot(projectDirectory);
    return workspaceRootDir;
  }

  /// Strips dev_dependencies from pubspec.yaml content in memory.
  /// Returns the modified content, or null if no changes were needed.
  static String? stripDevDependenciesFromPubspecContent(String pubspecContent) {
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
    String? message,
    String? hint,
    Iterable<String>? messages,
    Exception? nestedException,
    StackTrace? nestedStackTrace,
  }) {
    final allMessages = [?message, ...?messages];
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
    required Map<String, WorkspacePackage> allWorkspacePackages,
    required WorkspacePackage package,
    required Map<String, WorkspacePackage> included,
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
  ///
  /// Throws [WorkspaceException] if any issues are found.
  static void validateIncludedPackages(
    Iterable<Pubspec> includedPackagePubspecs,
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

  /// Validates that the included packages of a Flutter app are compatible
  /// with Serverpod Cloud.
  ///
  /// Throws [WorkspaceException] if any issues are found.
  static void validateIncludedAppPackages(
    Iterable<Pubspec> includedPackagePubspecs,
  ) {
    final issues = [
      for (final pubspec in includedPackagePubspecs)
        ...TenantProjectPubspec(pubspec).appDependencyIssues(),
    ];
    if (issues.isNotEmpty) {
      TenantProject._throwWorkspaceException(messages: issues);
    }
  }

  /// Creates the scloud root pubspec content based on
  /// the source root pubspec content.
  ///
  /// The Flutter SDK constraint is removed unless [keepFlutterEnvironment]
  /// is set.
  static String makeScloudRootPubspecContent(
    String rootPubspecContent,
    Iterable<String> includedPackagePaths, {
    bool keepFlutterEnvironment = false,
  }) {
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
    if (!keepFlutterEnvironment && environment is Map) {
      final newEnvironment = Map.from(environment);
      newEnvironment.remove('flutter');
      scloudRootPubspec['environment'] = newEnvironment;
    }

    return yamlEncode(scloudRootPubspec);
  }
}
