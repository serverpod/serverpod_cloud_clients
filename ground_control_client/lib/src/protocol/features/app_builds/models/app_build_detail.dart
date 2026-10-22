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
import '../../../features/app_builds/models/app_build_step_info.dart'
    as _izzyrcw0;
import '../../../features/app_builds/models/app_build_summary.dart'
    as _ilsfxlsi;

/// An app build with its steps. Step logs are fetched separately.
abstract class AppBuildDetail
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AppBuildDetail._({required this.build, required this.steps});

  factory AppBuildDetail({
    required _ilsfxlsi.AppBuildSummary build,
    required List<_izzyrcw0.AppBuildStepInfo> steps,
  }) = _AppBuildDetailImpl;

  factory AppBuildDetail.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppBuildDetail(
      build: _iod2a87h.Protocol().deserialize<_ilsfxlsi.AppBuildSummary>(
        jsonSerialization['build'],
      ),
      steps: _iod2a87h.Protocol().deserialize<List<_izzyrcw0.AppBuildStepInfo>>(
        jsonSerialization['steps'],
      ),
    );
  }

  _ilsfxlsi.AppBuildSummary build;

  /// The steps in run order. Empty until the build service starts
  /// preparing the build.
  List<_izzyrcw0.AppBuildStepInfo> steps;

  /// Returns a shallow copy of this [AppBuildDetail]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AppBuildDetail copyWith({
    _ilsfxlsi.AppBuildSummary? build,
    List<_izzyrcw0.AppBuildStepInfo>? steps,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppBuildDetail',
      'build': build.toJson(),
      'steps': steps.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppBuildDetail',
      'build': build.toJsonForProtocol(),
      'steps': steps.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AppBuildDetailImpl extends AppBuildDetail {
  _AppBuildDetailImpl({
    required _ilsfxlsi.AppBuildSummary build,
    required List<_izzyrcw0.AppBuildStepInfo> steps,
  }) : super._(build: build, steps: steps);

  /// Returns a shallow copy of this [AppBuildDetail]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppBuildDetail copyWith({
    _ilsfxlsi.AppBuildSummary? build,
    List<_izzyrcw0.AppBuildStepInfo>? steps,
  }) {
    return AppBuildDetail(
      build: build ?? this.build.copyWith(),
      steps: steps ?? this.steps.map((e0) => e0.copyWith()).toList(),
    );
  }
}
