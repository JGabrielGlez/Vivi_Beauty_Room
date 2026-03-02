import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SectionTitle extends StatelessWidget {
  // Lo que recibe desde fuera es el texto a mostrar
  final String titulo;

  // Constructor, como siempre se renderiza, ocupa tener un id, que es la key, posteriormente, siempre pedir lo que es el titulo a mostrar
  const SectionTitle({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Text(titulo, style: AppTextStyles.tituloPantalla);
  }
}
