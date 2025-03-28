sealed class ProjectZipperExceptions implements Exception {
  const ProjectZipperExceptions();
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
