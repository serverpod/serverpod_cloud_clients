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
import 'package:serverpod_client/serverpod_client.dart' as _i1;

/// Exception thrown when a resource is denied to the user / organization
/// due to insufficient quota, allowance, or other subscription limit.
///
/// This is distinct from access authorization.
abstract class ResourceDeniedException
    implements _i1.SerializableException, _i1.SerializableModel {
  ResourceDeniedException._({required this.message});

  factory ResourceDeniedException({required String message}) =
      _ResourceDeniedExceptionImpl;

  factory ResourceDeniedException.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return ResourceDeniedException(
        message: jsonSerialization['message'] as String);
  }

  String message;

  /// Returns a shallow copy of this [ResourceDeniedException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ResourceDeniedException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {'message': message};
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ResourceDeniedExceptionImpl extends ResourceDeniedException {
  _ResourceDeniedExceptionImpl({required String message})
      : super._(message: message);

  /// Returns a shallow copy of this [ResourceDeniedException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ResourceDeniedException copyWith({String? message}) {
    return ResourceDeniedException(message: message ?? this.message);
  }
}
