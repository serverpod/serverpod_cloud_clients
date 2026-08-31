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

abstract class InsightsConnectionDetail
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  InsightsConnectionDetail._({required this.url, required this.serviceSecret});

  factory InsightsConnectionDetail({
    required Uri url,
    required String serviceSecret,
  }) = _InsightsConnectionDetailImpl;

  factory InsightsConnectionDetail.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return InsightsConnectionDetail(
      url: _isc.UriJsonExtension.fromJson(jsonSerialization['url']),
      serviceSecret: jsonSerialization['serviceSecret'] as String,
    );
  }

  Uri url;

  String serviceSecret;

  /// Returns a shallow copy of this [InsightsConnectionDetail]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  InsightsConnectionDetail copyWith({Uri? url, String? serviceSecret});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'InsightsConnectionDetail',
      'url': url.toJson(),
      'serviceSecret': serviceSecret,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'InsightsConnectionDetail',
      'url': url.toJson(),
      'serviceSecret': serviceSecret,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _InsightsConnectionDetailImpl extends InsightsConnectionDetail {
  _InsightsConnectionDetailImpl({
    required Uri url,
    required String serviceSecret,
  }) : super._(url: url, serviceSecret: serviceSecret);

  /// Returns a shallow copy of this [InsightsConnectionDetail]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  InsightsConnectionDetail copyWith({Uri? url, String? serviceSecret}) {
    return InsightsConnectionDetail(
      url: url ?? this.url,
      serviceSecret: serviceSecret ?? this.serviceSecret,
    );
  }
}
