import 'package:flutter/material.dart';
import 'package:radix_icons/radix_icons.dart';
import '../l10n/app_localizations.dart';
import '../widgets/ui/ui.dart';
import 'profile_page.dart';
import 'groups_page.dart';
import 'home_page.dart';
import 'stats_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _previousIndex = 0;

  late List<AnimationController> _controllers;
  late List<Animation<double>> _expandAnimations;
  late List<Animation<double>> _labelAnimations;

  final List<Widget> _pages = const [
    HomePage(),
    GroupsPage(),
    StatsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      4,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 350),
        vsync: this,
      ),
    );

    _expandAnimations = _controllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      );
    }).toList();

    _labelAnimations = _controllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      );
    }).toList();

    // Start animation for initial selected tab
    _controllers[_currentIndex].forward();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });

    // Animate out the previous tab
    _controllers[_previousIndex].reverse();
    // Animate in the new tab
    _controllers[index].forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = S.of(context)!;

    final labels = [l10n.today, l10n.tasks, 'Stats', l10n.profile];
    final icons = [RadixIcons.Home, RadixIcons.Checkbox, RadixIcons.Activity_Log, RadixIcons.Person];

    return Scaffold(
      body: Stack(
        children: [
          // Animated page transitions
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final offsetAnimation = Tween<Offset>(
                begin: Offset(_currentIndex > _previousIndex ? 0.05 : -0.05, 0),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: offsetAnimation,
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_currentIndex),
              child: _pages[_currentIndex],
            ),
          ),
          // Floating bottom navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 12,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF18181B) : Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int index = 0; index < 4; index++) ...[
                      if (index > 0) const SizedBox(width: 16),
                      _AnimatedNavItem(
                        index: index,
                        icon: icons[index],
                        label: labels[index],
                        isDark: isDark,
                        expandAnimation: _expandAnimations[index],
                        labelAnimation: _labelAnimations[index],
                        onTap: () => _onTabChanged(index),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedNavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool isDark;
  final Animation<double> expandAnimation;
  final Animation<double> labelAnimation;
  final VoidCallback onTap;

  const _AnimatedNavItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.isDark,
    required this.expandAnimation,
    required this.labelAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use subtle accent - only for selected state, keep it minimal
    final foregroundColor = isDark ? AppColors.foregroundDark : AppColors.foreground;
    final mutedColor = isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: expandAnimation,
        builder: (context, child) {
          final progress = expandAnimation.value;

          // Calculate label width based on animation
          final labelWidth = _measureTextWidth(label, context) + 24;
          final totalWidth = 40 + (labelWidth * progress);

          return Container(
            height: 40,
            width: totalWidth,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.secondaryDark : AppColors.secondary)
                  .withValues(alpha: progress * 0.8),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Stack(
              children: [
                // Circle with icon
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        Colors.transparent,
                        foregroundColor,
                        progress,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: progress > 0.5 ? 18 : 22,
                      color: Color.lerp(
                        mutedColor,
                        isDark ? AppColors.backgroundDark : AppColors.background,
                        progress,
                      ),
                    ),
                  ),
                ),
                // Animated label
                if (progress > 0)
                  Positioned(
                    left: 48,
                    top: 0,
                    bottom: 0,
                    right: 0,
                    child: AnimatedBuilder(
                      animation: labelAnimation,
                      builder: (context, _) {
                        final labelProgress = labelAnimation.value;
                        final visibleChars = (label.length * labelProgress).ceil();
                        final visibleText = label.substring(0, visibleChars);

                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Opacity(
                            opacity: progress,
                            child: Text(
                              visibleText,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: foregroundColor,
                              ),
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  double _measureTextWidth(String text, BuildContext context) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }
}
