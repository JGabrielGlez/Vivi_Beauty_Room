# Viviana Beauty Room — Correr Pantallas de Forma Aislada

Durante este sprint cada pantalla se desarrolla **sin estar conectada a las demás**. Flutter no tiene un modo aislado nativo, pero se puede lograr fácilmente con archivos de entrada separados.

---

## Por qué no tocar `main.dart`

Si todos modifican `main.dart` para apuntar a su pantalla y lo suben a GitHub, ese archivo generará conflictos constantemente. La solución es que cada integrante tenga su propio archivo de entrada y **`main.dart` nunca se toque durante el sprint visual**.

---

## Estructura de Archivos de Entrada

Crear estos archivos en la raíz de `lib/`. Uno por pantalla, cada quien solo toca el suyo:

```
lib/
├── main.dart                ← NO SE TOCA durante el sprint
├── main_login.dart          ← Rocío
├── main_agenda.dart         ← José Luis
├── main_nueva_cita.dart     ← Miguel
├── main_catalogo.dart       ← Gabriel
└── main_directorio.dart     ← Rocío
```

---

## Contenido de Cada Archivo de Entrada

Todos tienen la misma estructura. Solo cambia el `import` y el widget en `home`:

### `main_login.dart` (Rocío)
```dart
import 'package:flutter/material.dart';
import 'features/auth/screens/login_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    ),
  );
}
```

### `main_catalogo.dart` (Gabriel)
```dart
import 'package:flutter/material.dart';
import 'features/servicios/screens/catalogo_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CatalogoScreen(),
    ),
  );
}
```

*(El patrón es idéntico para `main_agenda.dart` y `main_directorio.dart`, cambiando el import y el widget.)*

---

## Cómo Correrlo desde Terminal

En lugar de `flutter run` normal, se usa la bandera `-t` para indicar el archivo de entrada:

```bash
flutter run -t lib/main_login.dart
flutter run -t lib/main_agenda.dart
flutter run -t lib/main_nueva_cita.dart
flutter run -t lib/main_catalogo.dart
flutter run -t lib/main_directorio.dart
```

Si tienes varios dispositivos o emuladores conectados, agrega `-d emulator-5554` (o el ID de tu dispositivo).

---

## Caso Especial: Modal de Nueva Cita (Miguel)

El modal **no es una pantalla completa**, es un widget que se despliega sobre otra. Para verlo aislado, Miguel necesita envolverlo en un `Scaffold` con un botón que lo abra:

```dart
import 'package:flutter/material.dart';
import 'features/citas/widgets/nueva_cita_modal.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: _ModalPreview(),
  ));
}

class _ModalPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF8F8),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFD4748F),
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,  // Permite que el modal ocupe la altura que necesite sin quedar cortado
              builder: (_) => NuevaCitaModal(),
            );
          },
          child: Text('Abrir modal'),
        ),
      ),
    );
  }
}
```

---

## Qué Agregar al `.gitignore`

Los archivos `main_*.dart` son temporales del sprint visual. Para que no contaminen el historial de Git una vez que se integre todo, agregarlos al `.gitignore` al **cerrar el sprint**:

```gitignore
# Archivos de preview aislado (borrar al integrar)
lib/main_login.dart
lib/main_agenda.dart
lib/main_nueva_cita.dart
lib/main_catalogo.dart
lib/main_directorio.dart
```
