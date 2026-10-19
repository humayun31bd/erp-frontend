// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ClientModel _$ClientModelFromJson(Map<String, dynamic> json) {
  return _ClientModel.fromJson(json);
}

/// @nodoc
mixin _$ClientModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get vatNumber => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get customerType => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseDouble)
  double? get funds => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseDouble)
  double? get dues => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseBool)
  bool get permitCredit => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseDouble)
  double get creditLimit => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseDateTime)
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ClientModelCopyWith<ClientModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClientModelCopyWith<$Res> {
  factory $ClientModelCopyWith(
          ClientModel value, $Res Function(ClientModel) then) =
      _$ClientModelCopyWithImpl<$Res, ClientModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? vatNumber,
      String? address,
      String? email,
      String? phoneNumber,
      String? country,
      String? state,
      String? city,
      String? customerType,
      @JsonKey(fromJson: _parseDouble) double? funds,
      @JsonKey(fromJson: _parseDouble) double? dues,
      @JsonKey(fromJson: _parseBool) bool permitCredit,
      @JsonKey(fromJson: _parseDouble) double creditLimit,
      @JsonKey(fromJson: _parseDateTime) DateTime createdAt});
}

/// @nodoc
class _$ClientModelCopyWithImpl<$Res, $Val extends ClientModel>
    implements $ClientModelCopyWith<$Res> {
  _$ClientModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? vatNumber = freezed,
    Object? address = freezed,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? country = freezed,
    Object? state = freezed,
    Object? city = freezed,
    Object? customerType = freezed,
    Object? funds = freezed,
    Object? dues = freezed,
    Object? permitCredit = null,
    Object? creditLimit = null,
    Object? createdAt = null,
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
      vatNumber: freezed == vatNumber
          ? _value.vatNumber
          : vatNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      customerType: freezed == customerType
          ? _value.customerType
          : customerType // ignore: cast_nullable_to_non_nullable
              as String?,
      funds: freezed == funds
          ? _value.funds
          : funds // ignore: cast_nullable_to_non_nullable
              as double?,
      dues: freezed == dues
          ? _value.dues
          : dues // ignore: cast_nullable_to_non_nullable
              as double?,
      permitCredit: null == permitCredit
          ? _value.permitCredit
          : permitCredit // ignore: cast_nullable_to_non_nullable
              as bool,
      creditLimit: null == creditLimit
          ? _value.creditLimit
          : creditLimit // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ClientModelCopyWith<$Res>
    implements $ClientModelCopyWith<$Res> {
  factory _$$_ClientModelCopyWith(
          _$_ClientModel value, $Res Function(_$_ClientModel) then) =
      __$$_ClientModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? vatNumber,
      String? address,
      String? email,
      String? phoneNumber,
      String? country,
      String? state,
      String? city,
      String? customerType,
      @JsonKey(fromJson: _parseDouble) double? funds,
      @JsonKey(fromJson: _parseDouble) double? dues,
      @JsonKey(fromJson: _parseBool) bool permitCredit,
      @JsonKey(fromJson: _parseDouble) double creditLimit,
      @JsonKey(fromJson: _parseDateTime) DateTime createdAt});
}

/// @nodoc
class __$$_ClientModelCopyWithImpl<$Res>
    extends _$ClientModelCopyWithImpl<$Res, _$_ClientModel>
    implements _$$_ClientModelCopyWith<$Res> {
  __$$_ClientModelCopyWithImpl(
      _$_ClientModel _value, $Res Function(_$_ClientModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? vatNumber = freezed,
    Object? address = freezed,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? country = freezed,
    Object? state = freezed,
    Object? city = freezed,
    Object? customerType = freezed,
    Object? funds = freezed,
    Object? dues = freezed,
    Object? permitCredit = null,
    Object? creditLimit = null,
    Object? createdAt = null,
  }) {
    return _then(_$_ClientModel(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      vatNumber: freezed == vatNumber
          ? _value.vatNumber
          : vatNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      customerType: freezed == customerType
          ? _value.customerType
          : customerType // ignore: cast_nullable_to_non_nullable
              as String?,
      funds: freezed == funds
          ? _value.funds
          : funds // ignore: cast_nullable_to_non_nullable
              as double?,
      dues: freezed == dues
          ? _value.dues
          : dues // ignore: cast_nullable_to_non_nullable
              as double?,
      permitCredit: null == permitCredit
          ? _value.permitCredit
          : permitCredit // ignore: cast_nullable_to_non_nullable
              as bool,
      creditLimit: null == creditLimit
          ? _value.creditLimit
          : creditLimit // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ClientModel implements _ClientModel {
  const _$_ClientModel(
      {required this.id,
      required this.name,
      this.vatNumber,
      this.address,
      this.email,
      this.phoneNumber,
      this.country,
      this.state,
      this.city,
      this.customerType,
      @JsonKey(fromJson: _parseDouble) this.funds = 0.0,
      @JsonKey(fromJson: _parseDouble) this.dues = 0.0,
      @JsonKey(fromJson: _parseBool) this.permitCredit = false,
      @JsonKey(fromJson: _parseDouble) this.creditLimit = 0.0,
      @JsonKey(fromJson: _parseDateTime) required this.createdAt});

  factory _$_ClientModel.fromJson(Map<String, dynamic> json) =>
      _$$_ClientModelFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? vatNumber;
  @override
  final String? address;
  @override
  final String? email;
  @override
  final String? phoneNumber;
  @override
  final String? country;
  @override
  final String? state;
  @override
  final String? city;
  @override
  final String? customerType;
  @override
  @JsonKey(fromJson: _parseDouble)
  final double? funds;
  @override
  @JsonKey(fromJson: _parseDouble)
  final double? dues;
  @override
  @JsonKey(fromJson: _parseBool)
  final bool permitCredit;
  @override
  @JsonKey(fromJson: _parseDouble)
  final double creditLimit;
  @override
  @JsonKey(fromJson: _parseDateTime)
  final DateTime createdAt;

  @override
  String toString() {
    return 'ClientModel(id: $id, name: $name, vatNumber: $vatNumber, address: $address, email: $email, phoneNumber: $phoneNumber, country: $country, state: $state, city: $city, customerType: $customerType, funds: $funds, dues: $dues, permitCredit: $permitCredit, creditLimit: $creditLimit, createdAt: $createdAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ClientModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.vatNumber, vatNumber) ||
                other.vatNumber == vatNumber) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.customerType, customerType) ||
                other.customerType == customerType) &&
            (identical(other.funds, funds) || other.funds == funds) &&
            (identical(other.dues, dues) || other.dues == dues) &&
            (identical(other.permitCredit, permitCredit) ||
                other.permitCredit == permitCredit) &&
            (identical(other.creditLimit, creditLimit) ||
                other.creditLimit == creditLimit) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      vatNumber,
      address,
      email,
      phoneNumber,
      country,
      state,
      city,
      customerType,
      funds,
      dues,
      permitCredit,
      creditLimit,
      createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ClientModelCopyWith<_$_ClientModel> get copyWith =>
      __$$_ClientModelCopyWithImpl<_$_ClientModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ClientModelToJson(
      this,
    );
  }
}

abstract class _ClientModel implements ClientModel {
  const factory _ClientModel(
      {required final String id,
      required final String name,
      final String? vatNumber,
      final String? address,
      final String? email,
      final String? phoneNumber,
      final String? country,
      final String? state,
      final String? city,
      final String? customerType,
      @JsonKey(fromJson: _parseDouble) final double? funds,
      @JsonKey(fromJson: _parseDouble) final double? dues,
      @JsonKey(fromJson: _parseBool) final bool permitCredit,
      @JsonKey(fromJson: _parseDouble) final double creditLimit,
      @JsonKey(fromJson: _parseDateTime)
      required final DateTime createdAt}) = _$_ClientModel;

  factory _ClientModel.fromJson(Map<String, dynamic> json) =
      _$_ClientModel.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get vatNumber;
  @override
  String? get address;
  @override
  String? get email;
  @override
  String? get phoneNumber;
  @override
  String? get country;
  @override
  String? get state;
  @override
  String? get city;
  @override
  String? get customerType;
  @override
  @JsonKey(fromJson: _parseDouble)
  double? get funds;
  @override
  @JsonKey(fromJson: _parseDouble)
  double? get dues;
  @override
  @JsonKey(fromJson: _parseBool)
  bool get permitCredit;
  @override
  @JsonKey(fromJson: _parseDouble)
  double get creditLimit;
  @override
  @JsonKey(fromJson: _parseDateTime)
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$_ClientModelCopyWith<_$_ClientModel> get copyWith =>
      throw _privateConstructorUsedError;
}
