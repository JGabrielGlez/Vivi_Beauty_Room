import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/services/token_storage_service.dart';
import 'core/services/api_client.dart';
import 'features/auth/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar servicios
  final tokenStorage = TokenStorageService();
  final apiClient = ApiClient(tokenStorage: tokenStorage);

  // Crear AuthProvider y restaurar sesión
  final authProvider = AuthProvider(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );
  await authProvider.restoreSession();

  runApp(
    MultiProvider(
      providers: [
        Provider<TokenStorageService>.value(value: tokenStorage),
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: const App(),
    ),
  );
}
