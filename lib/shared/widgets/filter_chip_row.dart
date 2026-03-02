import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

// Las categorías disponibles — si en el futuro agregan una nueva,
// solo se agrega aquí y el widget lo muestra automáticamente
const List<String> _categorias = [
  'TODOS',
  'PESTAÑAS',
  'CEJAS',
  'MAQUILLAJE',
  'COMBOS',
];

class FilterChipRow extends StatefulWidget {
  // onCategoriaSeleccionada: función que el padre recibe cuando
  // la usuaria cambia el filtro. Así CatalogoScreen puede reaccionar.
  final void Function(String categoria) onCategoriaSeleccionada;

  const FilterChipRow({super.key, required this.onCategoriaSeleccionada});

  @override
  State<FilterChipRow> createState() => _FilterChipRowState();
}

class _FilterChipRowState extends State<FilterChipRow> {
  // Empieza con 'TODOS' seleccionado por defecto
  String _categoriaActiva = 'TODOS';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      // SingleChildScrollView permite que la fila se desplace
      // horizontalmente si los chips no caben en pantalla
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categorias.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final categoria = _categorias[index];
          final estaActivo = categoria == _categoriaActiva;

          return GestureDetector(
            onTap: () {
              // setState le dice a Flutter: "algo cambió, vuelve a dibujar"
              setState(() {
                _categoriaActiva = categoria;
              });
              // Notifica al padre cuál categoría se seleccionó
              widget.onCategoriaSeleccionada(categoria);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                // Si está activo: fondo rosa. Si no: transparente con borde
                color: estaActivo ? AppColors.rosa : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: estaActivo ? AppColors.rosa : AppColors.grisClaro,
                ),
              ),
              child: Text(
                categoria,
                style: AppTextStyles.etiqueta.copyWith(
                  color: estaActivo ? Colors.white : AppColors.negro,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
