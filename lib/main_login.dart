import 'package:flutter/material.dart';
import 'features/auth/screens/login_screen.dart';

// Archivo de entrada para correr solo la pantalla de login
// Comando: flutter run -t lib/main_login.dart
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginScreen(),
  ));
} 
