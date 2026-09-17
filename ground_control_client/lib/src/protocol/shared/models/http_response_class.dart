/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// An HTTP response status class.
///
/// Naming by meaning rather than digit keeps the wire self-describing, and
/// `byName` serialization keeps the order stable if a class is ever added.
enum HttpResponseClass implements _isc.SerializableModel {
  /// 1xx — informational.
  informational,

  /// 2xx — successful.
  successful,

  /// 3xx — redirection.
  redirection,

  /// 4xx — client error.
  clientError,

  /// 5xx — server error.
  serverError;

  static HttpResponseClass fromJson(String name) {
    switch (name) {
      case 'informational':
        return HttpResponseClass.informational;
      case 'successful':
        return HttpResponseClass.successful;
      case 'redirection':
        return HttpResponseClass.redirection;
      case 'clientError':
        return HttpResponseClass.clientError;
      case 'serverError':
        return HttpResponseClass.serverError;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "HttpResponseClass"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
