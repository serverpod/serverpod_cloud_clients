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
import '../../../protocol.dart' as _i26f4ubs;
part 'app_store_connect_credential_info.dart';
part 'google_play_credential_info.dart';

/// The public part of a store credential, stored with the connection. The
/// key itself is never stored here.
sealed class StoreCredentialInfo
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  StoreCredentialInfo();

  /// Returns a shallow copy of this [StoreCredentialInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  StoreCredentialInfo copyWith();
}
