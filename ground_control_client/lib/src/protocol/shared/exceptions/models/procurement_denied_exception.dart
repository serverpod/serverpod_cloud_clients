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

/// Exception thrown when a procurement is denied to the user / organization
/// due to insufficient allowance or other subscription limits.
///
/// This is distinct from access authorization, and from quota limits.
abstract class ProcurementDeniedException
    implements _i1.SerializableException, _i1.SerializableModel {
  ProcurementDeniedException._({required this.message});

  factory ProcurementDeniedException({required String message}) =
      _ProcurementDeniedExceptionImpl;

  factory ProcurementDeniedException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ProcurementDeniedException(
      message: jsonSerialization['message'] as String,
    );
  }

  String message;

  /// Returns a shallow copy of this [ProcurementDeniedException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProcurementDeniedException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {'__className__': 'ProcurementDeniedException', 'message': message};
  }

  @override
  String toString() {
    return 'ProcurementDeniedException(message: $message)';
  }
}

class _ProcurementDeniedExceptionImpl extends ProcurementDeniedException {
  _ProcurementDeniedExceptionImpl({required String message})
    : super._(message: message);

  /// Returns a shallow copy of this [ProcurementDeniedException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProcurementDeniedException copyWith({String? message}) {
    return ProcurementDeniedException(message: message ?? this.message);
  }
}
