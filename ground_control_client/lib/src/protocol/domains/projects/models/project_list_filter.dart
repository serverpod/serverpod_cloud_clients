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
import '../../../domains/projects/models/project_lifecycle_status.dart'
    as _ie2v77w9;

/// Filters a project list by lifecycle phase and by when projects were
/// created, suspended, or archived.
///
/// Archived projects are included when [phase] is archived, or when
/// [archivedSince] or [archivedUntil] is set, even if the caller did not
/// ask to include archived projects.
/// Time bounds are inclusive. A null bound is not applied.
abstract class ProjectListFilter
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ProjectListFilter._({
    this.phase,
    this.createdSince,
    this.createdUntil,
    this.suspendedSince,
    this.suspendedUntil,
    this.archivedSince,
    this.archivedUntil,
  });

  factory ProjectListFilter({
    _ie2v77w9.ProjectLifecycleStatus? phase,
    DateTime? createdSince,
    DateTime? createdUntil,
    DateTime? suspendedSince,
    DateTime? suspendedUntil,
    DateTime? archivedSince,
    DateTime? archivedUntil,
  }) = _ProjectListFilterImpl;

  factory ProjectListFilter.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProjectListFilter(
      phase: jsonSerialization['phase'] == null
          ? null
          : _ie2v77w9.ProjectLifecycleStatus.fromJson(
              (jsonSerialization['phase'] as String),
            ),
      createdSince: jsonSerialization['createdSince'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['createdSince'],
            ),
      createdUntil: jsonSerialization['createdUntil'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['createdUntil'],
            ),
      suspendedSince: jsonSerialization['suspendedSince'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['suspendedSince'],
            ),
      suspendedUntil: jsonSerialization['suspendedUntil'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['suspendedUntil'],
            ),
      archivedSince: jsonSerialization['archivedSince'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['archivedSince'],
            ),
      archivedUntil: jsonSerialization['archivedUntil'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['archivedUntil'],
            ),
    );
  }

  /// Only projects in this lifecycle phase.
  _ie2v77w9.ProjectLifecycleStatus? phase;

  /// Only projects created at or after this time.
  DateTime? createdSince;

  /// Only projects created at or before this time.
  DateTime? createdUntil;

  /// Only projects suspended at or after this time.
  DateTime? suspendedSince;

  /// Only projects suspended at or before this time.
  DateTime? suspendedUntil;

  /// Only projects archived at or after this time.
  DateTime? archivedSince;

  /// Only projects archived at or before this time.
  DateTime? archivedUntil;

  /// Returns a shallow copy of this [ProjectListFilter]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ProjectListFilter copyWith({
    _ie2v77w9.ProjectLifecycleStatus? phase,
    DateTime? createdSince,
    DateTime? createdUntil,
    DateTime? suspendedSince,
    DateTime? suspendedUntil,
    DateTime? archivedSince,
    DateTime? archivedUntil,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProjectListFilter',
      if (phase != null) 'phase': phase?.toJson(),
      if (createdSince != null) 'createdSince': createdSince?.toJson(),
      if (createdUntil != null) 'createdUntil': createdUntil?.toJson(),
      if (suspendedSince != null) 'suspendedSince': suspendedSince?.toJson(),
      if (suspendedUntil != null) 'suspendedUntil': suspendedUntil?.toJson(),
      if (archivedSince != null) 'archivedSince': archivedSince?.toJson(),
      if (archivedUntil != null) 'archivedUntil': archivedUntil?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ProjectListFilter',
      if (phase != null) 'phase': phase?.toJson(),
      if (createdSince != null) 'createdSince': createdSince?.toJson(),
      if (createdUntil != null) 'createdUntil': createdUntil?.toJson(),
      if (suspendedSince != null) 'suspendedSince': suspendedSince?.toJson(),
      if (suspendedUntil != null) 'suspendedUntil': suspendedUntil?.toJson(),
      if (archivedSince != null) 'archivedSince': archivedSince?.toJson(),
      if (archivedUntil != null) 'archivedUntil': archivedUntil?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProjectListFilterImpl extends ProjectListFilter {
  _ProjectListFilterImpl({
    _ie2v77w9.ProjectLifecycleStatus? phase,
    DateTime? createdSince,
    DateTime? createdUntil,
    DateTime? suspendedSince,
    DateTime? suspendedUntil,
    DateTime? archivedSince,
    DateTime? archivedUntil,
  }) : super._(
         phase: phase,
         createdSince: createdSince,
         createdUntil: createdUntil,
         suspendedSince: suspendedSince,
         suspendedUntil: suspendedUntil,
         archivedSince: archivedSince,
         archivedUntil: archivedUntil,
       );

  /// Returns a shallow copy of this [ProjectListFilter]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ProjectListFilter copyWith({
    Object? phase = _Undefined,
    Object? createdSince = _Undefined,
    Object? createdUntil = _Undefined,
    Object? suspendedSince = _Undefined,
    Object? suspendedUntil = _Undefined,
    Object? archivedSince = _Undefined,
    Object? archivedUntil = _Undefined,
  }) {
    return ProjectListFilter(
      phase: phase is _ie2v77w9.ProjectLifecycleStatus? ? phase : this.phase,
      createdSince: createdSince is DateTime?
          ? createdSince
          : this.createdSince,
      createdUntil: createdUntil is DateTime?
          ? createdUntil
          : this.createdUntil,
      suspendedSince: suspendedSince is DateTime?
          ? suspendedSince
          : this.suspendedSince,
      suspendedUntil: suspendedUntil is DateTime?
          ? suspendedUntil
          : this.suspendedUntil,
      archivedSince: archivedSince is DateTime?
          ? archivedSince
          : this.archivedSince,
      archivedUntil: archivedUntil is DateTime?
          ? archivedUntil
          : this.archivedUntil,
    );
  }
}
