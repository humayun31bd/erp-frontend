import 'package:freezed_annotation/freezed_annotation.dart';
import '../../invoicing/domain/invoice_model.dart';

part 'dashboard_stats_model.freezed.dart';
part 'dashboard_stats_model.g.dart';

@freezed
class DashboardStatsModel with _$DashboardStatsModel {
  const factory DashboardStatsModel({
    required double totalRevenue,
    required int invoicesCleared,
    required double overdueAmount,
    required bool isZatcaHealthy,
    required List<InvoiceModel> recentActivity,
  }) = _DashboardStatsModel;

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) => _$DashboardStatsModelFromJson(json);
}
