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
import '../../../domains/app_builds/models/app_build_status.dart' as _ih9cduki;
import '../../../domains/app_builds/models/app_platform.dart' as _ibmlgwb0;
import '../../../domains/users/models/user.dart' as _ijl94k1v;

/// One app build, as listed in build history and as a platform's latest
/// build.
abstract class AppBuildSummary
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AppBuildSummary._({
    required this.id,
    required this.platform,
    required this.status,
    this.queuePosition,
    this.versionName,
    this.buildNumber,
    this.message,
    this.requestedBy,
    this.commitHash,
    this.commitMessage,
    this.branch,
    this.deployAttemptId,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
  });

  factory AppBuildSummary({
    required _isc.UuidValue id,
    required _ibmlgwb0.AppPlatform platform,
    required _ih9cduki.AppBuildStatus status,
    int? queuePosition,
    String? versionName,
    String? buildNumber,
    String? message,
    _ijl94k1v.User? requestedBy,
    String? commitHash,
    String? commitMessage,
    String? branch,
    _isc.UuidValue? deployAttemptId,
    required DateTime createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
  }) = _AppBuildSummaryImpl;

  factory AppBuildSummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppBuildSummary(
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      platform: _ibmlgwb0.AppPlatform.fromJson(
        (jsonSerialization['platform'] as String),
      ),
      status: _ih9cduki.AppBuildStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      queuePosition: jsonSerialization['queuePosition'] as int?,
      versionName: jsonSerialization['versionName'] as String?,
      buildNumber: jsonSerialization['buildNumber'] as String?,
      message: jsonSerialization['message'] as String?,
      requestedBy: jsonSerialization['requestedBy'] == null
          ? null
          : _iod2a87h.Protocol().deserialize<_ijl94k1v.User>(
              jsonSerialization['requestedBy'],
            ),
      commitHash: jsonSerialization['commitHash'] as String?,
      commitMessage: jsonSerialization['commitMessage'] as String?,
      branch: jsonSerialization['branch'] as String?,
      deployAttemptId: jsonSerialization['deployAttemptId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['deployAttemptId'],
            ),
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      startedAt: jsonSerialization['startedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['startedAt']),
      endedAt: jsonSerialization['endedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['endedAt']),
    );
  }

  _isc.UuidValue id;

  _ibmlgwb0.AppPlatform platform;

  _ih9cduki.AppBuildStatus status;

  /// The build's place in the owner's queue, starting at 1. Only set while
  /// the status is `queued`.
  int? queuePosition;

  /// The app version the build was made with, from the app's pubspec.
  String? versionName;

  /// The build number the store received. Set when the build succeeds.
  /// A string because Apple allows dotted build numbers.
  String? buildNumber;

  /// The build service's explanation when it rejects or fails the build.
  String? message;

  /// The user who requested the build, if known.
  _ijl94k1v.User? requestedBy;

  /// Short git commit hash, if provided by the client at deploy time.
  String? commitHash;

  /// First line of the git commit message, if provided by the client at
  /// deploy time.
  String? commitMessage;

  /// Git branch the deploy was triggered from, if provided by the client
  /// at deploy time.
  String? branch;

  /// The server deploy attempt of the same `scloud deploy` run, if the
  /// client provided one.
  _isc.UuidValue? deployAttemptId;

  /// When the build was requested.
  DateTime createdAt;

  /// When the build was handed to the build service. Null while queued.
  DateTime? startedAt;

  /// When the build reached a final status.
  DateTime? endedAt;

  /// Returns a shallow copy of this [AppBuildSummary]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AppBuildSummary copyWith({
    _isc.UuidValue? id,
    _ibmlgwb0.AppPlatform? platform,
    _ih9cduki.AppBuildStatus? status,
    int? queuePosition,
    String? versionName,
    String? buildNumber,
    String? message,
    _ijl94k1v.User? requestedBy,
    String? commitHash,
    String? commitMessage,
    String? branch,
    _isc.UuidValue? deployAttemptId,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppBuildSummary',
      'id': id.toJson(),
      'platform': platform.toJson(),
      'status': status.toJson(),
      if (queuePosition != null) 'queuePosition': queuePosition,
      if (versionName != null) 'versionName': versionName,
      if (buildNumber != null) 'buildNumber': buildNumber,
      if (message != null) 'message': message,
      if (requestedBy != null) 'requestedBy': requestedBy?.toJson(),
      if (commitHash != null) 'commitHash': commitHash,
      if (commitMessage != null) 'commitMessage': commitMessage,
      if (branch != null) 'branch': branch,
      if (deployAttemptId != null) 'deployAttemptId': deployAttemptId?.toJson(),
      'createdAt': createdAt.toJson(),
      if (startedAt != null) 'startedAt': startedAt?.toJson(),
      if (endedAt != null) 'endedAt': endedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppBuildSummary',
      'id': id.toJson(),
      'platform': platform.toJson(),
      'status': status.toJson(),
      if (queuePosition != null) 'queuePosition': queuePosition,
      if (versionName != null) 'versionName': versionName,
      if (buildNumber != null) 'buildNumber': buildNumber,
      if (message != null) 'message': message,
      if (requestedBy != null) 'requestedBy': requestedBy?.toJsonForProtocol(),
      if (commitHash != null) 'commitHash': commitHash,
      if (commitMessage != null) 'commitMessage': commitMessage,
      if (branch != null) 'branch': branch,
      if (deployAttemptId != null) 'deployAttemptId': deployAttemptId?.toJson(),
      'createdAt': createdAt.toJson(),
      if (startedAt != null) 'startedAt': startedAt?.toJson(),
      if (endedAt != null) 'endedAt': endedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AppBuildSummaryImpl extends AppBuildSummary {
  _AppBuildSummaryImpl({
    required _isc.UuidValue id,
    required _ibmlgwb0.AppPlatform platform,
    required _ih9cduki.AppBuildStatus status,
    int? queuePosition,
    String? versionName,
    String? buildNumber,
    String? message,
    _ijl94k1v.User? requestedBy,
    String? commitHash,
    String? commitMessage,
    String? branch,
    _isc.UuidValue? deployAttemptId,
    required DateTime createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
  }) : super._(
         id: id,
         platform: platform,
         status: status,
         queuePosition: queuePosition,
         versionName: versionName,
         buildNumber: buildNumber,
         message: message,
         requestedBy: requestedBy,
         commitHash: commitHash,
         commitMessage: commitMessage,
         branch: branch,
         deployAttemptId: deployAttemptId,
         createdAt: createdAt,
         startedAt: startedAt,
         endedAt: endedAt,
       );

  /// Returns a shallow copy of this [AppBuildSummary]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppBuildSummary copyWith({
    _isc.UuidValue? id,
    _ibmlgwb0.AppPlatform? platform,
    _ih9cduki.AppBuildStatus? status,
    Object? queuePosition = _Undefined,
    Object? versionName = _Undefined,
    Object? buildNumber = _Undefined,
    Object? message = _Undefined,
    Object? requestedBy = _Undefined,
    Object? commitHash = _Undefined,
    Object? commitMessage = _Undefined,
    Object? branch = _Undefined,
    Object? deployAttemptId = _Undefined,
    DateTime? createdAt,
    Object? startedAt = _Undefined,
    Object? endedAt = _Undefined,
  }) {
    return AppBuildSummary(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      status: status ?? this.status,
      queuePosition: queuePosition is int? ? queuePosition : this.queuePosition,
      versionName: versionName is String? ? versionName : this.versionName,
      buildNumber: buildNumber is String? ? buildNumber : this.buildNumber,
      message: message is String? ? message : this.message,
      requestedBy: requestedBy is _ijl94k1v.User?
          ? requestedBy
          : this.requestedBy?.copyWith(),
      commitHash: commitHash is String? ? commitHash : this.commitHash,
      commitMessage: commitMessage is String?
          ? commitMessage
          : this.commitMessage,
      branch: branch is String? ? branch : this.branch,
      deployAttemptId: deployAttemptId is _isc.UuidValue?
          ? deployAttemptId
          : this.deployAttemptId,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt is DateTime? ? startedAt : this.startedAt,
      endedAt: endedAt is DateTime? ? endedAt : this.endedAt,
    );
  }
}
