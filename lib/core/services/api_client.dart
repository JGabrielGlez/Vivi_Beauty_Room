import 'package:http/http.dart' as http;
import 'dart:convert';
import 'token_storage_service.dart';
import 'api_config.dart';

class ApiClient {
  final TokenStorageService tokenStorage;
  Future<void> Function()? onUnauthorized;

  ApiClient({required this.tokenStorage, this.onUnauthorized});

  Future<void> _handleUnauthorized() async {
    await tokenStorage.clearAll();
    final callback = onUnauthorized;
    if (callback != null) {
      await callback();
    }
  }

  Future<Map<String, String>> _authJsonHeaders() async {
    final token = await tokenStorage.readToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sin token');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(
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
          'statusCode': 401,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Error en autenticación',
          'statusCode': response.statusCode,
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

      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/auth/me'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            ApiConfig.receiveTimeout,
            onTimeout: () => throw Exception('Timeout en conexión'),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 401) {
        await _handleUnauthorized();
        return {
          'success': false,
          'error': 'Token inválido o expirado',
          'statusCode': 401,
        };
      } else {
        return {
          'success': false,
          'error': 'Error al validar sesión',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getClientas({String? query}) async {
    try {
      final headers = await _authJsonHeaders();
      final uri = Uri.parse('${ApiConfig.baseUrl}/clientas').replace(
        queryParameters: (query != null && query.trim().isNotEmpty)
            ? {'q': query.trim()}
            : null,
      );

      final response = await http
          .get(uri, headers: headers)
          .timeout(
            ApiConfig.receiveTimeout,
            onTimeout: () => throw Exception('Timeout en conexión'),
          );

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body);
        final list = decodedBody is List ? decodedBody : <dynamic>[];
        return {'success': true, 'data': list};
      }

      if (response.statusCode == 401) {
        await _handleUnauthorized();
        return {
          'success': false,
          'statusCode': 401,
          'error': 'Token inválido o expirado',
        };
      }

      final errorData = jsonDecode(response.body);
      return {
        'success': false,
        'statusCode': response.statusCode,
        'error': errorData['error'] ?? 'Error al cargar clientas',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getClientaDetalle(String id) async {
    try {
      final headers = await _authJsonHeaders();
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/clientas/$id'), headers: headers)
          .timeout(ApiConfig.receiveTimeout,
              onTimeout: () => throw Exception('Timeout en conexión'));

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      if (response.statusCode == 401) {
        await _handleUnauthorized();
        return {'success': false, 'statusCode': 401, 'error': 'Token inválido o expirado'};
      }
      final errorData = jsonDecode(response.body);
      return {
        'success': false,
        'statusCode': response.statusCode,
        'error': errorData['error'] ?? 'Error al cargar la clienta',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getClientaHistorial(String id) async {
    try {
      final headers = await _authJsonHeaders();
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/clientas/$id/historial'), headers: headers)
          .timeout(ApiConfig.receiveTimeout,
              onTimeout: () => throw Exception('Timeout en conexión'));

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body);
        final list = decodedBody is List ? decodedBody : <dynamic>[];
        return {'success': true, 'data': list};
      }
      if (response.statusCode == 401) {
        await _handleUnauthorized();
        return {'success': false, 'statusCode': 401, 'error': 'Token inválido o expirado'};
      }
      final errorData = jsonDecode(response.body);
      return {
        'success': false,
        'statusCode': response.statusCode,
        'error': errorData['error'] ?? 'Error al cargar el historial',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateClienta(
    String id, {
    required String nombre,
    required String telefono,
    String? alergias,
    String? preferencias,
    String? notas,
  }) async {
    try {
      final headers = await _authJsonHeaders();
      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/clientas/$id'),
            headers: headers,
            body: jsonEncode({
              'nombre': nombre,
              'telefono': telefono,
              'alergias': alergias,
              'preferencias': preferencias,
              'notas': notas,
            }),
          )
          .timeout(ApiConfig.connectionTimeout,
              onTimeout: () => throw Exception('Timeout en conexión'));

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      if (response.statusCode == 401) {
        await _handleUnauthorized();
        return {'success': false, 'statusCode': 401, 'error': 'Token inválido o expirado'};
      }
      final errorData = jsonDecode(response.body);
      return {
        'success': false,
        'statusCode': response.statusCode,
        'error': errorData['error'] ?? 'No se pudo actualizar la clienta',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> eliminarClienta(String id) async {
    try {
      final headers = await _authJsonHeaders();

      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}/clientas/$id'),
            headers: headers,
          )
          .timeout(
            ApiConfig.connectionTimeout,
            onTimeout: () => throw Exception('Timeout en conexión'),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      }

      if (response.statusCode == 401) {
        await _handleUnauthorized();
        return {
          'success': false,
          'statusCode': 401,
          'error': 'Token inválido o expirado',
        };
      }

      final errorData = jsonDecode(response.body);
      return {
        'success': false,
        'statusCode': response.statusCode,
        'error': errorData['error'] ?? 'No se pudo desactivar la clienta',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createClienta({
    required String nombre,
    required String telefono,
    String? alergias,
    String? preferencias,
    String? notas,
  }) async {
    try {
      final headers = await _authJsonHeaders();

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/clientas'),
            headers: headers,
            body: jsonEncode({
              'nombre': nombre,
              'telefono': telefono,
              'alergias': alergias,
              'preferencias': preferencias,
              'notas': notas,
            }),
          )
          .timeout(
            ApiConfig.connectionTimeout,
            onTimeout: () => throw Exception('Timeout en conexión'),
          );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      }

      if (response.statusCode == 401) {
        await _handleUnauthorized();
        return {
          'success': false,
          'statusCode': 401,
          'error': 'Token inválido o expirado',
        };
      }

      final errorData = jsonDecode(response.body);
      return {
        'success': false,
        'statusCode': response.statusCode,
        'error': errorData['error'] ?? 'No se pudo crear la clienta',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
