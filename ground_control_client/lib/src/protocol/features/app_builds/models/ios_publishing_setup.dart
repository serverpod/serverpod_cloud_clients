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
import '../../../features/app_builds/models/app_store_access.dart' as _itimvqcs;
import '../../../features/app_builds/models/ios_signing.dart' as _ial6z2m9;

/// The iOS publishing setup. A null part is not set up yet.
abstract class IosPublishingSetup
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  IosPublishingSetup._({this.store, this.signing});

  factory IosPublishingSetup({
    _itimvqcs.AppStoreAccess? store,
    _ial6z2m9.IosSigning? signing,
  }) = _IosPublishingSetupImpl;

  factory IosPublishingSetup.fromJson(Map<String, dynamic> jsonSerialization) {
    return IosPublishingSetup(
      store: jsonSerialization['store'] == null
          ? null
          : _iod2a87h.Protocol().deserialize<_itimvqcs.AppStoreAccess>(
              jsonSerialization['store'],
            ),
      signing: jsonSerialization['signing'] == null
          ? null
          : _iod2a87h.Protocol().deserialize<_ial6z2m9.IosSigning>(
              jsonSerialization['signing'],
            ),
    );
  }

  _itimvqcs.AppStoreAccess? store;

  _ial6z2m9.IosSigning? signing;

  /// Returns a shallow copy of this [IosPublishingSetup]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  IosPublishingSetup copyWith({
    _itimvqcs.AppStoreAccess? store =
        const _UndefinedIosPublishingSetup$store(),
    _ial6z2m9.IosSigning? signing =
        const _UndefinedIosPublishingSetup$signing(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IosPublishingSetup',
      if (store != null) 'store': store?.toJson(),
      if (signing != null) 'signing': signing?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IosPublishingSetup',
      if (store != null) 'store': store?.toJsonForProtocol(),
      if (signing != null) 'signing': signing?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _UndefinedIosPublishingSetup$store extends _isc.UndefinedSentinel
    implements _itimvqcs.AppStoreAccess {
  const _UndefinedIosPublishingSetup$store();
}

class _UndefinedIosPublishingSetup$signing extends _isc.UndefinedSentinel
    implements _ial6z2m9.IosSigning {
  const _UndefinedIosPublishingSetup$signing();
}

class _IosPublishingSetupImpl extends IosPublishingSetup {
  _IosPublishingSetupImpl({
    _itimvqcs.AppStoreAccess? store,
    _ial6z2m9.IosSigning? signing,
  }) : super._(store: store, signing: signing);

  /// Returns a shallow copy of this [IosPublishingSetup]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  IosPublishingSetup copyWith({
    _itimvqcs.AppStoreAccess? store =
        const _UndefinedIosPublishingSetup$store(),
    _ial6z2m9.IosSigning? signing =
        const _UndefinedIosPublishingSetup$signing(),
  }) {
    return IosPublishingSetup(
      store: store is _isc.UndefinedSentinel ? this.store?.copyWith() : store,
      signing: signing is _isc.UndefinedSentinel
          ? this.signing?.copyWith()
          : signing,
    );
  }
}
