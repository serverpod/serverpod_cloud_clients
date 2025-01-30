/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class ProjectConfig implements _i1.SerializableModel {
  ProjectConfig._({required this.projectId});

  factory ProjectConfig({required String projectId}) = _ProjectConfigImpl;

  factory ProjectConfig.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProjectConfig(projectId: jsonSerialization['projectId'] as String);
  }

  String projectId;

  ProjectConfig copyWith({String? projectId});
  @override
  Map<String, dynamic> toJson() {
    return {'projectId': projectId};
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ProjectConfigImpl extends ProjectConfig {
  _ProjectConfigImpl({required String projectId})
      : super._(projectId: projectId);

  @override
  ProjectConfig copyWith({String? projectId}) {
    return ProjectConfig(projectId: projectId ?? this.projectId);
  }
}
