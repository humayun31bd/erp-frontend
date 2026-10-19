import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dev-mode fallback JWT token (tenantId: 336eaf82-..., expires 2036).
const _devToken =
    'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VySWQiOiI0NzFkNDMyYi1lMmJlLTQ2NDUtODE1NS0xOTQ3OGI1YjE5NmYiLCJyb2xlIjoiVEVOQU5UX0FETUlOIiwiZW1haWwiOiJvd25lckBkZW1vLWNsaWVudC5jb20iLCJ0ZW5hbnRJZCI6IjMzNmVhZjgyLWE1MjQtNGIwYS05MzI2LTcxOTdiMWU1NDU5ZSIsImlhdCI6MTc5MTMzNTcwNiwiZXhwIjoyMTA2OTExNzA2fQ.sNeIKK1REq_KZ63Nkj1oJvxMx5FX50mCZFUk3LiLGZY';

/// Dev-mode fallback tenant ID (extracted from the JWT above).
const _devTenantId = '336eaf82-a524-4b0a-9326-7197b1e5459e';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final Ref ref;

  /// Stored token from login flow. Falls back to [_devToken].
  String? _activeToken;

  /// Stored tenantId from login flow. Falls back to [_devTenantId].
  String? _activeTenantId;

  AuthInterceptor(this.dio, this.ref);

  /// Call this after a real login to inject the live token and tenantId.
  void setToken(String token, {String? tenantId}) {
    _activeToken = token;
    _activeTenantId = tenantId;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Strip duplicate /api/v1 prefix if provided by caller since baseUrl already contains /api/v1
    if (options.path.startsWith('/api/v1/')) {
      options.path = options.path.substring(7);
    } else if (options.path.startsWith('api/v1/')) {
      options.path = '/${options.path.substring(7)}';
    }

    final token = _activeToken ?? _devToken;
    options.headers['Authorization'] = 'Bearer $token';

    // Inject x-tenant-id if not already set by the caller.
    // This ensures PosApi (Retrofit-generated, no manual headers) also gets it.
    if (!options.headers.containsKey('x-tenant-id')) {
      final tenantId = _activeTenantId ?? _devTenantId;
      options.headers['x-tenant-id'] = tenantId;
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Log the 401 but don't auto-logout — it causes cascading failures
      // when the backend is slow to compile in dev mode.
      print('[AuthInterceptor] 401 on ${err.requestOptions.path}');
    }
    super.onError(err, handler);
  }
}
