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
import '../../../domains/projects/models/project_lifecycle_status.dart'
    as _ie2v77w9;
import '../../../domains/projects/models/project_suspension_reason.dart'
    as _ixae5ksq;
import '../../../domains/status/models/deploy_attempt.dart' as _inqbrt2s;
import '../../../features/admin/models/payments_status.dart' as _iyxx8r3m;
import '../../../features/projects/models/project_info/project_info.dart'
    as _igjtmryi;

abstract class AdminProjectInfo
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AdminProjectInfo._({
    required this.projectInfo,
    required this.status,
    this.suspendedAt,
    this.suspensionReason,
    required this.planProductId,
    required this.subscriptionId,
    required this.overduePaymentsStatuses,
    this.billingPlanId,
    this.latestDeployAttempt,
  });

  factory AdminProjectInfo({
    required _igjtmryi.ProjectInfo projectInfo,
    required _ie2v77w9.ProjectLifecycleStatus status,
    DateTime? suspendedAt,
    _ixae5ksq.ProjectSuspensionReason? suspensionReason,
    required String planProductId,
    required String subscriptionId,
    required List<_iyxx8r3m.PaymentsStatus> overduePaymentsStatuses,
    String? billingPlanId,
    _inqbrt2s.DeployAttempt? latestDeployAttempt,
  }) = _AdminProjectInfoImpl;

  factory AdminProjectInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminProjectInfo(
      projectInfo: _iod2a87h.Protocol().deserialize<_igjtmryi.ProjectInfo>(
        jsonSerialization['projectInfo'],
      ),
      status: _ie2v77w9.ProjectLifecycleStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      suspendedAt: jsonSerialization['suspendedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['suspendedAt'],
            ),
      suspensionReason: jsonSerialization['suspensionReason'] == null
          ? null
          : _ixae5ksq.ProjectSuspensionReason.fromJson(
              (jsonSerialization['suspensionReason'] as String),
            ),
      planProductId: jsonSerialization['planProductId'] as String,
      subscriptionId: jsonSerialization['subscriptionId'] as String,
      overduePaymentsStatuses: _iod2a87h.Protocol()
          .deserialize<List<_iyxx8r3m.PaymentsStatus>>(
            jsonSerialization['overduePaymentsStatuses'],
          ),
      billingPlanId: jsonSerialization['billingPlanId'] as String?,
      latestDeployAttempt: jsonSerialization['latestDeployAttempt'] == null
          ? null
          : _iod2a87h.Protocol().deserialize<_inqbrt2s.DeployAttempt>(
              jsonSerialization['latestDeployAttempt'],
            ),
    );
  }

  _igjtmryi.ProjectInfo projectInfo;

  /// The lifecycle status of the project.
  _ie2v77w9.ProjectLifecycleStatus status;

  /// When the project was last suspended, when set.
  DateTime? suspendedAt;

  /// Why the project was last suspended, when set.
  _ixae5ksq.ProjectSuspensionReason? suspensionReason;

  /// The product id of the plan for the project.
  String planProductId;

  /// The Orb subscription id for the project.
  String subscriptionId;

  /// The subscription's overdue payments statuses, one per overdue invoice.
  /// Note that in some cases this may reflect on more projects/products than
  /// just this project.
  List<_iyxx8r3m.PaymentsStatus> overduePaymentsStatuses;

  /// Orb billing system plan id and version (e.g. starter-private:2).
  String? billingPlanId;

  /// The most recent deploy attempt for the project, when any exist.
  _inqbrt2s.DeployAttempt? latestDeployAttempt;

  /// Returns a shallow copy of this [AdminProjectInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AdminProjectInfo copyWith({
    _igjtmryi.ProjectInfo? projectInfo,
    _ie2v77w9.ProjectLifecycleStatus? status,
    DateTime? suspendedAt,
    _ixae5ksq.ProjectSuspensionReason? suspensionReason,
    String? planProductId,
    String? subscriptionId,
    List<_iyxx8r3m.PaymentsStatus>? overduePaymentsStatuses,
    String? billingPlanId,
    _inqbrt2s.DeployAttempt? latestDeployAttempt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminProjectInfo',
      'projectInfo': projectInfo.toJson(),
      'status': status.toJson(),
      if (suspendedAt != null) 'suspendedAt': suspendedAt?.toJson(),
      if (suspensionReason != null)
        'suspensionReason': suspensionReason?.toJson(),
      'planProductId': planProductId,
      'subscriptionId': subscriptionId,
      'overduePaymentsStatuses': overduePaymentsStatuses.toJson(
        valueToJson: (v) => v.toJson(),
      ),
      if (billingPlanId != null) 'billingPlanId': billingPlanId,
      if (latestDeployAttempt != null)
        'latestDeployAttempt': latestDeployAttempt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminProjectInfo',
      'projectInfo': projectInfo.toJsonForProtocol(),
      'status': status.toJson(),
      if (suspendedAt != null) 'suspendedAt': suspendedAt?.toJson(),
      if (suspensionReason != null)
        'suspensionReason': suspensionReason?.toJson(),
      'planProductId': planProductId,
      'subscriptionId': subscriptionId,
      'overduePaymentsStatuses': overduePaymentsStatuses.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      if (billingPlanId != null) 'billingPlanId': billingPlanId,
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

class _AdminProjectInfoImpl extends AdminProjectInfo {
  _AdminProjectInfoImpl({
    required _igjtmryi.ProjectInfo projectInfo,
    required _ie2v77w9.ProjectLifecycleStatus status,
    DateTime? suspendedAt,
    _ixae5ksq.ProjectSuspensionReason? suspensionReason,
    required String planProductId,
    required String subscriptionId,
    required List<_iyxx8r3m.PaymentsStatus> overduePaymentsStatuses,
    String? billingPlanId,
    _inqbrt2s.DeployAttempt? latestDeployAttempt,
  }) : super._(
         projectInfo: projectInfo,
         status: status,
         suspendedAt: suspendedAt,
         suspensionReason: suspensionReason,
         planProductId: planProductId,
         subscriptionId: subscriptionId,
         overduePaymentsStatuses: overduePaymentsStatuses,
         billingPlanId: billingPlanId,
         latestDeployAttempt: latestDeployAttempt,
       );

  /// Returns a shallow copy of this [AdminProjectInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AdminProjectInfo copyWith({
    _igjtmryi.ProjectInfo? projectInfo,
    _ie2v77w9.ProjectLifecycleStatus? status,
    Object? suspendedAt = _Undefined,
    Object? suspensionReason = _Undefined,
    String? planProductId,
    String? subscriptionId,
    List<_iyxx8r3m.PaymentsStatus>? overduePaymentsStatuses,
    Object? billingPlanId = _Undefined,
    Object? latestDeployAttempt = _Undefined,
  }) {
    return AdminProjectInfo(
      projectInfo: projectInfo ?? this.projectInfo.copyWith(),
      status: status ?? this.status,
      suspendedAt: suspendedAt is DateTime? ? suspendedAt : this.suspendedAt,
      suspensionReason: suspensionReason is _ixae5ksq.ProjectSuspensionReason?
          ? suspensionReason
          : this.suspensionReason,
      planProductId: planProductId ?? this.planProductId,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      overduePaymentsStatuses:
          overduePaymentsStatuses ??
          this.overduePaymentsStatuses.map((e0) => e0.copyWith()).toList(),
      billingPlanId: billingPlanId is String?
          ? billingPlanId
          : this.billingPlanId,
      latestDeployAttempt: latestDeployAttempt is _inqbrt2s.DeployAttempt?
          ? latestDeployAttempt
          : this.latestDeployAttempt?.copyWith(),
    );
  }
}
