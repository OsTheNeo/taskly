import 'package:flutter/material.dart';

/// Shadcn color palette - monochrome black/white primary
abstract class AppColors {
  // Background colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF09090B);

  static const Color foreground = Color(0xFF09090B);
  static const Color foregroundDark = Color(0xFFFAFAFA);

  // Card colors
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF09090B);

  // Primary colors - BLACK in light mode, WHITE in dark mode (shadcn style)
  static const Color primary = Color(0xFF18181B);
  static const Color primaryDark = Color(0xFFFAFAFA);
  static const Color primaryForeground = Color(0xFFFAFAFA);
  static const Color primaryForegroundDark = Color(0xFF18181B);

  // Secondary colors
  static const Color secondary = Color(0xFFF4F4F5);
  static const Color secondaryDark = Color(0xFF27272A);
  static const Color secondaryForeground = Color(0xFF18181B);
  static const Color secondaryForegroundDark = Color(0xFFFAFAFA);

  // Muted colors
  static const Color muted = Color(0xFFF4F4F5);
  static const Color mutedDark = Color(0xFF27272A);
  static const Color mutedForeground = Color(0xFF71717A);
  static const Color mutedForegroundDark = Color(0xFFA1A1AA);

  // Accent colors
  static const Color accent = Color(0xFFF4F4F5);
  static const Color accentDark = Color(0xFF27272A);
  static const Color accentForeground = Color(0xFF18181B);
  static const Color accentForegroundDark = Color(0xFFFAFAFA);

  // Success colors
  static const Color success = Color(0xFF22C55E);
  static const Color successForeground = Color(0xFFFFFFFF);

  // Destructive colors
  static const Color destructive = Color(0xFFEF4444);
  static const Color destructiveForeground = Color(0xFFFAFAFA);
  static const Color destructiveDark = Color(0xFF7F1D1D);
  static const Color destructiveForegroundDark = Color(0xFFFAFAFA);

  // Warning colors
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningForeground = Color(0xFFFFFFFF);

  // Border colors
  static const Color border = Color(0xFFE4E4E7);
  static const Color borderDark = Color(0xFF27272A);

  // Input colors
  static const Color input = Color(0xFFE4E4E7);
  static const Color inputDark = Color(0xFF27272A);

  // Ring (focus) color - matches primary
  static const Color ring = Color(0xFF18181B);
  static const Color ringDark = Color(0xFFD4D4D8);
}
