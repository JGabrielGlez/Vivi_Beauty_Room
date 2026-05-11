import 'package:flutter/material.dart';
import 'features/citas/widgets/nueva_cita_modal.dart';

// Archivo de entrada aislado para el modal de Nueva Cita (Miguel)
// Correr con: flutter run -t lib/main_nueva_cita.dart
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: _ModalPreview(),
  ));
}

// Pantalla temporal que solo existe para poder abrir el modal y verlo en acción.
// El modal no es una pantalla completa, por eso necesita este Scaffold de envoltura.
class _ModalPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF8F8),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFD4748F),
          ),
          onPressed: () {
            // isScrollControlled: true permite que el modal ocupe la altura
            // que necesite sin quedar cortado por el teclado o el contenido
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => NuevaCitaModal(),
            );
          },
          child: Text('Abrir modal'),
        ),
      ),
    );
  }
}
