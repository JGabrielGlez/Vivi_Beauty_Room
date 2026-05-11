# Guía de implementación del token de autenticación

## Flujo general

```
[Login screen]
     │ email + password
     ▼
POST /api/auth/login
     │ { token }
     ▼
TokenStorageService.saveToken()   ← flutter_secure_storage (cifrado)
     │
     ▼
[Cualquier pantalla autenticada]
     │ _authJsonHeaders() → lee token automáticamente
     ▼
GET/POST/PUT/DELETE /api/...
  Authorization: Bearer <token>
     │
     ├─ 200 → datos
     └─ 401 → clearAll() → callback → /login
```

El token se almacena en `flutter_secure_storage` (Keychain en iOS, Keystore en Android). Nunca queda en texto plano.

Si el token expira o es inválido, el backend responde 401 y la app redirige automáticamente al login.

---

## Para desarrolladores de Backend

### Proteger un router completo
```js
const authMiddleware = require('../middleware/auth');

// Al inicio del archivo de rutas, antes de definir los endpoints:
router.use(authMiddleware);

router.get('/', (req, res) => { ... });
router.post('/', (req, res) => { ... });
```

### Proteger una ruta individual
```js
router.get('/ruta', authMiddleware, (req, res) => { ... });
```

### Rutas solo para ADMIN
```js
const soloAdmin = require('../middleware/soloAdmin');

router.put('/config', authMiddleware, soloAdmin, (req, res) => { ... });
```

### Acceder al usuario autenticado dentro del handler
```js
router.get('/mi-ruta', authMiddleware, (req, res) => {
  const uid = req.user.uid; // disponible tras pasar el middleware
  // ...
});
```

---

## Para desarrolladores de Flutter

### Regla: nunca usar `http` directamente — agregar el método al `ApiClient`

**Archivo:** `lib/core/services/api_client.dart`

#### Plantilla para un método nuevo
```dart
Future<Map<String, dynamic>> miNuevoMetodo() async {
  try {
    final headers = await _authJsonHeaders(); // inyecta el token automáticamente

    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/mi-ruta'),
          headers: headers,
        )
        .timeout(
          ApiConfig.receiveTimeout,
          onTimeout: () => throw Exception('Timeout en conexión'),
        );

    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    }

    if (response.statusCode == 401) {
      await _handleUnauthorized(); // limpia token y redirige a login
      return {'success': false, 'statusCode': 401, 'error': 'Token inválido o expirado'};
    }

    final errorData = jsonDecode(response.body);
    return {
      'success': false,
      'statusCode': response.statusCode,
      'error': errorData['error'] ?? 'Error desconocido',
    };
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}
```

#### Métodos HTTP disponibles
```dart
// GET
final response = await http.get(uri, headers: headers);

// POST con body
final response = await http.post(uri, headers: headers, body: jsonEncode({...}));

// PUT con body
final response = await http.put(uri, headers: headers, body: jsonEncode({...}));

// PATCH con body
final response = await http.patch(uri, headers: headers, body: jsonEncode({...}));

// DELETE
final response = await http.delete(uri, headers: headers);
```

#### Usar el ApiClient en una pantalla
```dart
// En un StatefulWidget o StatelessWidget:
final apiClient = context.read<ApiClient>();
final result = await apiClient.miNuevoMetodo();

if (result['success'] == true) {
  final data = result['data'];
  // ...
} else {
  final error = result['error'];
  // mostrar error al usuario
}
```

#### Usar el ApiClient en un Provider
```dart
class MiProvider extends ChangeNotifier {
  MiProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<void> cargarDatos() async {
    final result = await _apiClient.miNuevoMetodo();
    // ...
  }
}
```

---

## Lo que NO se debe hacer

```dart
// ❌ Nunca hacer llamadas HTTP directas sin el token
http.get(Uri.parse('http://...'));

// ❌ Nunca leer el token manualmente fuera del ApiClient
final token = await tokenStorage.readToken();
final headers = {'Authorization': 'Bearer $token'};

// ❌ Nunca ignorar el código 401
if (response.statusCode == 200) { ... }
// (sin manejar 401 → el usuario queda atrapado con token expirado)
```

---

## Resumen rápido

| Rol        | Qué hacer                                                                 |
|------------|---------------------------------------------------------------------------|
| Backend    | `router.use(require('../middleware/auth'))` al inicio del router           |
| Flutter    | Método nuevo en `ApiClient` usando `_authJsonHeaders()` y `_handleUnauthorized()` |
| Flutter    | Obtener `ApiClient` via `context.read<ApiClient>()` o inyección en constructor |
