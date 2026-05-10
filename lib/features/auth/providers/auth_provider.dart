import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:vivi_room/core/services/api_client.dart';
import 'package:vivi_room/core/services/token_storage_service.dart';
import 'package:vivi_room/shared/models/usuario_model.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final TokenStorageService _tokenStorage;

  AuthState _state = AuthState.initial;
  Usuario? _usuario;
  String? _token;
  String? _errorMessage;

  AuthProvider({
    required ApiClient apiClient,
    required TokenStorageService tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  // Getters
  AuthState get state => _state;
  Usuario? get usuario => _usuario;
  String? get token => _token;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  /// Restaurar sesión al iniciar app
  Future<void> restoreSession() async {
    _state = AuthState.initial;
    notifyListeners();

    try {
      final token = await _tokenStorage.readToken();
      if (token != null) {
        _token = token;

        // Validar token con backend
        final meResult = await _apiClient.getMe();
        if (meResult['success']) {
          final usuarioData = meResult['data']['usuario'];
          _usuario = Usuario.fromJson(usuarioData);
          _state = AuthState.authenticated;
          _errorMessage = null;
        } else {
          // Token inválido o expirado
          await _tokenStorage.clearAll();
          _token = null;
          _usuario = null;
          _state = AuthState.unauthenticated;
          _errorMessage = meResult['error'];
        }
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      _state = AuthState.unauthenticated;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  /// Iniciar sesión con email y contraseña
  Future<bool> signIn(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiClient.login(email: email, password: password);

      if (result['success']) {
        final data = result['data'];
        _token = data['token'];
        _usuario = Usuario.fromJson(data['usuario']);

        // Guardar token
        await _tokenStorage.saveToken(_token!);
        await _tokenStorage.saveUser(jsonEncode(_usuario!.toJson()));

        _state = AuthState.authenticated;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _state = AuthState.error;
        _errorMessage = result['error'] ?? 'Error en autenticación';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    await _tokenStorage.clearAll();
    _token = null;
    _usuario = null;
    _state = AuthState.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpiar error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
