// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'whatsapp_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

WhatsAppLogModel _$WhatsAppLogModelFromJson(Map<String, dynamic> json) {
  return _WhatsAppLogModel.fromJson(json);
}

/// @nodoc
mixin _$WhatsAppLogModel {
  String get waMessageId => throw _privateConstructorUsedError;
  String get invoiceId => throw _privateConstructorUsedError;
  String get phoneNumber => throw _privateConstructorUsedError;
  String get templateName => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get sentAt => throw _privateConstructorUsedError;
  String? get deliveredAt => throw _privateConstructorUsedError;
  String? get readAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WhatsAppLogModelCopyWith<WhatsAppLogModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WhatsAppLogModelCopyWith<$Res> {
  factory $WhatsAppLogModelCopyWith(
          WhatsAppLogModel value, $Res Function(WhatsAppLogModel) then) =
      _$WhatsAppLogModelCopyWithImpl<$Res, WhatsAppLogModel>;
  @useResult
  $Res call(
      {String waMessageId,
      String invoiceId,
      String phoneNumber,
      String templateName,
      String status,
      String? sentAt,
      String? deliveredAt,
      String? readAt});
}

/// @nodoc
class _$WhatsAppLogModelCopyWithImpl<$Res, $Val extends WhatsAppLogModel>
    implements $WhatsAppLogModelCopyWith<$Res> {
  _$WhatsAppLogModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? waMessageId = null,
    Object? invoiceId = null,
    Object? phoneNumber = null,
    Object? templateName = null,
    Object? status = null,
    Object? sentAt = freezed,
    Object? deliveredAt = freezed,
    Object? readAt = freezed,
  }) {
    return _then(_value.copyWith(
      waMessageId: null == waMessageId
          ? _value.waMessageId
          : waMessageId // ignore: cast_nullable_to_non_nullable
              as String,
      invoiceId: null == invoiceId
          ? _value.invoiceId
          : invoiceId // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      templateName: null == templateName
          ? _value.templateName
          : templateName // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      sentAt: freezed == sentAt
          ? _value.sentAt
          : sentAt // ignore: cast_nullable_to_non_nullable
              as String?,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as String?,
      readAt: freezed == readAt
          ? _value.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_WhatsAppLogModelCopyWith<$Res>
    implements $WhatsAppLogModelCopyWith<$Res> {
  factory _$$_WhatsAppLogModelCopyWith(
          _$_WhatsAppLogModel value, $Res Function(_$_WhatsAppLogModel) then) =
      __$$_WhatsAppLogModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String waMessageId,
      String invoiceId,
      String phoneNumber,
      String templateName,
      String status,
      String? sentAt,
      String? deliveredAt,
      String? readAt});
}

/// @nodoc
class __$$_WhatsAppLogModelCopyWithImpl<$Res>
    extends _$WhatsAppLogModelCopyWithImpl<$Res, _$_WhatsAppLogModel>
    implements _$$_WhatsAppLogModelCopyWith<$Res> {
  __$$_WhatsAppLogModelCopyWithImpl(
      _$_WhatsAppLogModel _value, $Res Function(_$_WhatsAppLogModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? waMessageId = null,
    Object? invoiceId = null,
    Object? phoneNumber = null,
    Object? templateName = null,
    Object? status = null,
    Object? sentAt = freezed,
    Object? deliveredAt = freezed,
    Object? readAt = freezed,
  }) {
    return _then(_$_WhatsAppLogModel(
      waMessageId: null == waMessageId
          ? _value.waMessageId
          : waMessageId // ignore: cast_nullable_to_non_nullable
              as String,
      invoiceId: null == invoiceId
          ? _value.invoiceId
          : invoiceId // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      templateName: null == templateName
          ? _value.templateName
          : templateName // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      sentAt: freezed == sentAt
          ? _value.sentAt
          : sentAt // ignore: cast_nullable_to_non_nullable
              as String?,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as String?,
      readAt: freezed == readAt
          ? _value.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_WhatsAppLogModel implements _WhatsAppLogModel {
  const _$_WhatsAppLogModel(
      {required this.waMessageId,
      required this.invoiceId,
      required this.phoneNumber,
      required this.templateName,
      required this.status,
      this.sentAt,
      this.deliveredAt,
      this.readAt});

  factory _$_WhatsAppLogModel.fromJson(Map<String, dynamic> json) =>
      _$$_WhatsAppLogModelFromJson(json);

  @override
  final String waMessageId;
  @override
  final String invoiceId;
  @override
  final String phoneNumber;
  @override
  final String templateName;
  @override
  final String status;
  @override
  final String? sentAt;
  @override
  final String? deliveredAt;
  @override
  final String? readAt;

  @override
  String toString() {
    return 'WhatsAppLogModel(waMessageId: $waMessageId, invoiceId: $invoiceId, phoneNumber: $phoneNumber, templateName: $templateName, status: $status, sentAt: $sentAt, deliveredAt: $deliveredAt, readAt: $readAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_WhatsAppLogModel &&
            (identical(other.waMessageId, waMessageId) ||
                other.waMessageId == waMessageId) &&
            (identical(other.invoiceId, invoiceId) ||
                other.invoiceId == invoiceId) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.templateName, templateName) ||
                other.templateName == templateName) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.sentAt, sentAt) || other.sentAt == sentAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            (identical(other.readAt, readAt) || other.readAt == readAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, waMessageId, invoiceId,
      phoneNumber, templateName, status, sentAt, deliveredAt, readAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_WhatsAppLogModelCopyWith<_$_WhatsAppLogModel> get copyWith =>
      __$$_WhatsAppLogModelCopyWithImpl<_$_WhatsAppLogModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_WhatsAppLogModelToJson(
      this,
    );
  }
}

abstract class _WhatsAppLogModel implements WhatsAppLogModel {
  const factory _WhatsAppLogModel(
      {required final String waMessageId,
      required final String invoiceId,
      required final String phoneNumber,
      required final String templateName,
      required final String status,
      final String? sentAt,
      final String? deliveredAt,
      final String? readAt}) = _$_WhatsAppLogModel;

  factory _WhatsAppLogModel.fromJson(Map<String, dynamic> json) =
      _$_WhatsAppLogModel.fromJson;

  @override
  String get waMessageId;
  @override
  String get invoiceId;
  @override
  String get phoneNumber;
  @override
  String get templateName;
  @override
  String get status;
  @override
  String? get sentAt;
  @override
  String? get deliveredAt;
  @override
  String? get readAt;
  @override
  @JsonKey(ignore: true)
  _$$_WhatsAppLogModelCopyWith<_$_WhatsAppLogModel> get copyWith =>
      throw _privateConstructorUsedError;
}
