// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'overtime_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

OvertimeRecord _$OvertimeRecordFromJson(Map<String, dynamic> json) {
  return _OvertimeRecord.fromJson(json);
}

/// @nodoc
mixin _$OvertimeRecord {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'employeeId')
  String get employeeId => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  String get hours => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  String? get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OvertimeRecordCopyWith<OvertimeRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OvertimeRecordCopyWith<$Res> {
  factory $OvertimeRecordCopyWith(
          OvertimeRecord value, $Res Function(OvertimeRecord) then) =
      _$OvertimeRecordCopyWithImpl<$Res, OvertimeRecord>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'employeeId') String employeeId,
      String date,
      String hours,
      String status,
      String? reason,
      String? firstName,
      String? lastName});
}

/// @nodoc
class _$OvertimeRecordCopyWithImpl<$Res, $Val extends OvertimeRecord>
    implements $OvertimeRecordCopyWith<$Res> {
  _$OvertimeRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? date = null,
    Object? hours = null,
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
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      hours: null == hours
          ? _value.hours
          : hours // ignore: cast_nullable_to_non_nullable
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
abstract class _$$_OvertimeRecordCopyWith<$Res>
    implements $OvertimeRecordCopyWith<$Res> {
  factory _$$_OvertimeRecordCopyWith(
          _$_OvertimeRecord value, $Res Function(_$_OvertimeRecord) then) =
      __$$_OvertimeRecordCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'employeeId') String employeeId,
      String date,
      String hours,
      String status,
      String? reason,
      String? firstName,
      String? lastName});
}

/// @nodoc
class __$$_OvertimeRecordCopyWithImpl<$Res>
    extends _$OvertimeRecordCopyWithImpl<$Res, _$_OvertimeRecord>
    implements _$$_OvertimeRecordCopyWith<$Res> {
  __$$_OvertimeRecordCopyWithImpl(
      _$_OvertimeRecord _value, $Res Function(_$_OvertimeRecord) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? date = null,
    Object? hours = null,
    Object? status = null,
    Object? reason = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
  }) {
    return _then(_$_OvertimeRecord(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      employeeId: null == employeeId
          ? _value.employeeId
          : employeeId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      hours: null == hours
          ? _value.hours
          : hours // ignore: cast_nullable_to_non_nullable
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
class _$_OvertimeRecord implements _OvertimeRecord {
  const _$_OvertimeRecord(
      {required this.id,
      @JsonKey(name: 'employeeId') required this.employeeId,
      required this.date,
      required this.hours,
      required this.status,
      this.reason,
      this.firstName,
      this.lastName});

  factory _$_OvertimeRecord.fromJson(Map<String, dynamic> json) =>
      _$$_OvertimeRecordFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'employeeId')
  final String employeeId;
  @override
  final String date;
  @override
  final String hours;
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
    return 'OvertimeRecord(id: $id, employeeId: $employeeId, date: $date, hours: $hours, status: $status, reason: $reason, firstName: $firstName, lastName: $lastName)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_OvertimeRecord &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.hours, hours) || other.hours == hours) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, employeeId, date, hours,
      status, reason, firstName, lastName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_OvertimeRecordCopyWith<_$_OvertimeRecord> get copyWith =>
      __$$_OvertimeRecordCopyWithImpl<_$_OvertimeRecord>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_OvertimeRecordToJson(
      this,
    );
  }
}

abstract class _OvertimeRecord implements OvertimeRecord {
  const factory _OvertimeRecord(
      {required final String id,
      @JsonKey(name: 'employeeId') required final String employeeId,
      required final String date,
      required final String hours,
      required final String status,
      final String? reason,
      final String? firstName,
      final String? lastName}) = _$_OvertimeRecord;

  factory _OvertimeRecord.fromJson(Map<String, dynamic> json) =
      _$_OvertimeRecord.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'employeeId')
  String get employeeId;
  @override
  String get date;
  @override
  String get hours;
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
  _$$_OvertimeRecordCopyWith<_$_OvertimeRecord> get copyWith =>
      throw _privateConstructorUsedError;
}
