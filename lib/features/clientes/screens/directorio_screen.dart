import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivi_room/core/services/api_client.dart';
import 'package:vivi_room/features/clientes/models/clienta_model.dart';
import 'package:vivi_room/features/clientes/providers/clientas_provider.dart';
import 'package:vivi_room/features/clientes/widgets/nueva_clienta_modal.dart';
import '../../../../shared/widgets/cliente_avatar.dart';
import '../../../../shared/widgets/search_bar_widget.dart';
import '../../../../shared/widgets/fab_button.dart';

// Pantalla principal del directorio de clientas - Rocío
class DirectorioScreen extends StatelessWidget {
  const DirectorioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ClientasProvider>(
      create: (context) =>
          ClientasProvider(apiClient: context.read<ApiClient>())
            ..fetchClientas(),
      child: const _DirectorioScreenView(),
    );
  }
}

class _DirectorioScreenView extends StatefulWidget {
  const _DirectorioScreenView();

  @override
  State<_DirectorioScreenView> createState() => _DirectorioScreenViewState();
}

class _DirectorioScreenViewState extends State<_DirectorioScreenView> {
  final _searchController = TextEditingController();

  Future<void> _openNuevaClientaModal() async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NuevaClientaModal(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClientasProvider>();
    final filtered = provider.filteredClientas;
    final recientes = filtered.take(2).toList();
    final todas = filtered.skip(recientes.length).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F8),
      // Botón flotante para agregar una nueva clienta
      floatingActionButton: FabButton(onPressed: _openNuevaClientaModal),
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
                      onChanged: provider.setSearchQuery,
                    ),

                    const SizedBox(height: 16),

                    // Lista de clientas dividida por secciones
                    Expanded(child: _buildBody(provider, recientes, todas)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    ClientasProvider provider,
    List<Clienta> recientes,
    List<Clienta> todas,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final hasData = recientes.isNotEmpty || todas.isNotEmpty;

    if (!hasData) {
      final message = provider.searchQuery.trim().isNotEmpty
          ? 'No se encontraron clientas con ese filtro'
          : 'Aun no hay clientas registradas';

      return Center(
        child: Text(
          message,
          style: const TextStyle(color: Color(0xFF888888), fontSize: 14),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchClientas(),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (provider.errorMessage != null) ...[
            Text(
              provider.errorMessage!,
              style: const TextStyle(
                color: Color(0xFFD4748F),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (recientes.isNotEmpty) ...[
            const _SectionLabel('RECIENTES'),
            const SizedBox(height: 8),
            ...recientes.map(
              (clienta) => _ClienteRow(
                nombre: clienta.nombre,
                info: _clientaInfo(clienta),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (todas.isNotEmpty) ...[
            const _SectionLabel('TODAS'),
            const SizedBox(height: 8),
            ...todas.map(
              (clienta) => _ClienteRow(
                nombre: clienta.nombre,
                info: _clientaInfo(clienta),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  String _clientaInfo(Clienta clienta) {
    if (clienta.ultimaVisita == null || clienta.ultimaVisita!.isEmpty) {
      return 'Sin citas completadas';
    }
    return 'Ultima visita: ${clienta.ultimaVisita}';
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
