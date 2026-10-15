import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'csid_api.g.dart';

@RestApi()
abstract class CsidApi {
  factory CsidApi(Dio dio, {String baseUrl}) = _CsidApi;

  @GET('/csid/status')
  Future<CsidStatusResponse> getStatus();

  @POST('/csid/compliance')
  Future<ComplianceCsidResponse> generateComplianceCsid(@Body() Map<String, dynamic> body);

  @POST('/csid/production')
  Future<ProductionCsidResponse> generateProductionCsid(@Body() Map<String, dynamic> body);
}

class CsidStatusResponse {
  final bool success;
  final bool hasCompliance;
  final bool hasProduction;
  final String? complianceRequestId;

  CsidStatusResponse({
    required this.success,
    required this.hasCompliance,
    required this.hasProduction,
    this.complianceRequestId,
  });

  factory CsidStatusResponse.fromJson(Map<String, dynamic> json) {
    return CsidStatusResponse(
      success: json['success'] ?? false,
      hasCompliance: json['hasCompliance'] ?? false,
      hasProduction: json['hasProduction'] ?? false,
      complianceRequestId: json['complianceRequestId'],
    );
  }
}

class ComplianceCsidResponse {
  final bool success;
  final String? complianceRequestId;
  final String? message;

  ComplianceCsidResponse({this.success = false, this.complianceRequestId, this.message});

  factory ComplianceCsidResponse.fromJson(Map<String, dynamic> json) {
    return ComplianceCsidResponse(
      success: json['success'] ?? false,
      complianceRequestId: json['complianceRequestId'],
      message: json['message'],
    );
  }
}

class ProductionCsidResponse {
  final bool success;
  final String? productionCsid;
  final String? message;

  ProductionCsidResponse({this.success = false, this.productionCsid, this.message});

  factory ProductionCsidResponse.fromJson(Map<String, dynamic> json) {
    return ProductionCsidResponse(
      success: json['success'] ?? false,
      productionCsid: json['productionCsid'],
      message: json['message'],
    );
  }
}
