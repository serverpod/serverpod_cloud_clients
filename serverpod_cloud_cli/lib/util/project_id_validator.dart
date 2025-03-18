/// Validates the format of a project ID.
/// This is only a local format check, it will not check with the server
/// whether it is already in use.
///
/// Throws a [FormatException] with an error message if the project ID is invalid.
void validateProjectIdFormat(final String projectId) {
  const cloudProjectIdPattern = r'^[a-z-][a-z0-9-]{5,31}$';
  final cloudProjectIdRegExp = RegExp(cloudProjectIdPattern);
  if (!cloudProjectIdRegExp.hasMatch(projectId)) {
    throw FormatException(
        'Invalid project ID. Must be 6-32 characters long '
        'and contain only lowercase letters, numbers, and hyphens.',
        projectId);
  }
}
