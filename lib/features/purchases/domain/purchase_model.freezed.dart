// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

PurchaseModel _$PurchaseModelFromJson(Map<String, dynamic> json) {
  return _PurchaseModel.fromJson(json);
}

/// @nodoc
mixin _$PurchaseModel {
  String get id => throw _privateConstructorUsedError;
  String get supplierId => throw _privateConstructorUsedError;
  String? get supplierName => throw _privateConstructorUsedError;
  String get invoiceNumber => throw _privateConstructorUsedError;
  DateTime get issueDate => throw _privateConstructorUsedError;
  DateTime? get dueDate => throw _privateConstructorUsedError;
  String get subtotalAmount => throw _privateConstructorUsedError;
  String get totalVatAmount => throw _privateConstructorUsedError;
  String get totalAmount => throw _privateConstructorUsedError;
  String get paymentStatus => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  List<PurchaseLineItemModel> get lineItems =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PurchaseModelCopyWith<PurchaseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseModelCopyWith<$Res> {
  factory $PurchaseModelCopyWith(
          PurchaseModel value, $Res Function(PurchaseModel) then) =
      _$PurchaseModelCopyWithImpl<$Res, PurchaseModel>;
  @useResult
  $Res call(
      {String id,
      String supplierId,
      String? supplierName,
      String invoiceNumber,
      DateTime issueDate,
      DateTime? dueDate,
      String subtotalAmount,
      String totalVatAmount,
      String totalAmount,
      String paymentStatus,
      DateTime createdAt,
      List<PurchaseLineItemModel> lineItems});
}

/// @nodoc
class _$PurchaseModelCopyWithImpl<$Res, $Val extends PurchaseModel>
    implements $PurchaseModelCopyWith<$Res> {
  _$PurchaseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? supplierId = null,
    Object? supplierName = freezed,
    Object? invoiceNumber = null,
    Object? issueDate = null,
    Object? dueDate = freezed,
    Object? subtotalAmount = null,
    Object? totalVatAmount = null,
    Object? totalAmount = null,
    Object? paymentStatus = null,
    Object? createdAt = null,
    Object? lineItems = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      supplierId: null == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String,
      supplierName: freezed == supplierName
          ? _value.supplierName
          : supplierName // ignore: cast_nullable_to_non_nullable
              as String?,
      invoiceNumber: null == invoiceNumber
          ? _value.invoiceNumber
          : invoiceNumber // ignore: cast_nullable_to_non_nullable
              as String,
      issueDate: null == issueDate
          ? _value.issueDate
          : issueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      subtotalAmount: null == subtotalAmount
          ? _value.subtotalAmount
          : subtotalAmount // ignore: cast_nullable_to_non_nullable
              as String,
      totalVatAmount: null == totalVatAmount
          ? _value.totalVatAmount
          : totalVatAmount // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as String,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lineItems: null == lineItems
          ? _value.lineItems
          : lineItems // ignore: cast_nullable_to_non_nullable
              as List<PurchaseLineItemModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_PurchaseModelCopyWith<$Res>
    implements $PurchaseModelCopyWith<$Res> {
  factory _$$_PurchaseModelCopyWith(
          _$_PurchaseModel value, $Res Function(_$_PurchaseModel) then) =
      __$$_PurchaseModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String supplierId,
      String? supplierName,
      String invoiceNumber,
      DateTime issueDate,
      DateTime? dueDate,
      String subtotalAmount,
      String totalVatAmount,
      String totalAmount,
      String paymentStatus,
      DateTime createdAt,
      List<PurchaseLineItemModel> lineItems});
}

/// @nodoc
class __$$_PurchaseModelCopyWithImpl<$Res>
    extends _$PurchaseModelCopyWithImpl<$Res, _$_PurchaseModel>
    implements _$$_PurchaseModelCopyWith<$Res> {
  __$$_PurchaseModelCopyWithImpl(
      _$_PurchaseModel _value, $Res Function(_$_PurchaseModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? supplierId = null,
    Object? supplierName = freezed,
    Object? invoiceNumber = null,
    Object? issueDate = null,
    Object? dueDate = freezed,
    Object? subtotalAmount = null,
    Object? totalVatAmount = null,
    Object? totalAmount = null,
    Object? paymentStatus = null,
    Object? createdAt = null,
    Object? lineItems = null,
  }) {
    return _then(_$_PurchaseModel(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      supplierId: null == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String,
      supplierName: freezed == supplierName
          ? _value.supplierName
          : supplierName // ignore: cast_nullable_to_non_nullable
              as String?,
      invoiceNumber: null == invoiceNumber
          ? _value.invoiceNumber
          : invoiceNumber // ignore: cast_nullable_to_non_nullable
              as String,
      issueDate: null == issueDate
          ? _value.issueDate
          : issueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      subtotalAmount: null == subtotalAmount
          ? _value.subtotalAmount
          : subtotalAmount // ignore: cast_nullable_to_non_nullable
              as String,
      totalVatAmount: null == totalVatAmount
          ? _value.totalVatAmount
          : totalVatAmount // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as String,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lineItems: null == lineItems
          ? _value._lineItems
          : lineItems // ignore: cast_nullable_to_non_nullable
              as List<PurchaseLineItemModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_PurchaseModel implements _PurchaseModel {
  const _$_PurchaseModel(
      {required this.id,
      required this.supplierId,
      this.supplierName,
      required this.invoiceNumber,
      required this.issueDate,
      this.dueDate,
      required this.subtotalAmount,
      required this.totalVatAmount,
      required this.totalAmount,
      required this.paymentStatus,
      required this.createdAt,
      final List<PurchaseLineItemModel> lineItems = const []})
      : _lineItems = lineItems;

  factory _$_PurchaseModel.fromJson(Map<String, dynamic> json) =>
      _$$_PurchaseModelFromJson(json);

  @override
  final String id;
  @override
  final String supplierId;
  @override
  final String? supplierName;
  @override
  final String invoiceNumber;
  @override
  final DateTime issueDate;
  @override
  final DateTime? dueDate;
  @override
  final String subtotalAmount;
  @override
  final String totalVatAmount;
  @override
  final String totalAmount;
  @override
  final String paymentStatus;
  @override
  final DateTime createdAt;
  final List<PurchaseLineItemModel> _lineItems;
  @override
  @JsonKey()
  List<PurchaseLineItemModel> get lineItems {
    if (_lineItems is EqualUnmodifiableListView) return _lineItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lineItems);
  }

  @override
  String toString() {
    return 'PurchaseModel(id: $id, supplierId: $supplierId, supplierName: $supplierName, invoiceNumber: $invoiceNumber, issueDate: $issueDate, dueDate: $dueDate, subtotalAmount: $subtotalAmount, totalVatAmount: $totalVatAmount, totalAmount: $totalAmount, paymentStatus: $paymentStatus, createdAt: $createdAt, lineItems: $lineItems)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PurchaseModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.supplierName, supplierName) ||
                other.supplierName == supplierName) &&
            (identical(other.invoiceNumber, invoiceNumber) ||
                other.invoiceNumber == invoiceNumber) &&
            (identical(other.issueDate, issueDate) ||
                other.issueDate == issueDate) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.subtotalAmount, subtotalAmount) ||
                other.subtotalAmount == subtotalAmount) &&
            (identical(other.totalVatAmount, totalVatAmount) ||
                other.totalVatAmount == totalVatAmount) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality()
                .equals(other._lineItems, _lineItems));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      supplierId,
      supplierName,
      invoiceNumber,
      issueDate,
      dueDate,
      subtotalAmount,
      totalVatAmount,
      totalAmount,
      paymentStatus,
      createdAt,
      const DeepCollectionEquality().hash(_lineItems));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PurchaseModelCopyWith<_$_PurchaseModel> get copyWith =>
      __$$_PurchaseModelCopyWithImpl<_$_PurchaseModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PurchaseModelToJson(
      this,
    );
  }
}

abstract class _PurchaseModel implements PurchaseModel {
  const factory _PurchaseModel(
      {required final String id,
      required final String supplierId,
      final String? supplierName,
      required final String invoiceNumber,
      required final DateTime issueDate,
      final DateTime? dueDate,
      required final String subtotalAmount,
      required final String totalVatAmount,
      required final String totalAmount,
      required final String paymentStatus,
      required final DateTime createdAt,
      final List<PurchaseLineItemModel> lineItems}) = _$_PurchaseModel;

  factory _PurchaseModel.fromJson(Map<String, dynamic> json) =
      _$_PurchaseModel.fromJson;

  @override
  String get id;
  @override
  String get supplierId;
  @override
  String? get supplierName;
  @override
  String get invoiceNumber;
  @override
  DateTime get issueDate;
  @override
  DateTime? get dueDate;
  @override
  String get subtotalAmount;
  @override
  String get totalVatAmount;
  @override
  String get totalAmount;
  @override
  String get paymentStatus;
  @override
  DateTime get createdAt;
  @override
  List<PurchaseLineItemModel> get lineItems;
  @override
  @JsonKey(ignore: true)
  _$$_PurchaseModelCopyWith<_$_PurchaseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

PurchaseLineItemModel _$PurchaseLineItemModelFromJson(
    Map<String, dynamic> json) {
  return _PurchaseLineItemModel.fromJson(json);
}

/// @nodoc
mixin _$PurchaseLineItemModel {
  String? get id => throw _privateConstructorUsedError;
  String? get productId => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;
  double get unitPrice => throw _privateConstructorUsedError;
  double get vatRate => throw _privateConstructorUsedError;
  double get subtotalAmount => throw _privateConstructorUsedError;
  double get vatAmount => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PurchaseLineItemModelCopyWith<PurchaseLineItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseLineItemModelCopyWith<$Res> {
  factory $PurchaseLineItemModelCopyWith(PurchaseLineItemModel value,
          $Res Function(PurchaseLineItemModel) then) =
      _$PurchaseLineItemModelCopyWithImpl<$Res, PurchaseLineItemModel>;
  @useResult
  $Res call(
      {String? id,
      String? productId,
      String description,
      double quantity,
      double unitPrice,
      double vatRate,
      double subtotalAmount,
      double vatAmount,
      double totalAmount});
}

/// @nodoc
class _$PurchaseLineItemModelCopyWithImpl<$Res,
        $Val extends PurchaseLineItemModel>
    implements $PurchaseLineItemModelCopyWith<$Res> {
  _$PurchaseLineItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? productId = freezed,
    Object? description = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? vatRate = null,
    Object? subtotalAmount = null,
    Object? vatAmount = null,
    Object? totalAmount = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      productId: freezed == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String?,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      vatRate: null == vatRate
          ? _value.vatRate
          : vatRate // ignore: cast_nullable_to_non_nullable
              as double,
      subtotalAmount: null == subtotalAmount
          ? _value.subtotalAmount
          : subtotalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      vatAmount: null == vatAmount
          ? _value.vatAmount
          : vatAmount // ignore: cast_nullable_to_non_nullable
              as double,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_PurchaseLineItemModelCopyWith<$Res>
    implements $PurchaseLineItemModelCopyWith<$Res> {
  factory _$$_PurchaseLineItemModelCopyWith(_$_PurchaseLineItemModel value,
          $Res Function(_$_PurchaseLineItemModel) then) =
      __$$_PurchaseLineItemModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? productId,
      String description,
      double quantity,
      double unitPrice,
      double vatRate,
      double subtotalAmount,
      double vatAmount,
      double totalAmount});
}

/// @nodoc
class __$$_PurchaseLineItemModelCopyWithImpl<$Res>
    extends _$PurchaseLineItemModelCopyWithImpl<$Res, _$_PurchaseLineItemModel>
    implements _$$_PurchaseLineItemModelCopyWith<$Res> {
  __$$_PurchaseLineItemModelCopyWithImpl(_$_PurchaseLineItemModel _value,
      $Res Function(_$_PurchaseLineItemModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? productId = freezed,
    Object? description = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? vatRate = null,
    Object? subtotalAmount = null,
    Object? vatAmount = null,
    Object? totalAmount = null,
  }) {
    return _then(_$_PurchaseLineItemModel(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      productId: freezed == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String?,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      vatRate: null == vatRate
          ? _value.vatRate
          : vatRate // ignore: cast_nullable_to_non_nullable
              as double,
      subtotalAmount: null == subtotalAmount
          ? _value.subtotalAmount
          : subtotalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      vatAmount: null == vatAmount
          ? _value.vatAmount
          : vatAmount // ignore: cast_nullable_to_non_nullable
              as double,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_PurchaseLineItemModel implements _PurchaseLineItemModel {
  const _$_PurchaseLineItemModel(
      {this.id,
      this.productId,
      required this.description,
      required this.quantity,
      required this.unitPrice,
      this.vatRate = 15.0,
      required this.subtotalAmount,
      required this.vatAmount,
      required this.totalAmount});

  factory _$_PurchaseLineItemModel.fromJson(Map<String, dynamic> json) =>
      _$$_PurchaseLineItemModelFromJson(json);

  @override
  final String? id;
  @override
  final String? productId;
  @override
  final String description;
  @override
  final double quantity;
  @override
  final double unitPrice;
  @override
  @JsonKey()
  final double vatRate;
  @override
  final double subtotalAmount;
  @override
  final double vatAmount;
  @override
  final double totalAmount;

  @override
  String toString() {
    return 'PurchaseLineItemModel(id: $id, productId: $productId, description: $description, quantity: $quantity, unitPrice: $unitPrice, vatRate: $vatRate, subtotalAmount: $subtotalAmount, vatAmount: $vatAmount, totalAmount: $totalAmount)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PurchaseLineItemModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.vatRate, vatRate) || other.vatRate == vatRate) &&
            (identical(other.subtotalAmount, subtotalAmount) ||
                other.subtotalAmount == subtotalAmount) &&
            (identical(other.vatAmount, vatAmount) ||
                other.vatAmount == vatAmount) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, productId, description,
      quantity, unitPrice, vatRate, subtotalAmount, vatAmount, totalAmount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PurchaseLineItemModelCopyWith<_$_PurchaseLineItemModel> get copyWith =>
      __$$_PurchaseLineItemModelCopyWithImpl<_$_PurchaseLineItemModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PurchaseLineItemModelToJson(
      this,
    );
  }
}

abstract class _PurchaseLineItemModel implements PurchaseLineItemModel {
  const factory _PurchaseLineItemModel(
      {final String? id,
      final String? productId,
      required final String description,
      required final double quantity,
      required final double unitPrice,
      final double vatRate,
      required final double subtotalAmount,
      required final double vatAmount,
      required final double totalAmount}) = _$_PurchaseLineItemModel;

  factory _PurchaseLineItemModel.fromJson(Map<String, dynamic> json) =
      _$_PurchaseLineItemModel.fromJson;

  @override
  String? get id;
  @override
  String? get productId;
  @override
  String get description;
  @override
  double get quantity;
  @override
  double get unitPrice;
  @override
  double get vatRate;
  @override
  double get subtotalAmount;
  @override
  double get vatAmount;
  @override
  double get totalAmount;
  @override
  @JsonKey(ignore: true)
  _$$_PurchaseLineItemModelCopyWith<_$_PurchaseLineItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}
