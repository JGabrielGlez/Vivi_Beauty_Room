import 'package:flutter/material.dart';
import 'package:vivi_room/shared/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../shared/models/servicio.dart';

class ServiceCard extends StatelessWidget {
  final Servicio servicio;
  final VoidCallback? onAgendar;
  final VoidCallback? onEditar;

  const ServiceCard({
    super.key,
    required this.servicio,
    this.onAgendar,
    this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagen izquierda
          _Foto(proximamente: servicio.proximamente),

          // Contenido derecho
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    servicio.nombre,
                    style: AppTextStyles.subtitulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Text(
                        '\$${servicio.precio.toStringAsFixed(0)}',
                        style: AppTextStyles.precio,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${servicio.duracionMin} min',
                        style: AppTextStyles.textoSecundario,
                      ),
                    ],
                  ),

                  const Spacer(),

                  if (servicio.proximamente)
                    const _BadgeProximamente()
                  else
                    Row(
                      children: [
                        Flexible(child: _BotonAgendar(onTap: onAgendar)),
                        if (onEditar != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            iconSize: 30,
                            onPressed: onEditar,
                            icon: const Icon(Icons.edit_outlined),
                            color: AppColors.rosa,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            style: IconButton.styleFrom(
                              side: BorderSide(color: AppColors.rosa, width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
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
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
      child: Container(
        width: 110,
        color: proximamente
            ? AppColors.grisClaro.withOpacity(.3)
            : AppColors.rosaClaro.withOpacity(.3),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            color: AppColors.grisClaro,
            size: 36,
          ),
        ),
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

class _BotonAgendar extends StatelessWidget {
  final VoidCallback? onTap;
  const _BotonAgendar({this.onTap});

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: 'Agendar',
      onPressed: onTap,
      enabled: onTap != null,
    );
  }
}
