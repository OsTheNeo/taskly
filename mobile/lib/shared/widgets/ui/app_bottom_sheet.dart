import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showHandle;
  final EdgeInsets? padding;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showHandle = true,
    this.padding,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool showHandle = true,
    bool isScrollControlled = true,
    EdgeInsets? padding,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => AppBottomSheet(
        title: title,
        showHandle: showHandle,
        padding: padding,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showHandle) ...[
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.mutedDark : AppColors.muted,
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
              ),
            ],
            if (title != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
            ],
            Flexible(
              child: SingleChildScrollView(
                padding: padding ?? AppSpacing.paddingLg,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
