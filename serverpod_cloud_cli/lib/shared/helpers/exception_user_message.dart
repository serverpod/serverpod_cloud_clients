import 'package:ground_control_client/ground_control_client.dart';

String userFriendlyExceptionMessage(final Exception e) {
  if (e is SerializableException) {
    final json = e.toJson();
    if (json is Map<String, dynamic>) {
      if (json['message'] != null) {
        return json['message'] as String;
      }
    }
  }
  return e.toString();
}
