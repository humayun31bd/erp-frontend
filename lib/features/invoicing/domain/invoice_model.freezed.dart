// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

InvoiceModel _$InvoiceModelFromJson(Map<String, dynamic> json) {
  return _InvoiceModel.fromJson(json);
}

/// @nodoc
mixin _$InvoiceModel {
  @JsonKey(fromJson: _parseString)
  String get id => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseString)
  String get invoiceNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'buyerName', fromJson: _parseClientName)
  String get clientName => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseDouble)
  double get totalAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'totalVatAmount', fromJson: _parseDouble)
  double get vatAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'zatcaStatus', fromJson: _parseStatus)
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'paymentStatus', fromJson: _parsePaymentStatus)
  String get paymentStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'issueDatetime', fromJson: _parseDateTime)
  DateTime get issueDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'qrCodeBase64')
  String? get zatcaQrBase64 => throw _privateConstructorUsedError;
  String? get counterId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InvoiceModelCopyWith<InvoiceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvoiceModelCopyWith<$Res> {
  factory $InvoiceModelCopyWith(
          InvoiceModel value, $Res Function(InvoiceModel) then) =
      _$InvoiceModelCopyWithImpl<$Res, InvoiceModel>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: _parseString) String id,
      @JsonKey(fromJson: _parseString) String invoiceNumber,
      @JsonKey(name: 'buyerName', fromJson: _parseClientName) String clientName,
      @JsonKey(fromJson: _parseDouble) double totalAmount,
      @JsonKey(name: 'totalVatAmount', fromJson: _parseDouble) double vatAmount,
      @JsonKey(name: 'zatcaStatus', fromJson: _parseStatus) String status,
      @JsonKey(name: 'paymentStatus', fromJson: _parsePaymentStatus)
      String paymentStatus,
      @JsonKey(name: 'issueDatetime', fromJson: _parseDateTime)
      DateTime issueDate,
      @JsonKey(name: 'qrCodeBase64') String? zatcaQrBase64,
      String? counterId});
}

/// @nodoc
class _$InvoiceModelCopyWithImpl<$Res, $Val extends InvoiceModel>
    implements $InvoiceModelCopyWith<$Res> {
  _$InvoiceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? invoiceNumber = null,
    Object? clientName = null,
    Object? totalAmount = null,
    Object? vatAmount = null,
    Object? status = null,
    Object? paymentStatus = null,
    Object? issueDate = null,
    Object? zatcaQrBase64 = freezed,
    Object? counterId = freezed,
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
      clientName: null == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      vatAmount: null == vatAmount
          ? _value.vatAmount
          : vatAmount // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      issueDate: null == issueDate
          ? _value.issueDate
          : issueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      zatcaQrBase64: freezed == zatcaQrBase64
          ? _value.zatcaQrBase64
          : zatcaQrBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      counterId: freezed == counterId
          ? _value.counterId
          : counterId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_InvoiceModelCopyWith<$Res>
    implements $InvoiceModelCopyWith<$Res> {
  factory _$$_InvoiceModelCopyWith(
          _$_InvoiceModel value, $Res Function(_$_InvoiceModel) then) =
      __$$_InvoiceModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: _parseString) String id,
      @JsonKey(fromJson: _parseString) String invoiceNumber,
      @JsonKey(name: 'buyerName', fromJson: _parseClientName) String clientName,
      @JsonKey(fromJson: _parseDouble) double totalAmount,
      @JsonKey(name: 'totalVatAmount', fromJson: _parseDouble) double vatAmount,
      @JsonKey(name: 'zatcaStatus', fromJson: _parseStatus) String status,
      @JsonKey(name: 'paymentStatus', fromJson: _parsePaymentStatus)
      String paymentStatus,
      @JsonKey(name: 'issueDatetime', fromJson: _parseDateTime)
      DateTime issueDate,
      @JsonKey(name: 'qrCodeBase64') String? zatcaQrBase64,
      String? counterId});
}

/// @nodoc
class __$$_InvoiceModelCopyWithImpl<$Res>
    extends _$InvoiceModelCopyWithImpl<$Res, _$_InvoiceModel>
    implements _$$_InvoiceModelCopyWith<$Res> {
  __$$_InvoiceModelCopyWithImpl(
      _$_InvoiceModel _value, $Res Function(_$_InvoiceModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? invoiceNumber = null,
    Object? clientName = null,
    Object? totalAmount = null,
    Object? vatAmount = null,
    Object? status = null,
    Object? paymentStatus = null,
    Object? issueDate = null,
    Object? zatcaQrBase64 = freezed,
    Object? counterId = freezed,
  }) {
    return _then(_$_InvoiceModel(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      invoiceNumber: null == invoiceNumber
          ? _value.invoiceNumber
          : invoiceNumber // ignore: cast_nullable_to_non_nullable
              as String,
      clientName: null == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      vatAmount: null == vatAmount
          ? _value.vatAmount
          : vatAmount // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      issueDate: null == issueDate
          ? _value.issueDate
          : issueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      zatcaQrBase64: freezed == zatcaQrBase64
          ? _value.zatcaQrBase64
          : zatcaQrBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      counterId: freezed == counterId
          ? _value.counterId
          : counterId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_InvoiceModel implements _InvoiceModel {
  const _$_InvoiceModel(
      {@JsonKey(fromJson: _parseString) required this.id,
      @JsonKey(fromJson: _parseString) required this.invoiceNumber,
      @JsonKey(name: 'buyerName', fromJson: _parseClientName)
      required this.clientName,
      @JsonKey(fromJson: _parseDouble) required this.totalAmount,
      @JsonKey(name: 'totalVatAmount', fromJson: _parseDouble)
      required this.vatAmount,
      @JsonKey(name: 'zatcaStatus', fromJson: _parseStatus)
      required this.status,
      @JsonKey(name: 'paymentStatus', fromJson: _parsePaymentStatus)
      this.paymentStatus = 'UNPAID',
      @JsonKey(name: 'issueDatetime', fromJson: _parseDateTime)
      required this.issueDate,
      @JsonKey(name: 'qrCodeBase64') this.zatcaQrBase64,
      this.counterId});

  factory _$_InvoiceModel.fromJson(Map<String, dynamic> json) =>
      _$$_InvoiceModelFromJson(json);

  @override
  @JsonKey(fromJson: _parseString)
  final String id;
  @override
  @JsonKey(fromJson: _parseString)
  final String invoiceNumber;
  @override
  @JsonKey(name: 'buyerName', fromJson: _parseClientName)
  final String clientName;
  @override
  @JsonKey(fromJson: _parseDouble)
  final double totalAmount;
  @override
  @JsonKey(name: 'totalVatAmount', fromJson: _parseDouble)
  final double vatAmount;
  @override
  @JsonKey(name: 'zatcaStatus', fromJson: _parseStatus)
  final String status;
  @override
  @JsonKey(name: 'paymentStatus', fromJson: _parsePaymentStatus)
  final String paymentStatus;
  @override
  @JsonKey(name: 'issueDatetime', fromJson: _parseDateTime)
  final DateTime issueDate;
  @override
  @JsonKey(name: 'qrCodeBase64')
  final String? zatcaQrBase64;
  @override
  final String? counterId;

  @override
  String toString() {
    return 'InvoiceModel(id: $id, invoiceNumber: $invoiceNumber, clientName: $clientName, totalAmount: $totalAmount, vatAmount: $vatAmount, status: $status, paymentStatus: $paymentStatus, issueDate: $issueDate, zatcaQrBase64: $zatcaQrBase64, counterId: $counterId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_InvoiceModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.invoiceNumber, invoiceNumber) ||
                other.invoiceNumber == invoiceNumber) &&
            (identical(other.clientName, clientName) ||
                other.clientName == clientName) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.vatAmount, vatAmount) ||
                other.vatAmount == vatAmount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.issueDate, issueDate) ||
                other.issueDate == issueDate) &&
            (identical(other.zatcaQrBase64, zatcaQrBase64) ||
                other.zatcaQrBase64 == zatcaQrBase64) &&
            (identical(other.counterId, counterId) ||
                other.counterId == counterId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      invoiceNumber,
      clientName,
      totalAmount,
      vatAmount,
      status,
      paymentStatus,
      issueDate,
      zatcaQrBase64,
      counterId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_InvoiceModelCopyWith<_$_InvoiceModel> get copyWith =>
      __$$_InvoiceModelCopyWithImpl<_$_InvoiceModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_InvoiceModelToJson(
      this,
    );
  }
}

abstract class _InvoiceModel implements InvoiceModel {
  const factory _InvoiceModel(
      {@JsonKey(fromJson: _parseString) required final String id,
      @JsonKey(fromJson: _parseString) required final String invoiceNumber,
      @JsonKey(name: 'buyerName', fromJson: _parseClientName)
      required final String clientName,
      @JsonKey(fromJson: _parseDouble) required final double totalAmount,
      @JsonKey(name: 'totalVatAmount', fromJson: _parseDouble)
      required final double vatAmount,
      @JsonKey(name: 'zatcaStatus', fromJson: _parseStatus)
      required final String status,
      @JsonKey(name: 'paymentStatus', fromJson: _parsePaymentStatus)
      final String paymentStatus,
      @JsonKey(name: 'issueDatetime', fromJson: _parseDateTime)
      required final DateTime issueDate,
      @JsonKey(name: 'qrCodeBase64') final String? zatcaQrBase64,
      final String? counterId}) = _$_InvoiceModel;

  factory _InvoiceModel.fromJson(Map<String, dynamic> json) =
      _$_InvoiceModel.fromJson;

  @override
  @JsonKey(fromJson: _parseString)
  String get id;
  @override
  @JsonKey(fromJson: _parseString)
  String get invoiceNumber;
  @override
  @JsonKey(name: 'buyerName', fromJson: _parseClientName)
  String get clientName;
  @override
  @JsonKey(fromJson: _parseDouble)
  double get totalAmount;
  @override
  @JsonKey(name: 'totalVatAmount', fromJson: _parseDouble)
  double get vatAmount;
  @override
  @JsonKey(name: 'zatcaStatus', fromJson: _parseStatus)
  String get status;
  @override
  @JsonKey(name: 'paymentStatus', fromJson: _parsePaymentStatus)
  String get paymentStatus;
  @override
  @JsonKey(name: 'issueDatetime', fromJson: _parseDateTime)
  DateTime get issueDate;
  @override
  @JsonKey(name: 'qrCodeBase64')
  String? get zatcaQrBase64;
  @override
  String? get counterId;
  @override
  @JsonKey(ignore: true)
  _$$_InvoiceModelCopyWith<_$_InvoiceModel> get copyWith =>
      throw _privateConstructorUsedError;
}
