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

abstract class UnauthorizedException
    implements _i1.SerializableException, _i1.SerializableModel {
  UnauthorizedException._({required this.message});

  factory UnauthorizedException({required String message}) =
      _UnauthorizedExceptionImpl;

  factory UnauthorizedException.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return UnauthorizedException(
        message: jsonSerialization['message'] as String);
  }

  String message;

  /// Returns a shallow copy of this [UnauthorizedException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UnauthorizedException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {'message': message};
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _UnauthorizedExceptionImpl extends UnauthorizedException {
  _UnauthorizedExceptionImpl({required String message})
      : super._(message: message);

  /// Returns a shallow copy of this [UnauthorizedException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UnauthorizedException copyWith({String? message}) {
    return UnauthorizedException(message: message ?? this.message);
  }
}
