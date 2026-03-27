import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/auth_model.dart';

class AuthService {
  final _client = ApiClient();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

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
    final prefs = await _prefs;
    await prefs.setString('jwt_token', response.token);
    await prefs.setString('user_name', response.user.name);
    await prefs.setString('user_email', response.user.email);
    await prefs.setString('user_id', response.user.id);
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
    final prefs = await _prefs;
    await prefs.setString('jwt_token', response.token);
    await prefs.setString('user_name', response.user.name);
    await prefs.setString('user_email', response.user.email);
    await prefs.setString('user_id', response.user.id);
    return response;
  }

  Future<AuthUser?> getStoredUser() async {
    final prefs = await _prefs;
    final token = prefs.getString('jwt_token');
    if (token == null || token.isEmpty) return null;
    final id = prefs.getString('user_id') ?? '';
    final name = prefs.getString('user_name') ?? '';
    final email = prefs.getString('user_email') ?? '';
    return AuthUser(id: id, name: name, email: email);
  }

  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.remove('jwt_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_id');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    final token = prefs.getString('jwt_token');
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString('jwt_token');
  }
}
