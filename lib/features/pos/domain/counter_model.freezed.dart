// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'counter_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CounterModel _$CounterModelFromJson(Map<String, dynamic> json) {
  return _CounterModel.fromJson(json);
}

/// @nodoc
mixin _$CounterModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get branchId => throw _privateConstructorUsedError;
  String get branchName => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CounterModelCopyWith<CounterModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CounterModelCopyWith<$Res> {
  factory $CounterModelCopyWith(
          CounterModel value, $Res Function(CounterModel) then) =
      _$CounterModelCopyWithImpl<$Res, CounterModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String branchId,
      String branchName,
      bool isActive});
}

/// @nodoc
class _$CounterModelCopyWithImpl<$Res, $Val extends CounterModel>
    implements $CounterModelCopyWith<$Res> {
  _$CounterModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? branchId = null,
    Object? branchName = null,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      branchId: null == branchId
          ? _value.branchId
          : branchId // ignore: cast_nullable_to_non_nullable
              as String,
      branchName: null == branchName
          ? _value.branchName
          : branchName // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CounterModelCopyWith<$Res>
    implements $CounterModelCopyWith<$Res> {
  factory _$$_CounterModelCopyWith(
          _$_CounterModel value, $Res Function(_$_CounterModel) then) =
      __$$_CounterModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String branchId,
      String branchName,
      bool isActive});
}

/// @nodoc
class __$$_CounterModelCopyWithImpl<$Res>
    extends _$CounterModelCopyWithImpl<$Res, _$_CounterModel>
    implements _$$_CounterModelCopyWith<$Res> {
  __$$_CounterModelCopyWithImpl(
      _$_CounterModel _value, $Res Function(_$_CounterModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? branchId = null,
    Object? branchName = null,
    Object? isActive = null,
  }) {
    return _then(_$_CounterModel(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      branchId: null == branchId
          ? _value.branchId
          : branchId // ignore: cast_nullable_to_non_nullable
              as String,
      branchName: null == branchName
          ? _value.branchName
          : branchName // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CounterModel implements _CounterModel {
  const _$_CounterModel(
      {required this.id,
      required this.name,
      required this.branchId,
      required this.branchName,
      required this.isActive});

  factory _$_CounterModel.fromJson(Map<String, dynamic> json) =>
      _$$_CounterModelFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String branchId;
  @override
  final String branchName;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'CounterModel(id: $id, name: $name, branchId: $branchId, branchName: $branchName, isActive: $isActive)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CounterModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.branchId, branchId) ||
                other.branchId == branchId) &&
            (identical(other.branchName, branchName) ||
                other.branchName == branchName) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, branchId, branchName, isActive);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CounterModelCopyWith<_$_CounterModel> get copyWith =>
      __$$_CounterModelCopyWithImpl<_$_CounterModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CounterModelToJson(
      this,
    );
  }
}

abstract class _CounterModel implements CounterModel {
  const factory _CounterModel(
      {required final String id,
      required final String name,
      required final String branchId,
      required final String branchName,
      required final bool isActive}) = _$_CounterModel;

  factory _CounterModel.fromJson(Map<String, dynamic> json) =
      _$_CounterModel.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get branchId;
  @override
  String get branchName;
  @override
  bool get isActive;
  @override
  @JsonKey(ignore: true)
  _$$_CounterModelCopyWith<_$_CounterModel> get copyWith =>
      throw _privateConstructorUsedError;
}

CounterListResponse _$CounterListResponseFromJson(Map<String, dynamic> json) {
  return _CounterListResponse.fromJson(json);
}

/// @nodoc
mixin _$CounterListResponse {
  bool get success => throw _privateConstructorUsedError;
  List<CounterModel> get counters => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CounterListResponseCopyWith<CounterListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CounterListResponseCopyWith<$Res> {
  factory $CounterListResponseCopyWith(
          CounterListResponse value, $Res Function(CounterListResponse) then) =
      _$CounterListResponseCopyWithImpl<$Res, CounterListResponse>;
  @useResult
  $Res call({bool success, List<CounterModel> counters});
}

/// @nodoc
class _$CounterListResponseCopyWithImpl<$Res, $Val extends CounterListResponse>
    implements $CounterListResponseCopyWith<$Res> {
  _$CounterListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? counters = null,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      counters: null == counters
          ? _value.counters
          : counters // ignore: cast_nullable_to_non_nullable
              as List<CounterModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CounterListResponseCopyWith<$Res>
    implements $CounterListResponseCopyWith<$Res> {
  factory _$$_CounterListResponseCopyWith(_$_CounterListResponse value,
          $Res Function(_$_CounterListResponse) then) =
      __$$_CounterListResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, List<CounterModel> counters});
}

/// @nodoc
class __$$_CounterListResponseCopyWithImpl<$Res>
    extends _$CounterListResponseCopyWithImpl<$Res, _$_CounterListResponse>
    implements _$$_CounterListResponseCopyWith<$Res> {
  __$$_CounterListResponseCopyWithImpl(_$_CounterListResponse _value,
      $Res Function(_$_CounterListResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? counters = null,
  }) {
    return _then(_$_CounterListResponse(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      counters: null == counters
          ? _value._counters
          : counters // ignore: cast_nullable_to_non_nullable
              as List<CounterModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CounterListResponse implements _CounterListResponse {
  const _$_CounterListResponse(
      {required this.success, final List<CounterModel> counters = const []})
      : _counters = counters;

  factory _$_CounterListResponse.fromJson(Map<String, dynamic> json) =>
      _$$_CounterListResponseFromJson(json);

  @override
  final bool success;
  final List<CounterModel> _counters;
  @override
  @JsonKey()
  List<CounterModel> get counters {
    if (_counters is EqualUnmodifiableListView) return _counters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_counters);
  }

  @override
  String toString() {
    return 'CounterListResponse(success: $success, counters: $counters)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CounterListResponse &&
            (identical(other.success, success) || other.success == success) &&
            const DeepCollectionEquality().equals(other._counters, _counters));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, success, const DeepCollectionEquality().hash(_counters));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CounterListResponseCopyWith<_$_CounterListResponse> get copyWith =>
      __$$_CounterListResponseCopyWithImpl<_$_CounterListResponse>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CounterListResponseToJson(
      this,
    );
  }
}

abstract class _CounterListResponse implements CounterListResponse {
  const factory _CounterListResponse(
      {required final bool success,
      final List<CounterModel> counters}) = _$_CounterListResponse;

  factory _CounterListResponse.fromJson(Map<String, dynamic> json) =
      _$_CounterListResponse.fromJson;

  @override
  bool get success;
  @override
  List<CounterModel> get counters;
  @override
  @JsonKey(ignore: true)
  _$$_CounterListResponseCopyWith<_$_CounterListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}
