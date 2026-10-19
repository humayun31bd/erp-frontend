// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_DashboardStatsModel _$$_DashboardStatsModelFromJson(
        Map<String, dynamic> json) =>
    _$_DashboardStatsModel(
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalCashOnHand: (json['totalCashOnHand'] as num).toDouble(),
      invoicesCleared: json['invoicesCleared'] as int,
      overdueAmount: (json['overdueAmount'] as num).toDouble(),
      isZatcaHealthy: json['isZatcaHealthy'] as bool,
      recentActivity: (json['recentActivity'] as List<dynamic>)
          .map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_DashboardStatsModelToJson(
        _$_DashboardStatsModel instance) =>
    <String, dynamic>{
      'totalRevenue': instance.totalRevenue,
      'totalCashOnHand': instance.totalCashOnHand,
      'invoicesCleared': instance.invoicesCleared,
      'overdueAmount': instance.overdueAmount,
      'isZatcaHealthy': instance.isZatcaHealthy,
      'recentActivity': instance.recentActivity,
    };
