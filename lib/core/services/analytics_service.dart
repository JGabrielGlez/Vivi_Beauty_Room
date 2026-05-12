import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ─── Auth ────────────────────────────────────────────────────────────────
  static Future<void> loginExitoso(String rol) async {
    await _analytics.logEvent(name: 'login_exitoso', parameters: {'rol': rol});
  }

  static Future<void> logout() async {
    await _analytics.logEvent(name: 'logout');
  }

  // ─── Citas ───────────────────────────────────────────────────────────────
  static Future<void> citaCreada(String servicio) async {
    await _analytics.logEvent(
      name: 'cita_creada',
      parameters: {'servicio': servicio},
    );
  }

  static Future<void> citaCancelada(String idCita) async {
    await _analytics.logEvent(
      name: 'cita_cancelada',
      parameters: {'id_cita': idCita},
    );
  }

  static Future<void> citaVista(String idCita) async {
    await _analytics.logEvent(
      name: 'cita_vista',
      parameters: {'id_cita': idCita},
    );
  }

  // ─── Clientes ────────────────────────────────────────────────────────────
  static Future<void> clienteRegistrado() async {
    await _analytics.logEvent(name: 'cliente_registrado');
  }

  static Future<void> clienteBuscado(String termino) async {
    await _analytics.logEvent(
      name: 'cliente_buscado',
      parameters: {'termino': termino},
    );
  }

  // ─── Servicios ───────────────────────────────────────────────────────────
  static Future<void> servicioVisto(String nombreServicio) async {
    await _analytics.logEvent(
      name: 'servicio_visto',
      parameters: {'servicio': nombreServicio},
    );
  }
}
