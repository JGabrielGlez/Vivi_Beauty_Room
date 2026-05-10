import 'package:http/http.dart' as http;
import 'dart:convert';
import 'token_storage_service.dart';
import 'api_config.dart';

class ApiClient {
  final TokenStorageService tokenStorage;

  ApiClient({required this.tokenStorage});

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        ApiConfig.connectionTimeout,
        onTimeout: () => throw Exception('Timeout en conexión'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Credenciales incorrectas',
          'statusCode': 401
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Error en autenticación',
          'statusCode': response.statusCode
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final token = await tokenStorage.readToken();
      if (token == null) {
        return {'success': false, 'error': 'Sin token', 'statusCode': 401};
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        ApiConfig.receiveTimeout,
        onTimeout: () => throw Exception('Timeout en conexión'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 401) {
        await tokenStorage.clearAll();
        return {
          'success': false,
          'error': 'Token inválido o expirado',
          'statusCode': 401
        };
      } else {
        return {
          'success': false,
          'error': 'Error al validar sesión',
          'statusCode': response.statusCode
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
