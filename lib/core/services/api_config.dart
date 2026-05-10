class ApiConfig {
  // URL base del backend
  // Para emulador Android: 10.0.2.2
  // Para dispositivo físico: reemplazar por IP de la máquina donde corre backend
  // Para iOS simulador: localhost o 127.0.0.1
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
