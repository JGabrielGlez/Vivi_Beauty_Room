import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vivi_room/core/services/analytics_service.dart';
import 'package:vivi_room/features/clientes/providers/clientas_provider.dart';
import 'package:vivi_room/shared/widgets/app_text_field.dart';
import 'package:vivi_room/shared/widgets/primary_button.dart';

class NuevaClientaModal extends StatefulWidget {
  const NuevaClientaModal({super.key});

  @override
  State<NuevaClientaModal> createState() => _NuevaClientaModalState();
}

class _NuevaClientaModalState extends State<NuevaClientaModal> {
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _alergiasController = TextEditingController();
  final _preferenciasController = TextEditingController();
  final _notasController = TextEditingController();

  String? _nombreError;
  String? _telefonoError;
  String? _formError;

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _alergiasController.dispose();
    _preferenciasController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _onGuardar() async {
    final nombre = _nombreController.text.trim();
    final telefono = _telefonoController.text.trim();

    setState(() {
      _nombreError = nombre.isEmpty ? 'Nombre obligatorio' : null;
      _telefonoError = telefono.isEmpty
          ? 'Teléfono obligatorio'
          : (telefono.length != 10
                ? 'El teléfono debe tener 10 dígitos'
                : null);
      _formError = null;
    });

    if (_nombreError != null || _telefonoError != null) return;

    final provider = context.read<ClientasProvider>();
    final success = await provider.createClienta(
      nombre: nombre,
      telefono: telefono,
      alergias: _alergiasController.text.trim(),
      preferencias: _preferenciasController.text.trim(),
      notas: _notasController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      AnalyticsService.clienteRegistrado();
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _formError = provider.errorMessage ?? 'No se pudo guardar la clienta';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<ClientasProvider>().isSaving;

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
                const Text(
                  'Nueva Clienta',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                IconButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.cancel,
                    color: Color(0xFFE0E7FF),
                    size: 30,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLabel('DATOS DE LA CLIENTA'),
            const SizedBox(height: 8),
            AppTextField(
              label: 'Nombre completo',
              controller: _nombreController,
              errorText: _nombreError,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Teléfono',
              controller: _telefonoController,
              keyboardType: TextInputType.number,
              errorText: _telefonoError,
              maxLength: 10,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            const SizedBox(height: 16),
            _buildLabel('INFORMACIÓN ADICIONAL'),
            const SizedBox(height: 8),
            AppTextField(
              label: 'Alergias (opcional)',
              controller: _alergiasController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Preferencias (opcional)',
              controller: _preferenciasController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Notas (opcional)',
              controller: _notasController,
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 20,
              child: Align(
                alignment: Alignment.centerLeft,
                child: (_formError == null)
                    ? const SizedBox.shrink()
                    : Text(
                        _formError!,
                        style: const TextStyle(
                          color: Color(0xFFD4748F),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              text: isSaving ? 'Guardando...' : 'Guardar Clienta',
              enabled: !isSaving,
              onPressed: isSaving ? null : _onGuardar,
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
}
