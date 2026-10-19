// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tenant_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

TenantModel _$TenantModelFromJson(Map<String, dynamic> json) {
  return _TenantModel.fromJson(json);
}

/// @nodoc
mixin _$TenantModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get vatNumber => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get subdomain => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get marketingPlan => throw _privateConstructorUsedError;
  List<String> get branches => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TenantModelCopyWith<TenantModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TenantModelCopyWith<$Res> {
  factory $TenantModelCopyWith(
          TenantModel value, $Res Function(TenantModel) then) =
      _$TenantModelCopyWithImpl<$Res, TenantModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String vatNumber,
      String email,
      String? subdomain,
      String status,
      DateTime createdAt,
      String marketingPlan,
      List<String> branches});
}

/// @nodoc
class _$TenantModelCopyWithImpl<$Res, $Val extends TenantModel>
    implements $TenantModelCopyWith<$Res> {
  _$TenantModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? vatNumber = null,
    Object? email = null,
    Object? subdomain = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? marketingPlan = null,
    Object? branches = null,
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
      vatNumber: null == vatNumber
          ? _value.vatNumber
          : vatNumber // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      subdomain: freezed == subdomain
          ? _value.subdomain
          : subdomain // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      marketingPlan: null == marketingPlan
          ? _value.marketingPlan
          : marketingPlan // ignore: cast_nullable_to_non_nullable
              as String,
      branches: null == branches
          ? _value.branches
          : branches // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_TenantModelCopyWith<$Res>
    implements $TenantModelCopyWith<$Res> {
  factory _$$_TenantModelCopyWith(
          _$_TenantModel value, $Res Function(_$_TenantModel) then) =
      __$$_TenantModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String vatNumber,
      String email,
      String? subdomain,
      String status,
      DateTime createdAt,
      String marketingPlan,
      List<String> branches});
}

/// @nodoc
class __$$_TenantModelCopyWithImpl<$Res>
    extends _$TenantModelCopyWithImpl<$Res, _$_TenantModel>
    implements _$$_TenantModelCopyWith<$Res> {
  __$$_TenantModelCopyWithImpl(
      _$_TenantModel _value, $Res Function(_$_TenantModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? vatNumber = null,
    Object? email = null,
    Object? subdomain = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? marketingPlan = null,
    Object? branches = null,
  }) {
    return _then(_$_TenantModel(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      vatNumber: null == vatNumber
          ? _value.vatNumber
          : vatNumber // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      subdomain: freezed == subdomain
          ? _value.subdomain
          : subdomain // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      marketingPlan: null == marketingPlan
          ? _value.marketingPlan
          : marketingPlan // ignore: cast_nullable_to_non_nullable
              as String,
      branches: null == branches
          ? _value._branches
          : branches // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_TenantModel implements _TenantModel {
  const _$_TenantModel(
      {required this.id,
      required this.name,
      required this.vatNumber,
      required this.email,
      this.subdomain,
      required this.status,
      required this.createdAt,
      this.marketingPlan = 'Basic',
      final List<String> branches = const []})
      : _branches = branches;

  factory _$_TenantModel.fromJson(Map<String, dynamic> json) =>
      _$$_TenantModelFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String vatNumber;
  @override
  final String email;
  @override
  final String? subdomain;
  @override
  final String status;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final String marketingPlan;
  final List<String> _branches;
  @override
  @JsonKey()
  List<String> get branches {
    if (_branches is EqualUnmodifiableListView) return _branches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_branches);
  }

  @override
  String toString() {
    return 'TenantModel(id: $id, name: $name, vatNumber: $vatNumber, email: $email, subdomain: $subdomain, status: $status, createdAt: $createdAt, marketingPlan: $marketingPlan, branches: $branches)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_TenantModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.vatNumber, vatNumber) ||
                other.vatNumber == vatNumber) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.subdomain, subdomain) ||
                other.subdomain == subdomain) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.marketingPlan, marketingPlan) ||
                other.marketingPlan == marketingPlan) &&
            const DeepCollectionEquality().equals(other._branches, _branches));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      vatNumber,
      email,
      subdomain,
      status,
      createdAt,
      marketingPlan,
      const DeepCollectionEquality().hash(_branches));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_TenantModelCopyWith<_$_TenantModel> get copyWith =>
      __$$_TenantModelCopyWithImpl<_$_TenantModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_TenantModelToJson(
      this,
    );
  }
}

abstract class _TenantModel implements TenantModel {
  const factory _TenantModel(
      {required final String id,
      required final String name,
      required final String vatNumber,
      required final String email,
      final String? subdomain,
      required final String status,
      required final DateTime createdAt,
      final String marketingPlan,
      final List<String> branches}) = _$_TenantModel;

  factory _TenantModel.fromJson(Map<String, dynamic> json) =
      _$_TenantModel.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get vatNumber;
  @override
  String get email;
  @override
  String? get subdomain;
  @override
  String get status;
  @override
  DateTime get createdAt;
  @override
  String get marketingPlan;
  @override
  List<String> get branches;
  @override
  @JsonKey(ignore: true)
  _$$_TenantModelCopyWith<_$_TenantModel> get copyWith =>
      throw _privateConstructorUsedError;
}
