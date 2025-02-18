/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import '../../../features/auth/models/terms.dart' as _i2;

abstract class AcceptedTermsDTO implements _i1.SerializableModel {
  AcceptedTermsDTO._({
    required this.termsType,
    required this.termsVersion,
  });

  factory AcceptedTermsDTO({
    required _i2.Terms termsType,
    required String termsVersion,
  }) = _AcceptedTermsDTOImpl;

  factory AcceptedTermsDTO.fromJson(Map<String, dynamic> jsonSerialization) {
    return AcceptedTermsDTO(
      termsType: _i2.Terms.fromJson((jsonSerialization['termsType'] as String)),
      termsVersion: jsonSerialization['termsVersion'] as String,
    );
  }

  _i2.Terms termsType;

  String termsVersion;

  AcceptedTermsDTO copyWith({
    _i2.Terms? termsType,
    String? termsVersion,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'termsType': termsType.toJson(),
      'termsVersion': termsVersion,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AcceptedTermsDTOImpl extends AcceptedTermsDTO {
  _AcceptedTermsDTOImpl({
    required _i2.Terms termsType,
    required String termsVersion,
  }) : super._(
          termsType: termsType,
          termsVersion: termsVersion,
        );

  @override
  AcceptedTermsDTO copyWith({
    _i2.Terms? termsType,
    String? termsVersion,
  }) {
    return AcceptedTermsDTO(
      termsType: termsType ?? this.termsType,
      termsVersion: termsVersion ?? this.termsVersion,
    );
  }
}
