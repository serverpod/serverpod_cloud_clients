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
import '../../../features/custom_domains/models/custom_domain_name.dart' as _i2;
import '../../../features/custom_domains/models/domain_name_target.dart' as _i3;
import 'package:ground_control_client/src/protocol/protocol.dart' as _i4;

abstract class CustomDomainNameList implements _i1.SerializableModel {
  CustomDomainNameList._({
    required this.customDomainNames,
    required this.defaultDomainsByTarget,
  });

  factory CustomDomainNameList({
    required List<_i2.CustomDomainName> customDomainNames,
    required Map<_i3.DomainNameTarget, String> defaultDomainsByTarget,
  }) = _CustomDomainNameListImpl;

  factory CustomDomainNameList.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CustomDomainNameList(
      customDomainNames: _i4.Protocol().deserialize<List<_i2.CustomDomainName>>(
        jsonSerialization['customDomainNames'],
      ),
      defaultDomainsByTarget: _i4.Protocol()
          .deserialize<Map<_i3.DomainNameTarget, String>>(
            jsonSerialization['defaultDomainsByTarget'],
          ),
    );
  }

  List<_i2.CustomDomainName> customDomainNames;

  Map<_i3.DomainNameTarget, String> defaultDomainsByTarget;

  /// Returns a shallow copy of this [CustomDomainNameList]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CustomDomainNameList copyWith({
    List<_i2.CustomDomainName>? customDomainNames,
    Map<_i3.DomainNameTarget, String>? defaultDomainsByTarget,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CustomDomainNameList',
      'customDomainNames': customDomainNames.toJson(
        valueToJson: (v) => v.toJson(),
      ),
      'defaultDomainsByTarget': defaultDomainsByTarget.toJson(
        keyToJson: (k) => k.toJson(),
      ),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _CustomDomainNameListImpl extends CustomDomainNameList {
  _CustomDomainNameListImpl({
    required List<_i2.CustomDomainName> customDomainNames,
    required Map<_i3.DomainNameTarget, String> defaultDomainsByTarget,
  }) : super._(
         customDomainNames: customDomainNames,
         defaultDomainsByTarget: defaultDomainsByTarget,
       );

  /// Returns a shallow copy of this [CustomDomainNameList]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CustomDomainNameList copyWith({
    List<_i2.CustomDomainName>? customDomainNames,
    Map<_i3.DomainNameTarget, String>? defaultDomainsByTarget,
  }) {
    return CustomDomainNameList(
      customDomainNames:
          customDomainNames ??
          this.customDomainNames.map((e0) => e0.copyWith()).toList(),
      defaultDomainsByTarget:
          defaultDomainsByTarget ??
          this.defaultDomainsByTarget.map(
            (
              key0,
              value0,
            ) => MapEntry(
              key0,
              value0,
            ),
          ),
    );
  }
}
