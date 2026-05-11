import 'package:flutter/material.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../../../shared/widgets/cliente_avatar.dart';
import '../../../core/theme/app_colors.dart';
import 'package:http/http.dart' as http;
import 'agenda_screen.dart';

String backendBaseUrl = const String.fromEnvironment('BACKEND_URL', defaultValue: 'http://localhost:3000');
bool pago=true;
String token="";
Map<String,String> header = {'Content-Type': 'application/json','Authorization': 'Bearer $token'};

// ─── MODELO TEMPORAL (sprint visual) ─────────────────────────────────────────
// Reemplazar por el objeto Cita real de shared/models/ al integrar
class _CitaMock {
  final String nombreClienta;
  final String servicio;
  final DateTime fechaHora;
  final int duracionMin;
  final double montoAnticipo;
  final bool tieneAlergia;
  final String? notasAlergia;
  final String notas;
  String estado;
  bool anticipoPagado;
  final String id;

  _CitaMock({
    required this.nombreClienta,
    required this.servicio,
    required this.fechaHora,
    required this.duracionMin,
    required this.montoAnticipo,
    required this.tieneAlergia,
    this.notasAlergia,
    required this.notas,
    required this.estado,
    required this.anticipoPagado,
    required this.id,
  });
}

// ─── PANTALLA ─────────────────────────────────────────────────────────────────
class DetalleCitaScreen extends StatefulWidget {
  final Map<String, dynamic>? citaData;
  const DetalleCitaScreen({super.key, this.citaData});

  @override
  State<DetalleCitaScreen> createState() => _DetalleCitaScreenState();
}

class _DetalleCitaScreenState extends State<DetalleCitaScreen> {
  static const Color _rosa = Color(0xFFD4748F);
  static const Color _blancoRoto = Color(0xFFFAF8F8);
  static const Color _blanco = Color(0xFFFFFFFF);
  static const Color _negro = Color(0xFF1A1A1A);
  static const Color _grisOscuro = Color(0xFF666666);

  late Map<String, dynamic> _cita;

  @override
  void initState() {
    super.initState();
    _cita = widget.citaData ?? {
      'nombreClienta': 'Sofía Ramírez',
      'servicio': 'Extensiones de Pestañas Clásicas',
      'fechaHora': DateTime(2026, 3, 15, 10, 30).toIso8601String(),
      'duracionMin': 90,
      'montoAnticipo': 100.0,
      'tieneAlergia': true,
      'notasAlergia': 'Alérgica al adhesivo de látex. Usar pegamento sin látex.',
      'notas': 'Cliente frecuente. Prefiere el acabado en L+.',
      'estado': 'PENDIENTE',
      'anticipoPagado': false,
    };
    pago=_cita['anticipoPagado']==1;
  }

  String get _fechaFormateada {
    const meses = [
      '',
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    DateTime d;
    if (_cita['fechaHora'] is DateTime) {
      d = _cita['fechaHora'];
    } else if (_cita['fechaHora'] is String) {
      d = DateTime.tryParse(_cita['fechaHora']) ?? DateTime.now();
    } else {
      d = DateTime.now();
    }
    return '${d.day} de ${meses[d.month]} de ${d.year}';
  }

  String get _horaFormateada {
    DateTime d;
    if (_cita['fechaHora'] is DateTime) {
      d = _cita['fechaHora'];
    } else if (_cita['fechaHora'] is String) {
      d = DateTime.tryParse(_cita['fechaHora']) ?? DateTime.now();
    } else {
      d = DateTime.now();
    }
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} hrs';
  }

  Future<void> _marcarAnticipoRecibido() async {
    try {
      final response = await http.put(
        Uri.parse('$backendBaseUrl/api/agenda/citas/${_cita['id']}'),
        headers: header,
        body: '{"anticipoPagado": 1}',
      );
      if (response.statusCode == 200) {
        // Opcional: volver a cargar la cita desde el backend para asegurar datos frescos
        _showSnack('Anticipo marcado como recibido');
        setState(() {pago=!pago;});
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (_) =>const AgendaScreen()),);
      } else {
        _showSnack('Error al marcar anticipo: ${response.statusCode}');
      }
    } catch (e) {
      _showSnack('Error de red: $e');
    }
  }

  Future<void> _refrescarCita() async {
    try {
      final response = await http.get(
        Uri.parse('$backendBaseUrl/api/agenda/citas/${_cita['id']}'),
        headers: header,
      );
      if (response.statusCode == 200) {
        final nuevaCita = Map<String, dynamic>.from(
          response.body.isNotEmpty ? (response.body.startsWith('{') ? (response.body as dynamic) : {}) : {}
        );
        setState(() {
          _cita.addAll(nuevaCita);
        });
      }
    } catch (_) {
      // Silenciar error de refresco
    }
  }
  Future<void> _confirmarCita() async {
    try {
      final response = await http.put(
        Uri.parse('$backendBaseUrl/api/agenda/citas/${_cita['id']}'),
        headers: header,
        body: '{"estado": "CONFIRMADA"}',
      );
      if (response.statusCode == 200) {
        await _refrescarCita();
        _showSnack('Cita confirmada');
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (_) =>const AgendaScreen()),);
      } else {
        _showSnack('Error al confirmar cita: ${response.statusCode}');
      }
    } catch (e) {
      _showSnack('Error de red: $e');
    }
  }
  Future<void> _completarCita() async {
    try {
      final response = await http.put(
        Uri.parse('$backendBaseUrl/api/agenda/citas/${_cita['id']}'),
        headers: header,
        body: '{"estado": "COMPLETADA"}',
      );
      if (response.statusCode == 200) {
        setState(() {
          _cita['estado'] = 'COMPLETADA';
        });
        _showSnack('Cita marcada como completada');
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (_) =>const AgendaScreen()),);
        
      } else {
        _showSnack('Error al completar cita: ${response.statusCode}');
      }
    } catch (e) {
      _showSnack('Error de red: $e');
    }
  }
  void _reprogramarCita() =>
      _showSnack('Función de reprogramación próximamente');
  void _verPerfilClienta() =>
      _showSnack('Navegar al perfil de ${_cita['nombreClienta'] ?? ''}');

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: _rosa,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _mostrarModalCancelacion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _blanco,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Cancelar cita',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: _negro,
          ),
        ),
        content: const Text(
          'El anticipo quedará retenido y el horario se liberará. Esta acción no se puede deshacer.',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: _grisOscuro,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Volver',
              style: TextStyle(fontFamily: 'Poppins', color: _grisOscuro),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Sí, cancelar',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      try {
        final response = await http.put(
          Uri.parse('$backendBaseUrl/api/agenda/citas/${_cita['id']}'),
          headers: header,
          body: '{"estado": "CANCELADA"}',
        );
        if (response.statusCode == 200) {
          await _refrescarCita();
          _showSnack('Cita cancelada. Anticipo retenido.');
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (_) =>const AgendaScreen()),);
        } else {
          _showSnack('Error al cancelar cita: ${response.statusCode}');
        }
      } catch (e) {
        _showSnack('Error de red: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _blancoRoto,
      appBar: AppBar(
        backgroundColor: _blanco,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _negro, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalle de cita',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _negro,
          ),
        ),
        centerTitle: false,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_cita['tieneAlergia'] == true) ...[
              _AlertBanner(
                texto:
                    _cita['notasAlergia'] ?? 'Clienta tiene alergias registradas.',
              ),
              const SizedBox(height: 16),
            ],
            _TarjetaEncabezado(
              nombreClienta: _cita['nombreClienta'].toString() ?? '',
              servicio: _cita['servicio'] ?? '',
              fecha: _fechaFormateada,
              hora: _horaFormateada,
              duracionMin: _cita['duracionMin'] ?? _cita['duracion'] ?? 0,
              estado: _cita['estado'] ?? '',
              onVerPerfil: _verPerfilClienta,
            ),
            const SizedBox(height: 16),
            _TarjetaAnticipo(
              monto: (_cita['montoAnticipo'] ?? 0).toDouble(),
              pagado: _cita['anticipoPagado'] == 1,
              onMarcarRecibido: (_cita['anticipoPagado'] == 0)
                  ? _marcarAnticipoRecibido
                  : null,
            ),
            const SizedBox(height: 16),
            if ((_cita['notas'] ?? '').toString().isNotEmpty) ...[
              _TarjetaNotas(notas: _cita['notas']),
              const SizedBox(height: 24),
            ],
            _SeccionAcciones(
              estado: _cita['estado'] ?? '',
              anticipoPagado: _cita['anticipoPagado'] == 1,
              onConfirmar: _confirmarCita,
              onCompletar: _completarCita,
              onReprogramar: _reprogramarCita,
              onCancelar: _mostrarModalCancelacion,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── SUB-WIDGETS ──────────────────────────────────────────────────────────────

/// AlertBanner inline — cuando el widget global exista en shared/widgets/,
/// reemplazar esta clase por el import correspondiente.
class _AlertBanner extends StatelessWidget {
  final String texto;
  const _AlertBanner({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            decoration: const BoxDecoration(
              color: Color(0xFFFFC107),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFFF8F00),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                texto,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Color(0xFF6D4C00),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _TarjetaEncabezado extends StatelessWidget {
  final String nombreClienta, servicio, fecha, hora, estado;
  final int duracionMin;
  final VoidCallback onVerPerfil;

  const _TarjetaEncabezado({
    required this.nombreClienta,
    required this.servicio,
    required this.fecha,
    required this.hora,
    required this.duracionMin,
    required this.estado,
    required this.onVerPerfil,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClienteAvatar(nombre: nombreClienta),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreClienta,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    StatusBadge(status: estado),
                  ],
                ),
              ),

            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          _InfoRow(icono: Icons.content_cut_outlined, texto: servicio),
          const SizedBox(height: 10),
          _InfoRow(icono: Icons.calendar_today_outlined, texto: fecha),
          const SizedBox(height: 10),
          _InfoRow(
            icono: Icons.access_time_outlined,
            texto: '$hora  ·  $duracionMin min',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _InfoRow({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, size: 18, color: const Color(0xFFD4748F)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ],
    );
  }
}

class _TarjetaAnticipo extends StatelessWidget {
  final double monto;
  final bool pagado;
  final VoidCallback? onMarcarRecibido;

  const _TarjetaAnticipo({
    required this.monto,
    required this.pagado,
    this.onMarcarRecibido,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ANTICIPO',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF666666),
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${monto.toStringAsFixed(0)} MXN',
                style: const TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFD4748F),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: pagado
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      pagado
                          ? Icons.check_circle_outline
                          : Icons.radio_button_unchecked,
                      size: 16,
                      color: pagado
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      pagado ? 'Recibido' : 'Pendiente',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: pagado
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!pagado) ...[
            const SizedBox(height: 14),
            SecondaryButton(
              text: 'Marcar anticipo como recibido',
              onPressed: onMarcarRecibido ?? () {},
            ),
          ],
        ],
      ),
    );
  }
}

class _TarjetaNotas extends StatelessWidget {
  final String notas;
  const _TarjetaNotas({required this.notas});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NOTAS',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF666666),
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            notas,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Color(0xFF1A1A1A),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeccionAcciones extends StatelessWidget {
  final String estado;
  final bool anticipoPagado;
  final VoidCallback onConfirmar, onCompletar, onReprogramar;
  final VoidCallback onCancelar;

  const _SeccionAcciones({
    required this.estado,
    required this.anticipoPagado,
    required this.onConfirmar,
    required this.onCompletar,
    required this.onReprogramar,
    required this.onCancelar,
  });

  bool get _puedeCancel => estado != 'CANCELADA' && estado != 'COMPLETADA';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Confirmar: PENDIENTE + anticipo pagado
        if (estado == 'PENDIENTE' && anticipoPagado) ...[
          PrimaryButton(text: 'Confirmar cita', onPressed: onConfirmar),
          const SizedBox(height: 12),
        ],
        // Completar: solo CONFIRMADA
        if (estado == 'CONFIRMADA') ...[
          PrimaryButton(text: 'Marcar como completada', onPressed:pago?onCompletar: null),
          const SizedBox(height: 12),
        ],
        // Reprogramar: PENDIENTE o CONFIRMADA
        if (estado == 'PENDIENTE' || estado == 'CONFIRMADA') ...[
          SecondaryButton(text: 'Reprogramar cita', onPressed: onReprogramar),
          const SizedBox(height: 12),
        ],
        // Cancelar: destructivo con modal de confirmación
        if (_puedeCancel) _BotonCancelar(onPressed: onCancelar),
        // Estado final
        if (estado == 'CANCELADA')
          _MensajeEstadoFinal(
            icono: Icons.cancel_outlined,
            color: const Color(0xFFF44336),
            texto: 'Esta cita fue cancelada. El anticipo quedó retenido.',
          ),
        if (estado == 'COMPLETADA')
          _MensajeEstadoFinal(
            icono: Icons.check_circle_outline,
            color: const Color(0xFF4CAF50),
            texto: 'Servicio completado.',
          ),
      ],
    );
  }
}

class _BotonCancelar extends StatelessWidget {
  final VoidCallback onPressed;
  const _BotonCancelar({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        'Cancelar cita',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MensajeEstadoFinal extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String texto;
  const _MensajeEstadoFinal({
    required this.icono,
    required this.color,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
