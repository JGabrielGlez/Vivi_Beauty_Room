import 'package:flutter/material.dart';
import 'package:vivi_room/shared/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../shared/models/servicio.dart';

class ServiceCard extends StatelessWidget {
  // Este es el model de datos que se creó
  final Servicio servicio;

  // funciones dentro de este widget
  // como no retornarán nada serán VoidCallback

  final VoidCallback? onAgendar;
  final VoidCallback? onEditar;

  // onAgendar y editar se agregarán después
  // Constructor
  const ServiceCard({
    super.key,
    required this.servicio,
    this.onAgendar,
    this.onEditar,
  });

  // Esto es lo que pinta el widget
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Foto(proximamente: servicio.proximamente),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre del servicio
                Text(servicio.nombre, style: AppTextStyles.subtitulo),

                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '\$${servicio.precio.toStringAsFixed(0)}',
                      style: AppTextStyles.precio,
                    ),

                    const Spacer(),

                    Text(
                      '${servicio.duracionMin} min',
                      style: AppTextStyles.textoSecundario,
                    ),
                    const SizedBox(height: 12),

                    // botones
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Foto extends StatelessWidget {
  final bool proximamente;

  const _Foto({required this.proximamente});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: proximamente
            ? AppColors.grisClaro.withOpacity(.3)
            : AppColors.rosaClaro.withOpacity(.3),

        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Center(
        child: Icon(Icons.image_outlined, color: AppColors.grisClaro, size: 40),
      ),
    );
  }
}

class _BadgeProximamente extends StatelessWidget {
  const _BadgeProximamente();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.grisClaro.withOpacity(.4),
        borderRadius: BorderRadius.circular(8),
      ),

      child: Text('Proximamente', style: AppTextStyles.etiqueta),
    );
  }
}

// boton que aparece cuando el servicio está activo
class _BotonAgendar extends StatelessWidget {
  // Solo recibe el método que debe de usar
  final VoidCallback? onTap;
  const _BotonAgendar({this.onTap});

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: 'Agendar',
      onPressed: onTap,
      enabled: onTap != null, //si onTap es nulo, retorna falso
    );
  }
}
