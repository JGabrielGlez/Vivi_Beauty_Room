import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vivi_room/features/citas/widgets/nueva_cita_modal.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/servicio.dart';
import '../../../shared/widgets/filter_chip_row.dart';
import '../../../shared/widgets/search_bar_widget.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/fab_button.dart';
import '../../../shared/widgets/service_card.dart';
import '../widgets/nuevo_servicio_modal.dart';

const String _baseUrl = 'http://localhost:3000';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  String _categoriaActiva = 'TODOS';
  String _textoBusqueda = '';

  // Lista completa: activos + inactivos
  List<Servicio> _todosLosServicios = [];

  // Lista filtrada que se muestra en pantalla
  List<Servicio> _serviciosFiltrados = [];

  bool _cargando = true;
  String? _errorServicios;

  @override
  void initState() {
    super.initState();
    _cargarServicios();
  }

  // Carga activos e inactivos en paralelo y los combina
  Future<void> _cargarServicios() async {
    setState(() {
      _cargando = true;
      _errorServicios = null;
    });

    try {
      // Hacemos las dos peticiones al mismo tiempo
      final responses = await Future.wait([
        http.get(Uri.parse('$_baseUrl/api/servicios')),
        http.get(Uri.parse('$_baseUrl/api/servicios/inactivos')),
      ]);

      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        final activos = (jsonDecode(responses[0].body) as List)
            .map((e) => Servicio.fromJson(e))
            .toList();
        final inactivos = (jsonDecode(responses[1].body) as List)
            .map((e) => Servicio.fromJson(e))
            .toList();

        setState(() {
          _todosLosServicios = [...activos, ...inactivos];
          _cargando = false;
        });
        _aplicarFiltros();
      } else {
        setState(() {
          _errorServicios = 'Error al cargar servicios';
          _cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorServicios = 'No se pudo conectar al servidor';
        _cargando = false;
      });
    }
  }

  bool _coincideCategoria(Servicio servicio, String categoria) {
    switch (categoria) {
      case 'PESTAÑAS':
        return servicio.activo &&
            servicio.nombre.toUpperCase().contains('PESTA');
      case 'CEJAS':
        return servicio.activo &&
            servicio.nombre.toUpperCase().contains('CEJA');
      case 'MAQUILLAJE':
        return servicio.activo &&
            servicio.nombre.toUpperCase().contains('MAQUILL');
      case 'COMBOS':
        return servicio.activo && servicio.esCombo;
      case 'INACTIVOS':
        return !servicio.activo;
      case 'TODOS':
      default:
        return servicio.activo;
    }
  }

  void _aplicarFiltros() {
    final query = _textoBusqueda.trim().toLowerCase();

    setState(() {
      _serviciosFiltrados = _todosLosServicios.where((servicio) {
        final coincideCategoria =
            _coincideCategoria(servicio, _categoriaActiva);

        if (query.isEmpty) return coincideCategoria;

        final coincideTexto =
            servicio.nombre.toLowerCase().contains(query) ||
                servicio.descripcion.toLowerCase().contains(query);

        return coincideCategoria && coincideTexto;
      }).toList();
    });
  }

  void _abrirNuevoServicio() async {
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => const NuevoServicioModal(),
    );
    _cargarServicios();
  }

  void _abrirEditarServicio(Servicio servicio) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => NuevoServicioModal(servicio: servicio),
    );
    _cargarServicios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blancoRoto,
      floatingActionButton: FabButton(onPressed: _abrirNuevoServicio),

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
                child: _cargando
                    ? const Center(child: CircularProgressIndicator())
                    : _errorServicios != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _errorServicios!,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: _cargarServicios,
                                  child: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          )
                        : _serviciosFiltrados.isEmpty
                            ? const Center(
                                child: Text(
                                  'No se encontraron servicios',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.separated(
                                itemCount: _serviciosFiltrados.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final servicio = _serviciosFiltrados[index];

                                  return ServiceCard(
                                    servicio: servicio,
                                    onAgendar: servicio.proximamente ||
                                            !servicio.activo
                                        ? null
                                        : () => showModalBottomSheet(
                                              isScrollControlled: true,
                                              context: context,
                                              builder: (context) =>
                                                  const NuevaCitaModal(),
                                            ),
                                    onEditar: () =>
                                        _abrirEditarServicio(servicio),
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