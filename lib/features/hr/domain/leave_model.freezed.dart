// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leave_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

LeaveRecord _$LeaveRecordFromJson(Map<String, dynamic> json) {
  return _LeaveRecord.fromJson(json);
}

/// @nodoc
mixin _$LeaveRecord {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'employeeId')
  String get employeeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'leaveType')
  String get leaveType => throw _privateConstructorUsedError;
  @JsonKey(name: 'startDate')
  String get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'endDate')
  String get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'durationDays')
  String get durationDays => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  String? get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LeaveRecordCopyWith<LeaveRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaveRecordCopyWith<$Res> {
  factory $LeaveRecordCopyWith(
          LeaveRecord value, $Res Function(LeaveRecord) then) =
      _$LeaveRecordCopyWithImpl<$Res, LeaveRecord>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'employeeId') String employeeId,
      @JsonKey(name: 'leaveType') String leaveType,
      @JsonKey(name: 'startDate') String startDate,
      @JsonKey(name: 'endDate') String endDate,
      @JsonKey(name: 'durationDays') String durationDays,
      String status,
      String? reason,
      String? firstName,
      String? lastName});
}

/// @nodoc
class _$LeaveRecordCopyWithImpl<$Res, $Val extends LeaveRecord>
    implements $LeaveRecordCopyWith<$Res> {
  _$LeaveRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? leaveType = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? durationDays = null,
    Object? status = null,
    Object? reason = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      employeeId: null == employeeId
          ? _value.employeeId
          : employeeId // ignore: cast_nullable_to_non_nullable
              as String,
      leaveType: null == leaveType
          ? _value.leaveType
          : leaveType // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String,
      durationDays: null == durationDays
          ? _value.durationDays
          : durationDays // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_LeaveRecordCopyWith<$Res>
    implements $LeaveRecordCopyWith<$Res> {
  factory _$$_LeaveRecordCopyWith(
          _$_LeaveRecord value, $Res Function(_$_LeaveRecord) then) =
      __$$_LeaveRecordCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'employeeId') String employeeId,
      @JsonKey(name: 'leaveType') String leaveType,
      @JsonKey(name: 'startDate') String startDate,
      @JsonKey(name: 'endDate') String endDate,
      @JsonKey(name: 'durationDays') String durationDays,
      String status,
      String? reason,
      String? firstName,
      String? lastName});
}

/// @nodoc
class __$$_LeaveRecordCopyWithImpl<$Res>
    extends _$LeaveRecordCopyWithImpl<$Res, _$_LeaveRecord>
    implements _$$_LeaveRecordCopyWith<$Res> {
  __$$_LeaveRecordCopyWithImpl(
      _$_LeaveRecord _value, $Res Function(_$_LeaveRecord) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? leaveType = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? durationDays = null,
    Object? status = null,
    Object? reason = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
  }) {
    return _then(_$_LeaveRecord(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      employeeId: null == employeeId
          ? _value.employeeId
          : employeeId // ignore: cast_nullable_to_non_nullable
              as String,
      leaveType: null == leaveType
          ? _value.leaveType
          : leaveType // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String,
      durationDays: null == durationDays
          ? _value.durationDays
          : durationDays // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_LeaveRecord implements _LeaveRecord {
  const _$_LeaveRecord(
      {required this.id,
      @JsonKey(name: 'employeeId') required this.employeeId,
      @JsonKey(name: 'leaveType') required this.leaveType,
      @JsonKey(name: 'startDate') required this.startDate,
      @JsonKey(name: 'endDate') required this.endDate,
      @JsonKey(name: 'durationDays') required this.durationDays,
      required this.status,
      this.reason,
      this.firstName,
      this.lastName});

  factory _$_LeaveRecord.fromJson(Map<String, dynamic> json) =>
      _$$_LeaveRecordFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'employeeId')
  final String employeeId;
  @override
  @JsonKey(name: 'leaveType')
  final String leaveType;
  @override
  @JsonKey(name: 'startDate')
  final String startDate;
  @override
  @JsonKey(name: 'endDate')
  final String endDate;
  @override
  @JsonKey(name: 'durationDays')
  final String durationDays;
  @override
  final String status;
  @override
  final String? reason;
  @override
  final String? firstName;
  @override
  final String? lastName;

  @override
  String toString() {
    return 'LeaveRecord(id: $id, employeeId: $employeeId, leaveType: $leaveType, startDate: $startDate, endDate: $endDate, durationDays: $durationDays, status: $status, reason: $reason, firstName: $firstName, lastName: $lastName)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_LeaveRecord &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.leaveType, leaveType) ||
                other.leaveType == leaveType) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.durationDays, durationDays) ||
                other.durationDays == durationDays) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, employeeId, leaveType,
      startDate, endDate, durationDays, status, reason, firstName, lastName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_LeaveRecordCopyWith<_$_LeaveRecord> get copyWith =>
      __$$_LeaveRecordCopyWithImpl<_$_LeaveRecord>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_LeaveRecordToJson(
      this,
    );
  }
}

abstract class _LeaveRecord implements LeaveRecord {
  const factory _LeaveRecord(
      {required final String id,
      @JsonKey(name: 'employeeId') required final String employeeId,
      @JsonKey(name: 'leaveType') required final String leaveType,
      @JsonKey(name: 'startDate') required final String startDate,
      @JsonKey(name: 'endDate') required final String endDate,
      @JsonKey(name: 'durationDays') required final String durationDays,
      required final String status,
      final String? reason,
      final String? firstName,
      final String? lastName}) = _$_LeaveRecord;

  factory _LeaveRecord.fromJson(Map<String, dynamic> json) =
      _$_LeaveRecord.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'employeeId')
  String get employeeId;
  @override
  @JsonKey(name: 'leaveType')
  String get leaveType;
  @override
  @JsonKey(name: 'startDate')
  String get startDate;
  @override
  @JsonKey(name: 'endDate')
  String get endDate;
  @override
  @JsonKey(name: 'durationDays')
  String get durationDays;
  @override
  String get status;
  @override
  String? get reason;
  @override
  String? get firstName;
  @override
  String? get lastName;
  @override
  @JsonKey(ignore: true)
  _$$_LeaveRecordCopyWith<_$_LeaveRecord> get copyWith =>
      throw _privateConstructorUsedError;
}
