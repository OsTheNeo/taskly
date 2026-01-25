import 'package:flutter/material.dart';
import '../widgets/ui/duotone_icon.dart';

/// Available icons for categories (now using DuotoneIcon names)
class CategoryIcons {
  static const Map<String, String> icons = {
    'bookmark': DuotoneIcon.bookmark,
    'star': DuotoneIcon.sparkle,
    'rocket': DuotoneIcon.rocket,
    'target': DuotoneIcon.target,
    'home': DuotoneIcon.home,
    'user': DuotoneIcon.user,
    'users': DuotoneIcon.users,
    'gear': DuotoneIcon.gear,
    'timer': DuotoneIcon.timer,
    'heart': DuotoneIcon.heart,
    'gauge': DuotoneIcon.gauge,
    'book': DuotoneIcon.book,
    'wallet': DuotoneIcon.wallet,
    'feather': DuotoneIcon.feather,
    'leaf': DuotoneIcon.leaf,
    'flame': DuotoneIcon.flame,
    'chart': DuotoneIcon.chart,
    'bolt': DuotoneIcon.bolt,
  };

  static String fromString(String? key) {
    return icons[key] ?? DuotoneIcon.bookmark;
  }

  static String? toKey(String iconName) {
    for (final entry in icons.entries) {
      if (entry.value == iconName) return entry.key;
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

  static Color? fromHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return null;
    }
  }

  static String toHex(Color color) {
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }
}

/// Task category model
class TaskCategory {
  final String id;
  final String name;
  final String iconName; // DuotoneIcon name
  final Color accentColor;

  const TaskCategory({
    required this.id,
    required this.name,
    required this.iconName,
    required this.accentColor,
  });

  TaskCategory copyWith({
    String? id,
    String? name,
    String? iconName,
    Color? accentColor,
  }) {
    return TaskCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': CategoryIcons.toKey(iconName),
      'accentColor': CategoryColors.toHex(accentColor),
    };
  }

  factory TaskCategory.fromJson(Map<String, dynamic> json) {
    return TaskCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      iconName: CategoryIcons.fromString(json['icon'] as String?),
      accentColor: CategoryColors.fromHex(json['accentColor'] as String?) ?? const Color(0xFF18181B),
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
      iconName: DuotoneIcon.heart,
      accentColor: const Color(0xFFEF4444), // Red
    ),
    TaskCategory(
      id: 'fitness',
      name: 'Ejercicio',
      iconName: DuotoneIcon.timer,
      accentColor: const Color(0xFFF97316), // Orange
    ),
    TaskCategory(
      id: 'work',
      name: 'Trabajo',
      iconName: DuotoneIcon.gauge,
      accentColor: const Color(0xFF3B82F6), // Blue
    ),
    TaskCategory(
      id: 'study',
      name: 'Estudio',
      iconName: DuotoneIcon.book,
      accentColor: const Color(0xFF8B5CF6), // Violet
    ),
    TaskCategory(
      id: 'personal',
      name: 'Personal',
      iconName: DuotoneIcon.user,
      accentColor: const Color(0xFF6366F1), // Indigo
    ),
    TaskCategory(
      id: 'home',
      name: 'Hogar',
      iconName: DuotoneIcon.home,
      accentColor: const Color(0xFF14B8A6), // Teal
    ),
    TaskCategory(
      id: 'finance',
      name: 'Finanzas',
      iconName: DuotoneIcon.wallet,
      accentColor: const Color(0xFF22C55E), // Green
    ),
    TaskCategory(
      id: 'social',
      name: 'Social',
      iconName: DuotoneIcon.users,
      accentColor: const Color(0xFFEC4899), // Pink
    ),
    TaskCategory(
      id: 'creativity',
      name: 'Creatividad',
      iconName: DuotoneIcon.feather,
      accentColor: const Color(0xFFF59E0B), // Amber
    ),
    TaskCategory(
      id: 'mindfulness',
      name: 'Bienestar',
      iconName: DuotoneIcon.leaf,
      accentColor: const Color(0xFF06B6D4), // Cyan
    ),
    TaskCategory(
      id: 'other',
      name: 'Otros',
      iconName: DuotoneIcon.bookmark,
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
