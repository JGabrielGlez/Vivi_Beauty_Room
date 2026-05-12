import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:vivi_room/core/services/api_client.dart';
import 'package:vivi_room/core/services/token_storage_service.dart';
import 'package:vivi_room/features/auth/providers/auth_provider.dart';

import 'auth_provider_test.mocks.dart';

@GenerateMocks([ApiClient, TokenStorageService])
void main() {
  late MockApiClient mockApiClient;
  late MockTokenStorageService mockTokenStorage;
  late AuthProvider authProvider;

  setUp(() {
    mockApiClient   = MockApiClient();
    mockTokenStorage = MockTokenStorageService();
    authProvider = AuthProvider(
      apiClient: mockApiClient,
      tokenStorage: mockTokenStorage,
    );
  });

  // ─── restoreSession ──────────────────────────────────────────────────────
  group('restoreSession', () {
    test('sin token guardado → estado unauthenticated', () async {
      when(mockTokenStorage.readToken()).thenAnswer((_) async => null);

      await authProvider.restoreSession();

      expect(authProvider.state, AuthState.unauthenticated);
      expect(authProvider.usuario, isNull);
      expect(authProvider.token, isNull);
    });

    test('con token válido y backend responde OK → estado authenticated', () async {
      when(mockTokenStorage.readToken()).thenAnswer((_) async => 'jwt-valido');
      when(mockApiClient.getMe()).thenAnswer((_) async => {
        'success': true,
        'data': {
          'idUsuario': '1',
          'nombre': 'Viviana',
          'email': 'v@test.com',
          'rol': 'ADMIN',
        },
      });

      await authProvider.restoreSession();

      expect(authProvider.state, AuthState.authenticated);
      expect(authProvider.usuario?.nombre, 'Viviana');
      expect(authProvider.token, 'jwt-valido');
    });

    test('token expirado (backend 401) → clearAll llamado y estado unauthenticated', () async {
      when(mockTokenStorage.readToken()).thenAnswer((_) async => 'token-expirado');
      when(mockTokenStorage.clearAll()).thenAnswer((_) async {});
      when(mockApiClient.getMe()).thenAnswer((_) async => {
        'success': false,
        'statusCode': 401,
        'error': 'Token inválido o expirado',
      });

      await authProvider.restoreSession();

      expect(authProvider.state, AuthState.unauthenticated);
      expect(authProvider.errorMessage, isNull);
      verify(mockTokenStorage.clearAll()).called(1);
    });
  });

  // ─── signIn ──────────────────────────────────────────────────────────────
  group('signIn', () {
    test('credenciales válidas → retorna true, estado authenticated, token guardado', () async {
      when(mockApiClient.login(email: 'v@test.com', password: '123456'))
          .thenAnswer((_) async => {
                'success': true,
                'data': {
                  'token': 'jwt-token',
                  'usuario': {
                    'idUsuario': '1',
                    'nombre': 'Viviana',
                    'email': 'v@test.com',
                    'rol': 'ADMIN',
                  },
                },
              });
      when(mockTokenStorage.saveToken(any)).thenAnswer((_) async {});
      when(mockTokenStorage.saveUser(any)).thenAnswer((_) async {});

      final result = await authProvider.signIn('v@test.com', '123456');

      expect(result, true);
      expect(authProvider.state, AuthState.authenticated);
      expect(authProvider.token, 'jwt-token');
      expect(authProvider.usuario?.nombre, 'Viviana');
      verify(mockTokenStorage.saveToken('jwt-token')).called(1);
    });

    test('credenciales incorrectas → retorna false, estado error, errorMessage establecido', () async {
      when(mockApiClient.login(email: 'x@test.com', password: 'wrong'))
          .thenAnswer((_) async => {
                'success': false,
                'error': 'Credenciales incorrectas',
              });

      final result = await authProvider.signIn('x@test.com', 'wrong');

      expect(result, false);
      expect(authProvider.state, AuthState.error);
      expect(authProvider.errorMessage, 'Credenciales incorrectas');
    });

    test('excepción en la API → retorna false, mensaje de servicio no disponible', () async {
      when(mockApiClient.login(email: anyNamed('email'), password: anyNamed('password')))
          .thenThrow(Exception('Connection refused'));

      final result = await authProvider.signIn('v@test.com', '123456');

      expect(result, false);
      expect(authProvider.state, AuthState.error);
      expect(authProvider.errorMessage, 'Servicio no disponible. Inténtalo más tarde.');
    });
  });

  // ─── signOut ─────────────────────────────────────────────────────────────
  group('signOut', () {
    test('limpia token, usuario y pasa a estado unauthenticated', () async {
      when(mockTokenStorage.clearAll()).thenAnswer((_) async {});

      await authProvider.signOut();

      expect(authProvider.state, AuthState.unauthenticated);
      expect(authProvider.usuario, isNull);
      expect(authProvider.token, isNull);
      expect(authProvider.errorMessage, isNull);
      verify(mockTokenStorage.clearAll()).called(1);
    });
  });
}
