import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../../shared/widgets/cliente_avatar.dart';
import '../../../../shared/widgets/search_bar_widget.dart';
import '../../../../shared/widgets/fab_button.dart';

// Pantalla principal del directorio de clientas - Rocío
class DirectorioScreen extends StatefulWidget {
  const DirectorioScreen({super.key});

  @override
  State<DirectorioScreen> createState() => _DirectorioScreenState();
}

class _DirectorioScreenState extends State<DirectorioScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F8),
      // Botón flotante para agregar una nueva clienta
      floatingActionButton: FabButton(
        onPressed: () {},
      ),
      body: Column(
        children: [
          // Encabezado rosado con el título de la pantalla
          Container(
            color: const Color(0xFFE8A0B4),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mis clientas',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Contenido principal de la pantalla
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -32),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Buscador de clientas
                    SearchBarWidget(
                      controller: _searchController,
                      hintText: 'Buscar clienta...',
                    ),

                    const SizedBox(height: 16),

                    // Lista de clientas dividida por secciones
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          // Clientas vistas recientemente
                          const _SectionLabel('RECIENTES'),
                          const SizedBox(height: 8),
                          const _ClienteRow(nombre: 'Sofía Ramírez', info: '14 ene · Pestañas clásicas'),
                          const _ClienteRow(nombre: 'Mariana Lopez', info: '2 feb · Maquillaje social'),

                          const SizedBox(height: 16),

                          // Todas las clientas registradas
                          const _SectionLabel('TODAS'),
                          const SizedBox(height: 8),
                          const _ClienteRow(nombre: 'Daniela Morales', info: '8 ene · Laminado de cejas'),
                          const _ClienteRow(nombre: 'Janeth Lopez', info: '2 feb · Maquillaje social'),
                          const _ClienteRow(nombre: 'Sofía Ramírez', info: '14 ene · Pestañas clásicas'),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Barra de navegación inferior
          AppBottomNavBar(
            currentIndex: 1,
            onTap: (index) {},
          ),
        ],
      ),
    );
  }
}

// ─── WIDGETS PROPIOS DE ESTA PANTALLA ────────────────────────────────────────

// Etiqueta que separa las secciones de la lista
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFF888888),
        letterSpacing: 1.2,
      ),
    );
  }
}

// Tarjeta individual de cada clienta con avatar, nombre y última cita
class _ClienteRow extends StatelessWidget {
  const _ClienteRow({required this.nombre, required this.info});
  final String nombre;
  final String info;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Círculo con la inicial del nombre de la clienta
          ClienteAvatar(nombre: nombre),
          const SizedBox(width: 12),
          // Nombre y detalle de su última cita
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  info,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC), size: 20),
        ],
      ),
    );
  }
}