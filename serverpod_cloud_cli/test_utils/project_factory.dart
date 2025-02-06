import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// A class for constructing directories with contents
/// and removing them after use.
class DirectoryFactory {
  final List<DirectoryFactory> _subdirectories;
  final List<FileFactory> _files;
  final List<SymLinkFactory> _symLinks;
  DirectoryFactory? _parent;
  String? _path;
  String _name;

  Directory? _constructedDirectory;
  Directory? _originalDirectory;

  /// Creates a new directory factory,
  /// which is used to construct a directory under an existing path,
  /// with a particular name and contents.
  ///
  /// The directory name is a random UUID by default.
  ///
  /// The path is where the directory should be created,
  /// the current directory by default.
  /// It must exist prior to construction.
  ///
  /// To create multiple levels of constructed directories,
  /// use [withParent] instead of [withPath].
  DirectoryFactory({
    final DirectoryFactory? withParent,
    final String? withPath,
    final String? withName,
    final List<DirectoryFactory>? withSubdirectories,
    final List<FileFactory>? withFiles,
    final List<SymLinkFactory>? withSymLinks,
  })  : _parent = withParent,
        _path = withPath,
        _name = withName ?? Uuid().v4(),
        _subdirectories = withSubdirectories ?? [],
        _files = withFiles ?? [],
        _symLinks = withSymLinks ?? [];

  /// Sets the parent directory factory.
  /// This has precedence over [withPath].
  /// The parent directory does not need to exist prior to construction.
  void withParent(final DirectoryFactory parent) {
    _parent = parent;
  }

  /// Sets the path to where the directory should be created.
  /// The path must exist prior to construction.
  void withPath(final String path) {
    _path = path;
  }

  /// Sets the name of the directory to be created upon construction.
  void withName(final String name) {
    _name = name;
  }

  /// Adds a subdirectory to be created upon construction.
  void addSubdirectory(final DirectoryFactory subdirectory) {
    if (subdirectory._path != null) {
      throw ArgumentError('subdirectory cannot have a location path');
    }
    _subdirectories.add(subdirectory);
  }

  /// Adds file to be created upon construction.
  void addFile(final FileFactory file) {
    _files.add(file);
  }

  /// Adds symbolic link to be created upon construction.
  void addSymLink(final SymLinkFactory symLink) {
    _symLinks.add(symLink);
  }

  /// Returns the constructed directory.
  /// Throws [StateError] if this factory has not constructed a directory.
  Directory get directory {
    final directory = _constructedDirectory;
    if (directory == null) {
      throw StateError('directory not constructed');
    }
    return directory;
  }

  /// Constructs the directory and all subdirectories and files.
  /// Returns the created directory.
  ///
  /// Test authors should prefer using `withPath` instead of the [path] argument.
  ///
  /// The [path] is the path to where the directory should be created.
  /// If the path is not provided, the preset path or preset parent's path is used,
  /// or the current directory if none of these is set.
  ///
  /// If [stateless] is `true` this factory is kept stateless,
  /// which means [construct] can be called multiple times
  /// and [destruct] cannot be called.
  Directory construct({
    final String? path,
    final bool pushCurrentDirectory = false,
    final bool stateless = false,
  }) {
    if (_constructedDirectory != null) {
      throw StateError('directory already constructed');
    }

    final locationPath =
        path ?? _path ?? _parent?.directory.path ?? Directory.current.path;
    final locationDir = Directory(locationPath);
    if (!locationDir.existsSync()) {
      throw StateError('location path does not exist: $locationPath');
    }

    final directory = Directory(
      p.join(locationPath, _name),
    );

    if (directory.existsSync()) {
      throw StateError('directory already exists: $directory');
    }

    if (!stateless) {
      _constructedDirectory = directory;
    }

    directory.createSync(recursive: true);

    for (final subDirectory in _subdirectories) {
      subDirectory.construct(
        path: directory.path,
        stateless: true,
      );
    }

    for (final file in _files) {
      file.construct(directory.path);
    }

    for (final symlink in _symLinks) {
      symlink.construct(directory.path);
    }

    if (pushCurrentDirectory) {
      _originalDirectory = Directory.current;
      Directory.current = directory.path;
    }

    return directory;
  }

  void destruct() {
    final dir = directory;

    final originalDirectory = _originalDirectory;
    if (originalDirectory != null) {
      Directory.current = originalDirectory.path;
    }

    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }

    _constructedDirectory = null;
    _originalDirectory = null;
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
