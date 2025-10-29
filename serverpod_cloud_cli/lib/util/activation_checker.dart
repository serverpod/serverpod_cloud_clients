import 'dart:io' show Platform;

/// Determines whether the CLI was activated from the public pub.dev repository.
///
/// Returns `true` if the command is running from pub cache (activated via
/// `dart pub global activate`), `false` if running from source or other locations.
bool isActivatedFromPub() {
  if (_isInPubCache(Platform.resolvedExecutable)) {
    return true;
  }

  if (_isInPubCache(Platform.script.path)) {
    return true;
  }

  return false;
}

bool _isInPubCache(final String path) {
  return path.contains('pub-cache') || path.contains('.pub-cache');
}
