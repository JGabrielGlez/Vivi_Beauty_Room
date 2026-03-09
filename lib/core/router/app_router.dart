// Esta será la instancia del go router que se usará en toda la aplicación

import 'package:go_router/go_router.dart';
import 'package:vivi_room/features/auth/screens/login_screen.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
  ],
);
