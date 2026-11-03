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
import '../../../features/app_builds/models/android_signing.dart' as _idapt6vp;
import '../../../features/app_builds/models/google_play_access.dart'
    as _ivee1xvx;

/// The Android publishing setup. A null part is not set up yet.
abstract class AndroidPublishingSetup
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AndroidPublishingSetup._({this.store, this.signing});

  factory AndroidPublishingSetup({
    _ivee1xvx.GooglePlayAccess? store,
    _idapt6vp.AndroidSigning? signing,
  }) = _AndroidPublishingSetupImpl;

  factory AndroidPublishingSetup.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AndroidPublishingSetup(
      store: jsonSerialization['store'] == null
          ? null
          : _iod2a87h.Protocol().deserialize<_ivee1xvx.GooglePlayAccess>(
              jsonSerialization['store'],
            ),
      signing: jsonSerialization['signing'] == null
          ? null
          : _iod2a87h.Protocol().deserialize<_idapt6vp.AndroidSigning>(
              jsonSerialization['signing'],
            ),
    );
  }

  _ivee1xvx.GooglePlayAccess? store;

  _idapt6vp.AndroidSigning? signing;

  /// Returns a shallow copy of this [AndroidPublishingSetup]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AndroidPublishingSetup copyWith({
    _ivee1xvx.GooglePlayAccess? store,
    _idapt6vp.AndroidSigning? signing,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AndroidPublishingSetup',
      if (store != null) 'store': store?.toJson(),
      if (signing != null) 'signing': signing?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AndroidPublishingSetup',
      if (store != null) 'store': store?.toJsonForProtocol(),
      if (signing != null) 'signing': signing?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AndroidPublishingSetupImpl extends AndroidPublishingSetup {
  _AndroidPublishingSetupImpl({
    _ivee1xvx.GooglePlayAccess? store,
    _idapt6vp.AndroidSigning? signing,
  }) : super._(store: store, signing: signing);

  /// Returns a shallow copy of this [AndroidPublishingSetup]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AndroidPublishingSetup copyWith({
    Object? store = _Undefined,
    Object? signing = _Undefined,
  }) {
    return AndroidPublishingSetup(
      store: store is _ivee1xvx.GooglePlayAccess?
          ? store
          : this.store?.copyWith(),
      signing: signing is _idapt6vp.AndroidSigning?
          ? signing
          : this.signing?.copyWith(),
    );
  }
}
