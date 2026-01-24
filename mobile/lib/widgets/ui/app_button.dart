import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, destructive }
enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(),
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor: _getBackgroundColor(isDark),
          foregroundColor: _getForegroundColor(isDark),
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
            side: _getBorderSide(isDark),
          ),
          disabledBackgroundColor: _getBackgroundColor(isDark)?.withValues(alpha: 0.5),
        ),
        child: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _getForegroundColor(isDark),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: _getIconSize()),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: _getFontSize(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.sm:
        return 36;
      case AppButtonSize.md:
        return 40;
      case AppButtonSize.lg:
        return 48;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case AppButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case AppButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    }
  }

  double _getFontSize() {
    switch (size) {
      case AppButtonSize.sm:
        return 13;
      case AppButtonSize.md:
        return 14;
      case AppButtonSize.lg:
        return 16;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.sm:
        return 14;
      case AppButtonSize.md:
        return 16;
      case AppButtonSize.lg:
        return 18;
    }
  }

  Color? _getBackgroundColor(bool isDark) {
    switch (variant) {
      case AppButtonVariant.primary:
        return isDark ? AppColors.primaryDark : AppColors.primary;
      case AppButtonVariant.secondary:
        return isDark ? AppColors.secondaryDark : AppColors.secondary;
      case AppButtonVariant.outline:
      case AppButtonVariant.ghost:
        return Colors.transparent;
      case AppButtonVariant.destructive:
        return AppColors.destructive;
    }
  }

  Color _getForegroundColor(bool isDark) {
    switch (variant) {
      case AppButtonVariant.primary:
        return isDark ? AppColors.primaryForegroundDark : AppColors.primaryForeground;
      case AppButtonVariant.secondary:
        return isDark ? AppColors.secondaryForegroundDark : AppColors.secondaryForeground;
      case AppButtonVariant.outline:
      case AppButtonVariant.ghost:
        return isDark ? AppColors.foregroundDark : AppColors.foreground;
      case AppButtonVariant.destructive:
        return AppColors.destructiveForeground;
    }
  }

  BorderSide _getBorderSide(bool isDark) {
    if (variant == AppButtonVariant.outline) {
      return BorderSide(
        color: isDark ? AppColors.borderDark : AppColors.border,
        width: 1,
      );
    }
    return BorderSide.none;
  }
}
