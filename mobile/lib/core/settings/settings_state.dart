import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../shared/models/task_category.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final int accentColorIndex;
  final Locale locale;
  final List<TaskCategory> customCategories;

  static const List<Color> accentColors = [
    Color(0xFF18181B), // Zinc (default)
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFFF59E0B), // Amber
    Color(0xFF22C55E), // Green
    Color(0xFF14B8A6), // Teal
    Color(0xFF3B82F6), // Blue
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Pink
  ];

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.accentColorIndex = 0,
    this.locale = const Locale('es'),
    this.customCategories = const [],
  });

  Color get accentColor => accentColors[accentColorIndex];

  List<TaskCategory> get allCategories => [
        ...PredefinedCategories.all,
        ...customCategories,
      ];

  SettingsState copyWith({
    ThemeMode? themeMode,
    int? accentColorIndex,
    Locale? locale,
    List<TaskCategory>? customCategories,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      accentColorIndex: accentColorIndex ?? this.accentColorIndex,
      locale: locale ?? this.locale,
      customCategories: customCategories ?? this.customCategories,
    );
  }

  @override
  List<Object?> get props => [themeMode, accentColorIndex, locale, customCategories];
}
