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
import '../../../domains/products/models/plan_type.dart' as _i2;
import '../../../domains/products/models/project_product_info.dart' as _i3;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i4;

/// Information about a plan product.
/// Contains information to be sent to the client.
abstract class PlanInfo implements _i1.SerializableModel {
  PlanInfo._({
    required this.planType,
    required this.projectProduct,
    this.productId,
    this.name,
    required this.displayName,
    this.description,
    this.trialLength,
    this.trialEndDate,
    this.projectsLimit,
    this.projectProductInfo,
  });

  factory PlanInfo({
    required _i2.PlanType planType,
    required _i3.ProjectProductInfo projectProduct,
    String? productId,
    String? name,
    required String displayName,
    String? description,
    int? trialLength,
    DateTime? trialEndDate,
    int? projectsLimit,
    List<_i3.ProjectProductInfo>? projectProductInfo,
  }) = _PlanInfoImpl;

  factory PlanInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return PlanInfo(
      planType: _i2.PlanType.fromJson(
        (jsonSerialization['planType'] as String),
      ),
      projectProduct: _i4.Protocol().deserialize<_i3.ProjectProductInfo>(
        jsonSerialization['projectProduct'],
      ),
      productId: jsonSerialization['productId'] as String?,
      name: jsonSerialization['name'] as String?,
      displayName: jsonSerialization['displayName'] as String,
      description: jsonSerialization['description'] as String?,
      trialLength: jsonSerialization['trialLength'] as int?,
      trialEndDate: jsonSerialization['trialEndDate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['trialEndDate'],
            ),
      projectsLimit: jsonSerialization['projectsLimit'] as int?,
      projectProductInfo: jsonSerialization['projectProductInfo'] == null
          ? null
          : _i4.Protocol().deserialize<List<_i3.ProjectProductInfo>>(
              jsonSerialization['projectProductInfo'],
            ),
    );
  }

  /// The public plan type ([PlanType.starter] / [PlanType.growth]) when this
  /// plan is user-selectable. [PlanType.unknown] for internal plans
  /// (e.g. early-access, hackathon, closed-beta).
  _i2.PlanType planType;

  /// The bundled project product, resolved for the owner's customer billing
  /// type when available. Always set for plans returned to clients.
  _i3.ProjectProductInfo projectProduct;

  /// Deprecated: Plans are identified by [planType]. The catalog product id
  /// is no longer exposed to clients.
  String? productId;

  /// Deprecated: Use displayName instead.
  String? name;

  /// The user-friendly name of the product.
  /// (This is not the same as the technical product ID name.)
  String displayName;

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

  /// Deprecated: Use [projectProduct] instead. The list-style field is kept
  /// for backwards-compatibility with clients still reading bundled products.
  List<_i3.ProjectProductInfo>? projectProductInfo;

  /// Returns a shallow copy of this [PlanInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PlanInfo copyWith({
    _i2.PlanType? planType,
    _i3.ProjectProductInfo? projectProduct,
    String? productId,
    String? name,
    String? displayName,
    String? description,
    int? trialLength,
    DateTime? trialEndDate,
    int? projectsLimit,
    List<_i3.ProjectProductInfo>? projectProductInfo,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PlanInfo',
      'planType': planType.toJson(),
      'projectProduct': projectProduct.toJson(),
      if (productId != null) 'productId': productId,
      if (name != null) 'name': name,
      'displayName': displayName,
      if (description != null) 'description': description,
      if (trialLength != null) 'trialLength': trialLength,
      if (trialEndDate != null) 'trialEndDate': trialEndDate?.toJson(),
      if (projectsLimit != null) 'projectsLimit': projectsLimit,
      if (projectProductInfo != null)
        'projectProductInfo': projectProductInfo?.toJson(
          valueToJson: (v) => v.toJson(),
        ),
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
    required _i2.PlanType planType,
    required _i3.ProjectProductInfo projectProduct,
    String? productId,
    String? name,
    required String displayName,
    String? description,
    int? trialLength,
    DateTime? trialEndDate,
    int? projectsLimit,
    List<_i3.ProjectProductInfo>? projectProductInfo,
  }) : super._(
         planType: planType,
         projectProduct: projectProduct,
         productId: productId,
         name: name,
         displayName: displayName,
         description: description,
         trialLength: trialLength,
         trialEndDate: trialEndDate,
         projectsLimit: projectsLimit,
         projectProductInfo: projectProductInfo,
       );

  /// Returns a shallow copy of this [PlanInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PlanInfo copyWith({
    _i2.PlanType? planType,
    _i3.ProjectProductInfo? projectProduct,
    Object? productId = _Undefined,
    Object? name = _Undefined,
    String? displayName,
    Object? description = _Undefined,
    Object? trialLength = _Undefined,
    Object? trialEndDate = _Undefined,
    Object? projectsLimit = _Undefined,
    Object? projectProductInfo = _Undefined,
  }) {
    return PlanInfo(
      planType: planType ?? this.planType,
      projectProduct: projectProduct ?? this.projectProduct.copyWith(),
      productId: productId is String? ? productId : this.productId,
      name: name is String? ? name : this.name,
      displayName: displayName ?? this.displayName,
      description: description is String? ? description : this.description,
      trialLength: trialLength is int? ? trialLength : this.trialLength,
      trialEndDate: trialEndDate is DateTime?
          ? trialEndDate
          : this.trialEndDate,
      projectsLimit: projectsLimit is int? ? projectsLimit : this.projectsLimit,
      projectProductInfo: projectProductInfo is List<_i3.ProjectProductInfo>?
          ? projectProductInfo
          : this.projectProductInfo?.map((e0) => e0.copyWith()).toList(),
    );
  }
}
