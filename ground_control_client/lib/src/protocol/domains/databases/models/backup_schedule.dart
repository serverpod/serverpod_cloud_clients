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
import '../../../domains/databases/models/backup_frequency.dart' as _i2;

/// An automated backup (snapshot) schedule for a database.
abstract class BackupSchedule implements _i1.SerializableModel {
  BackupSchedule._({
    required this.frequency,
    this.hour,
    this.day,
    this.retention,
  });

  factory BackupSchedule({
    required _i2.BackupFrequency frequency,
    int? hour,
    int? day,
    Duration? retention,
  }) = _BackupScheduleImpl;

  factory BackupSchedule.fromJson(Map<String, dynamic> jsonSerialization) {
    return BackupSchedule(
      frequency: _i2.BackupFrequency.fromJson(
        (jsonSerialization['frequency'] as String),
      ),
      hour: jsonSerialization['hour'] as int?,
      day: jsonSerialization['day'] as int?,
      retention: jsonSerialization['retention'] == null
          ? null
          : _i1.DurationJsonExtension.fromJson(jsonSerialization['retention']),
    );
  }

  /// How often a snapshot is taken.
  _i2.BackupFrequency frequency;

  /// The hour of the day (0-23) to take the snapshot, if applicable.
  int? hour;

  /// The day of the week or month (1-31) to take the snapshot, if applicable.
  int? day;

  /// How long a snapshot is retained before it is automatically deleted.
  /// Null keeps snapshots indefinitely.
  Duration? retention;

  /// Returns a shallow copy of this [BackupSchedule]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  BackupSchedule copyWith({
    _i2.BackupFrequency? frequency,
    int? hour,
    int? day,
    Duration? retention,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BackupSchedule',
      'frequency': frequency.toJson(),
      if (hour != null) 'hour': hour,
      if (day != null) 'day': day,
      if (retention != null) 'retention': retention?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BackupScheduleImpl extends BackupSchedule {
  _BackupScheduleImpl({
    required _i2.BackupFrequency frequency,
    int? hour,
    int? day,
    Duration? retention,
  }) : super._(
         frequency: frequency,
         hour: hour,
         day: day,
         retention: retention,
       );

  /// Returns a shallow copy of this [BackupSchedule]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  BackupSchedule copyWith({
    _i2.BackupFrequency? frequency,
    Object? hour = _Undefined,
    Object? day = _Undefined,
    Object? retention = _Undefined,
  }) {
    return BackupSchedule(
      frequency: frequency ?? this.frequency,
      hour: hour is int? ? hour : this.hour,
      day: day is int? ? day : this.day,
      retention: retention is Duration? ? retention : this.retention,
    );
  }
}
