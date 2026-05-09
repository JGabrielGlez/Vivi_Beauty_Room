import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../shared/models/servicio.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/search_bar_widget.dart';

// URL base del backend. En emulador Android usar 10.0.2.2, en desktop/web usar localhost.
const String _baseUrl = 'http://localhost:3000';

class NuevaCitaModal extends StatefulWidget {
  const NuevaCitaModal({super.key});

  @override
  State<NuevaCitaModal> createState() => _NuevaCitaModalState();
}

class _NuevaCitaModalState extends State<NuevaCitaModal> {
  // Duración seleccionada en los chips de minutos
  String duracionSeleccionada = '60 MIN';

  // Lista de servicios cargados desde la API
  List<Servicio> _servicios = [];

  // ID del servicio actualmente seleccionado
  String? _servicioSeleccionadoId;

  // Controla si se está cargando la lista de servicios
  bool _cargando = true;

  // Mensaje de error si la petición falla
  String? _errorServicios;

  @override
  void initState() {
    super.initState();
    _cargarServicios();
  }

  // Llama al backend y llena la lista de servicios activos
  Future<void> _cargarServicios() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/servicios'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _servicios = data.map((e) => Servicio.fromJson(e)).toList();
          _cargando = false;
        });
      } else {
        setState(() {
          _errorServicios = 'Error ${response.statusCode}';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        // MediaQuery empuja el modal hacia arriba cuando aparece el teclado
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Palito gris decorativo para indicar que el modal es arrastrable
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Cabecera: título y botón cerrar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nueva Cita',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.cancel,
                    color: Color(0xFFE0E7FF),
                    size: 30,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Búsqueda de cliente
            _buildLabel('SELECCIONAR CLIENTE'),
            const SizedBox(height: 8),
            const SearchBarWidget(hintText: 'Buscar por nombre...'),
            const SizedBox(height: 20),

            // Chips de servicios cargados desde la BD
            _buildLabel('TIPO DE SERVICIO'),
            const SizedBox(height: 8),
            _buildListaServicios(),
            const SizedBox(height: 20),

            // Fecha y Horario en dos columnas
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('FECHA'),
                      const SizedBox(height: 8),
                      const AppTextField(label: '25 Feb 2026'),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('HORARIO'),
                      const SizedBox(height: 8),
                      const AppTextField(label: '10:00 AM'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Selector de duración
            _buildLabel('DURACIÓN'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  ['30 MIN', '45 MIN', '60 MIN', '90 MIN']
                      .map((t) => _buildDuracionTab(t))
                      .toList(),
            ),
            const SizedBox(height: 20),

            // Costos
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('COSTO TOTAL'),
                      const SizedBox(height: 8),
                      const AppTextField(label: '\$ 0.00'),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('ANTICIPO'),
                      const SizedBox(height: 8),
                      const AppTextField(label: '\$ 0.00'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            PrimaryButton(
              text: 'Guardar Cita',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // Muestra los chips de servicios, un spinner mientras carga, o un error
  Widget _buildListaServicios() {
    if (_cargando) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: CircularProgressIndicator(color: Color(0xFFD4748F)),
        ),
      );
    }

    if (_errorServicios != null) {
      return Text(
        _errorServicios!,
        style: const TextStyle(color: Colors.red, fontSize: 13),
      );
    }

    // Wrap permite que los chips bajen a la siguiente línea si no caben
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          _servicios
              .map((s) => _buildServiceChip(s))
              .toList(),
    );
  }

  // Chip de servicio individual. Se pone rosa cuando está seleccionado.
  Widget _buildServiceChip(Servicio servicio) {
    final isSelected = _servicioSeleccionadoId == servicio.id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _servicioSeleccionadoId = servicio.id;
          // Auto-seleccionar la duración más cercana a la del servicio
          _autoSeleccionarDuracion(servicio.duracionMin);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFFD4748F).withValues(alpha: 0.85)
                  : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFFD4748F))
              : null,
        ),
        child: Text(
          servicio.nombre,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // Selecciona automáticamente el chip de duración más cercano al del servicio
  void _autoSeleccionarDuracion(int duracionMin) {
    const opciones = [30, 45, 60, 90];
    final cercano = opciones.reduce(
      (a, b) =>
          (a - duracionMin).abs() < (b - duracionMin).abs() ? a : b,
    );
    duracionSeleccionada = '$cercano MIN';
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: Colors.grey,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildDuracionTab(String label) {
    final isSelected = duracionSeleccionada == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          duracionSeleccionada = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
          border:
              isSelected
                  ? Border.all(color: const Color(0xFFD4748F).withValues(alpha: 0.2))
                  : null,
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                    ),
                  ]
                  : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                isSelected ? const Color(0xFFD4748F) : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
