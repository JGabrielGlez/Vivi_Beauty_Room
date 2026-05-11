import 'package:flutter/foundation.dart';

class ApiConfig {
  // URL base del backend
  // Chrome / web / desktop / iOS simulador: localhost
  // Android emulador: 10.0.2.2
  // Dispositivo físico: pasar la IP de tu PC con --dart-define=API_HOST=192.168.1.XX
  static const String _physicalHost = String.fromEnvironment('API_HOST');

  static String get baseUrl {
    if (_physicalHost.isNotEmpty) {
      return 'http://$_physicalHost:3000/api';
    }

    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:3000/api';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return 'http://localhost:3000/api';
      case TargetPlatform.fuchsia:
        return 'http://localhost:3000/api';
    }
  }

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
