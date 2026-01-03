import 'package:flutter/material.dart';
import 'package:radix_icons/radix_icons.dart';

/// Available icons for categories
class CategoryIcons {
  static const Map<String, IconData> icons = {
    'bookmark': RadixIcons.Bookmark,
    'star': RadixIcons.Star,
    'star_filled': RadixIcons.Star_Filled,
    'lightning': RadixIcons.Lightning_Bolt,
    'rocket': RadixIcons.Rocket,
    'target': RadixIcons.Target,
    'pencil': RadixIcons.Pencil_1,
    'reader': RadixIcons.Reader,
    'backpack': RadixIcons.Backpack,
    'home': RadixIcons.Home,
    'person': RadixIcons.Person,
    'chat': RadixIcons.Chat_Bubble,
    'camera': RadixIcons.Camera,
    'video': RadixIcons.Video,
    'file': RadixIcons.File,
    'code': RadixIcons.Code,
    'gear': RadixIcons.Gear,
    'sun': RadixIcons.Sun,
    'moon': RadixIcons.Moon,
    'timer': RadixIcons.Timer,
    'activity': RadixIcons.Activity_Log,
    'dashboard': RadixIcons.Dashboard,
  };

  static IconData fromString(String? key) {
    return icons[key] ?? RadixIcons.Bookmark;
  }

  static String? toKey(IconData icon) {
    for (final entry in icons.entries) {
      if (entry.value == icon) return entry.key;
    }
    return 'bookmark';
  }
}

/// Predefined accent colors for categories
class CategoryColors {
  static const List<Color> accentColors = [
    Color(0xFF18181B), // Black (default)
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Pink
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFFF59E0B), // Amber
    Color(0xFF84CC16), // Lime
    Color(0xFF22C55E), // Green
    Color(0xFF14B8A6), // Teal
    Color(0xFF06B6D4), // Cyan
    Color(0xFF3B82F6), // Blue
  ];

  static Color fromHex(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  static String toHex(Color color) {
    final r = color.r.toInt().toRadixString(16).padLeft(2, '0');
    final g = color.g.toInt().toRadixString(16).padLeft(2, '0');
    final b = color.b.toInt().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }
}

/// Task category model
class TaskCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color accentColor;

  const TaskCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.accentColor,
  });

  TaskCategory copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? accentColor,
  }) {
    return TaskCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': CategoryIcons.toKey(icon),
      'accentColor': CategoryColors.toHex(accentColor),
    };
  }

  factory TaskCategory.fromJson(Map<String, dynamic> json) {
    return TaskCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: CategoryIcons.fromString(json['icon'] as String?),
      accentColor: CategoryColors.fromHex(json['accentColor'] as String),
    );
  }
}

/// Predefined categories
class PredefinedCategories {
  static const _defaultColor = Color(0xFF18181B);

  static List<TaskCategory> get all => [
    TaskCategory(
      id: 'health',
      name: 'Salud',
      icon: RadixIcons.Activity_Log,
      accentColor: const Color(0xFFEF4444), // Red
    ),
    TaskCategory(
      id: 'fitness',
      name: 'Ejercicio',
      icon: RadixIcons.Timer,
      accentColor: const Color(0xFFF97316), // Orange
    ),
    TaskCategory(
      id: 'work',
      name: 'Trabajo',
      icon: RadixIcons.Dashboard,
      accentColor: const Color(0xFF3B82F6), // Blue
    ),
    TaskCategory(
      id: 'study',
      name: 'Estudio',
      icon: RadixIcons.Reader,
      accentColor: const Color(0xFF8B5CF6), // Violet
    ),
    TaskCategory(
      id: 'personal',
      name: 'Personal',
      icon: RadixIcons.Person,
      accentColor: const Color(0xFF6366F1), // Indigo
    ),
    TaskCategory(
      id: 'home',
      name: 'Hogar',
      icon: RadixIcons.Home,
      accentColor: const Color(0xFF14B8A6), // Teal
    ),
    TaskCategory(
      id: 'finance',
      name: 'Finanzas',
      icon: RadixIcons.Backpack,
      accentColor: const Color(0xFF22C55E), // Green
    ),
    TaskCategory(
      id: 'social',
      name: 'Social',
      icon: RadixIcons.Chat_Bubble,
      accentColor: const Color(0xFFEC4899), // Pink
    ),
    TaskCategory(
      id: 'creativity',
      name: 'Creatividad',
      icon: RadixIcons.Pencil_1,
      accentColor: const Color(0xFFF59E0B), // Amber
    ),
    TaskCategory(
      id: 'mindfulness',
      name: 'Bienestar',
      icon: RadixIcons.Sun,
      accentColor: const Color(0xFF06B6D4), // Cyan
    ),
    TaskCategory(
      id: 'other',
      name: 'Otros',
      icon: RadixIcons.Bookmark,
      accentColor: _defaultColor,
    ),
  ];

  static TaskCategory getById(String id) {
    return all.firstWhere(
      (c) => c.id == id,
      orElse: () => all.last,
    );
  }

  static TaskCategory get defaultCategory => all.firstWhere((c) => c.id == 'personal');
}
