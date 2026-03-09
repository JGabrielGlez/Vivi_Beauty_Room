// Esta será la instancia del go router que se usará en toda la aplicación

import 'package:go_router/go_router.dart';
import 'package:vivi_room/features/agenda/screens/agenda_screen.dart';
import 'package:vivi_room/features/agenda/screens/detalle_cita_screen.dart';
import 'package:vivi_room/features/auth/screens/login_screen.dart';
import 'package:vivi_room/features/servicios/screens/catalogo_screen.dart';
import 'package:vivi_room/features/clientes/screens/directorio_screen.dart';
import 'package:vivi_room/shared/widgets/main_shell.dart';

/// The route configuration.
final GoRouter router = GoRouter(
  // Esta es la pantalla que se muestra cuando se abre por primera vez la app
  initialLocation: '/login',
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
  ],
);
