import 'package:dio/dio.dart';
import 'package:pub_semver/pub_semver.dart';

/// The pub registry that hosts the custom builds of the CLI.
const customBuildRegistryUrl =
    'https://quiver.serverpod.space/registry/serverpod';

/// The prefix of the pre-release channel of a custom build.
const _customBuildChannelPrefix = 'preview-';

/// Returns the custom build channel of [version], or null if [version] is a
/// released version.
///
/// A custom build, such as a build of the main branch or of a pull request,
/// has a pre-release version on a `preview-<tag>` channel:
/// `1.2.3-preview-main.4` is on the channel `preview-main`, and
/// `1.2.3-preview-56.7` is on the channel `preview-56`.
String? customBuildChannelOf(Version version) {
  final channel = version.preRelease.firstOrNull;
  if (channel is! String || !channel.startsWith(_customBuildChannelPrefix)) {
    return null;
  }
  return channel;
}

/// Fetches the latest version of the CLI on a custom build [channel].
///
/// Returns null if the channel has no versions.
typedef CustomBuildVersionFetcher = Future<Version?> Function(String channel);

/// Fetches the latest version of the CLI on [channel] from
/// [customBuildRegistryUrl].
///
/// Returns null if the channel has no versions.
/// Throws a [DioException] if the request fails, and a [FormatException] if
/// the response is not a package version listing.
Future<Version?> fetchLatestCustomBuildVersion(String channel) async {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 2),
      receiveTimeout: const Duration(seconds: 2),
    ),
  );
  try {
    final response = await dio.get<Object?>(
      '$customBuildRegistryUrl/api/packages/serverpod_cloud_cli',
    );
    return latestCustomBuildVersion(response.data, channel: channel);
  } finally {
    dio.close();
  }
}

/// Returns the highest version on [channel] in the pub package version
/// [listing], or null if the channel has no versions.
///
/// Entries that are not valid versions are skipped.
/// Throws a [FormatException] if [listing] has no `versions` list.
Version? latestCustomBuildVersion(Object? listing, {required String channel}) {
  final versions = listing is Map ? listing['versions'] : null;
  if (versions is! List) {
    throw const FormatException(
      'The package version listing has no versions list.',
    );
  }

  Version? latest;
  for (final entry in versions) {
    final versionString = entry is Map ? entry['version'] : null;
    if (versionString is! String) continue;

    final Version version;
    try {
      version = Version.parse(versionString);
    } on FormatException {
      continue;
    }

    if (customBuildChannelOf(version) != channel) continue;
    if (latest == null || version > latest) {
      latest = version;
    }
  }
  return latest;
}
