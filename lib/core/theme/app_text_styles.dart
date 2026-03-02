import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Estilos de tipografía oficiales de Viviana Beauty Room
///
/// Basados en:
/// - Playfair Display (títulos/marca) - debe estar en pubspec.yaml
/// - Poppins (cuerpo/UI) - debe estar en pubspec.yaml
class AppTextStyles {
  // Constructor privado para evitar instanciación
  AppTextStyles._();

  // ============================================
  // PLAYFAIR DISPLAY - Solo para marca y precios
  // ============================================

  /// Nombre de la app / marca
  /// Playfair Display Bold 28-32sp #D4748F
  static const TextStyle nombreApp = TextStyle(
    fontFamily: 'Playfair Display',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.rosa,
  );

  /// Precio en tarjeta de servicio
  /// Playfair Display Bold 20sp #D4748F
  static const TextStyle precio = TextStyle(
    fontFamily: 'Playfair Display',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.rosa,
  );

  // ============================================
  // POPPINS - Para toda la UI
  // ============================================

  /// Título de pantalla
  /// Poppins SemiBold 22-24sp #1A1A1A
  static const TextStyle tituloPantalla = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.negro,
  );

  /// Subtítulo / sección
  /// Poppins Medium 18-20sp #1A1A1A
  static const TextStyle subtitulo = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.negro,
  );

  /// Cuerpo de texto
  /// Poppins Regular 14-16sp #1A1A1A
  static const TextStyle cuerpo = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.negro,
  );

  /// Texto secundario
  /// Poppins Regular 12-14sp #666666
  static const TextStyle textoSecundario = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.grisOscuro,
  );

  /// Etiquetas / badges
  /// Poppins Medium 11-12sp (color variable según contexto)
  static const TextStyle etiqueta = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  /// Botón texto
  /// Poppins SemiBold 16sp
  static const TextStyle boton = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // ============================================
  // ESTILOS ESPECÍFICOS PARA COMPONENTES
  // ============================================

  /// Nombre de servicio en ServiceCard
  /// Poppins SemiBold 16sp #1A1A1A
  static const TextStyle nombreServicio = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.negro,
  );

  /// Duración de servicio
  /// Poppins Regular 12sp #666666
  static const TextStyle duracionServicio = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.grisOscuro,
  );

  /// Chip de filtro
  /// Poppins Medium 12sp
  static const TextStyle chip = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  /// Badge "Próximamente"
  /// Poppins SemiBold 11sp blanco
  static const TextStyle badgeProximamente = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
