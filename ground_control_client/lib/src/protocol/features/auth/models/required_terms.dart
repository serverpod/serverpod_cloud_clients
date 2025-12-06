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
import '../../../features/auth/models/terms.dart' as _i2;

abstract class RequiredTerms implements _i1.SerializableModel {
  RequiredTerms._({
    required this.termsType,
    required this.termsVersion,
    required this.termsUrl,
  });

  factory RequiredTerms({
    required _i2.Terms termsType,
    required String termsVersion,
    required String termsUrl,
  }) = _RequiredTermsImpl;

  factory RequiredTerms.fromJson(Map<String, dynamic> jsonSerialization) {
    return RequiredTerms(
      termsType: _i2.Terms.fromJson((jsonSerialization['termsType'] as String)),
      termsVersion: jsonSerialization['termsVersion'] as String,
      termsUrl: jsonSerialization['termsUrl'] as String,
    );
  }

  _i2.Terms termsType;

  String termsVersion;

  String termsUrl;

  /// Returns a shallow copy of this [RequiredTerms]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RequiredTerms copyWith({
    _i2.Terms? termsType,
    String? termsVersion,
    String? termsUrl,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RequiredTerms',
      'termsType': termsType.toJson(),
      'termsVersion': termsVersion,
      'termsUrl': termsUrl,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _RequiredTermsImpl extends RequiredTerms {
  _RequiredTermsImpl({
    required _i2.Terms termsType,
    required String termsVersion,
    required String termsUrl,
  }) : super._(
         termsType: termsType,
         termsVersion: termsVersion,
         termsUrl: termsUrl,
       );

  /// Returns a shallow copy of this [RequiredTerms]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RequiredTerms copyWith({
    _i2.Terms? termsType,
    String? termsVersion,
    String? termsUrl,
  }) {
    return RequiredTerms(
      termsType: termsType ?? this.termsType,
      termsVersion: termsVersion ?? this.termsVersion,
      termsUrl: termsUrl ?? this.termsUrl,
    );
  }
}
