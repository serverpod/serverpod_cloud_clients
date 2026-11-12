import 'package:ground_control_client/ground_control_client.dart';

/// Serializes an app build with the requester's display information.
Map<String, Object?> appBuildOutput(AppBuildSummary build) {
  final requester = build.requestedBy;
  return {
    ...build.toJson(),
    'requestedBy': requester == null
        ? null
        : {'name': requester.name, 'email': requester.email},
  };
}
