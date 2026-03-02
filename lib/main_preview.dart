import 'package:flutter/material.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/agenda/screens/agenda_screen.dart';
import 'features/citas/widgets/nueva_cita_modal.dart';
import 'features/servicios/screens/catalogo_screen.dart';
import 'features/agenda/screens/detalle_cita_screen.dart';
import 'features/clientes/screens/directorio_screen.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: _PreviewShell()),
  );
}

class _PreviewShell extends StatefulWidget {
  const _PreviewShell();

  @override
  State<_PreviewShell> createState() => _PreviewShellState();
}

class _PreviewShellState extends State<_PreviewShell> {
  int _index = 0;

  final List<Widget> _pantallas = [
    const LoginScreen(),
    const AgendaScreen(),
    const _NuevaCitaWrapper(),
    const CatalogoScreen(),
    const DetalleCitaScreen(),
    const DirectorioScreen(),
  ];

  void _siguiente() {
    setState(() {
      _index = (_index + 1) % _pantallas.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _pantallas[_index],
        Positioned(
          bottom: 80,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: Colors.black87,
            onPressed: _siguiente,
            child: const Icon(Icons.navigate_next, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// Wrapper para NuevaCitaModal ya que es un bottom sheet, no una pantalla completa
class _NuevaCitaWrapper extends StatelessWidget {
  const _NuevaCitaWrapper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F8),
      body: DraggableScrollableSheet(
        initialChildSize: 1.0,
        minChildSize: 1.0,
        maxChildSize: 1.0,
        builder: (_, controller) => const NuevaCitaModal(),
      ),
    );
  }
}
