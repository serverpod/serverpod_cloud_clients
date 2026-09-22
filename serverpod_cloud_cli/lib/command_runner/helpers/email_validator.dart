import 'package:serverpod_cloud_shared/serverpod_cloud_shared.dart';

/// Validates an email address.
///
/// Throws a [FormatException] if the email address is invalid.
void emailValidator(String value) {
  if (!EmailValidator.looksValid(value)) {
    throw FormatException('Invalid email address: $value');
  }
}
