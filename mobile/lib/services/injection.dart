import 'package:get_it/get_it.dart';

import 'auth_service.dart';
import 'data_service.dart';
import '../state/settings_state.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ============================================================
  // SETTINGS (using Signals)
  // ============================================================
  await initSettings();

  // ============================================================
  // SERVICES
  // ============================================================
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<DataService>(() => DataService());
}
