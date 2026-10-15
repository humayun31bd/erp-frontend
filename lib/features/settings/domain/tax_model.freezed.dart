// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tax_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

TaxModel _$TaxModelFromJson(Map<String, dynamic> json) {
  return _TaxModel.fromJson(json);
}

/// @nodoc
mixin _$TaxModel {
  String get id => throw _privateConstructorUsedError;
  String get categoryName => throw _privateConstructorUsedError;
  double get taxRate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TaxModelCopyWith<TaxModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaxModelCopyWith<$Res> {
  factory $TaxModelCopyWith(TaxModel value, $Res Function(TaxModel) then) =
      _$TaxModelCopyWithImpl<$Res, TaxModel>;
  @useResult
  $Res call({String id, String categoryName, double taxRate});
}

/// @nodoc
class _$TaxModelCopyWithImpl<$Res, $Val extends TaxModel>
    implements $TaxModelCopyWith<$Res> {
  _$TaxModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categoryName = null,
    Object? taxRate = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      categoryName: null == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String,
      taxRate: null == taxRate
          ? _value.taxRate
          : taxRate // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_TaxModelCopyWith<$Res> implements $TaxModelCopyWith<$Res> {
  factory _$$_TaxModelCopyWith(
          _$_TaxModel value, $Res Function(_$_TaxModel) then) =
      __$$_TaxModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String categoryName, double taxRate});
}

/// @nodoc
class __$$_TaxModelCopyWithImpl<$Res>
    extends _$TaxModelCopyWithImpl<$Res, _$_TaxModel>
    implements _$$_TaxModelCopyWith<$Res> {
  __$$_TaxModelCopyWithImpl(
      _$_TaxModel _value, $Res Function(_$_TaxModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categoryName = null,
    Object? taxRate = null,
  }) {
    return _then(_$_TaxModel(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      categoryName: null == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String,
      taxRate: null == taxRate
          ? _value.taxRate
          : taxRate // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_TaxModel implements _TaxModel {
  const _$_TaxModel(
      {required this.id, required this.categoryName, required this.taxRate});

  factory _$_TaxModel.fromJson(Map<String, dynamic> json) =>
      _$$_TaxModelFromJson(json);

  @override
  final String id;
  @override
  final String categoryName;
  @override
  final double taxRate;

  @override
  String toString() {
    return 'TaxModel(id: $id, categoryName: $categoryName, taxRate: $taxRate)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_TaxModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.taxRate, taxRate) || other.taxRate == taxRate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, categoryName, taxRate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_TaxModelCopyWith<_$_TaxModel> get copyWith =>
      __$$_TaxModelCopyWithImpl<_$_TaxModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_TaxModelToJson(
      this,
    );
  }
}

abstract class _TaxModel implements TaxModel {
  const factory _TaxModel(
      {required final String id,
      required final String categoryName,
      required final double taxRate}) = _$_TaxModel;

  factory _TaxModel.fromJson(Map<String, dynamic> json) = _$_TaxModel.fromJson;

  @override
  String get id;
  @override
  String get categoryName;
  @override
  double get taxRate;
  @override
  @JsonKey(ignore: true)
  _$$_TaxModelCopyWith<_$_TaxModel> get copyWith =>
      throw _privateConstructorUsedError;
}
