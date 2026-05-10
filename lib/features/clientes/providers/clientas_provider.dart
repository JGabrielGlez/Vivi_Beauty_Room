import 'package:flutter/material.dart';
import 'package:vivi_room/core/services/api_client.dart';
import 'package:vivi_room/features/clientes/models/clienta_model.dart';

class ClientasProvider extends ChangeNotifier {
  ClientasProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String _searchQuery = '';
  List<Clienta> _clientas = <Clienta>[];

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  List<Clienta> get clientas => _clientas;

  List<Clienta> get filteredClientas {
    if (_searchQuery.trim().isEmpty) return _clientas;

    final normalized = _searchQuery.trim().toLowerCase();
    return _clientas.where((clienta) {
      return clienta.nombre.toLowerCase().contains(normalized) ||
          clienta.telefono.toLowerCase().contains(normalized);
    }).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  Future<void> fetchClientas({String? query}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiClient.getClientas(query: query);
    if (result['success'] == true) {
      final rawList = (result['data'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .toList();
      _clientas = rawList.map(Clienta.fromJson).toList();
    } else {
      _errorMessage = result['statusCode'] == 401
          ? null
          : (result['error'] ?? 'No se pudieron cargar las clientas');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createClienta({
    required String nombre,
    required String telefono,
    String? alergias,
    String? preferencias,
    String? notas,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiClient.createClienta(
      nombre: nombre,
      telefono: telefono,
      alergias: alergias,
      preferencias: preferencias,
      notas: notas,
    );

    if (result['success'] == true) {
      await fetchClientas();
      _isSaving = false;
      notifyListeners();
      return true;
    }

    _isSaving = false;
    _errorMessage = result['statusCode'] == 401
        ? null
        : (result['error'] ?? 'No se pudo crear la clienta');
    notifyListeners();
    return false;
  }
}
