sealed class ProjectZipperExceptions implements Exception {
  const ProjectZipperExceptions();
}

class DirectorySymLinkException extends ProjectZipperExceptions {
  final String path;
  const DirectorySymLinkException(this.path);
}

class NonResolvingSymlinkException extends ProjectZipperExceptions {
  final String path;
  final String target;
  const NonResolvingSymlinkException(this.path, this.target);
}

class ProjectDirectoryDoesNotExistException extends ProjectZipperExceptions {
  final String path;
  const ProjectDirectoryDoesNotExistException(this.path);
}

class EmptyProjectException extends ProjectZipperExceptions {
  const EmptyProjectException();
}

class NullZipException extends ProjectZipperExceptions {
  const NullZipException();
}
