import 'dart:io';

import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// Constructors for Serverpod project directories and files.
class ProjectFactory {
  /// Returns descriptor for a Serverpod server directory with a valid pubspec.yaml file.
  /// Use `descriptor.create()` to create the directory.
  static d.DirectoryDescriptor serverpodServerDir({
    final String withDirectoryName = 'serverpod_server',
    final String withPackageName = 'my_project_server',
  }) {
    return d.dir(withDirectoryName, [
      serverpodServerPubspec(withPackageName: withPackageName),
    ]);
  }

  /// Returns descriptor for a valid Serverpod server pubspec.yaml file.
  /// Use `descriptor.create()` to create the file.
  static d.FileDescriptor serverpodServerPubspec({
    final String withPackageName = 'my_project_server',
  }) {
    return d.file(
      'pubspec.yaml',
      '''
name: $withPackageName
environment:
  sdk: '>=3.6.0 <3.7.0'
dependencies:
  serverpod: ^2.3.0
''',
    );
  }
}

/// A class for constructing directories with files.
class DirectoryFactory {
  final List<DirectoryFactory> _subDirectories;
  final List<FileFactory> _files;
  final List<SymLinkFactory> _symLinks;
  final String _directoryName;

  /// Creates a new directory factory.
  /// The directory name is a random UUID by default.
  DirectoryFactory({
    final String? withDirectoryName,
    final List<DirectoryFactory>? withSubDirectories,
    final List<FileFactory>? withFiles,
    final List<SymLinkFactory>? withSymLinks,
  })  : _directoryName = withDirectoryName ?? const Uuid().v4(),
        _subDirectories = withSubDirectories ?? [],
        _files = withFiles ?? [],
        _symLinks = withSymLinks ?? [];

  /// Constructs the directory and all subdirectories and files.
  /// Returns the created directory.
  ///
  /// The [path] is the path to where the directory should be created.
  Directory construct(final String path) {
    final directory = Directory(path);
    directory.createSync(recursive: true);

    for (final subDirectory in _subDirectories) {
      subDirectory
          .construct('${directory.path}/${subDirectory._directoryName}');
    }

    for (final file in _files) {
      file.construct(directory.path);
    }

    for (final symlink in _symLinks) {
      symlink.construct(directory.path);
    }

    return directory;
  }

  factory DirectoryFactory.serverpodServerDir() {
    return DirectoryFactory(withFiles: [
      FileFactory(
        withName: 'pubspec.yaml',
        withContents: '''
name: my_project_server
environment:
  sdk: '>=3.6.0 <3.7.0'
dependencies:
  serverpod: ^2.3.0
''',
      ),
    ]);
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
  FileFactory({
    final String? withName,
    final String? withContents,
  })  : _contents = withContents ?? '',
        _name = withName ?? const Uuid().v4();

  /// Constructs the file and writes the contents.
  /// The [path] is the path to where the file should be created.
  /// The file is created synchronously and recursively.
  File construct(final String path) {
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
  SymLinkFactory({
    final String? withName,
    final String? withTarget,
  })  : _target = withTarget ?? const Uuid().v4(),
        _name = withName ?? const Uuid().v4();

  /// Constructs the symbolic link.
  /// The [path] is the path to where the link should be created.
  FileSystemEntity construct(final String path) {
    final file = Link(p.join(path, _name));
    file.createSync(_target);
    return file;
  }
}
