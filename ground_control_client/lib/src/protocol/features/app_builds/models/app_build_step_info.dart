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
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../../../domains/app_builds/models/app_build_step_status.dart'
    as _igpykeyr;

/// One step of an app build.
abstract class AppBuildStepInfo
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AppBuildStepInfo._({
    required this.index,
    required this.name,
    required this.status,
    this.startedAt,
    this.endedAt,
  });

  factory AppBuildStepInfo({
    required int index,
    required String name,
    required _igpykeyr.AppBuildStepStatus status,
    DateTime? startedAt,
    DateTime? endedAt,
  }) = _AppBuildStepInfoImpl;

  factory AppBuildStepInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppBuildStepInfo(
      index: jsonSerialization['index'] as int,
      name: jsonSerialization['name'] as String,
      status: _igpykeyr.AppBuildStepStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      startedAt: jsonSerialization['startedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['startedAt']),
      endedAt: jsonSerialization['endedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['endedAt']),
    );
  }

  /// The step's position in the build, starting at 0. Used to fetch its
  /// log.
  int index;

  /// The step's name as the workflow defines it.
  String name;

  _igpykeyr.AppBuildStepStatus status;

  DateTime? startedAt;

  DateTime? endedAt;

  /// Returns a shallow copy of this [AppBuildStepInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AppBuildStepInfo copyWith({
    int? index,
    String? name,
    _igpykeyr.AppBuildStepStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppBuildStepInfo',
      'index': index,
      'name': name,
      'status': status.toJson(),
      if (startedAt != null) 'startedAt': startedAt?.toJson(),
      if (endedAt != null) 'endedAt': endedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppBuildStepInfo',
      'index': index,
      'name': name,
      'status': status.toJson(),
      if (startedAt != null) 'startedAt': startedAt?.toJson(),
      if (endedAt != null) 'endedAt': endedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AppBuildStepInfoImpl extends AppBuildStepInfo {
  _AppBuildStepInfoImpl({
    required int index,
    required String name,
    required _igpykeyr.AppBuildStepStatus status,
    DateTime? startedAt,
    DateTime? endedAt,
  }) : super._(
         index: index,
         name: name,
         status: status,
         startedAt: startedAt,
         endedAt: endedAt,
       );

  /// Returns a shallow copy of this [AppBuildStepInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppBuildStepInfo copyWith({
    int? index,
    String? name,
    _igpykeyr.AppBuildStepStatus? status,
    Object? startedAt = _Undefined,
    Object? endedAt = _Undefined,
  }) {
    return AppBuildStepInfo(
      index: index ?? this.index,
      name: name ?? this.name,
      status: status ?? this.status,
      startedAt: startedAt is DateTime? ? startedAt : this.startedAt,
      endedAt: endedAt is DateTime? ? endedAt : this.endedAt,
    );
  }
}
