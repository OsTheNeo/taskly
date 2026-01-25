import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'duotone_icon.dart';

class AppInput extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final Widget? prefix;
  final Widget? suffix;
  final String? prefixIconName;
  final String? suffixIconName;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;

  const AppInput({
    super.key,
    this.label,
    this.placeholder,
    this.errorText,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.prefix,
    this.suffix,
    this.prefixIconName,
    this.suffixIconName,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onEditingComplete: onEditingComplete,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
            prefixIcon: prefix ?? (prefixIconName != null
                ? SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: DuotoneIcon(
                        prefixIconName!,
                        size: 22,
                        strokeColor: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        accentColor: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),
                  )
                : null),
            suffixIcon: suffix ?? (suffixIconName != null
                ? SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: DuotoneIcon(
                        suffixIconName!,
                        size: 22,
                        strokeColor: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        accentColor: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),
                  )
                : null),
            filled: true,
            fillColor: isDark ? AppColors.backgroundDark : AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusMd,
              borderSide: BorderSide(
                color: isDark ? AppColors.inputDark : AppColors.input,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusMd,
              borderSide: BorderSide(
                color: isDark ? AppColors.inputDark : AppColors.input,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusMd,
              borderSide: const BorderSide(
                color: AppColors.ring,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusMd,
              borderSide: const BorderSide(
                color: AppColors.destructive,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusMd,
              borderSide: const BorderSide(
                color: AppColors.destructive,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusMd,
              borderSide: BorderSide(
                color: (isDark ? AppColors.inputDark : AppColors.input).withValues(alpha: 0.5),
              ),
            ),
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}
