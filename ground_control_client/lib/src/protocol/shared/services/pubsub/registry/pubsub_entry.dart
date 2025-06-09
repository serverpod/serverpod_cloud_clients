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

/// Represents the receiving of a Pubsub message.
abstract class PubsubEntry implements _i1.SerializableModel {
  PubsubEntry._({
    this.id,
    DateTime? createdAt,
    this.publishedAt,
    required this.messageId,
    required this.topic,
    required this.subscriber,
  }) : createdAt = createdAt ?? DateTime.now();

  factory PubsubEntry({
    int? id,
    DateTime? createdAt,
    DateTime? publishedAt,
    required String messageId,
    required String topic,
    required String subscriber,
  }) = _PubsubEntryImpl;

  factory PubsubEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return PubsubEntry(
      id: jsonSerialization['id'] as int?,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      publishedAt: jsonSerialization['publishedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['publishedAt']),
      messageId: jsonSerialization['messageId'] as String,
      topic: jsonSerialization['topic'] as String,
      subscriber: jsonSerialization['subscriber'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// When this pubsub entry was created in the database.
  DateTime createdAt;

  /// When this pubsub entry was published.
  DateTime? publishedAt;

  /// The message id of the pubsub entry. Globally unique.
  String messageId;

  /// The topic of the pubsub entry.
  String topic;

  /// The subscriber (listener) of the pubsub entry.
  String subscriber;

  /// Returns a shallow copy of this [PubsubEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PubsubEntry copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? publishedAt,
    String? messageId,
    String? topic,
    String? subscriber,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'createdAt': createdAt.toJson(),
      if (publishedAt != null) 'publishedAt': publishedAt?.toJson(),
      'messageId': messageId,
      'topic': topic,
      'subscriber': subscriber,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PubsubEntryImpl extends PubsubEntry {
  _PubsubEntryImpl({
    int? id,
    DateTime? createdAt,
    DateTime? publishedAt,
    required String messageId,
    required String topic,
    required String subscriber,
  }) : super._(
          id: id,
          createdAt: createdAt,
          publishedAt: publishedAt,
          messageId: messageId,
          topic: topic,
          subscriber: subscriber,
        );

  /// Returns a shallow copy of this [PubsubEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PubsubEntry copyWith({
    Object? id = _Undefined,
    DateTime? createdAt,
    Object? publishedAt = _Undefined,
    String? messageId,
    String? topic,
    String? subscriber,
  }) {
    return PubsubEntry(
      id: id is int? ? id : this.id,
      createdAt: createdAt ?? this.createdAt,
      publishedAt: publishedAt is DateTime? ? publishedAt : this.publishedAt,
      messageId: messageId ?? this.messageId,
      topic: topic ?? this.topic,
      subscriber: subscriber ?? this.subscriber,
    );
  }
}
