// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cash_book_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CashBookModel _$CashBookModelFromJson(Map<String, dynamic> json) {
  return _CashBookModel.fromJson(json);
}

/// @nodoc
mixin _$CashBookModel {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _amountToString)
  String get amount => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get referenceId => throw _privateConstructorUsedError;
  DateTime get entryDate => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CashBookModelCopyWith<CashBookModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CashBookModelCopyWith<$Res> {
  factory $CashBookModelCopyWith(
          CashBookModel value, $Res Function(CashBookModel) then) =
      _$CashBookModelCopyWithImpl<$Res, CashBookModel>;
  @useResult
  $Res call(
      {String id,
      String type,
      @JsonKey(fromJson: _amountToString) String amount,
      String? category,
      String? description,
      String? referenceId,
      DateTime entryDate,
      DateTime createdAt});
}

/// @nodoc
class _$CashBookModelCopyWithImpl<$Res, $Val extends CashBookModel>
    implements $CashBookModelCopyWith<$Res> {
  _$CashBookModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? amount = null,
    Object? category = freezed,
    Object? description = freezed,
    Object? referenceId = freezed,
    Object? entryDate = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceId: freezed == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String?,
      entryDate: null == entryDate
          ? _value.entryDate
          : entryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CashBookModelCopyWith<$Res>
    implements $CashBookModelCopyWith<$Res> {
  factory _$$_CashBookModelCopyWith(
          _$_CashBookModel value, $Res Function(_$_CashBookModel) then) =
      __$$_CashBookModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      @JsonKey(fromJson: _amountToString) String amount,
      String? category,
      String? description,
      String? referenceId,
      DateTime entryDate,
      DateTime createdAt});
}

/// @nodoc
class __$$_CashBookModelCopyWithImpl<$Res>
    extends _$CashBookModelCopyWithImpl<$Res, _$_CashBookModel>
    implements _$$_CashBookModelCopyWith<$Res> {
  __$$_CashBookModelCopyWithImpl(
      _$_CashBookModel _value, $Res Function(_$_CashBookModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? amount = null,
    Object? category = freezed,
    Object? description = freezed,
    Object? referenceId = freezed,
    Object? entryDate = null,
    Object? createdAt = null,
  }) {
    return _then(_$_CashBookModel(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceId: freezed == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String?,
      entryDate: null == entryDate
          ? _value.entryDate
          : entryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CashBookModel implements _CashBookModel {
  const _$_CashBookModel(
      {required this.id,
      required this.type,
      @JsonKey(fromJson: _amountToString) required this.amount,
      this.category,
      this.description,
      this.referenceId,
      required this.entryDate,
      required this.createdAt});

  factory _$_CashBookModel.fromJson(Map<String, dynamic> json) =>
      _$$_CashBookModelFromJson(json);

  @override
  final String id;
  @override
  final String type;
  @override
  @JsonKey(fromJson: _amountToString)
  final String amount;
  @override
  final String? category;
  @override
  final String? description;
  @override
  final String? referenceId;
  @override
  final DateTime entryDate;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'CashBookModel(id: $id, type: $type, amount: $amount, category: $category, description: $description, referenceId: $referenceId, entryDate: $entryDate, createdAt: $createdAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CashBookModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.referenceId, referenceId) ||
                other.referenceId == referenceId) &&
            (identical(other.entryDate, entryDate) ||
                other.entryDate == entryDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, amount, category,
      description, referenceId, entryDate, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CashBookModelCopyWith<_$_CashBookModel> get copyWith =>
      __$$_CashBookModelCopyWithImpl<_$_CashBookModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CashBookModelToJson(
      this,
    );
  }
}

abstract class _CashBookModel implements CashBookModel {
  const factory _CashBookModel(
      {required final String id,
      required final String type,
      @JsonKey(fromJson: _amountToString) required final String amount,
      final String? category,
      final String? description,
      final String? referenceId,
      required final DateTime entryDate,
      required final DateTime createdAt}) = _$_CashBookModel;

  factory _CashBookModel.fromJson(Map<String, dynamic> json) =
      _$_CashBookModel.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  @JsonKey(fromJson: _amountToString)
  String get amount;
  @override
  String? get category;
  @override
  String? get description;
  @override
  String? get referenceId;
  @override
  DateTime get entryDate;
  @override
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$_CashBookModelCopyWith<_$_CashBookModel> get copyWith =>
      throw _privateConstructorUsedError;
}

CashBookSummary _$CashBookSummaryFromJson(Map<String, dynamic> json) {
  return _CashBookSummary.fromJson(json);
}

/// @nodoc
mixin _$CashBookSummary {
  double get totalIn => throw _privateConstructorUsedError;
  double get totalOut => throw _privateConstructorUsedError;
  double get closingBalance => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CashBookSummaryCopyWith<CashBookSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CashBookSummaryCopyWith<$Res> {
  factory $CashBookSummaryCopyWith(
          CashBookSummary value, $Res Function(CashBookSummary) then) =
      _$CashBookSummaryCopyWithImpl<$Res, CashBookSummary>;
  @useResult
  $Res call({double totalIn, double totalOut, double closingBalance});
}

/// @nodoc
class _$CashBookSummaryCopyWithImpl<$Res, $Val extends CashBookSummary>
    implements $CashBookSummaryCopyWith<$Res> {
  _$CashBookSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalIn = null,
    Object? totalOut = null,
    Object? closingBalance = null,
  }) {
    return _then(_value.copyWith(
      totalIn: null == totalIn
          ? _value.totalIn
          : totalIn // ignore: cast_nullable_to_non_nullable
              as double,
      totalOut: null == totalOut
          ? _value.totalOut
          : totalOut // ignore: cast_nullable_to_non_nullable
              as double,
      closingBalance: null == closingBalance
          ? _value.closingBalance
          : closingBalance // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CashBookSummaryCopyWith<$Res>
    implements $CashBookSummaryCopyWith<$Res> {
  factory _$$_CashBookSummaryCopyWith(
          _$_CashBookSummary value, $Res Function(_$_CashBookSummary) then) =
      __$$_CashBookSummaryCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double totalIn, double totalOut, double closingBalance});
}

/// @nodoc
class __$$_CashBookSummaryCopyWithImpl<$Res>
    extends _$CashBookSummaryCopyWithImpl<$Res, _$_CashBookSummary>
    implements _$$_CashBookSummaryCopyWith<$Res> {
  __$$_CashBookSummaryCopyWithImpl(
      _$_CashBookSummary _value, $Res Function(_$_CashBookSummary) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalIn = null,
    Object? totalOut = null,
    Object? closingBalance = null,
  }) {
    return _then(_$_CashBookSummary(
      totalIn: null == totalIn
          ? _value.totalIn
          : totalIn // ignore: cast_nullable_to_non_nullable
              as double,
      totalOut: null == totalOut
          ? _value.totalOut
          : totalOut // ignore: cast_nullable_to_non_nullable
              as double,
      closingBalance: null == closingBalance
          ? _value.closingBalance
          : closingBalance // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CashBookSummary implements _CashBookSummary {
  const _$_CashBookSummary(
      {required this.totalIn,
      required this.totalOut,
      required this.closingBalance});

  factory _$_CashBookSummary.fromJson(Map<String, dynamic> json) =>
      _$$_CashBookSummaryFromJson(json);

  @override
  final double totalIn;
  @override
  final double totalOut;
  @override
  final double closingBalance;

  @override
  String toString() {
    return 'CashBookSummary(totalIn: $totalIn, totalOut: $totalOut, closingBalance: $closingBalance)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CashBookSummary &&
            (identical(other.totalIn, totalIn) || other.totalIn == totalIn) &&
            (identical(other.totalOut, totalOut) ||
                other.totalOut == totalOut) &&
            (identical(other.closingBalance, closingBalance) ||
                other.closingBalance == closingBalance));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, totalIn, totalOut, closingBalance);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CashBookSummaryCopyWith<_$_CashBookSummary> get copyWith =>
      __$$_CashBookSummaryCopyWithImpl<_$_CashBookSummary>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CashBookSummaryToJson(
      this,
    );
  }
}

abstract class _CashBookSummary implements CashBookSummary {
  const factory _CashBookSummary(
      {required final double totalIn,
      required final double totalOut,
      required final double closingBalance}) = _$_CashBookSummary;

  factory _CashBookSummary.fromJson(Map<String, dynamic> json) =
      _$_CashBookSummary.fromJson;

  @override
  double get totalIn;
  @override
  double get totalOut;
  @override
  double get closingBalance;
  @override
  @JsonKey(ignore: true)
  _$$_CashBookSummaryCopyWith<_$_CashBookSummary> get copyWith =>
      throw _privateConstructorUsedError;
}
