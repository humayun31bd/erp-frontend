// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'loan_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

LoanRecord _$LoanRecordFromJson(Map<String, dynamic> json) {
  return _LoanRecord.fromJson(json);
}

/// @nodoc
mixin _$LoanRecord {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'employeeId')
  String get employeeId => throw _privateConstructorUsedError;
  String get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'monthlyInstallment')
  String get monthlyInstallment => throw _privateConstructorUsedError;
  @JsonKey(name: 'remainingAmount')
  String get remainingAmount => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  String? get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LoanRecordCopyWith<LoanRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoanRecordCopyWith<$Res> {
  factory $LoanRecordCopyWith(
          LoanRecord value, $Res Function(LoanRecord) then) =
      _$LoanRecordCopyWithImpl<$Res, LoanRecord>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'employeeId') String employeeId,
      String amount,
      @JsonKey(name: 'monthlyInstallment') String monthlyInstallment,
      @JsonKey(name: 'remainingAmount') String remainingAmount,
      String status,
      String? reason,
      String? firstName,
      String? lastName});
}

/// @nodoc
class _$LoanRecordCopyWithImpl<$Res, $Val extends LoanRecord>
    implements $LoanRecordCopyWith<$Res> {
  _$LoanRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? amount = null,
    Object? monthlyInstallment = null,
    Object? remainingAmount = null,
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
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
      monthlyInstallment: null == monthlyInstallment
          ? _value.monthlyInstallment
          : monthlyInstallment // ignore: cast_nullable_to_non_nullable
              as String,
      remainingAmount: null == remainingAmount
          ? _value.remainingAmount
          : remainingAmount // ignore: cast_nullable_to_non_nullable
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
abstract class _$$_LoanRecordCopyWith<$Res>
    implements $LoanRecordCopyWith<$Res> {
  factory _$$_LoanRecordCopyWith(
          _$_LoanRecord value, $Res Function(_$_LoanRecord) then) =
      __$$_LoanRecordCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'employeeId') String employeeId,
      String amount,
      @JsonKey(name: 'monthlyInstallment') String monthlyInstallment,
      @JsonKey(name: 'remainingAmount') String remainingAmount,
      String status,
      String? reason,
      String? firstName,
      String? lastName});
}

/// @nodoc
class __$$_LoanRecordCopyWithImpl<$Res>
    extends _$LoanRecordCopyWithImpl<$Res, _$_LoanRecord>
    implements _$$_LoanRecordCopyWith<$Res> {
  __$$_LoanRecordCopyWithImpl(
      _$_LoanRecord _value, $Res Function(_$_LoanRecord) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? amount = null,
    Object? monthlyInstallment = null,
    Object? remainingAmount = null,
    Object? status = null,
    Object? reason = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
  }) {
    return _then(_$_LoanRecord(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      employeeId: null == employeeId
          ? _value.employeeId
          : employeeId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
      monthlyInstallment: null == monthlyInstallment
          ? _value.monthlyInstallment
          : monthlyInstallment // ignore: cast_nullable_to_non_nullable
              as String,
      remainingAmount: null == remainingAmount
          ? _value.remainingAmount
          : remainingAmount // ignore: cast_nullable_to_non_nullable
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
class _$_LoanRecord implements _LoanRecord {
  const _$_LoanRecord(
      {required this.id,
      @JsonKey(name: 'employeeId') required this.employeeId,
      required this.amount,
      @JsonKey(name: 'monthlyInstallment') required this.monthlyInstallment,
      @JsonKey(name: 'remainingAmount') required this.remainingAmount,
      required this.status,
      this.reason,
      this.firstName,
      this.lastName});

  factory _$_LoanRecord.fromJson(Map<String, dynamic> json) =>
      _$$_LoanRecordFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'employeeId')
  final String employeeId;
  @override
  final String amount;
  @override
  @JsonKey(name: 'monthlyInstallment')
  final String monthlyInstallment;
  @override
  @JsonKey(name: 'remainingAmount')
  final String remainingAmount;
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
    return 'LoanRecord(id: $id, employeeId: $employeeId, amount: $amount, monthlyInstallment: $monthlyInstallment, remainingAmount: $remainingAmount, status: $status, reason: $reason, firstName: $firstName, lastName: $lastName)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_LoanRecord &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.monthlyInstallment, monthlyInstallment) ||
                other.monthlyInstallment == monthlyInstallment) &&
            (identical(other.remainingAmount, remainingAmount) ||
                other.remainingAmount == remainingAmount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, employeeId, amount,
      monthlyInstallment, remainingAmount, status, reason, firstName, lastName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_LoanRecordCopyWith<_$_LoanRecord> get copyWith =>
      __$$_LoanRecordCopyWithImpl<_$_LoanRecord>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_LoanRecordToJson(
      this,
    );
  }
}

abstract class _LoanRecord implements LoanRecord {
  const factory _LoanRecord(
      {required final String id,
      @JsonKey(name: 'employeeId') required final String employeeId,
      required final String amount,
      @JsonKey(name: 'monthlyInstallment')
      required final String monthlyInstallment,
      @JsonKey(name: 'remainingAmount') required final String remainingAmount,
      required final String status,
      final String? reason,
      final String? firstName,
      final String? lastName}) = _$_LoanRecord;

  factory _LoanRecord.fromJson(Map<String, dynamic> json) =
      _$_LoanRecord.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'employeeId')
  String get employeeId;
  @override
  String get amount;
  @override
  @JsonKey(name: 'monthlyInstallment')
  String get monthlyInstallment;
  @override
  @JsonKey(name: 'remainingAmount')
  String get remainingAmount;
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
  _$$_LoanRecordCopyWith<_$_LoanRecord> get copyWith =>
      throw _privateConstructorUsedError;
}
