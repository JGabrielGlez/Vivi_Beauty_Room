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

GoRouter createAppRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final currentPath = state.uri.path;

      if (authProvider.state == AuthState.initial) {
        return currentPath == '/splash' ? null : '/splash';
      }

      if (currentPath == '/splash') {
        return authProvider.isAuthenticated ? '/' : '/login';
      }

      final isAuthenticated = authProvider.isAuthenticated;
      final isOnLogin = currentPath == '/login';

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
            builder: (context, GoRouterState state) {
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
      GoRoute(
        path: '/splash',
        builder: (context, state) => const _SplashScreen(),
      ),
    ],
  );
}
