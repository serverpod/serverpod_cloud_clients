/// Checks if the format of a project ID is valid.
/// This is only a local format check, it will not check with the server
/// whether it is already in use.
bool isValidProjectIdFormat(final String projectId) {
  const cloudProjectIdPattern = r'^[a-z-][a-z0-9-]{5,31}$';
  final cloudProjectIdRegExp = RegExp(cloudProjectIdPattern);
  return cloudProjectIdRegExp.hasMatch(projectId);
}
