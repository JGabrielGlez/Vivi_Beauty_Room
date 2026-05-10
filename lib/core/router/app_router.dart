// Esta será la instancia del go router que se usará en toda la aplicación

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vivi_room/features/agenda/screens/agenda_screen.dart';
import 'package:vivi_room/features/agenda/screens/detalle_cita_screen.dart';
import 'package:vivi_room/features/auth/screens/login_screen.dart';
import 'package:vivi_room/features/servicios/screens/catalogo_screen.dart';
import 'package:vivi_room/features/clientes/screens/directorio_screen.dart';
import 'package:vivi_room/shared/widgets/main_shell.dart';
import 'package:vivi_room/features/auth/providers/auth_provider.dart';

/// Splash screen temporal mientras se restaura la sesión
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F8),
      body: Center(
        child: ClipOval(
          child: Image.asset(
            'assets/images/logo.jpeg',
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

/// The route configuration.
final GoRouter router = GoRouter(
  // Esta es la pantalla que se muestra cuando se abre por primera vez la app
  initialLocation: '/login',
  redirect: (context, state) {
    final authProvider = context.read<AuthProvider>();

    // Si aún se está restaurando la sesión, mostrar splash
    if (authProvider.state == AuthState.initial) {
      return null;
    }

    final isAuthenticated = authProvider.isAuthenticated;
    final isOnLogin = state.fullPath == '/login';

    // Si autenticado pero en login, redirigir a home
    if (isAuthenticated && isOnLogin) {
      return '/';
    }

    // Si no autenticado y no en login, redirigir a login
    if (!isAuthenticated && !isOnLogin) {
      return '/login';
    }

    return null;
  },
  routes: <RouteBase>[
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          // Se define la pantalla principal, que en este caso es la agenda
          builder: (context, GoRouterState state) {
            return const AgendaScreen();
          },
          routes: [
            GoRoute(
              name: 'detalleCita',
              path: 'detalle-cita',
              builder: (context, state) => DetalleCitaScreen(),
            ),
          ],
        ),
        GoRoute(
          name: 'servicios',
          path: '/servicios',
          builder: (context, GoRouterState state) {
            return const CatalogoScreen();
          },
        ),
        GoRoute(
          name: 'clientes',
          path: '/clientes',
          builder: (context, state) {
            return const DirectorioScreen();
          },
        ),
      ],
    ),

    GoRoute(
      name: 'login',
      path: '/login',
      builder: (context, GoRouterState state) {
        return const LoginScreen();
      },
    ),

    // Splash screen para estado inicial
    GoRoute(
      path: '/splash',
      builder: (context, state) => const _SplashScreen(),
    ),
  ],
);
