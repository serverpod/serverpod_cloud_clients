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

/// Information about a plan product.
/// Contains information to be sent to the client.
abstract class PlanInfo implements _i1.SerializableModel {
  PlanInfo._({
    required this.productId,
    required this.name,
    this.description,
    this.trialLength,
    this.trialEndDate,
    this.projectsLimit,
  });

  factory PlanInfo({
    required String productId,
    required String name,
    String? description,
    int? trialLength,
    DateTime? trialEndDate,
    int? projectsLimit,
  }) = _PlanInfoImpl;

  factory PlanInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return PlanInfo(
      productId: jsonSerialization['productId'] as String,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String?,
      trialLength: jsonSerialization['trialLength'] as int?,
      trialEndDate: jsonSerialization['trialEndDate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['trialEndDate']),
      projectsLimit: jsonSerialization['projectsLimit'] as int?,
    );
  }

  /// The id of the product.
  String productId;

  /// The user-friendly name of the product.
  /// (This is not the same as the technical product ID name.)
  String name;

  /// The user-friendly description of the product.
  String? description;

  /// Trial period length in days, if defined.
  /// If there is a trial period, either trialLength or trialEndDate is set.
  int? trialLength;

  /// Trial period fixed end date, if defined.
  /// If there is a trial period, either trialLength or trialEndDate is set.
  DateTime? trialEndDate;

  /// The limit on the number of projects the subscriber may own, if any.
  int? projectsLimit;

  /// Returns a shallow copy of this [PlanInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PlanInfo copyWith({
    String? productId,
    String? name,
    String? description,
    int? trialLength,
    DateTime? trialEndDate,
    int? projectsLimit,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      if (description != null) 'description': description,
      if (trialLength != null) 'trialLength': trialLength,
      if (trialEndDate != null) 'trialEndDate': trialEndDate?.toJson(),
      if (projectsLimit != null) 'projectsLimit': projectsLimit,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PlanInfoImpl extends PlanInfo {
  _PlanInfoImpl({
    required String productId,
    required String name,
    String? description,
    int? trialLength,
    DateTime? trialEndDate,
    int? projectsLimit,
  }) : super._(
          productId: productId,
          name: name,
          description: description,
          trialLength: trialLength,
          trialEndDate: trialEndDate,
          projectsLimit: projectsLimit,
        );

  /// Returns a shallow copy of this [PlanInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PlanInfo copyWith({
    String? productId,
    String? name,
    Object? description = _Undefined,
    Object? trialLength = _Undefined,
    Object? trialEndDate = _Undefined,
    Object? projectsLimit = _Undefined,
  }) {
    return PlanInfo(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      description: description is String? ? description : this.description,
      trialLength: trialLength is int? ? trialLength : this.trialLength,
      trialEndDate:
          trialEndDate is DateTime? ? trialEndDate : this.trialEndDate,
      projectsLimit: projectsLimit is int? ? projectsLimit : this.projectsLimit,
    );
  }
}
