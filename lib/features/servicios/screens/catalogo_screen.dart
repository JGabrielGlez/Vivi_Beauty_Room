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
  List<Servicio> _serviciosFiltrados = serviciosMock;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blancoRoto,

      // boton flotante + en esq inf derecha
      floatingActionButton: FabButton(onPressed: () => {print('Nueva Cita')}),

      bottomNavigationBar:
          AppBottomNavBar
          // TODO: falta agregar el método a onTap
          (currentIndex: 1, onTap: (index) {}),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 15, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titulo de la pantalla
                SectionTitle(titulo: 'Servicios'),
                const SizedBox(height: 16),

                // Barra de búsqueda
                SearchBarWidget(
                  hintText: 'Buscar servicio...',
                  onChanged: (texto) {
                    print(texto);
                  },
                ),

                FilterChipRow(
                  onCategoriaSeleccionada: (categoria) {
                    setState(() {
                      _categoriaActiva = categoria;

                      // Filtra la lsita según la cat seleccionada
                      _serviciosFiltrados = categoria == 'TODOS'
                          ? serviciosMock
                          : serviciosMock
                                .where(
                                  (s) => s.nombre.toUpperCase().contains(
                                    categoria,
                                  ),
                                )
                                .toList();
                    });
                  },
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      // Cuántos items tiene la cuadricula
                      itemCount: _serviciosFiltrados.length,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: .7,
                          ),

                      // Construye la tarjeta según el índice
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
