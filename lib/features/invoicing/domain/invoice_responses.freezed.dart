// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice_responses.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

InvoiceListResponse _$InvoiceListResponseFromJson(Map<String, dynamic> json) {
  return _InvoiceListResponse.fromJson(json);
}

/// @nodoc
mixin _$InvoiceListResponse {
  bool get success => throw _privateConstructorUsedError;
  List<InvoiceModel> get invoices => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InvoiceListResponseCopyWith<InvoiceListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvoiceListResponseCopyWith<$Res> {
  factory $InvoiceListResponseCopyWith(
          InvoiceListResponse value, $Res Function(InvoiceListResponse) then) =
      _$InvoiceListResponseCopyWithImpl<$Res, InvoiceListResponse>;
  @useResult
  $Res call({bool success, List<InvoiceModel> invoices});
}

/// @nodoc
class _$InvoiceListResponseCopyWithImpl<$Res, $Val extends InvoiceListResponse>
    implements $InvoiceListResponseCopyWith<$Res> {
  _$InvoiceListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? invoices = null,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      invoices: null == invoices
          ? _value.invoices
          : invoices // ignore: cast_nullable_to_non_nullable
              as List<InvoiceModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_InvoiceListResponseCopyWith<$Res>
    implements $InvoiceListResponseCopyWith<$Res> {
  factory _$$_InvoiceListResponseCopyWith(_$_InvoiceListResponse value,
          $Res Function(_$_InvoiceListResponse) then) =
      __$$_InvoiceListResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, List<InvoiceModel> invoices});
}

/// @nodoc
class __$$_InvoiceListResponseCopyWithImpl<$Res>
    extends _$InvoiceListResponseCopyWithImpl<$Res, _$_InvoiceListResponse>
    implements _$$_InvoiceListResponseCopyWith<$Res> {
  __$$_InvoiceListResponseCopyWithImpl(_$_InvoiceListResponse _value,
      $Res Function(_$_InvoiceListResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? invoices = null,
  }) {
    return _then(_$_InvoiceListResponse(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      invoices: null == invoices
          ? _value._invoices
          : invoices // ignore: cast_nullable_to_non_nullable
              as List<InvoiceModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_InvoiceListResponse implements _InvoiceListResponse {
  const _$_InvoiceListResponse(
      {required this.success, required final List<InvoiceModel> invoices})
      : _invoices = invoices;

  factory _$_InvoiceListResponse.fromJson(Map<String, dynamic> json) =>
      _$$_InvoiceListResponseFromJson(json);

  @override
  final bool success;
  final List<InvoiceModel> _invoices;
  @override
  List<InvoiceModel> get invoices {
    if (_invoices is EqualUnmodifiableListView) return _invoices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_invoices);
  }

  @override
  String toString() {
    return 'InvoiceListResponse(success: $success, invoices: $invoices)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_InvoiceListResponse &&
            (identical(other.success, success) || other.success == success) &&
            const DeepCollectionEquality().equals(other._invoices, _invoices));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, success, const DeepCollectionEquality().hash(_invoices));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_InvoiceListResponseCopyWith<_$_InvoiceListResponse> get copyWith =>
      __$$_InvoiceListResponseCopyWithImpl<_$_InvoiceListResponse>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_InvoiceListResponseToJson(
      this,
    );
  }
}

abstract class _InvoiceListResponse implements InvoiceListResponse {
  const factory _InvoiceListResponse(
      {required final bool success,
      required final List<InvoiceModel> invoices}) = _$_InvoiceListResponse;

  factory _InvoiceListResponse.fromJson(Map<String, dynamic> json) =
      _$_InvoiceListResponse.fromJson;

  @override
  bool get success;
  @override
  List<InvoiceModel> get invoices;
  @override
  @JsonKey(ignore: true)
  _$$_InvoiceListResponseCopyWith<_$_InvoiceListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

InvoiceDetailResponse _$InvoiceDetailResponseFromJson(
    Map<String, dynamic> json) {
  return _InvoiceDetailResponse.fromJson(json);
}

/// @nodoc
mixin _$InvoiceDetailResponse {
  bool get success => throw _privateConstructorUsedError;
  InvoiceDetail get invoice => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InvoiceDetailResponseCopyWith<InvoiceDetailResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvoiceDetailResponseCopyWith<$Res> {
  factory $InvoiceDetailResponseCopyWith(InvoiceDetailResponse value,
          $Res Function(InvoiceDetailResponse) then) =
      _$InvoiceDetailResponseCopyWithImpl<$Res, InvoiceDetailResponse>;
  @useResult
  $Res call({bool success, InvoiceDetail invoice});

  $InvoiceDetailCopyWith<$Res> get invoice;
}

/// @nodoc
class _$InvoiceDetailResponseCopyWithImpl<$Res,
        $Val extends InvoiceDetailResponse>
    implements $InvoiceDetailResponseCopyWith<$Res> {
  _$InvoiceDetailResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? invoice = null,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      invoice: null == invoice
          ? _value.invoice
          : invoice // ignore: cast_nullable_to_non_nullable
              as InvoiceDetail,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $InvoiceDetailCopyWith<$Res> get invoice {
    return $InvoiceDetailCopyWith<$Res>(_value.invoice, (value) {
      return _then(_value.copyWith(invoice: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_InvoiceDetailResponseCopyWith<$Res>
    implements $InvoiceDetailResponseCopyWith<$Res> {
  factory _$$_InvoiceDetailResponseCopyWith(_$_InvoiceDetailResponse value,
          $Res Function(_$_InvoiceDetailResponse) then) =
      __$$_InvoiceDetailResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, InvoiceDetail invoice});

  @override
  $InvoiceDetailCopyWith<$Res> get invoice;
}

/// @nodoc
class __$$_InvoiceDetailResponseCopyWithImpl<$Res>
    extends _$InvoiceDetailResponseCopyWithImpl<$Res, _$_InvoiceDetailResponse>
    implements _$$_InvoiceDetailResponseCopyWith<$Res> {
  __$$_InvoiceDetailResponseCopyWithImpl(_$_InvoiceDetailResponse _value,
      $Res Function(_$_InvoiceDetailResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? invoice = null,
  }) {
    return _then(_$_InvoiceDetailResponse(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      invoice: null == invoice
          ? _value.invoice
          : invoice // ignore: cast_nullable_to_non_nullable
              as InvoiceDetail,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_InvoiceDetailResponse implements _InvoiceDetailResponse {
  const _$_InvoiceDetailResponse(
      {required this.success, required this.invoice});

  factory _$_InvoiceDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$$_InvoiceDetailResponseFromJson(json);

  @override
  final bool success;
  @override
  final InvoiceDetail invoice;

  @override
  String toString() {
    return 'InvoiceDetailResponse(success: $success, invoice: $invoice)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_InvoiceDetailResponse &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.invoice, invoice) || other.invoice == invoice));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, invoice);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_InvoiceDetailResponseCopyWith<_$_InvoiceDetailResponse> get copyWith =>
      __$$_InvoiceDetailResponseCopyWithImpl<_$_InvoiceDetailResponse>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_InvoiceDetailResponseToJson(
      this,
    );
  }
}

abstract class _InvoiceDetailResponse implements InvoiceDetailResponse {
  const factory _InvoiceDetailResponse(
      {required final bool success,
      required final InvoiceDetail invoice}) = _$_InvoiceDetailResponse;

  factory _InvoiceDetailResponse.fromJson(Map<String, dynamic> json) =
      _$_InvoiceDetailResponse.fromJson;

  @override
  bool get success;
  @override
  InvoiceDetail get invoice;
  @override
  @JsonKey(ignore: true)
  _$$_InvoiceDetailResponseCopyWith<_$_InvoiceDetailResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateInvoiceResponse _$CreateInvoiceResponseFromJson(
    Map<String, dynamic> json) {
  return _CreateInvoiceResponse.fromJson(json);
}

/// @nodoc
mixin _$CreateInvoiceResponse {
  bool get success => throw _privateConstructorUsedError;
  String get invoiceId => throw _privateConstructorUsedError;
  String get invoiceNumber => throw _privateConstructorUsedError;
  dynamic get zatca => throw _privateConstructorUsedError;
  dynamic get whatsapp => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateInvoiceResponseCopyWith<CreateInvoiceResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateInvoiceResponseCopyWith<$Res> {
  factory $CreateInvoiceResponseCopyWith(CreateInvoiceResponse value,
          $Res Function(CreateInvoiceResponse) then) =
      _$CreateInvoiceResponseCopyWithImpl<$Res, CreateInvoiceResponse>;
  @useResult
  $Res call(
      {bool success,
      String invoiceId,
      String invoiceNumber,
      dynamic zatca,
      dynamic whatsapp});
}

/// @nodoc
class _$CreateInvoiceResponseCopyWithImpl<$Res,
        $Val extends CreateInvoiceResponse>
    implements $CreateInvoiceResponseCopyWith<$Res> {
  _$CreateInvoiceResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? invoiceId = null,
    Object? invoiceNumber = null,
    Object? zatca = freezed,
    Object? whatsapp = freezed,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      invoiceId: null == invoiceId
          ? _value.invoiceId
          : invoiceId // ignore: cast_nullable_to_non_nullable
              as String,
      invoiceNumber: null == invoiceNumber
          ? _value.invoiceNumber
          : invoiceNumber // ignore: cast_nullable_to_non_nullable
              as String,
      zatca: freezed == zatca
          ? _value.zatca
          : zatca // ignore: cast_nullable_to_non_nullable
              as dynamic,
      whatsapp: freezed == whatsapp
          ? _value.whatsapp
          : whatsapp // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CreateInvoiceResponseCopyWith<$Res>
    implements $CreateInvoiceResponseCopyWith<$Res> {
  factory _$$_CreateInvoiceResponseCopyWith(_$_CreateInvoiceResponse value,
          $Res Function(_$_CreateInvoiceResponse) then) =
      __$$_CreateInvoiceResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool success,
      String invoiceId,
      String invoiceNumber,
      dynamic zatca,
      dynamic whatsapp});
}

/// @nodoc
class __$$_CreateInvoiceResponseCopyWithImpl<$Res>
    extends _$CreateInvoiceResponseCopyWithImpl<$Res, _$_CreateInvoiceResponse>
    implements _$$_CreateInvoiceResponseCopyWith<$Res> {
  __$$_CreateInvoiceResponseCopyWithImpl(_$_CreateInvoiceResponse _value,
      $Res Function(_$_CreateInvoiceResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? invoiceId = null,
    Object? invoiceNumber = null,
    Object? zatca = freezed,
    Object? whatsapp = freezed,
  }) {
    return _then(_$_CreateInvoiceResponse(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      invoiceId: null == invoiceId
          ? _value.invoiceId
          : invoiceId // ignore: cast_nullable_to_non_nullable
              as String,
      invoiceNumber: null == invoiceNumber
          ? _value.invoiceNumber
          : invoiceNumber // ignore: cast_nullable_to_non_nullable
              as String,
      zatca: freezed == zatca
          ? _value.zatca
          : zatca // ignore: cast_nullable_to_non_nullable
              as dynamic,
      whatsapp: freezed == whatsapp
          ? _value.whatsapp
          : whatsapp // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CreateInvoiceResponse implements _CreateInvoiceResponse {
  const _$_CreateInvoiceResponse(
      {required this.success,
      required this.invoiceId,
      required this.invoiceNumber,
      this.zatca,
      this.whatsapp});

  factory _$_CreateInvoiceResponse.fromJson(Map<String, dynamic> json) =>
      _$$_CreateInvoiceResponseFromJson(json);

  @override
  final bool success;
  @override
  final String invoiceId;
  @override
  final String invoiceNumber;
  @override
  final dynamic zatca;
  @override
  final dynamic whatsapp;

  @override
  String toString() {
    return 'CreateInvoiceResponse(success: $success, invoiceId: $invoiceId, invoiceNumber: $invoiceNumber, zatca: $zatca, whatsapp: $whatsapp)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CreateInvoiceResponse &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.invoiceId, invoiceId) ||
                other.invoiceId == invoiceId) &&
            (identical(other.invoiceNumber, invoiceNumber) ||
                other.invoiceNumber == invoiceNumber) &&
            const DeepCollectionEquality().equals(other.zatca, zatca) &&
            const DeepCollectionEquality().equals(other.whatsapp, whatsapp));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      success,
      invoiceId,
      invoiceNumber,
      const DeepCollectionEquality().hash(zatca),
      const DeepCollectionEquality().hash(whatsapp));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CreateInvoiceResponseCopyWith<_$_CreateInvoiceResponse> get copyWith =>
      __$$_CreateInvoiceResponseCopyWithImpl<_$_CreateInvoiceResponse>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CreateInvoiceResponseToJson(
      this,
    );
  }
}

abstract class _CreateInvoiceResponse implements CreateInvoiceResponse {
  const factory _CreateInvoiceResponse(
      {required final bool success,
      required final String invoiceId,
      required final String invoiceNumber,
      final dynamic zatca,
      final dynamic whatsapp}) = _$_CreateInvoiceResponse;

  factory _CreateInvoiceResponse.fromJson(Map<String, dynamic> json) =
      _$_CreateInvoiceResponse.fromJson;

  @override
  bool get success;
  @override
  String get invoiceId;
  @override
  String get invoiceNumber;
  @override
  dynamic get zatca;
  @override
  dynamic get whatsapp;
  @override
  @JsonKey(ignore: true)
  _$$_CreateInvoiceResponseCopyWith<_$_CreateInvoiceResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

InvoiceDetail _$InvoiceDetailFromJson(Map<String, dynamic> json) {
  return _InvoiceDetail.fromJson(json);
}

/// @nodoc
mixin _$InvoiceDetail {
  @JsonKey(fromJson: _stringFromJson)
  String get id => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _stringFromJson)
  String get invoiceNumber => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _sellerNameFromJson)
  String get sellerName => throw _privateConstructorUsedError;
  String? get sellerVat => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _buyerNameFromJson)
  String get buyerName => throw _privateConstructorUsedError;
  String? get buyerVat => throw _privateConstructorUsedError;
  String? get buyerPhone => throw _privateConstructorUsedError;
  String get paymentStatus => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _amountFromJson)
  String get totalAmount => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _amountFromJson)
  String get totalVatAmount => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _amountFromJson)
  String get subtotalAmount => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _statusFromJson)
  String get zatcaStatus => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateTimeFromJson)
  DateTime get issueDatetime => throw _privateConstructorUsedError;
  String? get qrCodeBase64 => throw _privateConstructorUsedError;
  List<InvoiceLineItem> get lineItems => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InvoiceDetailCopyWith<InvoiceDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvoiceDetailCopyWith<$Res> {
  factory $InvoiceDetailCopyWith(
          InvoiceDetail value, $Res Function(InvoiceDetail) then) =
      _$InvoiceDetailCopyWithImpl<$Res, InvoiceDetail>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: _stringFromJson) String id,
      @JsonKey(fromJson: _stringFromJson) String invoiceNumber,
      @JsonKey(fromJson: _sellerNameFromJson) String sellerName,
      String? sellerVat,
      @JsonKey(fromJson: _buyerNameFromJson) String buyerName,
      String? buyerVat,
      String? buyerPhone,
      String paymentStatus,
      @JsonKey(fromJson: _amountFromJson) String totalAmount,
      @JsonKey(fromJson: _amountFromJson) String totalVatAmount,
      @JsonKey(fromJson: _amountFromJson) String subtotalAmount,
      @JsonKey(fromJson: _statusFromJson) String zatcaStatus,
      @JsonKey(fromJson: _dateTimeFromJson) DateTime issueDatetime,
      String? qrCodeBase64,
      List<InvoiceLineItem> lineItems});
}

/// @nodoc
class _$InvoiceDetailCopyWithImpl<$Res, $Val extends InvoiceDetail>
    implements $InvoiceDetailCopyWith<$Res> {
  _$InvoiceDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? invoiceNumber = null,
    Object? sellerName = null,
    Object? sellerVat = freezed,
    Object? buyerName = null,
    Object? buyerVat = freezed,
    Object? buyerPhone = freezed,
    Object? paymentStatus = null,
    Object? totalAmount = null,
    Object? totalVatAmount = null,
    Object? subtotalAmount = null,
    Object? zatcaStatus = null,
    Object? issueDatetime = null,
    Object? qrCodeBase64 = freezed,
    Object? lineItems = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      invoiceNumber: null == invoiceNumber
          ? _value.invoiceNumber
          : invoiceNumber // ignore: cast_nullable_to_non_nullable
              as String,
      sellerName: null == sellerName
          ? _value.sellerName
          : sellerName // ignore: cast_nullable_to_non_nullable
              as String,
      sellerVat: freezed == sellerVat
          ? _value.sellerVat
          : sellerVat // ignore: cast_nullable_to_non_nullable
              as String?,
      buyerName: null == buyerName
          ? _value.buyerName
          : buyerName // ignore: cast_nullable_to_non_nullable
              as String,
      buyerVat: freezed == buyerVat
          ? _value.buyerVat
          : buyerVat // ignore: cast_nullable_to_non_nullable
              as String?,
      buyerPhone: freezed == buyerPhone
          ? _value.buyerPhone
          : buyerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as String,
      totalVatAmount: null == totalVatAmount
          ? _value.totalVatAmount
          : totalVatAmount // ignore: cast_nullable_to_non_nullable
              as String,
      subtotalAmount: null == subtotalAmount
          ? _value.subtotalAmount
          : subtotalAmount // ignore: cast_nullable_to_non_nullable
              as String,
      zatcaStatus: null == zatcaStatus
          ? _value.zatcaStatus
          : zatcaStatus // ignore: cast_nullable_to_non_nullable
              as String,
      issueDatetime: null == issueDatetime
          ? _value.issueDatetime
          : issueDatetime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      qrCodeBase64: freezed == qrCodeBase64
          ? _value.qrCodeBase64
          : qrCodeBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      lineItems: null == lineItems
          ? _value.lineItems
          : lineItems // ignore: cast_nullable_to_non_nullable
              as List<InvoiceLineItem>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_InvoiceDetailCopyWith<$Res>
    implements $InvoiceDetailCopyWith<$Res> {
  factory _$$_InvoiceDetailCopyWith(
          _$_InvoiceDetail value, $Res Function(_$_InvoiceDetail) then) =
      __$$_InvoiceDetailCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: _stringFromJson) String id,
      @JsonKey(fromJson: _stringFromJson) String invoiceNumber,
      @JsonKey(fromJson: _sellerNameFromJson) String sellerName,
      String? sellerVat,
      @JsonKey(fromJson: _buyerNameFromJson) String buyerName,
      String? buyerVat,
      String? buyerPhone,
      String paymentStatus,
      @JsonKey(fromJson: _amountFromJson) String totalAmount,
      @JsonKey(fromJson: _amountFromJson) String totalVatAmount,
      @JsonKey(fromJson: _amountFromJson) String subtotalAmount,
      @JsonKey(fromJson: _statusFromJson) String zatcaStatus,
      @JsonKey(fromJson: _dateTimeFromJson) DateTime issueDatetime,
      String? qrCodeBase64,
      List<InvoiceLineItem> lineItems});
}

/// @nodoc
class __$$_InvoiceDetailCopyWithImpl<$Res>
    extends _$InvoiceDetailCopyWithImpl<$Res, _$_InvoiceDetail>
    implements _$$_InvoiceDetailCopyWith<$Res> {
  __$$_InvoiceDetailCopyWithImpl(
      _$_InvoiceDetail _value, $Res Function(_$_InvoiceDetail) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? invoiceNumber = null,
    Object? sellerName = null,
    Object? sellerVat = freezed,
    Object? buyerName = null,
    Object? buyerVat = freezed,
    Object? buyerPhone = freezed,
    Object? paymentStatus = null,
    Object? totalAmount = null,
    Object? totalVatAmount = null,
    Object? subtotalAmount = null,
    Object? zatcaStatus = null,
    Object? issueDatetime = null,
    Object? qrCodeBase64 = freezed,
    Object? lineItems = null,
  }) {
    return _then(_$_InvoiceDetail(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      invoiceNumber: null == invoiceNumber
          ? _value.invoiceNumber
          : invoiceNumber // ignore: cast_nullable_to_non_nullable
              as String,
      sellerName: null == sellerName
          ? _value.sellerName
          : sellerName // ignore: cast_nullable_to_non_nullable
              as String,
      sellerVat: freezed == sellerVat
          ? _value.sellerVat
          : sellerVat // ignore: cast_nullable_to_non_nullable
              as String?,
      buyerName: null == buyerName
          ? _value.buyerName
          : buyerName // ignore: cast_nullable_to_non_nullable
              as String,
      buyerVat: freezed == buyerVat
          ? _value.buyerVat
          : buyerVat // ignore: cast_nullable_to_non_nullable
              as String?,
      buyerPhone: freezed == buyerPhone
          ? _value.buyerPhone
          : buyerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as String,
      totalVatAmount: null == totalVatAmount
          ? _value.totalVatAmount
          : totalVatAmount // ignore: cast_nullable_to_non_nullable
              as String,
      subtotalAmount: null == subtotalAmount
          ? _value.subtotalAmount
          : subtotalAmount // ignore: cast_nullable_to_non_nullable
              as String,
      zatcaStatus: null == zatcaStatus
          ? _value.zatcaStatus
          : zatcaStatus // ignore: cast_nullable_to_non_nullable
              as String,
      issueDatetime: null == issueDatetime
          ? _value.issueDatetime
          : issueDatetime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      qrCodeBase64: freezed == qrCodeBase64
          ? _value.qrCodeBase64
          : qrCodeBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      lineItems: null == lineItems
          ? _value._lineItems
          : lineItems // ignore: cast_nullable_to_non_nullable
              as List<InvoiceLineItem>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_InvoiceDetail implements _InvoiceDetail {
  const _$_InvoiceDetail(
      {@JsonKey(fromJson: _stringFromJson) required this.id,
      @JsonKey(fromJson: _stringFromJson) required this.invoiceNumber,
      @JsonKey(fromJson: _sellerNameFromJson) required this.sellerName,
      this.sellerVat,
      @JsonKey(fromJson: _buyerNameFromJson) required this.buyerName,
      this.buyerVat,
      this.buyerPhone,
      this.paymentStatus = 'UNPAID',
      @JsonKey(fromJson: _amountFromJson) required this.totalAmount,
      @JsonKey(fromJson: _amountFromJson) required this.totalVatAmount,
      @JsonKey(fromJson: _amountFromJson) required this.subtotalAmount,
      @JsonKey(fromJson: _statusFromJson) required this.zatcaStatus,
      @JsonKey(fromJson: _dateTimeFromJson) required this.issueDatetime,
      this.qrCodeBase64,
      required final List<InvoiceLineItem> lineItems})
      : _lineItems = lineItems;

  factory _$_InvoiceDetail.fromJson(Map<String, dynamic> json) =>
      _$$_InvoiceDetailFromJson(json);

  @override
  @JsonKey(fromJson: _stringFromJson)
  final String id;
  @override
  @JsonKey(fromJson: _stringFromJson)
  final String invoiceNumber;
  @override
  @JsonKey(fromJson: _sellerNameFromJson)
  final String sellerName;
  @override
  final String? sellerVat;
  @override
  @JsonKey(fromJson: _buyerNameFromJson)
  final String buyerName;
  @override
  final String? buyerVat;
  @override
  final String? buyerPhone;
  @override
  @JsonKey()
  final String paymentStatus;
  @override
  @JsonKey(fromJson: _amountFromJson)
  final String totalAmount;
  @override
  @JsonKey(fromJson: _amountFromJson)
  final String totalVatAmount;
  @override
  @JsonKey(fromJson: _amountFromJson)
  final String subtotalAmount;
  @override
  @JsonKey(fromJson: _statusFromJson)
  final String zatcaStatus;
  @override
  @JsonKey(fromJson: _dateTimeFromJson)
  final DateTime issueDatetime;
  @override
  final String? qrCodeBase64;
  final List<InvoiceLineItem> _lineItems;
  @override
  List<InvoiceLineItem> get lineItems {
    if (_lineItems is EqualUnmodifiableListView) return _lineItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lineItems);
  }

  @override
  String toString() {
    return 'InvoiceDetail(id: $id, invoiceNumber: $invoiceNumber, sellerName: $sellerName, sellerVat: $sellerVat, buyerName: $buyerName, buyerVat: $buyerVat, buyerPhone: $buyerPhone, paymentStatus: $paymentStatus, totalAmount: $totalAmount, totalVatAmount: $totalVatAmount, subtotalAmount: $subtotalAmount, zatcaStatus: $zatcaStatus, issueDatetime: $issueDatetime, qrCodeBase64: $qrCodeBase64, lineItems: $lineItems)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_InvoiceDetail &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.invoiceNumber, invoiceNumber) ||
                other.invoiceNumber == invoiceNumber) &&
            (identical(other.sellerName, sellerName) ||
                other.sellerName == sellerName) &&
            (identical(other.sellerVat, sellerVat) ||
                other.sellerVat == sellerVat) &&
            (identical(other.buyerName, buyerName) ||
                other.buyerName == buyerName) &&
            (identical(other.buyerVat, buyerVat) ||
                other.buyerVat == buyerVat) &&
            (identical(other.buyerPhone, buyerPhone) ||
                other.buyerPhone == buyerPhone) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.totalVatAmount, totalVatAmount) ||
                other.totalVatAmount == totalVatAmount) &&
            (identical(other.subtotalAmount, subtotalAmount) ||
                other.subtotalAmount == subtotalAmount) &&
            (identical(other.zatcaStatus, zatcaStatus) ||
                other.zatcaStatus == zatcaStatus) &&
            (identical(other.issueDatetime, issueDatetime) ||
                other.issueDatetime == issueDatetime) &&
            (identical(other.qrCodeBase64, qrCodeBase64) ||
                other.qrCodeBase64 == qrCodeBase64) &&
            const DeepCollectionEquality()
                .equals(other._lineItems, _lineItems));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      invoiceNumber,
      sellerName,
      sellerVat,
      buyerName,
      buyerVat,
      buyerPhone,
      paymentStatus,
      totalAmount,
      totalVatAmount,
      subtotalAmount,
      zatcaStatus,
      issueDatetime,
      qrCodeBase64,
      const DeepCollectionEquality().hash(_lineItems));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_InvoiceDetailCopyWith<_$_InvoiceDetail> get copyWith =>
      __$$_InvoiceDetailCopyWithImpl<_$_InvoiceDetail>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_InvoiceDetailToJson(
      this,
    );
  }
}

abstract class _InvoiceDetail implements InvoiceDetail {
  const factory _InvoiceDetail(
      {@JsonKey(fromJson: _stringFromJson) required final String id,
      @JsonKey(fromJson: _stringFromJson) required final String invoiceNumber,
      @JsonKey(fromJson: _sellerNameFromJson) required final String sellerName,
      final String? sellerVat,
      @JsonKey(fromJson: _buyerNameFromJson) required final String buyerName,
      final String? buyerVat,
      final String? buyerPhone,
      final String paymentStatus,
      @JsonKey(fromJson: _amountFromJson) required final String totalAmount,
      @JsonKey(fromJson: _amountFromJson) required final String totalVatAmount,
      @JsonKey(fromJson: _amountFromJson) required final String subtotalAmount,
      @JsonKey(fromJson: _statusFromJson) required final String zatcaStatus,
      @JsonKey(fromJson: _dateTimeFromJson)
      required final DateTime issueDatetime,
      final String? qrCodeBase64,
      required final List<InvoiceLineItem> lineItems}) = _$_InvoiceDetail;

  factory _InvoiceDetail.fromJson(Map<String, dynamic> json) =
      _$_InvoiceDetail.fromJson;

  @override
  @JsonKey(fromJson: _stringFromJson)
  String get id;
  @override
  @JsonKey(fromJson: _stringFromJson)
  String get invoiceNumber;
  @override
  @JsonKey(fromJson: _sellerNameFromJson)
  String get sellerName;
  @override
  String? get sellerVat;
  @override
  @JsonKey(fromJson: _buyerNameFromJson)
  String get buyerName;
  @override
  String? get buyerVat;
  @override
  String? get buyerPhone;
  @override
  String get paymentStatus;
  @override
  @JsonKey(fromJson: _amountFromJson)
  String get totalAmount;
  @override
  @JsonKey(fromJson: _amountFromJson)
  String get totalVatAmount;
  @override
  @JsonKey(fromJson: _amountFromJson)
  String get subtotalAmount;
  @override
  @JsonKey(fromJson: _statusFromJson)
  String get zatcaStatus;
  @override
  @JsonKey(fromJson: _dateTimeFromJson)
  DateTime get issueDatetime;
  @override
  String? get qrCodeBase64;
  @override
  List<InvoiceLineItem> get lineItems;
  @override
  @JsonKey(ignore: true)
  _$$_InvoiceDetailCopyWith<_$_InvoiceDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

InvoiceLineItem _$InvoiceLineItemFromJson(Map<String, dynamic> json) {
  return _InvoiceLineItem.fromJson(json);
}

/// @nodoc
mixin _$InvoiceLineItem {
  @JsonKey(fromJson: _stringFromJson)
  String get id => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _intFromJson)
  int get lineNumber => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _stringFromJson)
  String get description => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _qtyFromJson)
  String get quantity => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _amountFromJson)
  String get unitPrice => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _amountFromJson)
  String get taxPercent => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _amountFromJson)
  String get taxAmount => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _amountFromJson)
  String get lineTotal => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InvoiceLineItemCopyWith<InvoiceLineItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvoiceLineItemCopyWith<$Res> {
  factory $InvoiceLineItemCopyWith(
          InvoiceLineItem value, $Res Function(InvoiceLineItem) then) =
      _$InvoiceLineItemCopyWithImpl<$Res, InvoiceLineItem>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: _stringFromJson) String id,
      @JsonKey(fromJson: _intFromJson) int lineNumber,
      @JsonKey(fromJson: _stringFromJson) String description,
      @JsonKey(fromJson: _qtyFromJson) String quantity,
      @JsonKey(fromJson: _amountFromJson) String unitPrice,
      @JsonKey(fromJson: _amountFromJson) String taxPercent,
      @JsonKey(fromJson: _amountFromJson) String taxAmount,
      @JsonKey(fromJson: _amountFromJson) String lineTotal});
}

/// @nodoc
class _$InvoiceLineItemCopyWithImpl<$Res, $Val extends InvoiceLineItem>
    implements $InvoiceLineItemCopyWith<$Res> {
  _$InvoiceLineItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? lineNumber = null,
    Object? description = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? taxPercent = null,
    Object? taxAmount = null,
    Object? lineTotal = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      lineNumber: null == lineNumber
          ? _value.lineNumber
          : lineNumber // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as String,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as String,
      taxPercent: null == taxPercent
          ? _value.taxPercent
          : taxPercent // ignore: cast_nullable_to_non_nullable
              as String,
      taxAmount: null == taxAmount
          ? _value.taxAmount
          : taxAmount // ignore: cast_nullable_to_non_nullable
              as String,
      lineTotal: null == lineTotal
          ? _value.lineTotal
          : lineTotal // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_InvoiceLineItemCopyWith<$Res>
    implements $InvoiceLineItemCopyWith<$Res> {
  factory _$$_InvoiceLineItemCopyWith(
          _$_InvoiceLineItem value, $Res Function(_$_InvoiceLineItem) then) =
      __$$_InvoiceLineItemCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: _stringFromJson) String id,
      @JsonKey(fromJson: _intFromJson) int lineNumber,
      @JsonKey(fromJson: _stringFromJson) String description,
      @JsonKey(fromJson: _qtyFromJson) String quantity,
      @JsonKey(fromJson: _amountFromJson) String unitPrice,
      @JsonKey(fromJson: _amountFromJson) String taxPercent,
      @JsonKey(fromJson: _amountFromJson) String taxAmount,
      @JsonKey(fromJson: _amountFromJson) String lineTotal});
}

/// @nodoc
class __$$_InvoiceLineItemCopyWithImpl<$Res>
    extends _$InvoiceLineItemCopyWithImpl<$Res, _$_InvoiceLineItem>
    implements _$$_InvoiceLineItemCopyWith<$Res> {
  __$$_InvoiceLineItemCopyWithImpl(
      _$_InvoiceLineItem _value, $Res Function(_$_InvoiceLineItem) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? lineNumber = null,
    Object? description = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? taxPercent = null,
    Object? taxAmount = null,
    Object? lineTotal = null,
  }) {
    return _then(_$_InvoiceLineItem(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      lineNumber: null == lineNumber
          ? _value.lineNumber
          : lineNumber // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as String,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as String,
      taxPercent: null == taxPercent
          ? _value.taxPercent
          : taxPercent // ignore: cast_nullable_to_non_nullable
              as String,
      taxAmount: null == taxAmount
          ? _value.taxAmount
          : taxAmount // ignore: cast_nullable_to_non_nullable
              as String,
      lineTotal: null == lineTotal
          ? _value.lineTotal
          : lineTotal // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_InvoiceLineItem implements _InvoiceLineItem {
  const _$_InvoiceLineItem(
      {@JsonKey(fromJson: _stringFromJson) required this.id,
      @JsonKey(fromJson: _intFromJson) required this.lineNumber,
      @JsonKey(fromJson: _stringFromJson) required this.description,
      @JsonKey(fromJson: _qtyFromJson) required this.quantity,
      @JsonKey(fromJson: _amountFromJson) required this.unitPrice,
      @JsonKey(fromJson: _amountFromJson) required this.taxPercent,
      @JsonKey(fromJson: _amountFromJson) required this.taxAmount,
      @JsonKey(fromJson: _amountFromJson) required this.lineTotal});

  factory _$_InvoiceLineItem.fromJson(Map<String, dynamic> json) =>
      _$$_InvoiceLineItemFromJson(json);

  @override
  @JsonKey(fromJson: _stringFromJson)
  final String id;
  @override
  @JsonKey(fromJson: _intFromJson)
  final int lineNumber;
  @override
  @JsonKey(fromJson: _stringFromJson)
  final String description;
  @override
  @JsonKey(fromJson: _qtyFromJson)
  final String quantity;
  @override
  @JsonKey(fromJson: _amountFromJson)
  final String unitPrice;
  @override
  @JsonKey(fromJson: _amountFromJson)
  final String taxPercent;
  @override
  @JsonKey(fromJson: _amountFromJson)
  final String taxAmount;
  @override
  @JsonKey(fromJson: _amountFromJson)
  final String lineTotal;

  @override
  String toString() {
    return 'InvoiceLineItem(id: $id, lineNumber: $lineNumber, description: $description, quantity: $quantity, unitPrice: $unitPrice, taxPercent: $taxPercent, taxAmount: $taxAmount, lineTotal: $lineTotal)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_InvoiceLineItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.lineNumber, lineNumber) ||
                other.lineNumber == lineNumber) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.taxPercent, taxPercent) ||
                other.taxPercent == taxPercent) &&
            (identical(other.taxAmount, taxAmount) ||
                other.taxAmount == taxAmount) &&
            (identical(other.lineTotal, lineTotal) ||
                other.lineTotal == lineTotal));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, lineNumber, description,
      quantity, unitPrice, taxPercent, taxAmount, lineTotal);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_InvoiceLineItemCopyWith<_$_InvoiceLineItem> get copyWith =>
      __$$_InvoiceLineItemCopyWithImpl<_$_InvoiceLineItem>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_InvoiceLineItemToJson(
      this,
    );
  }
}

abstract class _InvoiceLineItem implements InvoiceLineItem {
  const factory _InvoiceLineItem(
      {@JsonKey(fromJson: _stringFromJson) required final String id,
      @JsonKey(fromJson: _intFromJson) required final int lineNumber,
      @JsonKey(fromJson: _stringFromJson) required final String description,
      @JsonKey(fromJson: _qtyFromJson) required final String quantity,
      @JsonKey(fromJson: _amountFromJson) required final String unitPrice,
      @JsonKey(fromJson: _amountFromJson) required final String taxPercent,
      @JsonKey(fromJson: _amountFromJson) required final String taxAmount,
      @JsonKey(fromJson: _amountFromJson)
      required final String lineTotal}) = _$_InvoiceLineItem;

  factory _InvoiceLineItem.fromJson(Map<String, dynamic> json) =
      _$_InvoiceLineItem.fromJson;

  @override
  @JsonKey(fromJson: _stringFromJson)
  String get id;
  @override
  @JsonKey(fromJson: _intFromJson)
  int get lineNumber;
  @override
  @JsonKey(fromJson: _stringFromJson)
  String get description;
  @override
  @JsonKey(fromJson: _qtyFromJson)
  String get quantity;
  @override
  @JsonKey(fromJson: _amountFromJson)
  String get unitPrice;
  @override
  @JsonKey(fromJson: _amountFromJson)
  String get taxPercent;
  @override
  @JsonKey(fromJson: _amountFromJson)
  String get taxAmount;
  @override
  @JsonKey(fromJson: _amountFromJson)
  String get lineTotal;
  @override
  @JsonKey(ignore: true)
  _$$_InvoiceLineItemCopyWith<_$_InvoiceLineItem> get copyWith =>
      throw _privateConstructorUsedError;
}
