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

abstract class DatabaseConnection implements _i1.SerializableModel {
  DatabaseConnection._({
    required this.host,
    required this.port,
    required this.name,
    required this.user,
    bool? requiresSsl,
  }) : requiresSsl = requiresSsl ?? true;

  factory DatabaseConnection({
    required String host,
    required int port,
    required String name,
    required String user,
    bool? requiresSsl,
  }) = _DatabaseConnectionImpl;

  factory DatabaseConnection.fromJson(Map<String, dynamic> jsonSerialization) {
    return DatabaseConnection(
      host: jsonSerialization['host'] as String,
      port: jsonSerialization['port'] as int,
      name: jsonSerialization['name'] as String,
      user: jsonSerialization['user'] as String,
      requiresSsl: jsonSerialization['requiresSsl'] as bool,
    );
  }

  String host;

  int port;

  String name;

  String user;

  bool requiresSsl;

  /// Returns a shallow copy of this [DatabaseConnection]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DatabaseConnection copyWith({
    String? host,
    int? port,
    String? name,
    String? user,
    bool? requiresSsl,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'host': host,
      'port': port,
      'name': name,
      'user': user,
      'requiresSsl': requiresSsl,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _DatabaseConnectionImpl extends DatabaseConnection {
  _DatabaseConnectionImpl({
    required String host,
    required int port,
    required String name,
    required String user,
    bool? requiresSsl,
  }) : super._(
          host: host,
          port: port,
          name: name,
          user: user,
          requiresSsl: requiresSsl,
        );

  /// Returns a shallow copy of this [DatabaseConnection]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DatabaseConnection copyWith({
    String? host,
    int? port,
    String? name,
    String? user,
    bool? requiresSsl,
  }) {
    return DatabaseConnection(
      host: host ?? this.host,
      port: port ?? this.port,
      name: name ?? this.name,
      user: user ?? this.user,
      requiresSsl: requiresSsl ?? this.requiresSsl,
    );
  }
}
