import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../shared/models/task_category.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  static const String _boxName = 'settings';
  static const String _themeModeKey = 'themeMode';
  static const String _accentColorKey = 'accentColor';
  static const String _localeKey = 'locale';
  static const String _customCategoriesKey = 'customCategories';

  SettingsCubit() : super(const SettingsState());

  Future<void> init() async {
    await Hive.initFlutter();
    final box = await Hive.openBox(_boxName);

    final themeModeIndex = box.get(_themeModeKey, defaultValue: 0) as int;
    final accentColorIndex = box.get(_accentColorKey, defaultValue: 0) as int;
    final localeCode = box.get(_localeKey, defaultValue: 'es') as String;
    final customCategoriesJson = box.get(_customCategoriesKey, defaultValue: '[]') as String;

    List<TaskCategory> customCategories = [];
    try {
      final List<dynamic> decoded = jsonDecode(customCategoriesJson);
      customCategories = decoded.map((item) => TaskCategory.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {}

    emit(SettingsState(
      themeMode: ThemeMode.values[themeModeIndex],
      accentColorIndex: accentColorIndex,
      locale: Locale(localeCode),
      customCategories: customCategories,
    ));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_themeModeKey, mode.index);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setAccentColor(int index) async {
    if (index < 0 || index >= SettingsState.accentColors.length) return;
    final box = await Hive.openBox(_boxName);
    await box.put(_accentColorKey, index);
    emit(state.copyWith(accentColorIndex: index));
  }

  Future<void> setLocale(Locale locale) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_localeKey, locale.languageCode);
    emit(state.copyWith(locale: locale));
  }

  Future<void> addCategory(TaskCategory category) async {
    final newCategories = [...state.customCategories, category];
    await _saveCategories(newCategories);
    emit(state.copyWith(customCategories: newCategories));
  }

  Future<void> updateCategory(TaskCategory category) async {
    final newCategories = state.customCategories.map((c) {
      return c.id == category.id ? category : c;
    }).toList();
    await _saveCategories(newCategories);
    emit(state.copyWith(customCategories: newCategories));
  }

  Future<void> deleteCategory(String categoryId) async {
    final newCategories = state.customCategories.where((c) => c.id != categoryId).toList();
    await _saveCategories(newCategories);
    emit(state.copyWith(customCategories: newCategories));
  }

  Future<void> _saveCategories(List<TaskCategory> categories) async {
    final box = await Hive.openBox(_boxName);
    final json = jsonEncode(categories.map((c) => c.toJson()).toList());
    await box.put(_customCategoriesKey, json);
  }
}
