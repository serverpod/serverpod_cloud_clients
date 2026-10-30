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
import '../../../domains/store_connections/models/store_type.dart' as _is7r02rq;

/// A store credential an owner registered for publishing apps. The key
/// itself lives in Secret Manager; this row records only where.
abstract class StoreConnection
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  StoreConnection._({
    _isc.UuidValue? id,
    required this.ownerId,
    required this.store,
    required this.name,
    this.issuerId,
    this.keyId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const _isc.Uuid().v4obj(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory StoreConnection({
    _isc.UuidValue? id,
    required _isc.UuidValue ownerId,
    required _is7r02rq.StoreType store,
    required String name,
    String? issuerId,
    String? keyId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _StoreConnectionImpl;

  factory StoreConnection.fromJson(Map<String, dynamic> jsonSerialization) {
    return StoreConnection(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      ownerId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['ownerId'],
      ),
      store: _is7r02rq.StoreType.fromJson(
        (jsonSerialization['store'] as String),
      ),
      name: jsonSerialization['name'] as String,
      issuerId: jsonSerialization['issuerId'] as String?,
      keyId: jsonSerialization['keyId'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The id of the object.
  _isc.UuidValue id;

  _isc.UuidValue ownerId;

  _is7r02rq.StoreType store;

  String name;

  /// App Store Connect only. Null for Google Play.
  String? issuerId;

  String? keyId;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [StoreConnection]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  StoreConnection copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? ownerId,
    _is7r02rq.StoreType? store,
    String? name,
    String? issuerId,
    String? keyId,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StoreConnection',
      'id': id.toJson(),
      'ownerId': ownerId.toJson(),
      'store': store.toJson(),
      'name': name,
      if (issuerId != null) 'issuerId': issuerId,
      if (keyId != null) 'keyId': keyId,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'StoreConnection',
      'id': id.toJson(),
      'ownerId': ownerId.toJson(),
      'store': store.toJson(),
      'name': name,
      if (issuerId != null) 'issuerId': issuerId,
      if (keyId != null) 'keyId': keyId,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StoreConnectionImpl extends StoreConnection {
  _StoreConnectionImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue ownerId,
    required _is7r02rq.StoreType store,
    required String name,
    String? issuerId,
    String? keyId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         ownerId: ownerId,
         store: store,
         name: name,
         issuerId: issuerId,
         keyId: keyId,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [StoreConnection]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  StoreConnection copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? ownerId,
    _is7r02rq.StoreType? store,
    String? name,
    Object? issuerId = _Undefined,
    Object? keyId = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StoreConnection(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      store: store ?? this.store,
      name: name ?? this.name,
      issuerId: issuerId is String? ? issuerId : this.issuerId,
      keyId: keyId is String? ? keyId : this.keyId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
