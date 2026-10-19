import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../data/auth_api.dart';

class AuthState {
  final bool isAuthenticated;
  final String? token;
  final String? tenantId;
  final String? userRole;
  final String? userEmail;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false, 
    this.token,
    this.tenantId,
    this.userRole,
    this.userEmail,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated, 
    String? token, 
    String? tenantId, 
    String? userRole,
    String? userEmail,
    bool? isLoading, 
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      tenantId: tenantId ?? this.tenantId,
      userRole: userRole ?? this.userRole,
      userEmail: userEmail ?? this.userEmail,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

const devDefaultTenantId = '336eaf82-a524-4b0a-9326-7197b1e5459e';

String _extractTenantId(Map<String, dynamic> payload) {
  final tId = payload['tenantId'] ?? payload['tenant_id'] ?? payload['tenant'];
  if (tId != null && tId.toString().trim().isNotEmpty) {
    return tId.toString().trim();
  }
  return devDefaultTenantId;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FlutterSecureStorage _storage;
  final AuthApi _authApi;
  static const _tokenKey = 'jwt_token';

  AuthNotifier(this._storage, this._authApi) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Map<String, dynamic> _parseJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};

      String output = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      switch (output.length % 4) {
        case 0: break;
        case 2: output += '=='; break;
        case 3: output += '='; break;
        default: return {};
      }
      
      final payload = utf8.decode(base64Url.decode(output));
      return json.decode(payload);
    } catch (e) {
      return {};
    }
  }

  Future<void> _checkAuthStatus() async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null && token.isNotEmpty) {
      final payload = _parseJwt(token);
      
      // SECURITY FIX: Validate JWT Expiration
      if (payload.containsKey('exp')) {
        final expTime = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
        if (DateTime.now().isAfter(expTime)) {
          // Token is expired, force logout
          print('SECURITY: JWT has expired. Logging out.');
          await logout();
          return;
        }
      }

      final tenantId = _extractTenantId(payload);
      final role = payload['role']?.toString();
      final email = payload['email']?.toString();
      state = state.copyWith(
        isAuthenticated: true, 
        token: token, 
        tenantId: tenantId,
        userRole: role,
        userEmail: email,
      );
    } else {
      state = state.copyWith(tenantId: devDefaultTenantId);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authApi.login({
        'email': email,
        'password': password,
      });
      
      await _storage.write(key: _tokenKey, value: response.accessToken);
      
      final payload = _parseJwt(response.accessToken);
      final tenantId = _extractTenantId(payload);
      final role = payload['role']?.toString();
      final userEmail = payload['email']?.toString() ?? email;

      state = state.copyWith(
        isAuthenticated: true, 
        token: response.accessToken, 
        tenantId: tenantId,
        userRole: role,
        userEmail: userEmail,
        isLoading: false
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false, 
        error: e.response?.data['error'] ?? 'Login failed. Please check credentials.',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    state = const AuthState();
  }
}

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

final authApiProvider = Provider<AuthApi>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthApi(dio);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final api = ref.watch(authApiProvider);
  return AuthNotifier(storage, api);
});

// Securely pull tenantId directly from the validated AuthState with fallback
final tenantIdProvider = Provider<String>((ref) {
  final authTenantId = ref.watch(authProvider).tenantId;
  if (authTenantId != null && authTenantId.trim().isNotEmpty) {
    return authTenantId.trim();
  }
  return devDefaultTenantId;
});

final userRoleProvider = Provider<String>((ref) {
  return ref.watch(authProvider).userRole ?? 'TENANT_USER';
});

final userEmailProvider = Provider<String>((ref) {
  return ref.watch(authProvider).userEmail ?? '';
});

