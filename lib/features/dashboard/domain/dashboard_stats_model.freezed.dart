// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

DashboardStatsModel _$DashboardStatsModelFromJson(Map<String, dynamic> json) {
  return _DashboardStatsModel.fromJson(json);
}

/// @nodoc
mixin _$DashboardStatsModel {
  double get totalRevenue => throw _privateConstructorUsedError;
  double get totalCashOnHand => throw _privateConstructorUsedError;
  int get invoicesCleared => throw _privateConstructorUsedError;
  double get overdueAmount => throw _privateConstructorUsedError;
  bool get isZatcaHealthy => throw _privateConstructorUsedError;
  List<InvoiceModel> get recentActivity => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DashboardStatsModelCopyWith<DashboardStatsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardStatsModelCopyWith<$Res> {
  factory $DashboardStatsModelCopyWith(
          DashboardStatsModel value, $Res Function(DashboardStatsModel) then) =
      _$DashboardStatsModelCopyWithImpl<$Res, DashboardStatsModel>;
  @useResult
  $Res call(
      {double totalRevenue,
      double totalCashOnHand,
      int invoicesCleared,
      double overdueAmount,
      bool isZatcaHealthy,
      List<InvoiceModel> recentActivity});
}

/// @nodoc
class _$DashboardStatsModelCopyWithImpl<$Res, $Val extends DashboardStatsModel>
    implements $DashboardStatsModelCopyWith<$Res> {
  _$DashboardStatsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalRevenue = null,
    Object? totalCashOnHand = null,
    Object? invoicesCleared = null,
    Object? overdueAmount = null,
    Object? isZatcaHealthy = null,
    Object? recentActivity = null,
  }) {
    return _then(_value.copyWith(
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      totalCashOnHand: null == totalCashOnHand
          ? _value.totalCashOnHand
          : totalCashOnHand // ignore: cast_nullable_to_non_nullable
              as double,
      invoicesCleared: null == invoicesCleared
          ? _value.invoicesCleared
          : invoicesCleared // ignore: cast_nullable_to_non_nullable
              as int,
      overdueAmount: null == overdueAmount
          ? _value.overdueAmount
          : overdueAmount // ignore: cast_nullable_to_non_nullable
              as double,
      isZatcaHealthy: null == isZatcaHealthy
          ? _value.isZatcaHealthy
          : isZatcaHealthy // ignore: cast_nullable_to_non_nullable
              as bool,
      recentActivity: null == recentActivity
          ? _value.recentActivity
          : recentActivity // ignore: cast_nullable_to_non_nullable
              as List<InvoiceModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_DashboardStatsModelCopyWith<$Res>
    implements $DashboardStatsModelCopyWith<$Res> {
  factory _$$_DashboardStatsModelCopyWith(_$_DashboardStatsModel value,
          $Res Function(_$_DashboardStatsModel) then) =
      __$$_DashboardStatsModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double totalRevenue,
      double totalCashOnHand,
      int invoicesCleared,
      double overdueAmount,
      bool isZatcaHealthy,
      List<InvoiceModel> recentActivity});
}

/// @nodoc
class __$$_DashboardStatsModelCopyWithImpl<$Res>
    extends _$DashboardStatsModelCopyWithImpl<$Res, _$_DashboardStatsModel>
    implements _$$_DashboardStatsModelCopyWith<$Res> {
  __$$_DashboardStatsModelCopyWithImpl(_$_DashboardStatsModel _value,
      $Res Function(_$_DashboardStatsModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalRevenue = null,
    Object? totalCashOnHand = null,
    Object? invoicesCleared = null,
    Object? overdueAmount = null,
    Object? isZatcaHealthy = null,
    Object? recentActivity = null,
  }) {
    return _then(_$_DashboardStatsModel(
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      totalCashOnHand: null == totalCashOnHand
          ? _value.totalCashOnHand
          : totalCashOnHand // ignore: cast_nullable_to_non_nullable
              as double,
      invoicesCleared: null == invoicesCleared
          ? _value.invoicesCleared
          : invoicesCleared // ignore: cast_nullable_to_non_nullable
              as int,
      overdueAmount: null == overdueAmount
          ? _value.overdueAmount
          : overdueAmount // ignore: cast_nullable_to_non_nullable
              as double,
      isZatcaHealthy: null == isZatcaHealthy
          ? _value.isZatcaHealthy
          : isZatcaHealthy // ignore: cast_nullable_to_non_nullable
              as bool,
      recentActivity: null == recentActivity
          ? _value._recentActivity
          : recentActivity // ignore: cast_nullable_to_non_nullable
              as List<InvoiceModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_DashboardStatsModel implements _DashboardStatsModel {
  const _$_DashboardStatsModel(
      {required this.totalRevenue,
      required this.totalCashOnHand,
      required this.invoicesCleared,
      required this.overdueAmount,
      required this.isZatcaHealthy,
      required final List<InvoiceModel> recentActivity})
      : _recentActivity = recentActivity;

  factory _$_DashboardStatsModel.fromJson(Map<String, dynamic> json) =>
      _$$_DashboardStatsModelFromJson(json);

  @override
  final double totalRevenue;
  @override
  final double totalCashOnHand;
  @override
  final int invoicesCleared;
  @override
  final double overdueAmount;
  @override
  final bool isZatcaHealthy;
  final List<InvoiceModel> _recentActivity;
  @override
  List<InvoiceModel> get recentActivity {
    if (_recentActivity is EqualUnmodifiableListView) return _recentActivity;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentActivity);
  }

  @override
  String toString() {
    return 'DashboardStatsModel(totalRevenue: $totalRevenue, totalCashOnHand: $totalCashOnHand, invoicesCleared: $invoicesCleared, overdueAmount: $overdueAmount, isZatcaHealthy: $isZatcaHealthy, recentActivity: $recentActivity)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_DashboardStatsModel &&
            (identical(other.totalRevenue, totalRevenue) ||
                other.totalRevenue == totalRevenue) &&
            (identical(other.totalCashOnHand, totalCashOnHand) ||
                other.totalCashOnHand == totalCashOnHand) &&
            (identical(other.invoicesCleared, invoicesCleared) ||
                other.invoicesCleared == invoicesCleared) &&
            (identical(other.overdueAmount, overdueAmount) ||
                other.overdueAmount == overdueAmount) &&
            (identical(other.isZatcaHealthy, isZatcaHealthy) ||
                other.isZatcaHealthy == isZatcaHealthy) &&
            const DeepCollectionEquality()
                .equals(other._recentActivity, _recentActivity));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalRevenue,
      totalCashOnHand,
      invoicesCleared,
      overdueAmount,
      isZatcaHealthy,
      const DeepCollectionEquality().hash(_recentActivity));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_DashboardStatsModelCopyWith<_$_DashboardStatsModel> get copyWith =>
      __$$_DashboardStatsModelCopyWithImpl<_$_DashboardStatsModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_DashboardStatsModelToJson(
      this,
    );
  }
}

abstract class _DashboardStatsModel implements DashboardStatsModel {
  const factory _DashboardStatsModel(
          {required final double totalRevenue,
          required final double totalCashOnHand,
          required final int invoicesCleared,
          required final double overdueAmount,
          required final bool isZatcaHealthy,
          required final List<InvoiceModel> recentActivity}) =
      _$_DashboardStatsModel;

  factory _DashboardStatsModel.fromJson(Map<String, dynamic> json) =
      _$_DashboardStatsModel.fromJson;

  @override
  double get totalRevenue;
  @override
  double get totalCashOnHand;
  @override
  int get invoicesCleared;
  @override
  double get overdueAmount;
  @override
  bool get isZatcaHealthy;
  @override
  List<InvoiceModel> get recentActivity;
  @override
  @JsonKey(ignore: true)
  _$$_DashboardStatsModelCopyWith<_$_DashboardStatsModel> get copyWith =>
      throw _privateConstructorUsedError;
}
