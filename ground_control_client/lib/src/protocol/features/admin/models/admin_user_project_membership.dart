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
import 'package:ground_control_client/src/protocol/protocol.dart' as _iod2a87h;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../../../domains/products/models/plan_type.dart' as _iic46wsa;
import '../../../domains/projects/models/project_role.dart' as _isypcm2i;
import '../../../domains/status/models/deploy_attempt.dart' as _inqbrt2s;

/// Project membership and procurement details for an admin user status view.
abstract class AdminUserProjectMembership
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AdminUserProjectMembership._({
    required this.cloudProjectId,
    required this.userRoles,
    this.planType,
    this.planProductId,
    this.billingPlanId,
    this.billingSubscriptionId,
    required this.projectCreatedAt,
    this.latestDeployAttempt,
  });

  factory AdminUserProjectMembership({
    required String cloudProjectId,
    required List<_isypcm2i.ProjectRole> userRoles,
    _iic46wsa.PlanType? planType,
    String? planProductId,
    String? billingPlanId,
    String? billingSubscriptionId,
    required DateTime projectCreatedAt,
    _inqbrt2s.DeployAttempt? latestDeployAttempt,
  }) = _AdminUserProjectMembershipImpl;

  factory AdminUserProjectMembership.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AdminUserProjectMembership(
      cloudProjectId: jsonSerialization['cloudProjectId'] as String,
      userRoles: _iod2a87h.Protocol().deserialize<List<_isypcm2i.ProjectRole>>(
        jsonSerialization['userRoles'],
      ),
      planType: jsonSerialization['planType'] == null
          ? null
          : _iic46wsa.PlanType.fromJson(
              (jsonSerialization['planType'] as String),
            ),
      planProductId: jsonSerialization['planProductId'] as String?,
      billingPlanId: jsonSerialization['billingPlanId'] as String?,
      billingSubscriptionId:
          jsonSerialization['billingSubscriptionId'] as String?,
      projectCreatedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['projectCreatedAt'],
      ),
      latestDeployAttempt: jsonSerialization['latestDeployAttempt'] == null
          ? null
          : _iod2a87h.Protocol().deserialize<_inqbrt2s.DeployAttempt>(
              jsonSerialization['latestDeployAttempt'],
            ),
    );
  }

  /// The cloud project id of the membership.
  String cloudProjectId;

  /// Roles the user holds on the project.
  List<_isypcm2i.ProjectRole> userRoles;

  /// The project's plan type, when known.
  _iic46wsa.PlanType? planType;

  /// Ground Control plan product id for the project's subscription.
  String? planProductId;

  /// Orb (billing system) plan id for the project's subscription.
  String? billingPlanId;

  /// Orb subscription id for the project's subscription.
  String? billingSubscriptionId;

  /// When the project was created.
  DateTime projectCreatedAt;

  /// The most recent deploy attempt for the project, when any exist.
  _inqbrt2s.DeployAttempt? latestDeployAttempt;

  /// Returns a shallow copy of this [AdminUserProjectMembership]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AdminUserProjectMembership copyWith({
    String? cloudProjectId,
    List<_isypcm2i.ProjectRole>? userRoles,
    _iic46wsa.PlanType? planType,
    String? planProductId,
    String? billingPlanId,
    String? billingSubscriptionId,
    DateTime? projectCreatedAt,
    _inqbrt2s.DeployAttempt? latestDeployAttempt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminUserProjectMembership',
      'cloudProjectId': cloudProjectId,
      'userRoles': userRoles.toJson(valueToJson: (v) => v.toJson()),
      if (planType != null) 'planType': planType?.toJson(),
      if (planProductId != null) 'planProductId': planProductId,
      if (billingPlanId != null) 'billingPlanId': billingPlanId,
      if (billingSubscriptionId != null)
        'billingSubscriptionId': billingSubscriptionId,
      'projectCreatedAt': projectCreatedAt.toJson(),
      if (latestDeployAttempt != null)
        'latestDeployAttempt': latestDeployAttempt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminUserProjectMembership',
      'cloudProjectId': cloudProjectId,
      'userRoles': userRoles.toJson(valueToJson: (v) => v.toJson()),
      if (planType != null) 'planType': planType?.toJson(),
      if (planProductId != null) 'planProductId': planProductId,
      if (billingPlanId != null) 'billingPlanId': billingPlanId,
      if (billingSubscriptionId != null)
        'billingSubscriptionId': billingSubscriptionId,
      'projectCreatedAt': projectCreatedAt.toJson(),
      if (latestDeployAttempt != null)
        'latestDeployAttempt': latestDeployAttempt?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminUserProjectMembershipImpl extends AdminUserProjectMembership {
  _AdminUserProjectMembershipImpl({
    required String cloudProjectId,
    required List<_isypcm2i.ProjectRole> userRoles,
    _iic46wsa.PlanType? planType,
    String? planProductId,
    String? billingPlanId,
    String? billingSubscriptionId,
    required DateTime projectCreatedAt,
    _inqbrt2s.DeployAttempt? latestDeployAttempt,
  }) : super._(
         cloudProjectId: cloudProjectId,
         userRoles: userRoles,
         planType: planType,
         planProductId: planProductId,
         billingPlanId: billingPlanId,
         billingSubscriptionId: billingSubscriptionId,
         projectCreatedAt: projectCreatedAt,
         latestDeployAttempt: latestDeployAttempt,
       );

  /// Returns a shallow copy of this [AdminUserProjectMembership]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AdminUserProjectMembership copyWith({
    String? cloudProjectId,
    List<_isypcm2i.ProjectRole>? userRoles,
    Object? planType = _Undefined,
    Object? planProductId = _Undefined,
    Object? billingPlanId = _Undefined,
    Object? billingSubscriptionId = _Undefined,
    DateTime? projectCreatedAt,
    Object? latestDeployAttempt = _Undefined,
  }) {
    return AdminUserProjectMembership(
      cloudProjectId: cloudProjectId ?? this.cloudProjectId,
      userRoles: userRoles ?? this.userRoles.map((e0) => e0).toList(),
      planType: planType is _iic46wsa.PlanType? ? planType : this.planType,
      planProductId: planProductId is String?
          ? planProductId
          : this.planProductId,
      billingPlanId: billingPlanId is String?
          ? billingPlanId
          : this.billingPlanId,
      billingSubscriptionId: billingSubscriptionId is String?
          ? billingSubscriptionId
          : this.billingSubscriptionId,
      projectCreatedAt: projectCreatedAt ?? this.projectCreatedAt,
      latestDeployAttempt: latestDeployAttempt is _inqbrt2s.DeployAttempt?
          ? latestDeployAttempt
          : this.latestDeployAttempt?.copyWith(),
    );
  }
}
