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

abstract class AcceptedTerms implements _i1.SerializableModel {
  AcceptedTerms._({
    this.id,
    required this.termsType,
    required this.termsVersion,
    DateTime? createdAt,
    required this.identifier,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AcceptedTerms({
    int? id,
    required _i2.Terms termsType,
    required String termsVersion,
    DateTime? createdAt,
    required String identifier,
  }) = _AcceptedTermsImpl;

  factory AcceptedTerms.fromJson(Map<String, dynamic> jsonSerialization) {
    return AcceptedTerms(
      id: jsonSerialization['id'] as int?,
      termsType: _i2.Terms.fromJson((jsonSerialization['termsType'] as String)),
      termsVersion: jsonSerialization['termsVersion'] as String,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      identifier: jsonSerialization['identifier'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _i2.Terms termsType;

  String termsVersion;

  DateTime createdAt;

  String identifier;

  AcceptedTerms copyWith({
    int? id,
    _i2.Terms? termsType,
    String? termsVersion,
    DateTime? createdAt,
    String? identifier,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'termsType': termsType.toJson(),
      'termsVersion': termsVersion,
      'createdAt': createdAt.toJson(),
      'identifier': identifier,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AcceptedTermsImpl extends AcceptedTerms {
  _AcceptedTermsImpl({
    int? id,
    required _i2.Terms termsType,
    required String termsVersion,
    DateTime? createdAt,
    required String identifier,
  }) : super._(
          id: id,
          termsType: termsType,
          termsVersion: termsVersion,
          createdAt: createdAt,
          identifier: identifier,
        );

  @override
  AcceptedTerms copyWith({
    Object? id = _Undefined,
    _i2.Terms? termsType,
    String? termsVersion,
    DateTime? createdAt,
    String? identifier,
  }) {
    return AcceptedTerms(
      id: id is int? ? id : this.id,
      termsType: termsType ?? this.termsType,
      termsVersion: termsVersion ?? this.termsVersion,
      createdAt: createdAt ?? this.createdAt,
      identifier: identifier ?? this.identifier,
    );
  }
}
