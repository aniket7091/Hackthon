import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final _storage = const FlutterSecureStorage();
  final _client = http.Client();

  Future<String?> _getToken() => _storage.read(key: 'jwt_token');

  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (withAuth) {
      final token = await _getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _uri(String path) => Uri.parse('${ApiConstants.baseUrl}$path');

  Map<String, dynamic> _parse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body as Map<String, dynamic>;
    }
    final msg = (body as Map<String, dynamic>)['message']?.toString() ?? 'Request failed';
    throw ApiException(msg, statusCode: response.statusCode);
  }

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _client.get(_uri(path), headers: await _headers());
    return _parse(response);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body, {bool withAuth = true}) async {
    final response = await _client.post(
      _uri(path),
      headers: await _headers(withAuth: withAuth),
      body: jsonEncode(body),
    );
    return _parse(response);
  }

  /// Returns raw bytes for binary responses (PDF).
  Future<Uint8List> postBytes(String path, Map<String, dynamic> body) async {
    final response = await _client.post(
      _uri(path),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    }
    throw ApiException('Failed to download', statusCode: response.statusCode);
  }
}
