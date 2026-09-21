import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../data/auth_api.dart';

class AuthState {
  final bool isAuthenticated;
  final String? token;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false, 
    this.token,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({bool? isAuthenticated, String? token, bool? isLoading, String? error}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FlutterSecureStorage _storage;
  final AuthApi _authApi;
  static const _tokenKey = 'jwt_token';

  AuthNotifier(this._storage, this._authApi) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null && token.isNotEmpty) {
      state = state.copyWith(isAuthenticated: true, token: token);
    }
  }

  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authApi.login({
        'phone': phone,
        'password': password,
      });
      
      await _storage.write(key: _tokenKey, value: response.accessToken);
      state = state.copyWith(
        isAuthenticated: true, 
        token: response.accessToken, 
        isLoading: false
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false, 
        error: e.response?.data['message'] ?? 'Login failed. Please check credentials.',
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
