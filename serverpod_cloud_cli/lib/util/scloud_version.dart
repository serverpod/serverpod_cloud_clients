import 'package:pub_semver/pub_semver.dart';

// Constant with the current version of the Serverpod Cloud CLI.
// This should be updated when a new version is released.
const String _cliVersionString = '0.13.0';

Version? _cliVersion;

/// The current version of the Serverpod Cloud CLI.
Version get cliVersion {
  final cachedVersion = _cliVersion;
  if (cachedVersion != null) {
    return cachedVersion;
  }

  final cliVersion = Version.parse(_cliVersionString);
  _cliVersion = cliVersion;
  return cliVersion;
}
