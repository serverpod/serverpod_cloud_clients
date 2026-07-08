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

/// A point-in-time snapshot (backup) of a database.
abstract class DatabaseSnapshot implements _i1.SerializableModel {
  DatabaseSnapshot._({
    required this.id,
    required this.name,
    required this.createdAt,
    this.expiresAt,
    required this.manual,
    this.fullSizeBytes,
    this.diffSizeBytes,
  });

  factory DatabaseSnapshot({
    required String id,
    required String name,
    required DateTime createdAt,
    DateTime? expiresAt,
    required bool manual,
    int? fullSizeBytes,
    int? diffSizeBytes,
  }) = _DatabaseSnapshotImpl;

  factory DatabaseSnapshot.fromJson(Map<String, dynamic> jsonSerialization) {
    return DatabaseSnapshot(
      id: jsonSerialization['id'] as String,
      name: jsonSerialization['name'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      expiresAt: jsonSerialization['expiresAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['expiresAt']),
      manual: _i1.BoolJsonExtension.fromJson(jsonSerialization['manual']),
      fullSizeBytes: jsonSerialization['fullSizeBytes'] as int?,
      diffSizeBytes: jsonSerialization['diffSizeBytes'] as int?,
    );
  }

  /// The provider snapshot ID.
  String id;

  /// The snapshot name.
  String name;

  /// When the snapshot was created.
  DateTime createdAt;

  /// When the snapshot will be automatically deleted, if a retention was set.
  DateTime? expiresAt;

  /// Whether the snapshot was created manually (true) or by an automated
  /// backup schedule (false).
  bool manual;

  /// Full logical size of the snapshot in bytes. Null when not yet calculated
  /// or the snapshot is not billed.
  int? fullSizeBytes;

  /// Incremental storage size in bytes since the previous scheduled snapshot,
  /// when billed on incremental (diff) usage. Null otherwise.
  int? diffSizeBytes;

  /// Returns a shallow copy of this [DatabaseSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DatabaseSnapshot copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? manual,
    int? fullSizeBytes,
    int? diffSizeBytes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DatabaseSnapshot',
      'id': id,
      'name': name,
      'createdAt': createdAt.toJson(),
      if (expiresAt != null) 'expiresAt': expiresAt?.toJson(),
      'manual': manual,
      if (fullSizeBytes != null) 'fullSizeBytes': fullSizeBytes,
      if (diffSizeBytes != null) 'diffSizeBytes': diffSizeBytes,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DatabaseSnapshotImpl extends DatabaseSnapshot {
  _DatabaseSnapshotImpl({
    required String id,
    required String name,
    required DateTime createdAt,
    DateTime? expiresAt,
    required bool manual,
    int? fullSizeBytes,
    int? diffSizeBytes,
  }) : super._(
         id: id,
         name: name,
         createdAt: createdAt,
         expiresAt: expiresAt,
         manual: manual,
         fullSizeBytes: fullSizeBytes,
         diffSizeBytes: diffSizeBytes,
       );

  /// Returns a shallow copy of this [DatabaseSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DatabaseSnapshot copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    Object? expiresAt = _Undefined,
    bool? manual,
    Object? fullSizeBytes = _Undefined,
    Object? diffSizeBytes = _Undefined,
  }) {
    return DatabaseSnapshot(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt is DateTime? ? expiresAt : this.expiresAt,
      manual: manual ?? this.manual,
      fullSizeBytes: fullSizeBytes is int? ? fullSizeBytes : this.fullSizeBytes,
      diffSizeBytes: diffSizeBytes is int? ? diffSizeBytes : this.diffSizeBytes,
    );
  }
}
