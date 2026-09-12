import 'package:serverpod_cloud_shared/serverpod_cloud_shared.dart';

/// Formats [bytes] as a decimal byte size, for example `1.5 MB`.
///
/// Returns `-` when [bytes] is null.
String formatByteSize(final int? bytes) {
  if (bytes == null) {
    return '-';
  }
  return ByteSizeFormatter.format(bytes);
}
