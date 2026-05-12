import 'package:flutter/material.dart';
import 'features/citas/widgets/nueva_cita_modal.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _NuevaCitaWrapper(),
    ),
  );
}

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
