import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vivi_room/shared/widgets/app_bottom_nav_bar.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    const nombresRutas = ['home', 'clientes', 'servicios'];
    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNavBar(
        onTap: (index) => {
          // Mapear el indice con las respectivas rutas
          context.goNamed(nombresRutas[index]),
        },
      ),
    );
  }
}
