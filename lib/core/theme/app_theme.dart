import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Tema principal de la aplicación Viviana Beauty Room
///
/// Define el ThemeData usado en MaterialApp con los colores y
/// estilos de tipografía oficiales del proyecto.
class AppTheme {
  // Constructor privado para evitar instanciación
  AppTheme._();

  /// Tema principal de la aplicación
  static ThemeData get lightTheme {
    return ThemeData(
      // Esquema de colores base
      useMaterial3: true,
      primaryColor: AppColors.rosa,
      scaffoldBackgroundColor: AppColors.blancoRoto,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.rosa,
        secondary: AppColors.rosaClaro,
        surface: AppColors.blanco,
        error: Colors.red.shade400,
        onPrimary: Colors.white,
        onSecondary: AppColors.negro,
        onSurface: AppColors.negro,
        onError: Colors.white,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.rosa,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Texto
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.nombreApp,
        headlineLarge: AppTextStyles.tituloPantalla,
        headlineMedium: AppTextStyles.subtitulo,
        bodyLarge: AppTextStyles.cuerpo,
        bodyMedium: AppTextStyles.textoSecundario,
        labelLarge: AppTextStyles.boton,
      ),

      // Tarjetas
      cardTheme: CardThemeData(
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Botones elevados (PrimaryButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rosa,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.boton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),

      // Botones outlined (SecondaryButton)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.rosa,
          side: const BorderSide(color: AppColors.rosa, width: 1.5),
          textStyle: AppTextStyles.boton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),

      // Input Decoration (TextFields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.blanco,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grisClaro),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grisClaro),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.rosa, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        labelStyle: AppTextStyles.textoSecundario,
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: AppColors.grisClaro,
        ),
        errorStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color: Colors.red.shade400,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Dividers
      dividerTheme: const DividerThemeData(
        color: AppColors.grisClaro,
        thickness: 1,
        space: 1,
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: AppColors.rosa,
        disabledColor: AppColors.grisClaro,
        labelStyle: AppTextStyles.chip,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.rosa,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.blanco,
        selectedItemColor: AppColors.rosa,
        unselectedItemColor: AppColors.grisOscuro,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
