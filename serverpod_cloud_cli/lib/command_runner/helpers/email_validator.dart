import 'package:email_validator/email_validator.dart';

/// Validates an email address.
///
/// Throws a [FormatException] if the email address is invalid.
void emailValidator(String value) {
  if (!EmailValidator.validate(value)) {
    throw FormatException('Invalid email address: $value');
  }
}
