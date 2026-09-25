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

/// Thrown when the project archive is larger than the deploy upload limit.
abstract class UploadTooLargeException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  UploadTooLargeException._({
    required this.message,
    required this.sizeBytes,
    required this.maxSizeBytes,
  });

  factory UploadTooLargeException({
    required String message,
    required int sizeBytes,
    required int maxSizeBytes,
  }) = _UploadTooLargeExceptionImpl;

  factory UploadTooLargeException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return UploadTooLargeException(
      message: jsonSerialization['message'] as String,
      sizeBytes: jsonSerialization['sizeBytes'] as int,
      maxSizeBytes: jsonSerialization['maxSizeBytes'] as int,
    );
  }

  String message;

  int sizeBytes;

  int maxSizeBytes;

  /// Returns a shallow copy of this [UploadTooLargeException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  UploadTooLargeException copyWith({
    String? message,
    int? sizeBytes,
    int? maxSizeBytes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UploadTooLargeException',
      'message': message,
      'sizeBytes': sizeBytes,
      'maxSizeBytes': maxSizeBytes,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UploadTooLargeException',
      'message': message,
      'sizeBytes': sizeBytes,
      'maxSizeBytes': maxSizeBytes,
    };
  }

  @override
  String toString() {
    return 'UploadTooLargeException(message: $message, sizeBytes: $sizeBytes, maxSizeBytes: $maxSizeBytes)';
  }
}

class _UploadTooLargeExceptionImpl extends UploadTooLargeException {
  _UploadTooLargeExceptionImpl({
    required String message,
    required int sizeBytes,
    required int maxSizeBytes,
  }) : super._(
         message: message,
         sizeBytes: sizeBytes,
         maxSizeBytes: maxSizeBytes,
       );

  /// Returns a shallow copy of this [UploadTooLargeException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  UploadTooLargeException copyWith({
    String? message,
    int? sizeBytes,
    int? maxSizeBytes,
  }) {
    return UploadTooLargeException(
      message: message ?? this.message,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      maxSizeBytes: maxSizeBytes ?? this.maxSizeBytes,
    );
  }
}
