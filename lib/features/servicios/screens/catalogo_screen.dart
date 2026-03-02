import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/servicio.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/widgets/filter_chip_row.dart';
import '../../../shared/widgets/search_bar_widget.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/fab_button.dart';
import '../../../shared/widgets/service_card.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  String _categoriaActiva = 'TODOS';
  String _textoBusqueda = '';
  List<Servicio> _serviciosFiltrados = serviciosMock;

  bool _coincideCategoria(Servicio servicio, String categoria) {
    switch (categoria) {
      case 'PESTAÑAS':
        return servicio.nombre.toUpperCase().contains('PESTA');
      case 'CEJAS':
        return servicio.nombre.toUpperCase().contains('CEJA');
      case 'MAQUILLAJE':
        return servicio.nombre.toUpperCase().contains('MAQUILL');
      case 'COMBOS':
        return servicio.esCombo;
      case 'TODOS':
      default:
        return true;
    }
  }

  void _aplicarFiltros() {
    final query = _textoBusqueda.trim().toLowerCase();

    setState(() {
      _serviciosFiltrados = serviciosMock.where((servicio) {
        final coincideCategoria = _coincideCategoria(
          servicio,
          _categoriaActiva,
        );

        if (query.isEmpty) {
          return coincideCategoria;
        }

        final coincideTexto =
            servicio.nombre.toLowerCase().contains(query) ||
            servicio.descripcion.toLowerCase().contains(query);

        return coincideCategoria && coincideTexto;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blancoRoto,

      // boton flotante + en esq inf derecha
      floatingActionButton: FabButton(onPressed: () => print('Nueva Cita')),

      bottomNavigationBar:
          AppBottomNavBar
          // TODO: falta agregar el método a onTap
          (currentIndex: 1, onTap: (index) {}),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(titulo: 'Servicios'),
              const SizedBox(height: 12),
              SearchBarWidget(
                hintText: 'Buscar servicio...',
                onChanged: (texto) {
                  _textoBusqueda = texto;
                  _aplicarFiltros();
                },
              ),
              const SizedBox(height: 12),
              FilterChipRow(
                onCategoriaSeleccionada: (categoria) {
                  _categoriaActiva = categoria;
                  _aplicarFiltros();
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  itemCount: _serviciosFiltrados.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: .7,
                  ),
                  itemBuilder: (context, index) {
                    final servicio = _serviciosFiltrados[index];

                    return ServiceCard(
                      servicio: servicio,
                      onAgendar: servicio.proximamente
                          ? null
                          : () {
                              print('Agendar: ${servicio.nombre}');
                            },
                      onEditar: () {
                        print('Editar: ${servicio.nombre}');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
