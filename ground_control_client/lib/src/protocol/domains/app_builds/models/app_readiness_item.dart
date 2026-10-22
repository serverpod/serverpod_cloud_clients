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
import '../../../domains/app_builds/models/app_readiness_key.dart' as _iadj8iaz;

/// One item of a platform's readiness checklist.
abstract class AppReadinessItem
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AppReadinessItem._({
    required this.key,
    required this.done,
    required this.title,
    this.action,
    this.url,
  });

  factory AppReadinessItem({
    required _iadj8iaz.AppReadinessKey key,
    required bool done,
    required String title,
    String? action,
    String? url,
  }) = _AppReadinessItemImpl;

  factory AppReadinessItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppReadinessItem(
      key: _iadj8iaz.AppReadinessKey.fromJson(
        (jsonSerialization['key'] as String),
      ),
      done: _isc.BoolJsonExtension.fromJson(jsonSerialization['done']),
      title: jsonSerialization['title'] as String,
      action: jsonSerialization['action'] as String?,
      url: jsonSerialization['url'] as String?,
    );
  }

  _iadj8iaz.AppReadinessKey key;

  bool done;

  /// What the item is, for display.
  String title;

  /// What the customer has to do when the item is not done.
  String? action;

  /// Where to do it, when there is a page for it.
  String? url;

  /// Returns a shallow copy of this [AppReadinessItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AppReadinessItem copyWith({
    _iadj8iaz.AppReadinessKey? key,
    bool? done,
    String? title,
    String? action,
    String? url,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppReadinessItem',
      'key': key.toJson(),
      'done': done,
      'title': title,
      if (action != null) 'action': action,
      if (url != null) 'url': url,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppReadinessItem',
      'key': key.toJson(),
      'done': done,
      'title': title,
      if (action != null) 'action': action,
      if (url != null) 'url': url,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AppReadinessItemImpl extends AppReadinessItem {
  _AppReadinessItemImpl({
    required _iadj8iaz.AppReadinessKey key,
    required bool done,
    required String title,
    String? action,
    String? url,
  }) : super._(key: key, done: done, title: title, action: action, url: url);

  /// Returns a shallow copy of this [AppReadinessItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppReadinessItem copyWith({
    _iadj8iaz.AppReadinessKey? key,
    bool? done,
    String? title,
    Object? action = _Undefined,
    Object? url = _Undefined,
  }) {
    return AppReadinessItem(
      key: key ?? this.key,
      done: done ?? this.done,
      title: title ?? this.title,
      action: action is String? ? action : this.action,
      url: url is String? ? url : this.url,
    );
  }
}
