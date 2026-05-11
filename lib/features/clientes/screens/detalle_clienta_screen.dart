import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vivi_room/core/services/api_client.dart';
import 'package:vivi_room/features/clientes/models/cita_historial_model.dart';
import 'package:vivi_room/features/clientes/models/clienta_model.dart';
import 'package:vivi_room/shared/widgets/app_text_field.dart';
import 'package:vivi_room/shared/widgets/cliente_avatar.dart';
import 'package:vivi_room/shared/widgets/primary_button.dart';
import 'package:vivi_room/shared/widgets/secondary_button.dart';
import 'package:vivi_room/shared/widgets/status_badge.dart';

class DetalleClientaScreen extends StatefulWidget {
  const DetalleClientaScreen({super.key, required this.clienta});

  final Clienta clienta;

  @override
  State<DetalleClientaScreen> createState() => _DetalleClientaScreenState();
}

class _DetalleClientaScreenState extends State<DetalleClientaScreen> {
  static const _rosa = Color(0xFFE8A0B4);
  static const _rosaOscuro = Color(0xFFD4748F);
  static const _fondo = Color(0xFFFAF8F8);

  late Clienta _clienta;

  // Edición
  bool _editMode = false;
  bool _isSaving = false;
  String? _editError;
  String? _nombreError;
  String? _telefonoError;

  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _alergiasCtrl = TextEditingController();
  final _preferenciasCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();

  // Historial
  bool _historialExpanded = false;
  bool _loadingHistorial = false;
  bool _historialCargado = false;
  List<CitaHistorial> _historial = [];

  @override
  void initState() {
    super.initState();
    _clienta = widget.clienta;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _alergiasCtrl.dispose();
    _preferenciasCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  void _iniciarEdicion() {
    _nombreCtrl.text = _clienta.nombre;
    _telefonoCtrl.text = _clienta.telefono;
    _alergiasCtrl.text = _clienta.alergias ?? '';
    _preferenciasCtrl.text = _clienta.preferencias ?? '';
    _notasCtrl.text = _clienta.notas ?? '';
    setState(() {
      _editMode = true;
      _editError = null;
      _nombreError = null;
      _telefonoError = null;
    });
  }

  void _cancelarEdicion() {
    setState(() {
      _editMode = false;
      _editError = null;
      _nombreError = null;
      _telefonoError = null;
    });
  }

  Future<void> _guardar() async {
    final nombre = _nombreCtrl.text.trim();
    final telefono = _telefonoCtrl.text.trim();

    setState(() {
      _nombreError = nombre.isEmpty ? 'Nombre obligatorio' : null;
      _telefonoError = telefono.isEmpty
          ? 'Teléfono obligatorio'
          : (telefono.length != 10 ? 'El teléfono debe tener 10 dígitos' : null);
      _editError = null;
    });

    if (_nombreError != null || _telefonoError != null) return;

    setState(() => _isSaving = true);

    final apiClient = context.read<ApiClient>();
    final result = await apiClient.updateClienta(
      _clienta.idClienta,
      nombre: nombre,
      telefono: telefono,
      alergias: _alergiasCtrl.text.trim().isEmpty ? null : _alergiasCtrl.text.trim(),
      preferencias: _preferenciasCtrl.text.trim().isEmpty ? null : _preferenciasCtrl.text.trim(),
      notas: _notasCtrl.text.trim().isEmpty ? null : _notasCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      setState(() {
        _clienta = Clienta.fromJson({...data, 'ultimaVisita': _clienta.ultimaVisita});
        _editMode = false;
        _editError = null;
      });
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _editError = result['error'] ?? 'No se pudo guardar';
      });
    }
  }

  Future<void> _toggleHistorial() async {
    final expand = !_historialExpanded;
    setState(() => _historialExpanded = expand);

    if (expand && !_historialCargado) {
      setState(() => _loadingHistorial = true);
      final apiClient = context.read<ApiClient>();
      final result = await apiClient.getClientaHistorial(_clienta.idClienta);
      if (!mounted) return;

      if (result['success'] == true) {
        final rawList = (result['data'] as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .toList();
        setState(() {
          _historial = rawList.map(CitaHistorial.fromJson).toList();
          _historialCargado = true;
        });
      }
      setState(() => _loadingHistorial = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Perfil de Clienta',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFEEEEEE), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildBotones(),
            const SizedBox(height: 24),
            const Divider(color: Color(0xFFEEEEEE)),
            const SizedBox(height: 16),
            _buildHistorialSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          ClienteAvatar(nombre: _clienta.nombre, size: 56),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_editMode)
                  AppTextField(
                    label: 'Nombre completo',
                    controller: _nombreCtrl,
                    errorText: _nombreError,
                  )
                else
                  Text(
                    _clienta.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                const SizedBox(height: 6),
                if (_editMode)
                  AppTextField(
                    label: 'Teléfono',
                    controller: _telefonoCtrl,
                    keyboardType: TextInputType.number,
                    errorText: _telefonoError,
                    maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  )
                else
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF888888)),
                      const SizedBox(width: 4),
                      Text(
                        _clienta.telefono,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'INFORMACIÓN ADICIONAL',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF888888),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          if (_editMode) ...[
            AppTextField(label: 'Alergias (opcional)', controller: _alergiasCtrl),
            const SizedBox(height: 10),
            AppTextField(label: 'Preferencias (opcional)', controller: _preferenciasCtrl),
            const SizedBox(height: 10),
            AppTextField(label: 'Notas (opcional)', controller: _notasCtrl),
          ] else ...[
            _infoRow('Alergias', _clienta.alergias),
            const SizedBox(height: 10),
            _infoRow('Preferencias', _clienta.preferencias),
            const SizedBox(height: 10),
            _infoRow('Notas', _clienta.notas),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF444444),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value?.isNotEmpty == true ? value! : 'Sin registrar',
            style: TextStyle(
              fontSize: 13,
              color: value?.isNotEmpty == true
                  ? const Color(0xFF1A1A1A)
                  : const Color(0xFFAAAAAA),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBotones() {
    if (_editMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_editError != null) ...[
            Text(
              _editError!,
              style: const TextStyle(
                color: _rosaOscuro,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
          ],
          PrimaryButton(
            text: _isSaving ? 'Guardando...' : 'Guardar cambios',
            enabled: !_isSaving,
            onPressed: _isSaving ? null : _guardar,
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            text: 'Cancelar',
            onPressed: _isSaving ? null : _cancelarEdicion,
          ),
        ],
      );
    }

    return SecondaryButton(
      text: 'Editar datos',
      onPressed: _iniciarEdicion,
    );
  }

  Widget _buildHistorialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _toggleHistorial,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Text(
                  'HISTORIAL DE CITAS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF888888),
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Icon(
                  _historialExpanded ? Icons.expand_less : Icons.expand_more,
                  color: _rosa,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (_historialExpanded) ...[
          const SizedBox(height: 12),
          if (_loadingHistorial)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(strokeWidth: 2, color: _rosa),
              ),
            )
          else if (_historial.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Sin citas registradas',
                style: TextStyle(color: Color(0xFF888888), fontSize: 13),
              ),
            )
          else
            ...(_historial.map((c) => _CitaHistorialCard(cita: c))),
        ],
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }
}

class _CitaHistorialCard extends StatelessWidget {
  const _CitaHistorialCard({required this.cita});
  final CitaHistorial cita;

  String _formatFecha(String fechaIso) {
    try {
      final dt = DateTime.parse(fechaIso);
      const meses = [
        '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
        'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
      ];
      final hora = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      return '${dt.day} ${meses[dt.month]} ${dt.year} · $hora';
    } catch (_) {
      return fechaIso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  cita.servicio,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Text(
                '\$${cita.precio.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatFecha(cita.fechaHora),
            style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 8),
          StatusBadge(status: cita.estado),
        ],
      ),
    );
  }
}
