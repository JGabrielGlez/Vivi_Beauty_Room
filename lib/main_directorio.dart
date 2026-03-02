 import 'package:flutter/material.dart';
import 'features/clientes/screens/directorio_screen.dart';

// Archivo de entrada para correr solo la pantalla de directorio
// Comando: flutter run -t lib/main_directorio.dart
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DirectorioScreen(),
  ));
}
