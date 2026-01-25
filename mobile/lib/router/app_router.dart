import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../pages/main_shell.dart';
import '../pages/auth_page.dart';
import '../services/injection.dart';
import '../services/auth_service.dart';

// Route names
abstract class Routes {
  static const String home = '/';
  static const String auth = '/auth';
}

/// Convierte el stream de auth en un Listenable para GoRouter
class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    _subscription = getIt<AuthService>().authStateChanges.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final _authNotifier = AuthNotifier();

final appRouter = GoRouter(
  initialLocation: Routes.home,
  debugLogDiagnostics: false,
  refreshListenable: _authNotifier,
  redirect: (context, state) {
    final authService = getIt<AuthService>();
    final isLoggedIn = authService.currentUser != null;
    final isAuthRoute = state.matchedLocation == Routes.auth;

    // Si no está logueado y no está en auth, redirigir a auth
    if (!isLoggedIn && !isAuthRoute) {
      return Routes.auth;
    }

    // Si está logueado y está en auth, redirigir a home
    if (isLoggedIn && isAuthRoute) {
      return Routes.home;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: Routes.home,
      name: 'home',
      builder: (context, state) => const MainShell(),
    ),
    GoRoute(
      path: Routes.auth,
      name: 'auth',
      builder: (context, state) => const AuthPage(),
    ),
  ],
);
