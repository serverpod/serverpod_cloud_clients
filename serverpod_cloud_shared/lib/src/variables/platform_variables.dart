/// Environment variables the platform sets on a capsule at deployment.
/// Users cannot store them as variables or secrets.
abstract final class PlatformVariables {
  static const String futureCallEnabled = 'SERVERPOD_FUTURE_CALL_ENABLED';

  static const Set<String> reservedNames = {futureCallEnabled};

  /// Returns null when a user may store [name], otherwise the reason not.
  static String? isReservedWithReason(String name) {
    if (!reservedNames.contains(name)) {
      return null;
    }
    return "'$name' is managed by your project plan and can't be set.";
  }
}
