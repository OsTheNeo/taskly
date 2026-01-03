import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/main_shell.dart';
import '../../features/auth/presentation/pages/auth_page.dart';

// Route names
abstract class Routes {
  static const String home = '/';
  static const String auth = '/auth';
}

final appRouter = GoRouter(
  initialLocation: Routes.home,
  debugLogDiagnostics: false,
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
