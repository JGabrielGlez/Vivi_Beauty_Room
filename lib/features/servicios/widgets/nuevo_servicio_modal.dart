import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/api_client.dart';
import '../../../shared/models/servicio.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/app_text_field.dart';

class NuevoServicioModal extends StatefulWidget {
  final Servicio? servicio;

  const NuevoServicioModal({super.key, this.servicio});

  @override
  State<NuevoServicioModal> createState() => _NuevoServicioModalState();
}

class _NuevoServicioModalState extends State<NuevoServicioModal> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();

  String _duracionSeleccionada = '60 MIN';
  bool _esCombo = false;
  bool _proximamente = false;
  bool _activo = true;

  bool _guardando = false;
  String? _errorGuardar;

  bool get _esEditar => widget.servicio != null;

  @override
  void initState() {
    super.initState();
    if (_esEditar) {
      final s = widget.servicio!;
      _nombreController.text = s.nombre;
      _descripcionController.text = s.descripcion;
      _precioController.text = s.precio.toStringAsFixed(0);
      _esCombo = s.esCombo;
      _proximamente = s.proximamente;
      _activo = s.activo;
      _duracionSeleccionada = _minToLabel(s.duracionMin);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  String _minToLabel(int min) {
    switch (min) {
      case 30:
        return '30 MIN';
      case 90:
        return '90 MIN';
      case 45:
      case 60:
      default:
        return '60 MIN';
    }
  }

  int _labelToMin(String label) {
    switch (label) {
      case '30 MIN':
        return 30;
      case '90 MIN':
        return 90;
      case '60 MIN':
      default:
        return 60;
    }
  }

  Future<void> _guardar() async {
    final nombre = _nombreController.text.trim();
    final precioTexto = _precioController.text.trim();

    if (nombre.isEmpty) {
      setState(() => _errorGuardar = 'El nombre es obligatorio');
      return;
    }

    if (precioTexto.isEmpty || double.tryParse(precioTexto) == null) {
      setState(() => _errorGuardar = 'El precio debe ser un número válido');
      return;
    }

    setState(() {
      _guardando = true;
      _errorGuardar = null;
    });

    final apiClient = context.read<ApiClient>();
    Map<String, dynamic> result;

    if (_esEditar) {
      result = await apiClient.actualizarServicio(
        widget.servicio!.id,
        nombre: nombre,
        descripcion: _descripcionController.text.trim(),
        precio: double.parse(precioTexto),
        duracionMin: _labelToMin(_duracionSeleccionada),
        activo: _activo ? 1 : 0,
        proximamente: _proximamente ? 1 : 0,
        esCombo: _esCombo ? 1 : 0,
      );
    } else {
      result = await apiClient.crearServicio(
        nombre: nombre,
        descripcion: _descripcionController.text.trim(),
        precio: double.parse(precioTexto),
        duracionMin: _labelToMin(_duracionSeleccionada),
        activo: _activo ? 1 : 0,
        proximamente: _proximamente ? 1 : 0,
        esCombo: _esCombo ? 1 : 0,
      );
    }

    if (result['success'] == true) {
      if (mounted) Navigator.pop(context);
    } else {
      setState(() {
        _errorGuardar = result['error'] ?? 'No se pudo guardar';
        _guardando = false;
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _esEditar ? 'Editar Servicio' : 'Nuevo Servicio',
                  style: const TextStyle(
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

            _buildLabel('NOMBRE DEL SERVICIO'),
            const SizedBox(height: 8),
            AppTextField(
              label: 'Ej. Extensiones de pestañas',
              controller: _nombreController,
            ),

            const SizedBox(height: 20),

            _buildLabel('DESCRIPCIÓN'),
            const SizedBox(height: 8),
            AppTextField(
              label: 'Describe el servicio...',
              controller: _descripcionController,
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('PRECIO'),
                      const SizedBox(height: 8),
                      AppTextField(
                        label: '\$ 0.00',
                        controller: _precioController,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildLabel('DURACIÓN'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['30 MIN', '60 MIN', '90 MIN']
                  .map((t) => _buildDuracionTab(t))
                  .toList(),
            ),

            const SizedBox(height: 20),

            _buildLabel('OPCIONES'),
            const SizedBox(height: 8),
            _buildSwitch(
              label: 'Es combo',
              value: _esCombo,
              onChanged: (val) => setState(() => _esCombo = val),
            ),
            const SizedBox(height: 8),
            _buildSwitch(
              label: 'Próximamente',
              value: _proximamente,
              onChanged: (val) => setState(() => _proximamente = val),
            ),
            const SizedBox(height: 8),
            _buildSwitch(
              label: 'Activo',
              value: _activo,
              onChanged: (val) => setState(() => _activo = val),
            ),

            if (_errorGuardar != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorGuardar!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],

            const SizedBox(height: 30),

            PrimaryButton(
              text: _guardando
                  ? 'Guardando...'
                  : _esEditar
                      ? 'Guardar Cambios'
                      : 'Guardar Servicio',
              onPressed: _guardando ? null : _guardar,
            ),
          ],
        ),
      ),
    );
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
    bool isSelected = _duracionSeleccionada == label;
    return GestureDetector(
      onTap: () => setState(() => _duracionSeleccionada = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: const Color(0xFFD4748F).withOpacity(0.2))
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFD4748F) : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Poppins',
            color: Colors.black87,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFD4748F),
        ),
      ],
    );
  }
}