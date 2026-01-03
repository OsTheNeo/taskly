import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/settings/settings_cubit.dart';
import 'core/settings/settings_state.dart';
import 'core/theme/app_theme.dart';

class TasklyApp extends StatelessWidget {
  const TasklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<SettingsCubit>(),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return MaterialApp.router(
            title: 'Taskly',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(settings.accentColor),
            darkTheme: AppTheme.darkTheme(settings.accentColor),
            themeMode: settings.themeMode,
            routerConfig: appRouter,
            locale: settings.locale,
            supportedLocales: const [
              Locale('es'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
