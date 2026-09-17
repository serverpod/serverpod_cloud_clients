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
import '../../../../domains/products/models/plan_type.dart' as _i36x9kwn;
import '../../../../domains/projects/models/project.dart' as _iwujrmz5;
import '../../../../features/projects/models/project_info/timestamp.dart'
    as _iv6ntt36;

/// Augments a project object with ancillary information.
///
/// Ancillary information fields are included according to use case,
/// in which case they are non-null.
/// In other words, null ancillary fields correspond to `undefined`.
abstract class ProjectInfo
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ProjectInfo._({
    required this.project,
    required this.productId,
    this.latestDeployAttemptTime,
    this.planType,
  });

  factory ProjectInfo({
    required _iwujrmz5.Project project,
    required String productId,
    _iv6ntt36.Timestamp? latestDeployAttemptTime,
    _i36x9kwn.PlanType? planType,
  }) = _ProjectInfoImpl;

  factory ProjectInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProjectInfo(
      project: _iod2a87h.Protocol().deserialize<_iwujrmz5.Project>(
        jsonSerialization['project'],
      ),
      productId: jsonSerialization['productId'] as String,
      latestDeployAttemptTime:
          jsonSerialization['latestDeployAttemptTime'] == null
          ? null
          : _iod2a87h.Protocol().deserialize<_iv6ntt36.Timestamp>(
              jsonSerialization['latestDeployAttemptTime'],
            ),
      planType: jsonSerialization['planType'] == null
          ? null
          : _i36x9kwn.PlanType.fromJson(
              (jsonSerialization['planType'] as String),
            ),
    );
  }

  _iwujrmz5.Project project;

  /// The procured product id for the project product type.
  String productId;

  /// The timestamp of the latest deploy attempt, or null if never deployed.
  /// (When deploy status is overhauled, this will likely be replaced by a
  /// `DeployAttempt` object.)
  _iv6ntt36.Timestamp? latestDeployAttemptTime;

  /// The public plan type the project belongs to, derived from its project
  /// product. [PlanType.unknown] for projects under internal plans.
  _i36x9kwn.PlanType? planType;

  /// Returns a shallow copy of this [ProjectInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ProjectInfo copyWith({
    _iwujrmz5.Project? project,
    String? productId,
    _iv6ntt36.Timestamp? latestDeployAttemptTime,
    _i36x9kwn.PlanType? planType,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProjectInfo',
      'project': project.toJson(),
      'productId': productId,
      if (latestDeployAttemptTime != null)
        'latestDeployAttemptTime': latestDeployAttemptTime?.toJson(),
      if (planType != null) 'planType': planType?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ProjectInfo',
      'project': project.toJsonForProtocol(),
      'productId': productId,
      if (latestDeployAttemptTime != null)
        'latestDeployAttemptTime': latestDeployAttemptTime?.toJsonForProtocol(),
      if (planType != null) 'planType': planType?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProjectInfoImpl extends ProjectInfo {
  _ProjectInfoImpl({
    required _iwujrmz5.Project project,
    required String productId,
    _iv6ntt36.Timestamp? latestDeployAttemptTime,
    _i36x9kwn.PlanType? planType,
  }) : super._(
         project: project,
         productId: productId,
         latestDeployAttemptTime: latestDeployAttemptTime,
         planType: planType,
       );

  /// Returns a shallow copy of this [ProjectInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ProjectInfo copyWith({
    _iwujrmz5.Project? project,
    String? productId,
    Object? latestDeployAttemptTime = _Undefined,
    Object? planType = _Undefined,
  }) {
    return ProjectInfo(
      project: project ?? this.project.copyWith(),
      productId: productId ?? this.productId,
      latestDeployAttemptTime: latestDeployAttemptTime is _iv6ntt36.Timestamp?
          ? latestDeployAttemptTime
          : this.latestDeployAttemptTime?.copyWith(),
      planType: planType is _i36x9kwn.PlanType? ? planType : this.planType,
    );
  }
}
