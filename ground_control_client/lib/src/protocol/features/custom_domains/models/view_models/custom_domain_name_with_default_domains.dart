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
import '../../../../domains/custom_domains/models/custom_domain_name.dart'
    as _i6gxfe1t;
import '../../../../domains/custom_domains/models/domain_name_target.dart'
    as _imbx0m9g;

abstract class CustomDomainNameWithDefaultDomains
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CustomDomainNameWithDefaultDomains._({
    required this.customDomainName,
    required this.defaultDomainsByTarget,
  });

  factory CustomDomainNameWithDefaultDomains({
    required _i6gxfe1t.CustomDomainName customDomainName,
    required Map<_imbx0m9g.DomainNameTarget, String> defaultDomainsByTarget,
  }) = _CustomDomainNameWithDefaultDomainsImpl;

  factory CustomDomainNameWithDefaultDomains.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CustomDomainNameWithDefaultDomains(
      customDomainName: _iod2a87h.Protocol()
          .deserialize<_i6gxfe1t.CustomDomainName>(
            jsonSerialization['customDomainName'],
          ),
      defaultDomainsByTarget: _iod2a87h.Protocol()
          .deserialize<Map<_imbx0m9g.DomainNameTarget, String>>(
            jsonSerialization['defaultDomainsByTarget'],
          ),
    );
  }

  _i6gxfe1t.CustomDomainName customDomainName;

  Map<_imbx0m9g.DomainNameTarget, String> defaultDomainsByTarget;

  /// Returns a shallow copy of this [CustomDomainNameWithDefaultDomains]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CustomDomainNameWithDefaultDomains copyWith({
    _i6gxfe1t.CustomDomainName? customDomainName,
    Map<_imbx0m9g.DomainNameTarget, String>? defaultDomainsByTarget,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CustomDomainNameWithDefaultDomains',
      'customDomainName': customDomainName.toJson(),
      'defaultDomainsByTarget': defaultDomainsByTarget.toJson(
        keyToJson: (k) => k.toJson(),
      ),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CustomDomainNameWithDefaultDomains',
      'customDomainName': customDomainName.toJsonForProtocol(),
      'defaultDomainsByTarget': defaultDomainsByTarget.toJson(
        keyToJson: (k) => k.toJson(),
      ),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CustomDomainNameWithDefaultDomainsImpl
    extends CustomDomainNameWithDefaultDomains {
  _CustomDomainNameWithDefaultDomainsImpl({
    required _i6gxfe1t.CustomDomainName customDomainName,
    required Map<_imbx0m9g.DomainNameTarget, String> defaultDomainsByTarget,
  }) : super._(
         customDomainName: customDomainName,
         defaultDomainsByTarget: defaultDomainsByTarget,
       );

  /// Returns a shallow copy of this [CustomDomainNameWithDefaultDomains]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CustomDomainNameWithDefaultDomains copyWith({
    _i6gxfe1t.CustomDomainName? customDomainName,
    Map<_imbx0m9g.DomainNameTarget, String>? defaultDomainsByTarget,
  }) {
    return CustomDomainNameWithDefaultDomains(
      customDomainName: customDomainName ?? this.customDomainName.copyWith(),
      defaultDomainsByTarget:
          defaultDomainsByTarget ??
          this.defaultDomainsByTarget.map(
            (key0, value0) => MapEntry(key0, value0),
          ),
    );
  }
}
