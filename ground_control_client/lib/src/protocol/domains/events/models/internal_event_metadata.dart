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

abstract class InternalEventMetadata
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  InternalEventMetadata._({
    required this.topic,
    required this.listener,
    required this.publishedAt,
  });

  factory InternalEventMetadata({
    required String topic,
    required String listener,
    required DateTime publishedAt,
  }) = _InternalEventMetadataImpl;

  factory InternalEventMetadata.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return InternalEventMetadata(
      topic: jsonSerialization['topic'] as String,
      listener: jsonSerialization['listener'] as String,
      publishedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['publishedAt'],
      ),
    );
  }

  String topic;

  String listener;

  DateTime publishedAt;

  /// Returns a shallow copy of this [InternalEventMetadata]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  InternalEventMetadata copyWith({
    String? topic,
    String? listener,
    DateTime? publishedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'InternalEventMetadata',
      'topic': topic,
      'listener': listener,
      'publishedAt': publishedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'InternalEventMetadata',
      'topic': topic,
      'listener': listener,
      'publishedAt': publishedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _InternalEventMetadataImpl extends InternalEventMetadata {
  _InternalEventMetadataImpl({
    required String topic,
    required String listener,
    required DateTime publishedAt,
  }) : super._(topic: topic, listener: listener, publishedAt: publishedAt);

  /// Returns a shallow copy of this [InternalEventMetadata]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  InternalEventMetadata copyWith({
    String? topic,
    String? listener,
    DateTime? publishedAt,
  }) {
    return InternalEventMetadata(
      topic: topic ?? this.topic,
      listener: listener ?? this.listener,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }
}
