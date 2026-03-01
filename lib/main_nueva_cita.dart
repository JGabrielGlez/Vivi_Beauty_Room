import 'package:flutter/material.dart';
// Importa tu modal (asegúrate de que la ruta sea correcta)
import 'features/citas/widgets/nueva_cita_modal.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(fontFamily: 'Poppins'), // Para que se vea como el diseño
    home: const ModalPreview(),
  ));
}

class ModalPreview extends StatelessWidget {
  const ModalPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F8), // El gris clarito de Viviana
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4748F), // El rosa de la marca
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          onPressed: () {
            // Esta es la función que abre tu trabajo
            showModalBottomSheet(
              context: context,
              isScrollControlled: true, // Esto permite que el modal crezca si hay teclado
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => const NuevaCitaModal(),
            );
          },
          child: const Text('Probar Modal de Miguel', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}