import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:signals/signals_flutter.dart';

import '../models/task_category.dart';

// ============================================================
// SETTINGS SIGNALS
// ============================================================

final themeMode = signal(ThemeMode.system);
final accentColorIndex = signal(0);
final locale = signal(const Locale('es'));
final customCategories = signal(<TaskCategory>[]);

// ============================================================
// COMPUTED VALUES
// ============================================================

const List<Color> accentColors = [
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

Color get accentColor => accentColors[accentColorIndex.value];

List<TaskCategory> get allCategories => [
  ...PredefinedCategories.all,
  ...customCategories.value,
];

// ============================================================
// HIVE STORAGE
// ============================================================

const String _boxName = 'settings';
const String _themeModeKey = 'themeMode';
const String _accentColorKey = 'accentColor';
const String _localeKey = 'locale';
const String _customCategoriesKey = 'customCategories';

// ============================================================
// INITIALIZATION
// ============================================================

Future<void> initSettings() async {
  await Hive.initFlutter();
  final box = await Hive.openBox(_boxName);

  final themeModeIndex = box.get(_themeModeKey, defaultValue: 0) as int;
  final savedAccentColorIndex = box.get(_accentColorKey, defaultValue: 0) as int;
  final localeCode = box.get(_localeKey, defaultValue: 'es') as String;
  final customCategoriesJson = box.get(_customCategoriesKey, defaultValue: '[]') as String;

  List<TaskCategory> categories = [];
  try {
    final List<dynamic> decoded = jsonDecode(customCategoriesJson);
    categories = decoded.map((item) => TaskCategory.fromJson(item as Map<String, dynamic>)).toList();
  } catch (_) {}

  themeMode.value = ThemeMode.values[themeModeIndex];
  accentColorIndex.value = savedAccentColorIndex;
  locale.value = Locale(localeCode);
  customCategories.value = categories;
}

// ============================================================
// ACTIONS
// ============================================================

Future<void> setThemeMode(ThemeMode mode) async {
  final box = await Hive.openBox(_boxName);
  await box.put(_themeModeKey, mode.index);
  themeMode.value = mode;
}

Future<void> setAccentColor(int index) async {
  if (index < 0 || index >= accentColors.length) return;
  final box = await Hive.openBox(_boxName);
  await box.put(_accentColorKey, index);
  accentColorIndex.value = index;
}

Future<void> setLocale(Locale newLocale) async {
  final box = await Hive.openBox(_boxName);
  await box.put(_localeKey, newLocale.languageCode);
  locale.value = newLocale;
}

Future<void> addCategory(TaskCategory category) async {
  final newCategories = [...customCategories.value, category];
  await _saveCategories(newCategories);
  customCategories.value = newCategories;
}

Future<void> updateCategory(TaskCategory category) async {
  final newCategories = customCategories.value.map((c) {
    return c.id == category.id ? category : c;
  }).toList();
  await _saveCategories(newCategories);
  customCategories.value = newCategories;
}

Future<void> deleteCategory(String categoryId) async {
  final newCategories = customCategories.value.where((c) => c.id != categoryId).toList();
  await _saveCategories(newCategories);
  customCategories.value = newCategories;
}

Future<void> _saveCategories(List<TaskCategory> categories) async {
  final box = await Hive.openBox(_boxName);
  final json = jsonEncode(categories.map((c) => c.toJson()).toList());
  await box.put(_customCategoriesKey, json);
}
