import 'package:flutter/material.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../../../shared/widgets/cliente_avatar.dart';
import '../../../core/theme/app_colors.dart';

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
  });
}

// ─── PANTALLA ─────────────────────────────────────────────────────────────────
class DetalleCitaScreen extends StatefulWidget {
  final _CitaMock? citaMock;
  const DetalleCitaScreen({super.key, this.citaMock});

  @override
  State<DetalleCitaScreen> createState() => _DetalleCitaScreenState();
}

class _DetalleCitaScreenState extends State<DetalleCitaScreen> {
  static const Color _rosa = Color(0xFFD4748F);
  static const Color _blancoRoto = Color(0xFFFAF8F8);
  static const Color _blanco = Color(0xFFFFFFFF);
  static const Color _negro = Color(0xFF1A1A1A);
  static const Color _grisOscuro = Color(0xFF666666);

  late _CitaMock _cita;

  @override
  void initState() {
    super.initState();
    _cita =
        widget.citaMock ??
        _CitaMock(
          nombreClienta: 'Sofía Ramírez',
          servicio: 'Extensiones de Pestañas Clásicas',
          fechaHora: DateTime(2026, 3, 15, 10, 30),
          duracionMin: 90,
          montoAnticipo: 100.0,
          tieneAlergia: true,
          notasAlergia:
              'Alérgica al adhesivo de látex. Usar pegamento sin látex.',
          notas: 'Cliente frecuente. Prefiere el acabado en L+.',
          estado: 'PENDIENTE',
          anticipoPagado: false,
        );
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
    final d = _cita.fechaHora;
    return '${d.day} de ${meses[d.month]} de ${d.year}';
  }

  String get _horaFormateada {
    final d = _cita.fechaHora;
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} hrs';
  }

  void _marcarAnticipoRecibido() => setState(() {
    _cita.anticipoPagado = true;
    _showSnack('Anticipo marcado como recibido');
  });
  void _confirmarCita() => setState(() {
    _cita.estado = 'CONFIRMADA';
    _showSnack('Cita confirmada');
  });
  void _completarCita() => setState(() {
    _cita.estado = 'COMPLETADA';
    _showSnack('Cita completada');
  });
  void _reprogramarCita() =>
      _showSnack('Función de reprogramación próximamente');
  void _verPerfilClienta() =>
      _showSnack('Navegar al perfil de ${_cita.nombreClienta}');

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
      setState(() {
        _cita.estado = 'CANCELADA';
      });
      _showSnack('Cita cancelada. Anticipo retenido.');
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
            if (_cita.tieneAlergia) ...[
              _AlertBanner(
                texto:
                    _cita.notasAlergia ?? 'Clienta tiene alergias registradas.',
              ),
              const SizedBox(height: 16),
            ],
            _TarjetaEncabezado(
              nombreClienta: _cita.nombreClienta,
              servicio: _cita.servicio,
              fecha: _fechaFormateada,
              hora: _horaFormateada,
              duracionMin: _cita.duracionMin,
              estado: _cita.estado,
              onVerPerfil: _verPerfilClienta,
            ),
            const SizedBox(height: 16),
            _TarjetaAnticipo(
              monto: _cita.montoAnticipo,
              pagado: _cita.anticipoPagado,
              onMarcarRecibido: _cita.anticipoPagado
                  ? null
                  : _marcarAnticipoRecibido,
            ),
            const SizedBox(height: 16),
            if (_cita.notas.isNotEmpty) ...[
              _TarjetaNotas(notas: _cita.notas),
              const SizedBox(height: 24),
            ],
            _SeccionAcciones(
              estado: _cita.estado,
              anticipoPagado: _cita.anticipoPagado,
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
              GestureDetector(
                onTap: onVerPerfil,
                child: const Text(
                  'Ver perfil',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Color(0xFFD4748F),
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFFD4748F),
                  ),
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
          PrimaryButton(text: 'Marcar como completada', onPressed: onCompletar),
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
