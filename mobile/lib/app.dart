import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:signals/signals_flutter.dart';
import 'l10n/app_localizations.dart';

import 'router/app_router.dart';
import 'state/settings_state.dart';
import 'theme/app_theme.dart';

class TasklyApp extends StatelessWidget {
  const TasklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final currentThemeMode = themeMode.value;
      final currentAccentColorIndex = accentColorIndex.value;
      final currentLocale = locale.value;
      final currentAccentColor = accentColors[currentAccentColorIndex];

      return MaterialApp.router(
        title: 'Taskly',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(currentAccentColor),
        darkTheme: AppTheme.darkTheme(currentAccentColor),
        themeMode: currentThemeMode,
        routerConfig: appRouter,
        locale: currentLocale,
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
    });
  }
}
