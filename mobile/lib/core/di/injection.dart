import 'package:get_it/get_it.dart';

import '../services/auth_service.dart';
import '../settings/settings_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ============================================================
  // CUBITS
  // ============================================================
  final settingsCubit = SettingsCubit();
  await settingsCubit.init();
  getIt.registerSingleton<SettingsCubit>(settingsCubit);

  // ============================================================
  // SERVICES
  // ============================================================
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  // getIt.registerLazySingleton<LocalStorageService>(() => HiveStorageService());

  // ============================================================
  // REPOSITORIES
  // ============================================================
  // TODO: Register repositories
  // getIt.registerLazySingleton<GoalsRepository>(() => GoalsRepositoryImpl());
  // getIt.registerLazySingleton<TasksRepository>(() => TasksRepositoryImpl());
  // getIt.registerLazySingleton<SharedTasksRepository>(() => SharedTasksRepositoryImpl());

  // ============================================================
  // CUBITS
  // ============================================================
  // TODO: Register cubits
  // getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt()));
  // getIt.registerFactory<GoalsCubit>(() => GoalsCubit(getIt()));
  // getIt.registerFactory<TasksCubit>(() => TasksCubit(getIt()));
  // getIt.registerFactory<HomeCubit>(() => HomeCubit(getIt(), getIt()));
}
