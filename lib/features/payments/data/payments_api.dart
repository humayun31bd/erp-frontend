import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'payments_api.g.dart';

@RestApi()
abstract class PaymentsApi {
  factory PaymentsApi(Dio dio, {String baseUrl}) = _PaymentsApi;

  @POST('/payments/link')
  Future<PaymentLinkResponse> generateLink(@Body() Map<String, dynamic> body);
}

class PaymentLinkResponse {
  final bool success;
  final String? paymentUrl;
  final String? error;

  PaymentLinkResponse({required this.success, this.paymentUrl, this.error});

  factory PaymentLinkResponse.fromJson(Map<String, dynamic> json) {
    return PaymentLinkResponse(
      success: json['success'] as bool? ?? false,
      paymentUrl: json['paymentUrl'] as String?,
      error: json['error'] as String?,
    );
  }
}
