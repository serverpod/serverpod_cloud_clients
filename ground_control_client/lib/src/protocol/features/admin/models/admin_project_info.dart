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
import '../../../features/admin/models/payments_status.dart' as _iyxx8r3m;
import '../../../features/projects/models/project_info/project_info.dart'
    as _igjtmryi;

abstract class AdminProjectInfo
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AdminProjectInfo._({
    required this.projectInfo,
    required this.planProductId,
    required this.subscriptionId,
    required this.overduePaymentsStatuses,
  });

  factory AdminProjectInfo({
    required _igjtmryi.ProjectInfo projectInfo,
    required String planProductId,
    required String subscriptionId,
    required List<_iyxx8r3m.PaymentsStatus> overduePaymentsStatuses,
  }) = _AdminProjectInfoImpl;

  factory AdminProjectInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminProjectInfo(
      projectInfo: _iod2a87h.Protocol().deserialize<_igjtmryi.ProjectInfo>(
        jsonSerialization['projectInfo'],
      ),
      planProductId: jsonSerialization['planProductId'] as String,
      subscriptionId: jsonSerialization['subscriptionId'] as String,
      overduePaymentsStatuses: _iod2a87h.Protocol()
          .deserialize<List<_iyxx8r3m.PaymentsStatus>>(
            jsonSerialization['overduePaymentsStatuses'],
          ),
    );
  }

  _igjtmryi.ProjectInfo projectInfo;

  /// The product id of the plan for the project.
  String planProductId;

  /// The Orb subscription id for the project.
  String subscriptionId;

  /// The subscription's overdue payments statuses, one per overdue invoice.
  /// Note that in some cases this may reflect on more projects/products than
  /// just this project.
  List<_iyxx8r3m.PaymentsStatus> overduePaymentsStatuses;

  /// Returns a shallow copy of this [AdminProjectInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AdminProjectInfo copyWith({
    _igjtmryi.ProjectInfo? projectInfo,
    String? planProductId,
    String? subscriptionId,
    List<_iyxx8r3m.PaymentsStatus>? overduePaymentsStatuses,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminProjectInfo',
      'projectInfo': projectInfo.toJson(),
      'planProductId': planProductId,
      'subscriptionId': subscriptionId,
      'overduePaymentsStatuses': overduePaymentsStatuses.toJson(
        valueToJson: (v) => v.toJson(),
      ),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminProjectInfo',
      'projectInfo': projectInfo.toJsonForProtocol(),
      'planProductId': planProductId,
      'subscriptionId': subscriptionId,
      'overduePaymentsStatuses': overduePaymentsStatuses.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AdminProjectInfoImpl extends AdminProjectInfo {
  _AdminProjectInfoImpl({
    required _igjtmryi.ProjectInfo projectInfo,
    required String planProductId,
    required String subscriptionId,
    required List<_iyxx8r3m.PaymentsStatus> overduePaymentsStatuses,
  }) : super._(
         projectInfo: projectInfo,
         planProductId: planProductId,
         subscriptionId: subscriptionId,
         overduePaymentsStatuses: overduePaymentsStatuses,
       );

  /// Returns a shallow copy of this [AdminProjectInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AdminProjectInfo copyWith({
    _igjtmryi.ProjectInfo? projectInfo,
    String? planProductId,
    String? subscriptionId,
    List<_iyxx8r3m.PaymentsStatus>? overduePaymentsStatuses,
  }) {
    return AdminProjectInfo(
      projectInfo: projectInfo ?? this.projectInfo.copyWith(),
      planProductId: planProductId ?? this.planProductId,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      overduePaymentsStatuses:
          overduePaymentsStatuses ??
          this.overduePaymentsStatuses.map((e0) => e0.copyWith()).toList(),
    );
  }
}
