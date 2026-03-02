import 'package:flutter/material.dart';

/// Paleta de colores oficial de Viviana Beauty Room
///
/// Basada en la identidad visual definida en las instrucciones del proyecto.
/// Los colores deben usarse de forma consistente en toda la aplicación.
class AppColors {
  // Constructor privado para evitar instanciación
  AppColors._();

  /// Color rosa principal - Acento, CTAs, íconos activos
  /// Uso: botones primarios, AppBar, elementos interactivos destacados
  static const Color rosa = Color(0xFFD4748F);

  /// Color rosa claro - Fondos de sección, hover
  /// Uso: fondos suaves, estados hover, highlights
  static const Color rosaClaro = Color(0xFFE8A0B4);

  /// Color blanco roto - Fondo principal de pantallas
  /// Uso: background de Scaffold, áreas principales
  static const Color blancoRoto = Color(0xFFFAF8F8);

  /// Color blanco puro - Tarjetas, modales, superficies
  /// Uso: Cards, BottomSheets, Dialogs
  static const Color blanco = Color(0xFFFFFFFF);

  /// Color negro - Tipografía principal
  /// Uso: títulos, texto principal, elementos de alta jerarquía
  static const Color negro = Color(0xFF1A1A1A);

  /// Color gris oscuro - Texto secundario, etiquetas
  /// Uso: subtítulos, descripciones, texto de apoyo
  static const Color grisOscuro = Color(0xFF666666);

  /// Color gris claro - Separadores, bordes, deshabilitados
  /// Uso: dividers, borders, elementos disabled
  static const Color grisClaro = Color(0xFFCCCCCC);
}
