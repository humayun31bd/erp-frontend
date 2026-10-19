// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cheque_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ChequeBookModel _$ChequeBookModelFromJson(Map<String, dynamic> json) {
  return _ChequeBookModel.fromJson(json);
}

/// @nodoc
mixin _$ChequeBookModel {
  String get id => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  String get bankAccountId => throw _privateConstructorUsedError;
  String get chequeBookNumber => throw _privateConstructorUsedError;
  int get startLeafNumber => throw _privateConstructorUsedError;
  int get endLeafNumber => throw _privateConstructorUsedError;
  int get totalLeaves => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // ACTIVE, EXHAUSTED, CANCELLED
  String get createdAt => throw _privateConstructorUsedError;
  String? get bankAccountName => throw _privateConstructorUsedError;
  String? get bankAccountCode => throw _privateConstructorUsedError;
  int get availableLeavesCount => throw _privateConstructorUsedError;
  int get usedLeavesCount => throw _privateConstructorUsedError;
  int get issuedLeavesCount => throw _privateConstructorUsedError;
  int get clearedLeavesCount => throw _privateConstructorUsedError;
  int get bouncedLeavesCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChequeBookModelCopyWith<ChequeBookModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChequeBookModelCopyWith<$Res> {
  factory $ChequeBookModelCopyWith(
          ChequeBookModel value, $Res Function(ChequeBookModel) then) =
      _$ChequeBookModelCopyWithImpl<$Res, ChequeBookModel>;
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String bankAccountId,
      String chequeBookNumber,
      int startLeafNumber,
      int endLeafNumber,
      int totalLeaves,
      String status,
      String createdAt,
      String? bankAccountName,
      String? bankAccountCode,
      int availableLeavesCount,
      int usedLeavesCount,
      int issuedLeavesCount,
      int clearedLeavesCount,
      int bouncedLeavesCount});
}

/// @nodoc
class _$ChequeBookModelCopyWithImpl<$Res, $Val extends ChequeBookModel>
    implements $ChequeBookModelCopyWith<$Res> {
  _$ChequeBookModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? bankAccountId = null,
    Object? chequeBookNumber = null,
    Object? startLeafNumber = null,
    Object? endLeafNumber = null,
    Object? totalLeaves = null,
    Object? status = null,
    Object? createdAt = null,
    Object? bankAccountName = freezed,
    Object? bankAccountCode = freezed,
    Object? availableLeavesCount = null,
    Object? usedLeavesCount = null,
    Object? issuedLeavesCount = null,
    Object? clearedLeavesCount = null,
    Object? bouncedLeavesCount = null,
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
      bankAccountId: null == bankAccountId
          ? _value.bankAccountId
          : bankAccountId // ignore: cast_nullable_to_non_nullable
              as String,
      chequeBookNumber: null == chequeBookNumber
          ? _value.chequeBookNumber
          : chequeBookNumber // ignore: cast_nullable_to_non_nullable
              as String,
      startLeafNumber: null == startLeafNumber
          ? _value.startLeafNumber
          : startLeafNumber // ignore: cast_nullable_to_non_nullable
              as int,
      endLeafNumber: null == endLeafNumber
          ? _value.endLeafNumber
          : endLeafNumber // ignore: cast_nullable_to_non_nullable
              as int,
      totalLeaves: null == totalLeaves
          ? _value.totalLeaves
          : totalLeaves // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      bankAccountName: freezed == bankAccountName
          ? _value.bankAccountName
          : bankAccountName // ignore: cast_nullable_to_non_nullable
              as String?,
      bankAccountCode: freezed == bankAccountCode
          ? _value.bankAccountCode
          : bankAccountCode // ignore: cast_nullable_to_non_nullable
              as String?,
      availableLeavesCount: null == availableLeavesCount
          ? _value.availableLeavesCount
          : availableLeavesCount // ignore: cast_nullable_to_non_nullable
              as int,
      usedLeavesCount: null == usedLeavesCount
          ? _value.usedLeavesCount
          : usedLeavesCount // ignore: cast_nullable_to_non_nullable
              as int,
      issuedLeavesCount: null == issuedLeavesCount
          ? _value.issuedLeavesCount
          : issuedLeavesCount // ignore: cast_nullable_to_non_nullable
              as int,
      clearedLeavesCount: null == clearedLeavesCount
          ? _value.clearedLeavesCount
          : clearedLeavesCount // ignore: cast_nullable_to_non_nullable
              as int,
      bouncedLeavesCount: null == bouncedLeavesCount
          ? _value.bouncedLeavesCount
          : bouncedLeavesCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ChequeBookModelCopyWith<$Res>
    implements $ChequeBookModelCopyWith<$Res> {
  factory _$$_ChequeBookModelCopyWith(
          _$_ChequeBookModel value, $Res Function(_$_ChequeBookModel) then) =
      __$$_ChequeBookModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String bankAccountId,
      String chequeBookNumber,
      int startLeafNumber,
      int endLeafNumber,
      int totalLeaves,
      String status,
      String createdAt,
      String? bankAccountName,
      String? bankAccountCode,
      int availableLeavesCount,
      int usedLeavesCount,
      int issuedLeavesCount,
      int clearedLeavesCount,
      int bouncedLeavesCount});
}

/// @nodoc
class __$$_ChequeBookModelCopyWithImpl<$Res>
    extends _$ChequeBookModelCopyWithImpl<$Res, _$_ChequeBookModel>
    implements _$$_ChequeBookModelCopyWith<$Res> {
  __$$_ChequeBookModelCopyWithImpl(
      _$_ChequeBookModel _value, $Res Function(_$_ChequeBookModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? bankAccountId = null,
    Object? chequeBookNumber = null,
    Object? startLeafNumber = null,
    Object? endLeafNumber = null,
    Object? totalLeaves = null,
    Object? status = null,
    Object? createdAt = null,
    Object? bankAccountName = freezed,
    Object? bankAccountCode = freezed,
    Object? availableLeavesCount = null,
    Object? usedLeavesCount = null,
    Object? issuedLeavesCount = null,
    Object? clearedLeavesCount = null,
    Object? bouncedLeavesCount = null,
  }) {
    return _then(_$_ChequeBookModel(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      bankAccountId: null == bankAccountId
          ? _value.bankAccountId
          : bankAccountId // ignore: cast_nullable_to_non_nullable
              as String,
      chequeBookNumber: null == chequeBookNumber
          ? _value.chequeBookNumber
          : chequeBookNumber // ignore: cast_nullable_to_non_nullable
              as String,
      startLeafNumber: null == startLeafNumber
          ? _value.startLeafNumber
          : startLeafNumber // ignore: cast_nullable_to_non_nullable
              as int,
      endLeafNumber: null == endLeafNumber
          ? _value.endLeafNumber
          : endLeafNumber // ignore: cast_nullable_to_non_nullable
              as int,
      totalLeaves: null == totalLeaves
          ? _value.totalLeaves
          : totalLeaves // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      bankAccountName: freezed == bankAccountName
          ? _value.bankAccountName
          : bankAccountName // ignore: cast_nullable_to_non_nullable
              as String?,
      bankAccountCode: freezed == bankAccountCode
          ? _value.bankAccountCode
          : bankAccountCode // ignore: cast_nullable_to_non_nullable
              as String?,
      availableLeavesCount: null == availableLeavesCount
          ? _value.availableLeavesCount
          : availableLeavesCount // ignore: cast_nullable_to_non_nullable
              as int,
      usedLeavesCount: null == usedLeavesCount
          ? _value.usedLeavesCount
          : usedLeavesCount // ignore: cast_nullable_to_non_nullable
              as int,
      issuedLeavesCount: null == issuedLeavesCount
          ? _value.issuedLeavesCount
          : issuedLeavesCount // ignore: cast_nullable_to_non_nullable
              as int,
      clearedLeavesCount: null == clearedLeavesCount
          ? _value.clearedLeavesCount
          : clearedLeavesCount // ignore: cast_nullable_to_non_nullable
              as int,
      bouncedLeavesCount: null == bouncedLeavesCount
          ? _value.bouncedLeavesCount
          : bouncedLeavesCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ChequeBookModel implements _ChequeBookModel {
  const _$_ChequeBookModel(
      {required this.id,
      required this.tenantId,
      required this.bankAccountId,
      required this.chequeBookNumber,
      required this.startLeafNumber,
      required this.endLeafNumber,
      required this.totalLeaves,
      required this.status,
      required this.createdAt,
      this.bankAccountName,
      this.bankAccountCode,
      this.availableLeavesCount = 0,
      this.usedLeavesCount = 0,
      this.issuedLeavesCount = 0,
      this.clearedLeavesCount = 0,
      this.bouncedLeavesCount = 0});

  factory _$_ChequeBookModel.fromJson(Map<String, dynamic> json) =>
      _$$_ChequeBookModelFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  final String bankAccountId;
  @override
  final String chequeBookNumber;
  @override
  final int startLeafNumber;
  @override
  final int endLeafNumber;
  @override
  final int totalLeaves;
  @override
  final String status;
// ACTIVE, EXHAUSTED, CANCELLED
  @override
  final String createdAt;
  @override
  final String? bankAccountName;
  @override
  final String? bankAccountCode;
  @override
  @JsonKey()
  final int availableLeavesCount;
  @override
  @JsonKey()
  final int usedLeavesCount;
  @override
  @JsonKey()
  final int issuedLeavesCount;
  @override
  @JsonKey()
  final int clearedLeavesCount;
  @override
  @JsonKey()
  final int bouncedLeavesCount;

  @override
  String toString() {
    return 'ChequeBookModel(id: $id, tenantId: $tenantId, bankAccountId: $bankAccountId, chequeBookNumber: $chequeBookNumber, startLeafNumber: $startLeafNumber, endLeafNumber: $endLeafNumber, totalLeaves: $totalLeaves, status: $status, createdAt: $createdAt, bankAccountName: $bankAccountName, bankAccountCode: $bankAccountCode, availableLeavesCount: $availableLeavesCount, usedLeavesCount: $usedLeavesCount, issuedLeavesCount: $issuedLeavesCount, clearedLeavesCount: $clearedLeavesCount, bouncedLeavesCount: $bouncedLeavesCount)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ChequeBookModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.bankAccountId, bankAccountId) ||
                other.bankAccountId == bankAccountId) &&
            (identical(other.chequeBookNumber, chequeBookNumber) ||
                other.chequeBookNumber == chequeBookNumber) &&
            (identical(other.startLeafNumber, startLeafNumber) ||
                other.startLeafNumber == startLeafNumber) &&
            (identical(other.endLeafNumber, endLeafNumber) ||
                other.endLeafNumber == endLeafNumber) &&
            (identical(other.totalLeaves, totalLeaves) ||
                other.totalLeaves == totalLeaves) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.bankAccountName, bankAccountName) ||
                other.bankAccountName == bankAccountName) &&
            (identical(other.bankAccountCode, bankAccountCode) ||
                other.bankAccountCode == bankAccountCode) &&
            (identical(other.availableLeavesCount, availableLeavesCount) ||
                other.availableLeavesCount == availableLeavesCount) &&
            (identical(other.usedLeavesCount, usedLeavesCount) ||
                other.usedLeavesCount == usedLeavesCount) &&
            (identical(other.issuedLeavesCount, issuedLeavesCount) ||
                other.issuedLeavesCount == issuedLeavesCount) &&
            (identical(other.clearedLeavesCount, clearedLeavesCount) ||
                other.clearedLeavesCount == clearedLeavesCount) &&
            (identical(other.bouncedLeavesCount, bouncedLeavesCount) ||
                other.bouncedLeavesCount == bouncedLeavesCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tenantId,
      bankAccountId,
      chequeBookNumber,
      startLeafNumber,
      endLeafNumber,
      totalLeaves,
      status,
      createdAt,
      bankAccountName,
      bankAccountCode,
      availableLeavesCount,
      usedLeavesCount,
      issuedLeavesCount,
      clearedLeavesCount,
      bouncedLeavesCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ChequeBookModelCopyWith<_$_ChequeBookModel> get copyWith =>
      __$$_ChequeBookModelCopyWithImpl<_$_ChequeBookModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ChequeBookModelToJson(
      this,
    );
  }
}

abstract class _ChequeBookModel implements ChequeBookModel {
  const factory _ChequeBookModel(
      {required final String id,
      required final String tenantId,
      required final String bankAccountId,
      required final String chequeBookNumber,
      required final int startLeafNumber,
      required final int endLeafNumber,
      required final int totalLeaves,
      required final String status,
      required final String createdAt,
      final String? bankAccountName,
      final String? bankAccountCode,
      final int availableLeavesCount,
      final int usedLeavesCount,
      final int issuedLeavesCount,
      final int clearedLeavesCount,
      final int bouncedLeavesCount}) = _$_ChequeBookModel;

  factory _ChequeBookModel.fromJson(Map<String, dynamic> json) =
      _$_ChequeBookModel.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  String get bankAccountId;
  @override
  String get chequeBookNumber;
  @override
  int get startLeafNumber;
  @override
  int get endLeafNumber;
  @override
  int get totalLeaves;
  @override
  String get status;
  @override // ACTIVE, EXHAUSTED, CANCELLED
  String get createdAt;
  @override
  String? get bankAccountName;
  @override
  String? get bankAccountCode;
  @override
  int get availableLeavesCount;
  @override
  int get usedLeavesCount;
  @override
  int get issuedLeavesCount;
  @override
  int get clearedLeavesCount;
  @override
  int get bouncedLeavesCount;
  @override
  @JsonKey(ignore: true)
  _$$_ChequeBookModelCopyWith<_$_ChequeBookModel> get copyWith =>
      throw _privateConstructorUsedError;
}

ChequeLeafModel _$ChequeLeafModelFromJson(Map<String, dynamic> json) {
  return _ChequeLeafModel.fromJson(json);
}

/// @nodoc
mixin _$ChequeLeafModel {
  String get id => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  String? get chequeBookId => throw _privateConstructorUsedError;
  String get bankAccountId => throw _privateConstructorUsedError;
  String get leafNumber => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // AVAILABLE, ISSUED, RECEIVED, PRESENTED, CLEARED, CANCELLED, BOUNCED
  String? get voucherId => throw _privateConstructorUsedError;
  String? get payeeName => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String? get issuedDate => throw _privateConstructorUsedError;
  String? get clearedDate => throw _privateConstructorUsedError;
  String? get bouncedDate => throw _privateConstructorUsedError;
  String? get remarks => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String? get bankAccountName => throw _privateConstructorUsedError;
  String? get chequeBookNumber => throw _privateConstructorUsedError;
  String? get pdcCategory =>
      throw _privateConstructorUsedError; // RECEIVED_PDC, ISSUED_PDC
  String? get maturityAlert => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChequeLeafModelCopyWith<ChequeLeafModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChequeLeafModelCopyWith<$Res> {
  factory $ChequeLeafModelCopyWith(
          ChequeLeafModel value, $Res Function(ChequeLeafModel) then) =
      _$ChequeLeafModelCopyWithImpl<$Res, ChequeLeafModel>;
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String? chequeBookId,
      String bankAccountId,
      String leafNumber,
      String status,
      String? voucherId,
      String? payeeName,
      double amount,
      String? issuedDate,
      String? clearedDate,
      String? bouncedDate,
      String? remarks,
      String createdAt,
      String? bankAccountName,
      String? chequeBookNumber,
      String? pdcCategory,
      String? maturityAlert});
}

/// @nodoc
class _$ChequeLeafModelCopyWithImpl<$Res, $Val extends ChequeLeafModel>
    implements $ChequeLeafModelCopyWith<$Res> {
  _$ChequeLeafModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? chequeBookId = freezed,
    Object? bankAccountId = null,
    Object? leafNumber = null,
    Object? status = null,
    Object? voucherId = freezed,
    Object? payeeName = freezed,
    Object? amount = null,
    Object? issuedDate = freezed,
    Object? clearedDate = freezed,
    Object? bouncedDate = freezed,
    Object? remarks = freezed,
    Object? createdAt = null,
    Object? bankAccountName = freezed,
    Object? chequeBookNumber = freezed,
    Object? pdcCategory = freezed,
    Object? maturityAlert = freezed,
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
      chequeBookId: freezed == chequeBookId
          ? _value.chequeBookId
          : chequeBookId // ignore: cast_nullable_to_non_nullable
              as String?,
      bankAccountId: null == bankAccountId
          ? _value.bankAccountId
          : bankAccountId // ignore: cast_nullable_to_non_nullable
              as String,
      leafNumber: null == leafNumber
          ? _value.leafNumber
          : leafNumber // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      voucherId: freezed == voucherId
          ? _value.voucherId
          : voucherId // ignore: cast_nullable_to_non_nullable
              as String?,
      payeeName: freezed == payeeName
          ? _value.payeeName
          : payeeName // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      issuedDate: freezed == issuedDate
          ? _value.issuedDate
          : issuedDate // ignore: cast_nullable_to_non_nullable
              as String?,
      clearedDate: freezed == clearedDate
          ? _value.clearedDate
          : clearedDate // ignore: cast_nullable_to_non_nullable
              as String?,
      bouncedDate: freezed == bouncedDate
          ? _value.bouncedDate
          : bouncedDate // ignore: cast_nullable_to_non_nullable
              as String?,
      remarks: freezed == remarks
          ? _value.remarks
          : remarks // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      bankAccountName: freezed == bankAccountName
          ? _value.bankAccountName
          : bankAccountName // ignore: cast_nullable_to_non_nullable
              as String?,
      chequeBookNumber: freezed == chequeBookNumber
          ? _value.chequeBookNumber
          : chequeBookNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      pdcCategory: freezed == pdcCategory
          ? _value.pdcCategory
          : pdcCategory // ignore: cast_nullable_to_non_nullable
              as String?,
      maturityAlert: freezed == maturityAlert
          ? _value.maturityAlert
          : maturityAlert // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ChequeLeafModelCopyWith<$Res>
    implements $ChequeLeafModelCopyWith<$Res> {
  factory _$$_ChequeLeafModelCopyWith(
          _$_ChequeLeafModel value, $Res Function(_$_ChequeLeafModel) then) =
      __$$_ChequeLeafModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String? chequeBookId,
      String bankAccountId,
      String leafNumber,
      String status,
      String? voucherId,
      String? payeeName,
      double amount,
      String? issuedDate,
      String? clearedDate,
      String? bouncedDate,
      String? remarks,
      String createdAt,
      String? bankAccountName,
      String? chequeBookNumber,
      String? pdcCategory,
      String? maturityAlert});
}

/// @nodoc
class __$$_ChequeLeafModelCopyWithImpl<$Res>
    extends _$ChequeLeafModelCopyWithImpl<$Res, _$_ChequeLeafModel>
    implements _$$_ChequeLeafModelCopyWith<$Res> {
  __$$_ChequeLeafModelCopyWithImpl(
      _$_ChequeLeafModel _value, $Res Function(_$_ChequeLeafModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? chequeBookId = freezed,
    Object? bankAccountId = null,
    Object? leafNumber = null,
    Object? status = null,
    Object? voucherId = freezed,
    Object? payeeName = freezed,
    Object? amount = null,
    Object? issuedDate = freezed,
    Object? clearedDate = freezed,
    Object? bouncedDate = freezed,
    Object? remarks = freezed,
    Object? createdAt = null,
    Object? bankAccountName = freezed,
    Object? chequeBookNumber = freezed,
    Object? pdcCategory = freezed,
    Object? maturityAlert = freezed,
  }) {
    return _then(_$_ChequeLeafModel(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      chequeBookId: freezed == chequeBookId
          ? _value.chequeBookId
          : chequeBookId // ignore: cast_nullable_to_non_nullable
              as String?,
      bankAccountId: null == bankAccountId
          ? _value.bankAccountId
          : bankAccountId // ignore: cast_nullable_to_non_nullable
              as String,
      leafNumber: null == leafNumber
          ? _value.leafNumber
          : leafNumber // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      voucherId: freezed == voucherId
          ? _value.voucherId
          : voucherId // ignore: cast_nullable_to_non_nullable
              as String?,
      payeeName: freezed == payeeName
          ? _value.payeeName
          : payeeName // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      issuedDate: freezed == issuedDate
          ? _value.issuedDate
          : issuedDate // ignore: cast_nullable_to_non_nullable
              as String?,
      clearedDate: freezed == clearedDate
          ? _value.clearedDate
          : clearedDate // ignore: cast_nullable_to_non_nullable
              as String?,
      bouncedDate: freezed == bouncedDate
          ? _value.bouncedDate
          : bouncedDate // ignore: cast_nullable_to_non_nullable
              as String?,
      remarks: freezed == remarks
          ? _value.remarks
          : remarks // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      bankAccountName: freezed == bankAccountName
          ? _value.bankAccountName
          : bankAccountName // ignore: cast_nullable_to_non_nullable
              as String?,
      chequeBookNumber: freezed == chequeBookNumber
          ? _value.chequeBookNumber
          : chequeBookNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      pdcCategory: freezed == pdcCategory
          ? _value.pdcCategory
          : pdcCategory // ignore: cast_nullable_to_non_nullable
              as String?,
      maturityAlert: freezed == maturityAlert
          ? _value.maturityAlert
          : maturityAlert // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ChequeLeafModel implements _ChequeLeafModel {
  const _$_ChequeLeafModel(
      {required this.id,
      required this.tenantId,
      this.chequeBookId,
      required this.bankAccountId,
      required this.leafNumber,
      required this.status,
      this.voucherId,
      this.payeeName,
      this.amount = 0.0,
      this.issuedDate,
      this.clearedDate,
      this.bouncedDate,
      this.remarks,
      required this.createdAt,
      this.bankAccountName,
      this.chequeBookNumber,
      this.pdcCategory,
      this.maturityAlert});

  factory _$_ChequeLeafModel.fromJson(Map<String, dynamic> json) =>
      _$$_ChequeLeafModelFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  final String? chequeBookId;
  @override
  final String bankAccountId;
  @override
  final String leafNumber;
  @override
  final String status;
// AVAILABLE, ISSUED, RECEIVED, PRESENTED, CLEARED, CANCELLED, BOUNCED
  @override
  final String? voucherId;
  @override
  final String? payeeName;
  @override
  @JsonKey()
  final double amount;
  @override
  final String? issuedDate;
  @override
  final String? clearedDate;
  @override
  final String? bouncedDate;
  @override
  final String? remarks;
  @override
  final String createdAt;
  @override
  final String? bankAccountName;
  @override
  final String? chequeBookNumber;
  @override
  final String? pdcCategory;
// RECEIVED_PDC, ISSUED_PDC
  @override
  final String? maturityAlert;

  @override
  String toString() {
    return 'ChequeLeafModel(id: $id, tenantId: $tenantId, chequeBookId: $chequeBookId, bankAccountId: $bankAccountId, leafNumber: $leafNumber, status: $status, voucherId: $voucherId, payeeName: $payeeName, amount: $amount, issuedDate: $issuedDate, clearedDate: $clearedDate, bouncedDate: $bouncedDate, remarks: $remarks, createdAt: $createdAt, bankAccountName: $bankAccountName, chequeBookNumber: $chequeBookNumber, pdcCategory: $pdcCategory, maturityAlert: $maturityAlert)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ChequeLeafModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.chequeBookId, chequeBookId) ||
                other.chequeBookId == chequeBookId) &&
            (identical(other.bankAccountId, bankAccountId) ||
                other.bankAccountId == bankAccountId) &&
            (identical(other.leafNumber, leafNumber) ||
                other.leafNumber == leafNumber) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.voucherId, voucherId) ||
                other.voucherId == voucherId) &&
            (identical(other.payeeName, payeeName) ||
                other.payeeName == payeeName) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.issuedDate, issuedDate) ||
                other.issuedDate == issuedDate) &&
            (identical(other.clearedDate, clearedDate) ||
                other.clearedDate == clearedDate) &&
            (identical(other.bouncedDate, bouncedDate) ||
                other.bouncedDate == bouncedDate) &&
            (identical(other.remarks, remarks) || other.remarks == remarks) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.bankAccountName, bankAccountName) ||
                other.bankAccountName == bankAccountName) &&
            (identical(other.chequeBookNumber, chequeBookNumber) ||
                other.chequeBookNumber == chequeBookNumber) &&
            (identical(other.pdcCategory, pdcCategory) ||
                other.pdcCategory == pdcCategory) &&
            (identical(other.maturityAlert, maturityAlert) ||
                other.maturityAlert == maturityAlert));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tenantId,
      chequeBookId,
      bankAccountId,
      leafNumber,
      status,
      voucherId,
      payeeName,
      amount,
      issuedDate,
      clearedDate,
      bouncedDate,
      remarks,
      createdAt,
      bankAccountName,
      chequeBookNumber,
      pdcCategory,
      maturityAlert);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ChequeLeafModelCopyWith<_$_ChequeLeafModel> get copyWith =>
      __$$_ChequeLeafModelCopyWithImpl<_$_ChequeLeafModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ChequeLeafModelToJson(
      this,
    );
  }
}

abstract class _ChequeLeafModel implements ChequeLeafModel {
  const factory _ChequeLeafModel(
      {required final String id,
      required final String tenantId,
      final String? chequeBookId,
      required final String bankAccountId,
      required final String leafNumber,
      required final String status,
      final String? voucherId,
      final String? payeeName,
      final double amount,
      final String? issuedDate,
      final String? clearedDate,
      final String? bouncedDate,
      final String? remarks,
      required final String createdAt,
      final String? bankAccountName,
      final String? chequeBookNumber,
      final String? pdcCategory,
      final String? maturityAlert}) = _$_ChequeLeafModel;

  factory _ChequeLeafModel.fromJson(Map<String, dynamic> json) =
      _$_ChequeLeafModel.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  String? get chequeBookId;
  @override
  String get bankAccountId;
  @override
  String get leafNumber;
  @override
  String get status;
  @override // AVAILABLE, ISSUED, RECEIVED, PRESENTED, CLEARED, CANCELLED, BOUNCED
  String? get voucherId;
  @override
  String? get payeeName;
  @override
  double get amount;
  @override
  String? get issuedDate;
  @override
  String? get clearedDate;
  @override
  String? get bouncedDate;
  @override
  String? get remarks;
  @override
  String get createdAt;
  @override
  String? get bankAccountName;
  @override
  String? get chequeBookNumber;
  @override
  String? get pdcCategory;
  @override // RECEIVED_PDC, ISSUED_PDC
  String? get maturityAlert;
  @override
  @JsonKey(ignore: true)
  _$$_ChequeLeafModelCopyWith<_$_ChequeLeafModel> get copyWith =>
      throw _privateConstructorUsedError;
}

PdcSummaryModel _$PdcSummaryModelFromJson(Map<String, dynamic> json) {
  return _PdcSummaryModel.fromJson(json);
}

/// @nodoc
mixin _$PdcSummaryModel {
  int get totalReceivedCount => throw _privateConstructorUsedError;
  int get totalIssuedCount => throw _privateConstructorUsedError;
  int get overdueCount => throw _privateConstructorUsedError;
  int get dueTodayCount => throw _privateConstructorUsedError;
  int get dueThisWeekCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PdcSummaryModelCopyWith<PdcSummaryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PdcSummaryModelCopyWith<$Res> {
  factory $PdcSummaryModelCopyWith(
          PdcSummaryModel value, $Res Function(PdcSummaryModel) then) =
      _$PdcSummaryModelCopyWithImpl<$Res, PdcSummaryModel>;
  @useResult
  $Res call(
      {int totalReceivedCount,
      int totalIssuedCount,
      int overdueCount,
      int dueTodayCount,
      int dueThisWeekCount});
}

/// @nodoc
class _$PdcSummaryModelCopyWithImpl<$Res, $Val extends PdcSummaryModel>
    implements $PdcSummaryModelCopyWith<$Res> {
  _$PdcSummaryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalReceivedCount = null,
    Object? totalIssuedCount = null,
    Object? overdueCount = null,
    Object? dueTodayCount = null,
    Object? dueThisWeekCount = null,
  }) {
    return _then(_value.copyWith(
      totalReceivedCount: null == totalReceivedCount
          ? _value.totalReceivedCount
          : totalReceivedCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalIssuedCount: null == totalIssuedCount
          ? _value.totalIssuedCount
          : totalIssuedCount // ignore: cast_nullable_to_non_nullable
              as int,
      overdueCount: null == overdueCount
          ? _value.overdueCount
          : overdueCount // ignore: cast_nullable_to_non_nullable
              as int,
      dueTodayCount: null == dueTodayCount
          ? _value.dueTodayCount
          : dueTodayCount // ignore: cast_nullable_to_non_nullable
              as int,
      dueThisWeekCount: null == dueThisWeekCount
          ? _value.dueThisWeekCount
          : dueThisWeekCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_PdcSummaryModelCopyWith<$Res>
    implements $PdcSummaryModelCopyWith<$Res> {
  factory _$$_PdcSummaryModelCopyWith(
          _$_PdcSummaryModel value, $Res Function(_$_PdcSummaryModel) then) =
      __$$_PdcSummaryModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalReceivedCount,
      int totalIssuedCount,
      int overdueCount,
      int dueTodayCount,
      int dueThisWeekCount});
}

/// @nodoc
class __$$_PdcSummaryModelCopyWithImpl<$Res>
    extends _$PdcSummaryModelCopyWithImpl<$Res, _$_PdcSummaryModel>
    implements _$$_PdcSummaryModelCopyWith<$Res> {
  __$$_PdcSummaryModelCopyWithImpl(
      _$_PdcSummaryModel _value, $Res Function(_$_PdcSummaryModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalReceivedCount = null,
    Object? totalIssuedCount = null,
    Object? overdueCount = null,
    Object? dueTodayCount = null,
    Object? dueThisWeekCount = null,
  }) {
    return _then(_$_PdcSummaryModel(
      totalReceivedCount: null == totalReceivedCount
          ? _value.totalReceivedCount
          : totalReceivedCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalIssuedCount: null == totalIssuedCount
          ? _value.totalIssuedCount
          : totalIssuedCount // ignore: cast_nullable_to_non_nullable
              as int,
      overdueCount: null == overdueCount
          ? _value.overdueCount
          : overdueCount // ignore: cast_nullable_to_non_nullable
              as int,
      dueTodayCount: null == dueTodayCount
          ? _value.dueTodayCount
          : dueTodayCount // ignore: cast_nullable_to_non_nullable
              as int,
      dueThisWeekCount: null == dueThisWeekCount
          ? _value.dueThisWeekCount
          : dueThisWeekCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_PdcSummaryModel implements _PdcSummaryModel {
  const _$_PdcSummaryModel(
      {this.totalReceivedCount = 0,
      this.totalIssuedCount = 0,
      this.overdueCount = 0,
      this.dueTodayCount = 0,
      this.dueThisWeekCount = 0});

  factory _$_PdcSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$$_PdcSummaryModelFromJson(json);

  @override
  @JsonKey()
  final int totalReceivedCount;
  @override
  @JsonKey()
  final int totalIssuedCount;
  @override
  @JsonKey()
  final int overdueCount;
  @override
  @JsonKey()
  final int dueTodayCount;
  @override
  @JsonKey()
  final int dueThisWeekCount;

  @override
  String toString() {
    return 'PdcSummaryModel(totalReceivedCount: $totalReceivedCount, totalIssuedCount: $totalIssuedCount, overdueCount: $overdueCount, dueTodayCount: $dueTodayCount, dueThisWeekCount: $dueThisWeekCount)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PdcSummaryModel &&
            (identical(other.totalReceivedCount, totalReceivedCount) ||
                other.totalReceivedCount == totalReceivedCount) &&
            (identical(other.totalIssuedCount, totalIssuedCount) ||
                other.totalIssuedCount == totalIssuedCount) &&
            (identical(other.overdueCount, overdueCount) ||
                other.overdueCount == overdueCount) &&
            (identical(other.dueTodayCount, dueTodayCount) ||
                other.dueTodayCount == dueTodayCount) &&
            (identical(other.dueThisWeekCount, dueThisWeekCount) ||
                other.dueThisWeekCount == dueThisWeekCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, totalReceivedCount,
      totalIssuedCount, overdueCount, dueTodayCount, dueThisWeekCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PdcSummaryModelCopyWith<_$_PdcSummaryModel> get copyWith =>
      __$$_PdcSummaryModelCopyWithImpl<_$_PdcSummaryModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PdcSummaryModelToJson(
      this,
    );
  }
}

abstract class _PdcSummaryModel implements PdcSummaryModel {
  const factory _PdcSummaryModel(
      {final int totalReceivedCount,
      final int totalIssuedCount,
      final int overdueCount,
      final int dueTodayCount,
      final int dueThisWeekCount}) = _$_PdcSummaryModel;

  factory _PdcSummaryModel.fromJson(Map<String, dynamic> json) =
      _$_PdcSummaryModel.fromJson;

  @override
  int get totalReceivedCount;
  @override
  int get totalIssuedCount;
  @override
  int get overdueCount;
  @override
  int get dueTodayCount;
  @override
  int get dueThisWeekCount;
  @override
  @JsonKey(ignore: true)
  _$$_PdcSummaryModelCopyWith<_$_PdcSummaryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

ChequeAuditLogModel _$ChequeAuditLogModelFromJson(Map<String, dynamic> json) {
  return _ChequeAuditLogModel.fromJson(json);
}

/// @nodoc
mixin _$ChequeAuditLogModel {
  String get id => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  String get chequeLeafId => throw _privateConstructorUsedError;
  String get actionType =>
      throw _privateConstructorUsedError; // CREATED, ISSUED, PDC_RECEIVED, DEPOSITED, CLEARED, BOUNCED, CANCELLED
  String? get previousStatus => throw _privateConstructorUsedError;
  String get newStatus => throw _privateConstructorUsedError;
  String get performedBy => throw _privateConstructorUsedError;
  String? get remarks => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChequeAuditLogModelCopyWith<ChequeAuditLogModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChequeAuditLogModelCopyWith<$Res> {
  factory $ChequeAuditLogModelCopyWith(
          ChequeAuditLogModel value, $Res Function(ChequeAuditLogModel) then) =
      _$ChequeAuditLogModelCopyWithImpl<$Res, ChequeAuditLogModel>;
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String chequeLeafId,
      String actionType,
      String? previousStatus,
      String newStatus,
      String performedBy,
      String? remarks,
      String createdAt});
}

/// @nodoc
class _$ChequeAuditLogModelCopyWithImpl<$Res, $Val extends ChequeAuditLogModel>
    implements $ChequeAuditLogModelCopyWith<$Res> {
  _$ChequeAuditLogModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? chequeLeafId = null,
    Object? actionType = null,
    Object? previousStatus = freezed,
    Object? newStatus = null,
    Object? performedBy = null,
    Object? remarks = freezed,
    Object? createdAt = null,
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
      chequeLeafId: null == chequeLeafId
          ? _value.chequeLeafId
          : chequeLeafId // ignore: cast_nullable_to_non_nullable
              as String,
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as String,
      previousStatus: freezed == previousStatus
          ? _value.previousStatus
          : previousStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      newStatus: null == newStatus
          ? _value.newStatus
          : newStatus // ignore: cast_nullable_to_non_nullable
              as String,
      performedBy: null == performedBy
          ? _value.performedBy
          : performedBy // ignore: cast_nullable_to_non_nullable
              as String,
      remarks: freezed == remarks
          ? _value.remarks
          : remarks // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ChequeAuditLogModelCopyWith<$Res>
    implements $ChequeAuditLogModelCopyWith<$Res> {
  factory _$$_ChequeAuditLogModelCopyWith(_$_ChequeAuditLogModel value,
          $Res Function(_$_ChequeAuditLogModel) then) =
      __$$_ChequeAuditLogModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String chequeLeafId,
      String actionType,
      String? previousStatus,
      String newStatus,
      String performedBy,
      String? remarks,
      String createdAt});
}

/// @nodoc
class __$$_ChequeAuditLogModelCopyWithImpl<$Res>
    extends _$ChequeAuditLogModelCopyWithImpl<$Res, _$_ChequeAuditLogModel>
    implements _$$_ChequeAuditLogModelCopyWith<$Res> {
  __$$_ChequeAuditLogModelCopyWithImpl(_$_ChequeAuditLogModel _value,
      $Res Function(_$_ChequeAuditLogModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? chequeLeafId = null,
    Object? actionType = null,
    Object? previousStatus = freezed,
    Object? newStatus = null,
    Object? performedBy = null,
    Object? remarks = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$_ChequeAuditLogModel(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      chequeLeafId: null == chequeLeafId
          ? _value.chequeLeafId
          : chequeLeafId // ignore: cast_nullable_to_non_nullable
              as String,
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as String,
      previousStatus: freezed == previousStatus
          ? _value.previousStatus
          : previousStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      newStatus: null == newStatus
          ? _value.newStatus
          : newStatus // ignore: cast_nullable_to_non_nullable
              as String,
      performedBy: null == performedBy
          ? _value.performedBy
          : performedBy // ignore: cast_nullable_to_non_nullable
              as String,
      remarks: freezed == remarks
          ? _value.remarks
          : remarks // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ChequeAuditLogModel implements _ChequeAuditLogModel {
  const _$_ChequeAuditLogModel(
      {required this.id,
      required this.tenantId,
      required this.chequeLeafId,
      required this.actionType,
      this.previousStatus,
      required this.newStatus,
      required this.performedBy,
      this.remarks,
      required this.createdAt});

  factory _$_ChequeAuditLogModel.fromJson(Map<String, dynamic> json) =>
      _$$_ChequeAuditLogModelFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  final String chequeLeafId;
  @override
  final String actionType;
// CREATED, ISSUED, PDC_RECEIVED, DEPOSITED, CLEARED, BOUNCED, CANCELLED
  @override
  final String? previousStatus;
  @override
  final String newStatus;
  @override
  final String performedBy;
  @override
  final String? remarks;
  @override
  final String createdAt;

  @override
  String toString() {
    return 'ChequeAuditLogModel(id: $id, tenantId: $tenantId, chequeLeafId: $chequeLeafId, actionType: $actionType, previousStatus: $previousStatus, newStatus: $newStatus, performedBy: $performedBy, remarks: $remarks, createdAt: $createdAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ChequeAuditLogModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.chequeLeafId, chequeLeafId) ||
                other.chequeLeafId == chequeLeafId) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.previousStatus, previousStatus) ||
                other.previousStatus == previousStatus) &&
            (identical(other.newStatus, newStatus) ||
                other.newStatus == newStatus) &&
            (identical(other.performedBy, performedBy) ||
                other.performedBy == performedBy) &&
            (identical(other.remarks, remarks) || other.remarks == remarks) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, tenantId, chequeLeafId,
      actionType, previousStatus, newStatus, performedBy, remarks, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ChequeAuditLogModelCopyWith<_$_ChequeAuditLogModel> get copyWith =>
      __$$_ChequeAuditLogModelCopyWithImpl<_$_ChequeAuditLogModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ChequeAuditLogModelToJson(
      this,
    );
  }
}

abstract class _ChequeAuditLogModel implements ChequeAuditLogModel {
  const factory _ChequeAuditLogModel(
      {required final String id,
      required final String tenantId,
      required final String chequeLeafId,
      required final String actionType,
      final String? previousStatus,
      required final String newStatus,
      required final String performedBy,
      final String? remarks,
      required final String createdAt}) = _$_ChequeAuditLogModel;

  factory _ChequeAuditLogModel.fromJson(Map<String, dynamic> json) =
      _$_ChequeAuditLogModel.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  String get chequeLeafId;
  @override
  String get actionType;
  @override // CREATED, ISSUED, PDC_RECEIVED, DEPOSITED, CLEARED, BOUNCED, CANCELLED
  String? get previousStatus;
  @override
  String get newStatus;
  @override
  String get performedBy;
  @override
  String? get remarks;
  @override
  String get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$_ChequeAuditLogModelCopyWith<_$_ChequeAuditLogModel> get copyWith =>
      throw _privateConstructorUsedError;
}
