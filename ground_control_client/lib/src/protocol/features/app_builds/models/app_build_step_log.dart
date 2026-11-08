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
import '../../../domains/app_builds/models/app_build_stage.dart' as _itii79hf;
import '../../../domains/app_builds/models/app_build_step_status.dart'
    as _igpykeyr;

/// The log of one ended step of an app build.
abstract class AppBuildStepLog
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AppBuildStepLog._({
    required this.index,
    required this.name,
    required this.stage,
    required this.status,
    this.log,
  });

  factory AppBuildStepLog({
    required int index,
    required String name,
    required _itii79hf.AppBuildStage stage,
    required _igpykeyr.AppBuildStepStatus status,
    String? log,
  }) = _AppBuildStepLogImpl;

  factory AppBuildStepLog.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppBuildStepLog(
      index: jsonSerialization['index'] as int,
      name: jsonSerialization['name'] as String,
      stage: _itii79hf.AppBuildStage.fromJson(
        (jsonSerialization['stage'] as String),
      ),
      status: _igpykeyr.AppBuildStepStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      log: jsonSerialization['log'] as String?,
    );
  }

  /// The step's position in the build, starting at 0.
  int index;

  /// The step's name as the workflow defines it.
  String name;

  _itii79hf.AppBuildStage stage;

  _igpykeyr.AppBuildStepStatus status;

  /// The log as the build service reports it, null once the service has
  /// discarded it.
  String? log;

  /// Returns a shallow copy of this [AppBuildStepLog]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AppBuildStepLog copyWith({
    int? index,
    String? name,
    _itii79hf.AppBuildStage? stage,
    _igpykeyr.AppBuildStepStatus? status,
    String? log,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppBuildStepLog',
      'index': index,
      'name': name,
      'stage': stage.toJson(),
      'status': status.toJson(),
      if (log != null) 'log': log,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppBuildStepLog',
      'index': index,
      'name': name,
      'stage': stage.toJson(),
      'status': status.toJson(),
      if (log != null) 'log': log,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AppBuildStepLogImpl extends AppBuildStepLog {
  _AppBuildStepLogImpl({
    required int index,
    required String name,
    required _itii79hf.AppBuildStage stage,
    required _igpykeyr.AppBuildStepStatus status,
    String? log,
  }) : super._(
         index: index,
         name: name,
         stage: stage,
         status: status,
         log: log,
       );

  /// Returns a shallow copy of this [AppBuildStepLog]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppBuildStepLog copyWith({
    int? index,
    String? name,
    _itii79hf.AppBuildStage? stage,
    _igpykeyr.AppBuildStepStatus? status,
    Object? log = _Undefined,
  }) {
    return AppBuildStepLog(
      index: index ?? this.index,
      name: name ?? this.name,
      stage: stage ?? this.stage,
      status: status ?? this.status,
      log: log is String? ? log : this.log,
    );
  }
}
