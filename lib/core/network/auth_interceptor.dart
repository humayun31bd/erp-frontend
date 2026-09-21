import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';

class AuthInterceptor extends Interceptor {
  final Ref ref;

  AuthInterceptor(this.ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Inject token if authenticated
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated && authState.token != null) {
      options.headers['Authorization'] = 'Bearer ${authState.token}';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized globally
    if (err.response?.statusCode == 401) {
      ref.read(authProvider.notifier).logout();
    }
    super.onError(err, handler);
  }
}
