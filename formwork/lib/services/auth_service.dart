import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/auth_model.dart';

class AuthService {
  final _client = ApiClient();
  final _storage = const FlutterSecureStorage();

  Future<AuthResponse> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final json = await _client.post(
      ApiConstants.signup,
      {'name': name, 'email': email, 'password': password},
      withAuth: false,
    );
    final response = AuthResponse.fromJson(json);
    await _storage.write(key: 'jwt_token', value: response.token);
    await _storage.write(key: 'user_name', value: response.user.name);
    await _storage.write(key: 'user_email', value: response.user.email);
    await _storage.write(key: 'user_id', value: response.user.id);
    return response;
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final json = await _client.post(
      ApiConstants.login,
      {'email': email, 'password': password},
      withAuth: false,
    );
    final response = AuthResponse.fromJson(json);
    await _storage.write(key: 'jwt_token', value: response.token);
    await _storage.write(key: 'user_name', value: response.user.name);
    await _storage.write(key: 'user_email', value: response.user.email);
    await _storage.write(key: 'user_id', value: response.user.id);
    return response;
  }

  Future<AuthUser?> getStoredUser() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return null;
    final id = await _storage.read(key: 'user_id') ?? '';
    final name = await _storage.read(key: 'user_name') ?? '';
    final email = await _storage.read(key: 'user_email') ?? '';
    return AuthUser(id: id, name: name, email: email);
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'jwt_token');
    return token != null && token.isNotEmpty;
  }
}
