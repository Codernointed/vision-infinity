import '../core/constants/app_constants.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthService({
    required ApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;

  Future<User> login({required String email, required String password}) async {
    try {
      final response = await _apiService.post(AppConstants.loginEndpoint, {
        'email': email,
        'password': password,
      });

      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>;
      final user = User.fromJson(userData);

      await _storageService.setString(AppConstants.tokenKey, token);
      await _storageService.setObject(AppConstants.userKey, userData);
      _apiService.setAuthToken(token);

      return user;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _apiService.post(AppConstants.registerEndpoint, {
        'email': email,
        'password': password,
        'name': name,
      });

      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>;
      final user = User.fromJson(userData);

      await _storageService.setString(AppConstants.tokenKey, token);
      await _storageService.setObject(AppConstants.userKey, userData);
      _apiService.setAuthToken(token);

      return user;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> logout() async {
    await _storageService.remove(AppConstants.tokenKey);
    await _storageService.remove(AppConstants.userKey);
    _apiService.removeAuthToken();
  }

  Future<User?> getCurrentUser() async {
    final userData = _storageService.getObject(AppConstants.userKey);
    if (userData == null) return null;
    return User.fromJson(userData);
  }

  Future<bool> isAuthenticated() async {
    final token = _storageService.getString(AppConstants.tokenKey);
    return token != null;
  }

  Future<void> restoreSession() async {
    final token = _storageService.getString(AppConstants.tokenKey);
    if (token != null) {
      _apiService.setAuthToken(token);
    }
  }

  Exception _handleAuthError(dynamic error) {
    if (error is ApiException) {
      switch (error.statusCode) {
        case 401:
          return AuthException('Invalid credentials');
        case 422:
          return AuthException('Invalid input data');
        default:
          return AuthException(error.message);
      }
    }
    return AuthException('Authentication failed');
  }
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
