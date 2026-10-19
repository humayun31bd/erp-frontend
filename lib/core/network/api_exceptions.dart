import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  factory ApiException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.cancel:
        return ApiException("Request to API server was cancelled");
      case DioExceptionType.connectionTimeout:
        return ApiException("Connection timeout with API server");
      case DioExceptionType.receiveTimeout:
        return ApiException("Receive timeout in connection with API server");
      case DioExceptionType.badResponse:
        return ApiException(_handleError(dioException.response?.statusCode, dioException.response?.data), dioException.response?.statusCode);
      case DioExceptionType.sendTimeout:
        return ApiException("Send timeout in connection with API server");
      case DioExceptionType.connectionError:
        return ApiException("Connection to API server failed due to internet connection");
      default:
        return ApiException("Something went wrong");
    }
  }

  static String _handleError(int? statusCode, dynamic error) {
    switch (statusCode) {
      case 400:
        return error['message'] ?? 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return error['message'] ?? 'Not found';
      case 500:
        return 'Internal server error';
      default:
        return 'Oops something went wrong';
    }
  }

  @override
  String toString() => message;
}
