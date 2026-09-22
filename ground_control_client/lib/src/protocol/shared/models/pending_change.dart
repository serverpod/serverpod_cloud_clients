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
import '../../shared/models/pending_change_state.dart' as _iizv7y8n;

/// A deployment input that has changed since the capsule was last deployed
/// with it, and that the next deployment will apply.
abstract class PendingChange
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PendingChange._({required this.name, required this.state});

  factory PendingChange({
    required String name,
    required _iizv7y8n.PendingChangeState state,
  }) = _PendingChangeImpl;

  factory PendingChange.fromJson(Map<String, dynamic> jsonSerialization) {
    return PendingChange(
      name: jsonSerialization['name'] as String,
      state: _iizv7y8n.PendingChangeState.fromJson(
        (jsonSerialization['state'] as String),
      ),
    );
  }

  /// The name of the environment variable or secret key. Values are never
  /// part of this model.
  String name;

  /// How it differs from the deployed version.
  _iizv7y8n.PendingChangeState state;

  /// Returns a shallow copy of this [PendingChange]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PendingChange copyWith({String? name, _iizv7y8n.PendingChangeState? state});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PendingChange',
      'name': name,
      'state': state.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PendingChange',
      'name': name,
      'state': state.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _PendingChangeImpl extends PendingChange {
  _PendingChangeImpl({
    required String name,
    required _iizv7y8n.PendingChangeState state,
  }) : super._(name: name, state: state);

  /// Returns a shallow copy of this [PendingChange]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PendingChange copyWith({String? name, _iizv7y8n.PendingChangeState? state}) {
    return PendingChange(name: name ?? this.name, state: state ?? this.state);
  }
}
