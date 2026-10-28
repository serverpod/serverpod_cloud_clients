import 'dart:io';

import 'package:serverpod_cloud_cli/constants.dart' show VersionConstants;
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// Constructors for Serverpod project directories and files.
class ProjectFactory {
  static const defaultDirectoryName = 'serverpod_server';
  static const defaultPackageName = 'my_project_server';
  static const validSdkVersion = '"^3.8.0"';
  static const highValidSdkVersion = '"^3.10.3"';
  static const validServerpodVersion =
      '"^${VersionConstants.minSupportedServerpodVersion}"';

  /// Returns descriptor for a Serverpod server directory with a valid pubspec.yaml file.
  /// Use `descriptor.create()` to create the directory.
  static d.DirectoryDescriptor serverpodServerDir({
    String withDirectoryName = defaultDirectoryName,
    String withPackageName = defaultPackageName,
    String? withResolution,
    Iterable<d.Descriptor>? contents,
  }) {
    return d.dir(withDirectoryName, [
      serverpodServerPubspec(withPackageName: withPackageName),
      ...?contents,
    ]);
  }

  /// Returns descriptor for a valid Serverpod server pubspec.yaml file.
  /// Use `descriptor.create()` to create the file.
  static d.FileDescriptor serverpodServerPubspec({
    String withPackageName = defaultPackageName,
    String? withResolution,
  }) {
    final String resolutionString = withResolution != null
        ? 'resolution: $withResolution'
        : '';
    return d.file('pubspec.yaml', '''
name: $withPackageName
environment:
  sdk: $validSdkVersion
$resolutionString
dependencies:
  serverpod: $validServerpodVersion
''');
  }

  /// Returns descriptor for a `monorepo` Dart workspace with a Serverpod
  /// server, client, and Flutter app package, resolved with a lock file and
  /// a package graph.
  /// Use `descriptor.create()` to create the directory.
  static d.DirectoryDescriptor serverpodAppWorkspace({
    List<String> extraWorkspacePackages = const [],
    List<d.Descriptor> extraContents = const [],
  }) {
    return d.dir('monorepo', [
      d.file(
        'pubspec.yaml',
        serverpodAppWorkspaceRootPubspec(extraWorkspacePackages),
      ),
      d.file('pubspec.lock', serverpodAppWorkspaceLock),
      d.dir('.dart_tool', [
        d.file('package_graph.json', '''
{
  "roots": ["project_server", "project_client", "project_flutter"],
  "packages": [
    {"name": "project_server", "version": "0.0.0", "dependencies": ["serverpod"]},
    {"name": "project_client", "version": "0.0.0", "dependencies": ["serverpod_client"]},
    {"name": "project_flutter", "version": "0.0.0", "dependencies": ["flutter", "project_client", "serverpod_flutter"]},
    {"name": "serverpod", "version": "3.0.0", "dependencies": []},
    {"name": "serverpod_client", "version": "3.0.0", "dependencies": []},
    {"name": "serverpod_flutter", "version": "3.0.0", "dependencies": ["flutter", "serverpod_client"]},
    {"name": "flutter", "version": "0.0.0", "dependencies": []}
  ],
  "configVersion": 1
}
'''),
      ]),
      d.dir('project_server', [
        d.file('pubspec.yaml', '''
name: project_server
environment:
  sdk: $validSdkVersion
resolution: workspace
dependencies:
  serverpod: $validServerpodVersion
'''),
      ]),
      d.dir('project_client', [
        d.file('pubspec.yaml', '''
name: project_client
environment:
  sdk: $validSdkVersion
resolution: workspace
dependencies:
  serverpod_client: $validServerpodVersion
'''),
      ]),
      d.dir('project_flutter', [
        d.file('pubspec.yaml', serverpodFlutterAppPubspec()),
      ]),
      ...extraContents,
    ]);
  }

  /// Returns the pubspec.yaml content of a Serverpod Flutter app package
  /// in the [serverpodAppWorkspace].
  static String serverpodFlutterAppPubspec({
    String withPackageName = 'project_flutter',
  }) {
    return '''
name: $withPackageName
environment:
  sdk: $validSdkVersion
  flutter: 3.29.0
resolution: workspace
dependencies:
  flutter:
    sdk: flutter
  project_client: any
  serverpod_flutter: $validServerpodVersion
dev_dependencies:
  flutter_test:
    sdk: flutter
''';
  }

  /// Returns the pubspec.yaml content of a Flutter app package resolved in
  /// a workspace, without any Serverpod dependencies.
  static String flutterAppPubspec({
    String withPackageName = 'project_flutter',
  }) {
    return '''
name: $withPackageName
environment:
  sdk: $validSdkVersion
resolution: workspace
dependencies:
  flutter:
    sdk: flutter
''';
  }

  /// Returns descriptor for a `project_flutter` Flutter app that is not
  /// resolved in a workspace, with a lock file and a package graph.
  /// Use `descriptor.create()` to create the directory.
  static d.DirectoryDescriptor nonWorkspaceFlutterAppDir({
    Iterable<d.Descriptor>? contents,
  }) {
    return d.dir('project_flutter', [
      d.file('pubspec.yaml', '''
name: project_flutter
environment:
  sdk: $validSdkVersion
  flutter: 3.29.0
dependencies:
  flutter:
    sdk: flutter
dev_dependencies:
  flutter_test:
    sdk: flutter
'''),
      d.file('pubspec.lock', '''
# Generated by pub
packages:
  flutter:
    dependency: "direct main"
    description: flutter
    source: sdk
    version: "0.0.0"
sdks:
  dart: $validSdkVersion
  flutter: 3.29.0
'''),
      d.dir('.dart_tool', [
        d.file('package_graph.json', '''
{
  "roots": ["project_flutter"],
  "packages": [
    {"name": "project_flutter", "version": "0.0.0", "dependencies": ["flutter"]},
    {"name": "flutter", "version": "0.0.0", "dependencies": []}
  ],
  "configVersion": 1
}
'''),
      ]),
      ...?contents,
    ]);
  }

  /// Returns the root pubspec.yaml content of the [serverpodAppWorkspace].
  static String serverpodAppWorkspaceRootPubspec([
    List<String> extraWorkspacePackages = const [],
  ]) {
    return '''
name: monorepo
environment:
  sdk: $validSdkVersion
  flutter: 3.29.0
workspace:
  - project_server
  - project_client
  - project_flutter
${extraWorkspacePackages.map((path) => '  - $path').join('\n')}
''';
  }

  /// The pubspec.lock content of the [serverpodAppWorkspace].
  static const serverpodAppWorkspaceLock =
      '''
# Generated by pub
packages:
  flutter:
    dependency: "direct main"
    description: flutter
    source: sdk
    version: "0.0.0"
  serverpod:
    dependency: "direct main"
    description:
      name: serverpod
      sha256: "2222222222222222222222222222222222222222222222222222222222222222"
      url: "https://pub.dev"
    source: hosted
    version: "3.0.0"
  serverpod_client:
    dependency: "direct main"
    description:
      name: serverpod_client
      sha256: "3333333333333333333333333333333333333333333333333333333333333333"
      url: "https://pub.dev"
    source: hosted
    version: "3.0.0"
  serverpod_flutter:
    dependency: "direct main"
    description:
      name: serverpod_flutter
      sha256: "4444444444444444444444444444444444444444444444444444444444444444"
      url: "https://pub.dev"
    source: hosted
    version: "3.0.0"
sdks:
  dart: $validSdkVersion
  flutter: 3.29.0
''';
}

/// A class for constructing directories with files.
///
/// This is retained for its symlink capability. For other use cases,
/// use [ProjectFactory] and the test_descriptor package instead.
class DirectoryFactory {
  final List<DirectoryFactory> _subDirectories;
  final List<FileFactory> _files;
  final List<SymLinkFactory> _symLinks;
  final String _directoryName;

  /// Creates a new directory factory.
  /// The directory name is a random UUID by default.
  DirectoryFactory({
    String? withDirectoryName,
    List<DirectoryFactory>? withSubDirectories,
    List<FileFactory>? withFiles,
    List<SymLinkFactory>? withSymLinks,
  }) : _directoryName = withDirectoryName ?? const Uuid().v4(),
       _subDirectories = withSubDirectories ?? [],
       _files = withFiles ?? [],
       _symLinks = withSymLinks ?? [];

  /// Constructs the directory and all subdirectories and files.
  /// Returns the created directory.
  ///
  /// The [path] is the path to where the directory should be created.
  Directory construct(String path) {
    final directory = Directory(path);
    directory.createSync(recursive: true);

    for (final subDirectory in _subDirectories) {
      subDirectory.construct(
        '${directory.path}/${subDirectory._directoryName}',
      );
    }

    for (final file in _files) {
      file.construct(directory.path);
    }

    for (final symlink in _symLinks) {
      symlink.construct(directory.path);
    }

    return directory;
  }
}

/// A class for constructing files.
class FileFactory {
  final String _contents;
  final String _name;

  /// Creates a new file factory.
  ///
  /// The file name is a random UUID by default.
  /// The file contents are empty by default.
  FileFactory({String? withName, String? withContents})
    : _contents = withContents ?? '',
      _name = withName ?? const Uuid().v4();

  /// Constructs the file and writes the contents.
  /// The [path] is the path to where the file should be created.
  /// The file is created synchronously and recursively.
  File construct(String path) {
    final file = File(p.join(path, _name));
    file.createSync(recursive: true);
    file.writeAsStringSync(_contents);
    return file;
  }
}

/// A class for constructing symbolic links.
class SymLinkFactory {
  final String _target;
  final String _name;

  /// Creates a new symbolic link factory.
  ///
  /// The link name is a random UUID by default.
  /// The link target is a random UUID by default.
  ///
  /// The [withTarget] is a relative path to the target.
  SymLinkFactory({String? withName, String? withTarget})
    : _target = withTarget ?? const Uuid().v4(),
      _name = withName ?? const Uuid().v4();

  /// Constructs the symbolic link.
  /// The [path] is the path to where the link should be created.
  FileSystemEntity construct(String path) {
    final file = Link(p.join(path, _name));
    file.createSync(_target);
    return file;
  }
}
