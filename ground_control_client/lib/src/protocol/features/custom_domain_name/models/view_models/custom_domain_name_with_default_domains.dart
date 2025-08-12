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
import '../../../../features/custom_domain_name/models/custom_domain_name.dart'
    as _i2;
import '../../../../features/custom_domain_name/models/domain_name_target.dart'
    as _i3;

abstract class CustomDomainNameWithDefaultDomains
    implements _i1.SerializableModel {
  CustomDomainNameWithDefaultDomains._({
    required this.customDomainName,
    required this.defaultDomainsByTarget,
  });

  factory CustomDomainNameWithDefaultDomains({
    required _i2.CustomDomainName customDomainName,
    required Map<_i3.DomainNameTarget, String> defaultDomainsByTarget,
  }) = _CustomDomainNameWithDefaultDomainsImpl;

  factory CustomDomainNameWithDefaultDomains.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return CustomDomainNameWithDefaultDomains(
      customDomainName: _i2.CustomDomainName.fromJson(
          (jsonSerialization['customDomainName'] as Map<String, dynamic>)),
      defaultDomainsByTarget:
          (jsonSerialization['defaultDomainsByTarget'] as List)
              .fold<Map<_i3.DomainNameTarget, String>>(
                  {},
                  (t, e) => {
                        ...t,
                        _i3.DomainNameTarget.fromJson((e['k'] as String)):
                            e['v'] as String
                      }),
    );
  }

  _i2.CustomDomainName customDomainName;

  Map<_i3.DomainNameTarget, String> defaultDomainsByTarget;

  /// Returns a shallow copy of this [CustomDomainNameWithDefaultDomains]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CustomDomainNameWithDefaultDomains copyWith({
    _i2.CustomDomainName? customDomainName,
    Map<_i3.DomainNameTarget, String>? defaultDomainsByTarget,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'customDomainName': customDomainName.toJson(),
      'defaultDomainsByTarget':
          defaultDomainsByTarget.toJson(keyToJson: (k) => k.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _CustomDomainNameWithDefaultDomainsImpl
    extends CustomDomainNameWithDefaultDomains {
  _CustomDomainNameWithDefaultDomainsImpl({
    required _i2.CustomDomainName customDomainName,
    required Map<_i3.DomainNameTarget, String> defaultDomainsByTarget,
  }) : super._(
          customDomainName: customDomainName,
          defaultDomainsByTarget: defaultDomainsByTarget,
        );

  /// Returns a shallow copy of this [CustomDomainNameWithDefaultDomains]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CustomDomainNameWithDefaultDomains copyWith({
    _i2.CustomDomainName? customDomainName,
    Map<_i3.DomainNameTarget, String>? defaultDomainsByTarget,
  }) {
    return CustomDomainNameWithDefaultDomains(
      customDomainName: customDomainName ?? this.customDomainName.copyWith(),
      defaultDomainsByTarget: defaultDomainsByTarget ??
          this.defaultDomainsByTarget.map((
                key0,
                value0,
              ) =>
                  MapEntry(
                    key0,
                    value0,
                  )),
    );
  }
}
