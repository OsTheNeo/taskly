import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

class AppCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final bool enabled;

  const AppCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primary;
    final primaryFgColor = isDark ? AppColors.primaryForegroundDark : AppColors.primaryForeground;

    final checkbox = GestureDetector(
      onTap: enabled ? () => onChanged?.call(!value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: value ? primaryColor : Colors.transparent,
          borderRadius: AppSpacing.borderRadiusXs,
          border: Border.all(
            color: value
                ? primaryColor
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: value ? 0 : 1.5,
          ),
        ),
        child: value
            ? Icon(
                Icons.check,
                size: 14,
                color: primaryFgColor,
              )
            : null,
      ),
    );

    if (label == null) return checkbox;

    return GestureDetector(
      onTap: enabled ? () => onChanged?.call(!value) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          checkbox,
          const SizedBox(width: 8),
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              color: enabled
                  ? (isDark ? AppColors.foregroundDark : AppColors.foreground)
                  : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
            ),
          ),
        ],
      ),
    );
  }
}

class AppCheckboxTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String title;
  final String? subtitle;
  final Widget? leading;
  final bool enabled;

  const AppCheckboxTile({
    super.key,
    required this.value,
    required this.title,
    this.onChanged,
    this.subtitle,
    this.leading,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: enabled ? () => onChanged?.call(!value) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      decoration: value ? TextDecoration.lineThrough : null,
                      color: value
                          ? (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground)
                          : (isDark ? AppColors.foregroundDark : AppColors.foreground),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AppCheckbox(
              value: value,
              onChanged: onChanged,
              enabled: enabled,
            ),
          ],
        ),
      ),
    );
  }
}
