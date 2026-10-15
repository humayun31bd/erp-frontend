// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'counter_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CounterSessionModel _$CounterSessionModelFromJson(Map<String, dynamic> json) {
  return _CounterSessionModel.fromJson(json);
}

/// @nodoc
mixin _$CounterSessionModel {
  String get id => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  String get counterId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get openedAt => throw _privateConstructorUsedError;
  DateTime? get closedAt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _stringFromJson)
  String get openingBalance => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _nullableStringFromJson)
  String? get closingBalance => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _stringFromJson)
  String get cashSales => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _stringFromJson)
  String get transferAmount => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CounterSessionModelCopyWith<CounterSessionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CounterSessionModelCopyWith<$Res> {
  factory $CounterSessionModelCopyWith(
          CounterSessionModel value, $Res Function(CounterSessionModel) then) =
      _$CounterSessionModelCopyWithImpl<$Res, CounterSessionModel>;
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String counterId,
      String userId,
      DateTime openedAt,
      DateTime? closedAt,
      @JsonKey(fromJson: _stringFromJson) String openingBalance,
      @JsonKey(fromJson: _nullableStringFromJson) String? closingBalance,
      @JsonKey(fromJson: _stringFromJson) String cashSales,
      @JsonKey(fromJson: _stringFromJson) String transferAmount,
      String status,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$CounterSessionModelCopyWithImpl<$Res, $Val extends CounterSessionModel>
    implements $CounterSessionModelCopyWith<$Res> {
  _$CounterSessionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? counterId = null,
    Object? userId = null,
    Object? openedAt = null,
    Object? closedAt = freezed,
    Object? openingBalance = null,
    Object? closingBalance = freezed,
    Object? cashSales = null,
    Object? transferAmount = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      counterId: null == counterId
          ? _value.counterId
          : counterId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      openedAt: null == openedAt
          ? _value.openedAt
          : openedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      closedAt: freezed == closedAt
          ? _value.closedAt
          : closedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      openingBalance: null == openingBalance
          ? _value.openingBalance
          : openingBalance // ignore: cast_nullable_to_non_nullable
              as String,
      closingBalance: freezed == closingBalance
          ? _value.closingBalance
          : closingBalance // ignore: cast_nullable_to_non_nullable
              as String?,
      cashSales: null == cashSales
          ? _value.cashSales
          : cashSales // ignore: cast_nullable_to_non_nullable
              as String,
      transferAmount: null == transferAmount
          ? _value.transferAmount
          : transferAmount // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CounterSessionModelCopyWith<$Res>
    implements $CounterSessionModelCopyWith<$Res> {
  factory _$$_CounterSessionModelCopyWith(_$_CounterSessionModel value,
          $Res Function(_$_CounterSessionModel) then) =
      __$$_CounterSessionModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String counterId,
      String userId,
      DateTime openedAt,
      DateTime? closedAt,
      @JsonKey(fromJson: _stringFromJson) String openingBalance,
      @JsonKey(fromJson: _nullableStringFromJson) String? closingBalance,
      @JsonKey(fromJson: _stringFromJson) String cashSales,
      @JsonKey(fromJson: _stringFromJson) String transferAmount,
      String status,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$_CounterSessionModelCopyWithImpl<$Res>
    extends _$CounterSessionModelCopyWithImpl<$Res, _$_CounterSessionModel>
    implements _$$_CounterSessionModelCopyWith<$Res> {
  __$$_CounterSessionModelCopyWithImpl(_$_CounterSessionModel _value,
      $Res Function(_$_CounterSessionModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? counterId = null,
    Object? userId = null,
    Object? openedAt = null,
    Object? closedAt = freezed,
    Object? openingBalance = null,
    Object? closingBalance = freezed,
    Object? cashSales = null,
    Object? transferAmount = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$_CounterSessionModel(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      counterId: null == counterId
          ? _value.counterId
          : counterId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      openedAt: null == openedAt
          ? _value.openedAt
          : openedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      closedAt: freezed == closedAt
          ? _value.closedAt
          : closedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      openingBalance: null == openingBalance
          ? _value.openingBalance
          : openingBalance // ignore: cast_nullable_to_non_nullable
              as String,
      closingBalance: freezed == closingBalance
          ? _value.closingBalance
          : closingBalance // ignore: cast_nullable_to_non_nullable
              as String?,
      cashSales: null == cashSales
          ? _value.cashSales
          : cashSales // ignore: cast_nullable_to_non_nullable
              as String,
      transferAmount: null == transferAmount
          ? _value.transferAmount
          : transferAmount // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CounterSessionModel implements _CounterSessionModel {
  const _$_CounterSessionModel(
      {required this.id,
      required this.tenantId,
      required this.counterId,
      required this.userId,
      required this.openedAt,
      this.closedAt,
      @JsonKey(fromJson: _stringFromJson) required this.openingBalance,
      @JsonKey(fromJson: _nullableStringFromJson) this.closingBalance,
      @JsonKey(fromJson: _stringFromJson) required this.cashSales,
      @JsonKey(fromJson: _stringFromJson) required this.transferAmount,
      required this.status,
      required this.createdAt,
      required this.updatedAt});

  factory _$_CounterSessionModel.fromJson(Map<String, dynamic> json) =>
      _$$_CounterSessionModelFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  final String counterId;
  @override
  final String userId;
  @override
  final DateTime openedAt;
  @override
  final DateTime? closedAt;
  @override
  @JsonKey(fromJson: _stringFromJson)
  final String openingBalance;
  @override
  @JsonKey(fromJson: _nullableStringFromJson)
  final String? closingBalance;
  @override
  @JsonKey(fromJson: _stringFromJson)
  final String cashSales;
  @override
  @JsonKey(fromJson: _stringFromJson)
  final String transferAmount;
  @override
  final String status;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'CounterSessionModel(id: $id, tenantId: $tenantId, counterId: $counterId, userId: $userId, openedAt: $openedAt, closedAt: $closedAt, openingBalance: $openingBalance, closingBalance: $closingBalance, cashSales: $cashSales, transferAmount: $transferAmount, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CounterSessionModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.counterId, counterId) ||
                other.counterId == counterId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.openedAt, openedAt) ||
                other.openedAt == openedAt) &&
            (identical(other.closedAt, closedAt) ||
                other.closedAt == closedAt) &&
            (identical(other.openingBalance, openingBalance) ||
                other.openingBalance == openingBalance) &&
            (identical(other.closingBalance, closingBalance) ||
                other.closingBalance == closingBalance) &&
            (identical(other.cashSales, cashSales) ||
                other.cashSales == cashSales) &&
            (identical(other.transferAmount, transferAmount) ||
                other.transferAmount == transferAmount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tenantId,
      counterId,
      userId,
      openedAt,
      closedAt,
      openingBalance,
      closingBalance,
      cashSales,
      transferAmount,
      status,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CounterSessionModelCopyWith<_$_CounterSessionModel> get copyWith =>
      __$$_CounterSessionModelCopyWithImpl<_$_CounterSessionModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CounterSessionModelToJson(
      this,
    );
  }
}

abstract class _CounterSessionModel implements CounterSessionModel {
  const factory _CounterSessionModel(
      {required final String id,
      required final String tenantId,
      required final String counterId,
      required final String userId,
      required final DateTime openedAt,
      final DateTime? closedAt,
      @JsonKey(fromJson: _stringFromJson) required final String openingBalance,
      @JsonKey(fromJson: _nullableStringFromJson) final String? closingBalance,
      @JsonKey(fromJson: _stringFromJson) required final String cashSales,
      @JsonKey(fromJson: _stringFromJson) required final String transferAmount,
      required final String status,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$_CounterSessionModel;

  factory _CounterSessionModel.fromJson(Map<String, dynamic> json) =
      _$_CounterSessionModel.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  String get counterId;
  @override
  String get userId;
  @override
  DateTime get openedAt;
  @override
  DateTime? get closedAt;
  @override
  @JsonKey(fromJson: _stringFromJson)
  String get openingBalance;
  @override
  @JsonKey(fromJson: _nullableStringFromJson)
  String? get closingBalance;
  @override
  @JsonKey(fromJson: _stringFromJson)
  String get cashSales;
  @override
  @JsonKey(fromJson: _stringFromJson)
  String get transferAmount;
  @override
  String get status;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$_CounterSessionModelCopyWith<_$_CounterSessionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

CounterSessionResponse _$CounterSessionResponseFromJson(
    Map<String, dynamic> json) {
  return _CounterSessionResponse.fromJson(json);
}

/// @nodoc
mixin _$CounterSessionResponse {
  bool get success => throw _privateConstructorUsedError;
  CounterSessionModel? get session => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CounterSessionResponseCopyWith<CounterSessionResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CounterSessionResponseCopyWith<$Res> {
  factory $CounterSessionResponseCopyWith(CounterSessionResponse value,
          $Res Function(CounterSessionResponse) then) =
      _$CounterSessionResponseCopyWithImpl<$Res, CounterSessionResponse>;
  @useResult
  $Res call({bool success, CounterSessionModel? session});

  $CounterSessionModelCopyWith<$Res>? get session;
}

/// @nodoc
class _$CounterSessionResponseCopyWithImpl<$Res,
        $Val extends CounterSessionResponse>
    implements $CounterSessionResponseCopyWith<$Res> {
  _$CounterSessionResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? session = freezed,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      session: freezed == session
          ? _value.session
          : session // ignore: cast_nullable_to_non_nullable
              as CounterSessionModel?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CounterSessionModelCopyWith<$Res>? get session {
    if (_value.session == null) {
      return null;
    }

    return $CounterSessionModelCopyWith<$Res>(_value.session!, (value) {
      return _then(_value.copyWith(session: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_CounterSessionResponseCopyWith<$Res>
    implements $CounterSessionResponseCopyWith<$Res> {
  factory _$$_CounterSessionResponseCopyWith(_$_CounterSessionResponse value,
          $Res Function(_$_CounterSessionResponse) then) =
      __$$_CounterSessionResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, CounterSessionModel? session});

  @override
  $CounterSessionModelCopyWith<$Res>? get session;
}

/// @nodoc
class __$$_CounterSessionResponseCopyWithImpl<$Res>
    extends _$CounterSessionResponseCopyWithImpl<$Res,
        _$_CounterSessionResponse>
    implements _$$_CounterSessionResponseCopyWith<$Res> {
  __$$_CounterSessionResponseCopyWithImpl(_$_CounterSessionResponse _value,
      $Res Function(_$_CounterSessionResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? session = freezed,
  }) {
    return _then(_$_CounterSessionResponse(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      session: freezed == session
          ? _value.session
          : session // ignore: cast_nullable_to_non_nullable
              as CounterSessionModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CounterSessionResponse implements _CounterSessionResponse {
  const _$_CounterSessionResponse({required this.success, this.session});

  factory _$_CounterSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$$_CounterSessionResponseFromJson(json);

  @override
  final bool success;
  @override
  final CounterSessionModel? session;

  @override
  String toString() {
    return 'CounterSessionResponse(success: $success, session: $session)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CounterSessionResponse &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.session, session) || other.session == session));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, session);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CounterSessionResponseCopyWith<_$_CounterSessionResponse> get copyWith =>
      __$$_CounterSessionResponseCopyWithImpl<_$_CounterSessionResponse>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CounterSessionResponseToJson(
      this,
    );
  }
}

abstract class _CounterSessionResponse implements CounterSessionResponse {
  const factory _CounterSessionResponse(
      {required final bool success,
      final CounterSessionModel? session}) = _$_CounterSessionResponse;

  factory _CounterSessionResponse.fromJson(Map<String, dynamic> json) =
      _$_CounterSessionResponse.fromJson;

  @override
  bool get success;
  @override
  CounterSessionModel? get session;
  @override
  @JsonKey(ignore: true)
  _$$_CounterSessionResponseCopyWith<_$_CounterSessionResponse> get copyWith =>
      throw _privateConstructorUsedError;
}
