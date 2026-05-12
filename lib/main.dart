import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'core/services/token_storage_service.dart';
import 'core/services/api_client.dart';
import 'core/services/firebase_options.dart';
import 'features/auth/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializar servicios
  final tokenStorage = TokenStorageService();
  final apiClient = ApiClient(tokenStorage: tokenStorage);

  // Crear AuthProvider y restaurar sesión
  final authProvider = AuthProvider(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );

  // Cualquier 401 en endpoints protegidos fuerza cierre de sesión inmediato.
  apiClient.onUnauthorized = authProvider.forceUnauthorizedLogout;

  runApp(
    MultiProvider(
      providers: [
        Provider<TokenStorageService>.value(value: tokenStorage),
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: App(authProvider: authProvider),
    ),
  );
}
