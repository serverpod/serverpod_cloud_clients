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
import '../../../features/projects/models/project_info/project_info.dart'
    as _i2;
import '../../../features/admin/models/payments_status.dart' as _i3;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i4;

abstract class AdminProjectInfo
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminProjectInfo._({
    required this.projectInfo,
    required this.subscriptionId,
    required this.overduePaymentsStatuses,
  });

  factory AdminProjectInfo({
    required _i2.ProjectInfo projectInfo,
    required String subscriptionId,
    required List<_i3.PaymentsStatus> overduePaymentsStatuses,
  }) = _AdminProjectInfoImpl;

  factory AdminProjectInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminProjectInfo(
      projectInfo: _i4.Protocol().deserialize<_i2.ProjectInfo>(
        jsonSerialization['projectInfo'],
      ),
      subscriptionId: jsonSerialization['subscriptionId'] as String,
      overduePaymentsStatuses: _i4.Protocol()
          .deserialize<List<_i3.PaymentsStatus>>(
            jsonSerialization['overduePaymentsStatuses'],
          ),
    );
  }

  _i2.ProjectInfo projectInfo;

  /// The Orb subscription id for the project.
  String subscriptionId;

  /// The subscription's overdue payments statuses, one per overdue invoice.
  /// Note that in some cases this may reflect on more projects/products than
  /// just this project.
  List<_i3.PaymentsStatus> overduePaymentsStatuses;

  /// Returns a shallow copy of this [AdminProjectInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminProjectInfo copyWith({
    _i2.ProjectInfo? projectInfo,
    String? subscriptionId,
    List<_i3.PaymentsStatus>? overduePaymentsStatuses,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminProjectInfo',
      'projectInfo': projectInfo.toJson(),
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
      'subscriptionId': subscriptionId,
      'overduePaymentsStatuses': overduePaymentsStatuses.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AdminProjectInfoImpl extends AdminProjectInfo {
  _AdminProjectInfoImpl({
    required _i2.ProjectInfo projectInfo,
    required String subscriptionId,
    required List<_i3.PaymentsStatus> overduePaymentsStatuses,
  }) : super._(
         projectInfo: projectInfo,
         subscriptionId: subscriptionId,
         overduePaymentsStatuses: overduePaymentsStatuses,
       );

  /// Returns a shallow copy of this [AdminProjectInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminProjectInfo copyWith({
    _i2.ProjectInfo? projectInfo,
    String? subscriptionId,
    List<_i3.PaymentsStatus>? overduePaymentsStatuses,
  }) {
    return AdminProjectInfo(
      projectInfo: projectInfo ?? this.projectInfo.copyWith(),
      subscriptionId: subscriptionId ?? this.subscriptionId,
      overduePaymentsStatuses:
          overduePaymentsStatuses ??
          this.overduePaymentsStatuses.map((e0) => e0.copyWith()).toList(),
    );
  }
}
