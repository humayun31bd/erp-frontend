// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

PosDashboardResponse _$PosDashboardResponseFromJson(Map<String, dynamic> json) {
  return _PosDashboardResponse.fromJson(json);
}

/// @nodoc
mixin _$PosDashboardResponse {
  bool get success => throw _privateConstructorUsedError;
  PosDashboardData get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PosDashboardResponseCopyWith<PosDashboardResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PosDashboardResponseCopyWith<$Res> {
  factory $PosDashboardResponseCopyWith(PosDashboardResponse value,
          $Res Function(PosDashboardResponse) then) =
      _$PosDashboardResponseCopyWithImpl<$Res, PosDashboardResponse>;
  @useResult
  $Res call({bool success, PosDashboardData data});

  $PosDashboardDataCopyWith<$Res> get data;
}

/// @nodoc
class _$PosDashboardResponseCopyWithImpl<$Res,
        $Val extends PosDashboardResponse>
    implements $PosDashboardResponseCopyWith<$Res> {
  _$PosDashboardResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as PosDashboardData,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PosDashboardDataCopyWith<$Res> get data {
    return $PosDashboardDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_PosDashboardResponseCopyWith<$Res>
    implements $PosDashboardResponseCopyWith<$Res> {
  factory _$$_PosDashboardResponseCopyWith(_$_PosDashboardResponse value,
          $Res Function(_$_PosDashboardResponse) then) =
      __$$_PosDashboardResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, PosDashboardData data});

  @override
  $PosDashboardDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$_PosDashboardResponseCopyWithImpl<$Res>
    extends _$PosDashboardResponseCopyWithImpl<$Res, _$_PosDashboardResponse>
    implements _$$_PosDashboardResponseCopyWith<$Res> {
  __$$_PosDashboardResponseCopyWithImpl(_$_PosDashboardResponse _value,
      $Res Function(_$_PosDashboardResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? data = null,
  }) {
    return _then(_$_PosDashboardResponse(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as PosDashboardData,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_PosDashboardResponse implements _PosDashboardResponse {
  const _$_PosDashboardResponse({required this.success, required this.data});

  factory _$_PosDashboardResponse.fromJson(Map<String, dynamic> json) =>
      _$$_PosDashboardResponseFromJson(json);

  @override
  final bool success;
  @override
  final PosDashboardData data;

  @override
  String toString() {
    return 'PosDashboardResponse(success: $success, data: $data)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PosDashboardResponse &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PosDashboardResponseCopyWith<_$_PosDashboardResponse> get copyWith =>
      __$$_PosDashboardResponseCopyWithImpl<_$_PosDashboardResponse>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PosDashboardResponseToJson(
      this,
    );
  }
}

abstract class _PosDashboardResponse implements PosDashboardResponse {
  const factory _PosDashboardResponse(
      {required final bool success,
      required final PosDashboardData data}) = _$_PosDashboardResponse;

  factory _PosDashboardResponse.fromJson(Map<String, dynamic> json) =
      _$_PosDashboardResponse.fromJson;

  @override
  bool get success;
  @override
  PosDashboardData get data;
  @override
  @JsonKey(ignore: true)
  _$$_PosDashboardResponseCopyWith<_$_PosDashboardResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

PosDashboardData _$PosDashboardDataFromJson(Map<String, dynamic> json) {
  return _PosDashboardData.fromJson(json);
}

/// @nodoc
mixin _$PosDashboardData {
  double get totalRevenue => throw _privateConstructorUsedError;
  List<TopProduct> get topProducts => throw _privateConstructorUsedError;
  List<LowStockProduct> get lowStock => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PosDashboardDataCopyWith<PosDashboardData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PosDashboardDataCopyWith<$Res> {
  factory $PosDashboardDataCopyWith(
          PosDashboardData value, $Res Function(PosDashboardData) then) =
      _$PosDashboardDataCopyWithImpl<$Res, PosDashboardData>;
  @useResult
  $Res call(
      {double totalRevenue,
      List<TopProduct> topProducts,
      List<LowStockProduct> lowStock});
}

/// @nodoc
class _$PosDashboardDataCopyWithImpl<$Res, $Val extends PosDashboardData>
    implements $PosDashboardDataCopyWith<$Res> {
  _$PosDashboardDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalRevenue = null,
    Object? topProducts = null,
    Object? lowStock = null,
  }) {
    return _then(_value.copyWith(
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      topProducts: null == topProducts
          ? _value.topProducts
          : topProducts // ignore: cast_nullable_to_non_nullable
              as List<TopProduct>,
      lowStock: null == lowStock
          ? _value.lowStock
          : lowStock // ignore: cast_nullable_to_non_nullable
              as List<LowStockProduct>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_PosDashboardDataCopyWith<$Res>
    implements $PosDashboardDataCopyWith<$Res> {
  factory _$$_PosDashboardDataCopyWith(
          _$_PosDashboardData value, $Res Function(_$_PosDashboardData) then) =
      __$$_PosDashboardDataCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double totalRevenue,
      List<TopProduct> topProducts,
      List<LowStockProduct> lowStock});
}

/// @nodoc
class __$$_PosDashboardDataCopyWithImpl<$Res>
    extends _$PosDashboardDataCopyWithImpl<$Res, _$_PosDashboardData>
    implements _$$_PosDashboardDataCopyWith<$Res> {
  __$$_PosDashboardDataCopyWithImpl(
      _$_PosDashboardData _value, $Res Function(_$_PosDashboardData) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalRevenue = null,
    Object? topProducts = null,
    Object? lowStock = null,
  }) {
    return _then(_$_PosDashboardData(
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      topProducts: null == topProducts
          ? _value._topProducts
          : topProducts // ignore: cast_nullable_to_non_nullable
              as List<TopProduct>,
      lowStock: null == lowStock
          ? _value._lowStock
          : lowStock // ignore: cast_nullable_to_non_nullable
              as List<LowStockProduct>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_PosDashboardData implements _PosDashboardData {
  const _$_PosDashboardData(
      {required this.totalRevenue,
      required final List<TopProduct> topProducts,
      required final List<LowStockProduct> lowStock})
      : _topProducts = topProducts,
        _lowStock = lowStock;

  factory _$_PosDashboardData.fromJson(Map<String, dynamic> json) =>
      _$$_PosDashboardDataFromJson(json);

  @override
  final double totalRevenue;
  final List<TopProduct> _topProducts;
  @override
  List<TopProduct> get topProducts {
    if (_topProducts is EqualUnmodifiableListView) return _topProducts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topProducts);
  }

  final List<LowStockProduct> _lowStock;
  @override
  List<LowStockProduct> get lowStock {
    if (_lowStock is EqualUnmodifiableListView) return _lowStock;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lowStock);
  }

  @override
  String toString() {
    return 'PosDashboardData(totalRevenue: $totalRevenue, topProducts: $topProducts, lowStock: $lowStock)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PosDashboardData &&
            (identical(other.totalRevenue, totalRevenue) ||
                other.totalRevenue == totalRevenue) &&
            const DeepCollectionEquality()
                .equals(other._topProducts, _topProducts) &&
            const DeepCollectionEquality().equals(other._lowStock, _lowStock));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalRevenue,
      const DeepCollectionEquality().hash(_topProducts),
      const DeepCollectionEquality().hash(_lowStock));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PosDashboardDataCopyWith<_$_PosDashboardData> get copyWith =>
      __$$_PosDashboardDataCopyWithImpl<_$_PosDashboardData>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PosDashboardDataToJson(
      this,
    );
  }
}

abstract class _PosDashboardData implements PosDashboardData {
  const factory _PosDashboardData(
      {required final double totalRevenue,
      required final List<TopProduct> topProducts,
      required final List<LowStockProduct> lowStock}) = _$_PosDashboardData;

  factory _PosDashboardData.fromJson(Map<String, dynamic> json) =
      _$_PosDashboardData.fromJson;

  @override
  double get totalRevenue;
  @override
  List<TopProduct> get topProducts;
  @override
  List<LowStockProduct> get lowStock;
  @override
  @JsonKey(ignore: true)
  _$$_PosDashboardDataCopyWith<_$_PosDashboardData> get copyWith =>
      throw _privateConstructorUsedError;
}

TopProduct _$TopProductFromJson(Map<String, dynamic> json) {
  return _TopProduct.fromJson(json);
}

/// @nodoc
mixin _$TopProduct {
  String get productId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get totalQuantitySold => throw _privateConstructorUsedError;
  double get totalRevenue => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TopProductCopyWith<TopProduct> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopProductCopyWith<$Res> {
  factory $TopProductCopyWith(
          TopProduct value, $Res Function(TopProduct) then) =
      _$TopProductCopyWithImpl<$Res, TopProduct>;
  @useResult
  $Res call(
      {String productId,
      String name,
      int totalQuantitySold,
      double totalRevenue});
}

/// @nodoc
class _$TopProductCopyWithImpl<$Res, $Val extends TopProduct>
    implements $TopProductCopyWith<$Res> {
  _$TopProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? name = null,
    Object? totalQuantitySold = null,
    Object? totalRevenue = null,
  }) {
    return _then(_value.copyWith(
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      totalQuantitySold: null == totalQuantitySold
          ? _value.totalQuantitySold
          : totalQuantitySold // ignore: cast_nullable_to_non_nullable
              as int,
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_TopProductCopyWith<$Res>
    implements $TopProductCopyWith<$Res> {
  factory _$$_TopProductCopyWith(
          _$_TopProduct value, $Res Function(_$_TopProduct) then) =
      __$$_TopProductCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String productId,
      String name,
      int totalQuantitySold,
      double totalRevenue});
}

/// @nodoc
class __$$_TopProductCopyWithImpl<$Res>
    extends _$TopProductCopyWithImpl<$Res, _$_TopProduct>
    implements _$$_TopProductCopyWith<$Res> {
  __$$_TopProductCopyWithImpl(
      _$_TopProduct _value, $Res Function(_$_TopProduct) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? name = null,
    Object? totalQuantitySold = null,
    Object? totalRevenue = null,
  }) {
    return _then(_$_TopProduct(
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      totalQuantitySold: null == totalQuantitySold
          ? _value.totalQuantitySold
          : totalQuantitySold // ignore: cast_nullable_to_non_nullable
              as int,
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_TopProduct implements _TopProduct {
  const _$_TopProduct(
      {required this.productId,
      required this.name,
      required this.totalQuantitySold,
      required this.totalRevenue});

  factory _$_TopProduct.fromJson(Map<String, dynamic> json) =>
      _$$_TopProductFromJson(json);

  @override
  final String productId;
  @override
  final String name;
  @override
  final int totalQuantitySold;
  @override
  final double totalRevenue;

  @override
  String toString() {
    return 'TopProduct(productId: $productId, name: $name, totalQuantitySold: $totalQuantitySold, totalRevenue: $totalRevenue)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_TopProduct &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.totalQuantitySold, totalQuantitySold) ||
                other.totalQuantitySold == totalQuantitySold) &&
            (identical(other.totalRevenue, totalRevenue) ||
                other.totalRevenue == totalRevenue));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, productId, name, totalQuantitySold, totalRevenue);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_TopProductCopyWith<_$_TopProduct> get copyWith =>
      __$$_TopProductCopyWithImpl<_$_TopProduct>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_TopProductToJson(
      this,
    );
  }
}

abstract class _TopProduct implements TopProduct {
  const factory _TopProduct(
      {required final String productId,
      required final String name,
      required final int totalQuantitySold,
      required final double totalRevenue}) = _$_TopProduct;

  factory _TopProduct.fromJson(Map<String, dynamic> json) =
      _$_TopProduct.fromJson;

  @override
  String get productId;
  @override
  String get name;
  @override
  int get totalQuantitySold;
  @override
  double get totalRevenue;
  @override
  @JsonKey(ignore: true)
  _$$_TopProductCopyWith<_$_TopProduct> get copyWith =>
      throw _privateConstructorUsedError;
}

LowStockProduct _$LowStockProductFromJson(Map<String, dynamic> json) {
  return _LowStockProduct.fromJson(json);
}

/// @nodoc
mixin _$LowStockProduct {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get stockQuantity => throw _privateConstructorUsedError;
  int get minStockLevel => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LowStockProductCopyWith<LowStockProduct> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LowStockProductCopyWith<$Res> {
  factory $LowStockProductCopyWith(
          LowStockProduct value, $Res Function(LowStockProduct) then) =
      _$LowStockProductCopyWithImpl<$Res, LowStockProduct>;
  @useResult
  $Res call({String id, String name, int stockQuantity, int minStockLevel});
}

/// @nodoc
class _$LowStockProductCopyWithImpl<$Res, $Val extends LowStockProduct>
    implements $LowStockProductCopyWith<$Res> {
  _$LowStockProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? stockQuantity = null,
    Object? minStockLevel = null,
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
      stockQuantity: null == stockQuantity
          ? _value.stockQuantity
          : stockQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      minStockLevel: null == minStockLevel
          ? _value.minStockLevel
          : minStockLevel // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_LowStockProductCopyWith<$Res>
    implements $LowStockProductCopyWith<$Res> {
  factory _$$_LowStockProductCopyWith(
          _$_LowStockProduct value, $Res Function(_$_LowStockProduct) then) =
      __$$_LowStockProductCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, int stockQuantity, int minStockLevel});
}

/// @nodoc
class __$$_LowStockProductCopyWithImpl<$Res>
    extends _$LowStockProductCopyWithImpl<$Res, _$_LowStockProduct>
    implements _$$_LowStockProductCopyWith<$Res> {
  __$$_LowStockProductCopyWithImpl(
      _$_LowStockProduct _value, $Res Function(_$_LowStockProduct) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? stockQuantity = null,
    Object? minStockLevel = null,
  }) {
    return _then(_$_LowStockProduct(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      stockQuantity: null == stockQuantity
          ? _value.stockQuantity
          : stockQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      minStockLevel: null == minStockLevel
          ? _value.minStockLevel
          : minStockLevel // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_LowStockProduct implements _LowStockProduct {
  const _$_LowStockProduct(
      {required this.id,
      required this.name,
      required this.stockQuantity,
      required this.minStockLevel});

  factory _$_LowStockProduct.fromJson(Map<String, dynamic> json) =>
      _$$_LowStockProductFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final int stockQuantity;
  @override
  final int minStockLevel;

  @override
  String toString() {
    return 'LowStockProduct(id: $id, name: $name, stockQuantity: $stockQuantity, minStockLevel: $minStockLevel)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_LowStockProduct &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.stockQuantity, stockQuantity) ||
                other.stockQuantity == stockQuantity) &&
            (identical(other.minStockLevel, minStockLevel) ||
                other.minStockLevel == minStockLevel));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, stockQuantity, minStockLevel);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_LowStockProductCopyWith<_$_LowStockProduct> get copyWith =>
      __$$_LowStockProductCopyWithImpl<_$_LowStockProduct>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_LowStockProductToJson(
      this,
    );
  }
}

abstract class _LowStockProduct implements LowStockProduct {
  const factory _LowStockProduct(
      {required final String id,
      required final String name,
      required final int stockQuantity,
      required final int minStockLevel}) = _$_LowStockProduct;

  factory _LowStockProduct.fromJson(Map<String, dynamic> json) =
      _$_LowStockProduct.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get stockQuantity;
  @override
  int get minStockLevel;
  @override
  @JsonKey(ignore: true)
  _$$_LowStockProductCopyWith<_$_LowStockProduct> get copyWith =>
      throw _privateConstructorUsedError;
}
