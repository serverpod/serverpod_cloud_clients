/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import '../../protocol.dart' as _i2;

abstract class CustomDomainNameList implements _i1.SerializableModel {
  CustomDomainNameList._({
    required this.customDomainNames,
    required this.defaultDomainsByTarget,
  });

  factory CustomDomainNameList({
    required List<_i2.CustomDomainName> customDomainNames,
    required Map<_i2.DomainNameTarget, String> defaultDomainsByTarget,
  }) = _CustomDomainNameListImpl;

  factory CustomDomainNameList.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return CustomDomainNameList(
      customDomainNames: (jsonSerialization['customDomainNames'] as List)
          .map(
              (e) => _i2.CustomDomainName.fromJson((e as Map<String, dynamic>)))
          .toList(),
      defaultDomainsByTarget:
          (jsonSerialization['defaultDomainsByTarget'] as List)
              .fold<Map<_i2.DomainNameTarget, String>>(
                  {},
                  (t, e) => {
                        ...t,
                        _i2.DomainNameTarget.fromJson((e['k'] as String)):
                            e['v'] as String
                      }),
    );
  }

  List<_i2.CustomDomainName> customDomainNames;

  Map<_i2.DomainNameTarget, String> defaultDomainsByTarget;

  CustomDomainNameList copyWith({
    List<_i2.CustomDomainName>? customDomainNames,
    Map<_i2.DomainNameTarget, String>? defaultDomainsByTarget,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'customDomainNames':
          customDomainNames.toJson(valueToJson: (v) => v.toJson()),
      'defaultDomainsByTarget':
          defaultDomainsByTarget.toJson(keyToJson: (k) => k.toJson()),
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
    required Map<_i2.DomainNameTarget, String> defaultDomainsByTarget,
  }) : super._(
          customDomainNames: customDomainNames,
          defaultDomainsByTarget: defaultDomainsByTarget,
        );

  @override
  CustomDomainNameList copyWith({
    List<_i2.CustomDomainName>? customDomainNames,
    Map<_i2.DomainNameTarget, String>? defaultDomainsByTarget,
  }) {
    return CustomDomainNameList(
      customDomainNames: customDomainNames ??
          this.customDomainNames.map((e0) => e0.copyWith()).toList(),
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
