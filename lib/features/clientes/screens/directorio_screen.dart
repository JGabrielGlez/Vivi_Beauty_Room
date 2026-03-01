 import 'package:flutter/material.dart';

// Pantalla de directorio de clientas - Rocío
// Widgets de búsqueda y navegación son temporales, se reemplazarán por los de José Luis
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
      body: Column(
        children: [
          // Header rosado con título y botón de agregar
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
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Contenido principal
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -32),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barra de búsqueda
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
                      decoration: InputDecoration(
                        hintText: 'Buscar clienta...',
                        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF888888)),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF888888), size: 20),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFCCCCCC), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD4748F), width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Lista de clientas
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          // Sección de clientas recientes
                          const _SectionLabel('RECIENTES'),
                          const SizedBox(height: 8),
                          const _ClienteRow(nombre: 'Sofía Ramírez', info: '14 ene · Pestañas clásicas'),
                          const _ClienteRow(nombre: 'Mariana Lopez', info: '2 feb · Maquillaje social'),

                          const SizedBox(height: 16),

                          // Sección con todas las clientas
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
          const _BottomNavBar(),
        ],
      ),
    );
  }
}

// ─── WIDGETS TEMPORALES ───────────────────────────────────────────────────────
// Estos se van a reemplazar por los que haga José Luis en shared/widgets

// Etiqueta de sección en mayúsculas
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

// Tarjeta de cada clienta con avatar, nombre y última cita
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
          // Avatar con inicial del nombre
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE8A0B4),
            ),
            alignment: Alignment.center,
            child: Text(
              nombre[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Nombre y última cita
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

// Barra de navegación inferior con 4 tabs
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    const tabs = [
      {'label': 'Agenda', 'icon': Icons.calendar_today_outlined, 'active': false},
      {'label': 'Servicios', 'icon': Icons.star_outline, 'active': false},
      {'label': 'Clientes', 'icon': Icons.people_outline, 'active': true},
      {'label': 'Más', 'icon': Icons.menu, 'active': false},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFCCCCCC), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: tabs.map((tab) {
            final isActive = tab['active'] as bool;
            final color = isActive ? const Color(0xFFD4748F) : const Color(0xFFAAAAAA);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tab['icon'] as IconData, color: color, size: 24),
                    const SizedBox(height: 3),
                    Text(
                      tab['label'] as String,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: color),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
