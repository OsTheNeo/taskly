import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signals/signals_flutter.dart';
import '../services/injection.dart';
import '../services/auth_service.dart';
import '../state/settings_state.dart' as settings;
import '../l10n/app_localizations.dart';
import '../widgets/ui/ui.dart';
import 'stats_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  final _picker = ImagePicker();
  final _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  AuthService get _authService => getIt<AuthService>();
  User? get _currentUser => _authService.currentUser;
  bool get isLoggedIn => _currentUser != null;

  String _getInitials() {
    final name = _currentUser?.displayName ?? '';
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Future<void> _pickImage() async {
    final l10n = S.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = Theme.of(context).colorScheme.primary;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: DuotoneIcon(DuotoneIcon.camera, size: 22, strokeColor: isDark ? AppColors.foregroundDark : AppColors.foreground, fillColor: isDark ? AppColors.foregroundDark : AppColors.foreground, accentColor: accentColor),
              title: Text(l10n.camera),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: DuotoneIcon(DuotoneIcon.image, size: 22, strokeColor: isDark ? AppColors.foregroundDark : AppColors.foreground, fillColor: isDark ? AppColors.foregroundDark : AppColors.foreground, accentColor: accentColor),
              title: Text(l10n.gallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: isLoggedIn ? _buildLoggedInView(context, isDark) : _buildLoggedOutView(context, isDark),
    );
  }

  Widget _buildLoggedOutView(BuildContext context, bool isDark) {
    final l10n = S.of(context)!;
    final accentColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: DuotoneIcon(
              DuotoneIcon.user,
              size: 32,
              color: accentColor,
              accentColor: accentColor,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            l10n.loginToSync,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            l10n.syncBenefits,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),

          const SizedBox(height: 32),

          // Benefits
          _buildBenefitItem(
            DuotoneIcon.refresh,
            l10n.cloudSync,
            l10n.cloudSyncDesc,
            isDark,
            accentColor,
          ),
          _buildBenefitItem(
            DuotoneIcon.download,
            l10n.autoBackup,
            l10n.autoBackupDesc,
            isDark,
            accentColor,
          ),
          _buildBenefitItem(
            DuotoneIcon.users,
            l10n.sharedTasks,
            l10n.sharedTasksDesc,
            isDark,
            accentColor,
          ),
          _buildBenefitItem(
            DuotoneIcon.chart,
            l10n.advancedStats,
            l10n.advancedStatsDesc,
            isDark,
            accentColor,
          ),

          const SizedBox(height: 32),

          AppButton(
            label: l10n.login,
            fullWidth: true,
            iconName: DuotoneIcon.exit,
            onPressed: () => context.push('/auth'),
          ),

          const SizedBox(height: 12),

          AppButton(
            label: l10n.createAccount,
            fullWidth: true,
            variant: AppButtonVariant.outline,
            iconName: DuotoneIcon.userPlus,
            onPressed: () => context.push('/auth'),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String iconName, String title, String subtitle, bool isDark, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: DuotoneIcon(
              iconName,
              color: accentColor,
              accentColor: accentColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInView(BuildContext context, bool isDark) {
    final l10n = S.of(context)!;
    final accentColor = Theme.of(context).colorScheme.primary;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Calculate collapse progress (0 = expanded, 1 = collapsed)
    const expandedHeight = 160.0;
    const collapsedHeight = 56.0;
    final collapseProgress = (_scrollOffset / (expandedHeight - collapsedHeight)).clamp(0.0, 1.0);

    // Interpolated values
    final avatarSize = 80.0 - (44.0 * collapseProgress); // 80 -> 36
    final nameFontSize = 18.0 - (4.0 * collapseProgress); // 18 -> 14
    final emailOpacity = (1.0 - collapseProgress * 1.5).clamp(0.0, 1.0);
    final cameraOpacity = (1.0 - collapseProgress * 2).clamp(0.0, 1.0);
    final headerHeight = expandedHeight - ((expandedHeight - collapsedHeight) * collapseProgress);

    return Stack(
      children: [
        // Main scrollable content
        ListView(
          controller: _scrollController,
          padding: EdgeInsets.only(
            top: topPadding + expandedHeight + 24,
            left: 16,
            right: 16,
            bottom: bottomPadding + 100,
          ),
          children: [
            // Stats card
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSettingsItem(
                    DuotoneIcon.chart,
                    'Estadisticas',
                    null,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StatsPage()),
                    ),
                    isDark,
                    accentColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Settings
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSettingsItem(
                    DuotoneIcon.bell,
                    l10n.notifications,
                    null,
                    () => _showNotificationsSettings(context, l10n, isDark),
                    isDark,
                    accentColor,
                  ),
                  _buildDivider(isDark),
                  Watch((context) {
                    final currentThemeMode = settings.themeMode.value;
                    return _buildSettingsItem(
                      DuotoneIcon.sparkle,
                      l10n.darkTheme,
                      null,
                      () {},
                      isDark,
                      accentColor,
                      trailing: Switch(
                        value: currentThemeMode == ThemeMode.dark ||
                            (currentThemeMode == ThemeMode.system && isDark),
                        activeTrackColor: accentColor.withValues(alpha: 0.5),
                        activeThumbColor: accentColor,
                        onChanged: (v) {
                          settings.setThemeMode(
                            v ? ThemeMode.dark : ThemeMode.light,
                          );
                        },
                      ),
                    );
                  }),
                  _buildDivider(isDark),
                  _buildSettingsItem(
                    DuotoneIcon.globe,
                    l10n.language,
                    l10n.spanish,
                    () => _showLanguageSelector(context, l10n, isDark),
                    isDark,
                    accentColor,
                  ),
                  _buildDivider(isDark),
                  _buildColorSelector(l10n, isDark, accentColor),
                  _buildDivider(isDark),
                  _buildFontSelector(l10n, isDark, accentColor),
                ],
              ),
            ),

            const SizedBox(height: 16),

            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSettingsItem(
                    DuotoneIcon.info,
                    l10n.help,
                    null,
                    () => _showHelpPage(context, l10n, isDark),
                    isDark,
                    accentColor,
                  ),
                  _buildDivider(isDark),
                  _buildSettingsItem(
                    DuotoneIcon.info,
                    l10n.about,
                    null,
                    () => _showAboutDialog(context, l10n, isDark),
                    isDark,
                    accentColor,
                  ),
                  _buildDivider(isDark),
                  _buildSettingsItem(
                    DuotoneIcon.exit,
                    l10n.logout,
                    null,
                    () => _showLogoutConfirmation(context, l10n, isDark),
                    isDark,
                    accentColor,
                  ),
                ],
              ),
            ),
          ],
        ),

        // Floating collapsible header
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: topPadding + headerHeight,
            decoration: BoxDecoration(
              color: isDark ? AppColors.backgroundDark : AppColors.background,
              boxShadow: collapseProgress > 0.5
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Avatar
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            width: avatarSize,
                            height: avatarSize,
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                              image: _profileImage != null
                                  ? DecorationImage(
                                      image: FileImage(_profileImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : _currentUser?.photoURL != null
                                      ? DecorationImage(
                                          image: NetworkImage(_currentUser!.photoURL!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                            ),
                            child: _profileImage == null && _currentUser?.photoURL == null
                                ? Center(
                                    child: Text(
                                      _getInitials(),
                                      style: TextStyle(
                                        fontSize: avatarSize * 0.35,
                                        fontWeight: FontWeight.bold,
                                        color: accentColor.computeLuminance() > 0.5
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          // Camera button (fades out when collapsed)
                          if (cameraOpacity > 0)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Opacity(
                                opacity: cameraOpacity,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.cardDark : AppColors.card,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark ? AppColors.backgroundDark : AppColors.background,
                                      width: 2,
                                    ),
                                  ),
                                  child: DuotoneIcon(
                                    DuotoneIcon.camera,
                                    size: 12,
                                    strokeColor: accentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                                    fillColor: accentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                                    accentColor: accentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Name and email
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentUser?.displayName ?? 'Usuario',
                            style: TextStyle(
                              fontSize: nameFontSize,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (emailOpacity > 0)
                            Opacity(
                              opacity: emailOpacity,
                              child: Text(
                                _currentUser?.email ?? '',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    String iconName,
    String title,
    String? subtitle,
    VoidCallback onTap,
    bool isDark,
    Color accentColor, {
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: DuotoneIcon(
                  iconName,
                  size: 18,
                  strokeColor: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  fillColor: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  accentColor: accentColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
            if (trailing != null) trailing,
            if (trailing == null)
              DuotoneIcon(
                DuotoneIcon.chevronRight,
                size: 18,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      color: isDark ? AppColors.borderDark : AppColors.border,
    );
  }

  Widget _buildColorSelector(S l10n, bool isDark, Color currentAccent) {
    return _buildSettingsItem(
      DuotoneIcon.sparkle,
      'Color de acento',
      null,
      () => _showAccentColorModal(context, isDark),
      isDark,
      currentAccent,
      trailing: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: currentAccent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
      ),
    );
  }

  void _showAccentColorModal(BuildContext context, bool isDark) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Watch((context) {
        final currentIndex = settings.accentColorIndex.value;
        final selectedColor = settings.accentColors[currentIndex];

        return Container(
          margin: const EdgeInsets.all(16),
          padding: EdgeInsets.only(bottom: bottomPadding),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                'Color de acento',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),

              const SizedBox(height: 24),

              // Color grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: List.generate(settings.accentColors.length, (index) {
                    final color = settings.accentColors[index];
                    final isSelected = currentIndex == index;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        settings.setAccentColor(index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: isDark ? Colors.white : Colors.black,
                                  width: 3,
                                )
                              : Border.all(
                                  color: color.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: AnimatedScale(
                          scale: isSelected ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.check_rounded,
                            size: 22,
                            color: index == 0
                                ? Colors.white
                                : (color.computeLuminance() > 0.5 ? Colors.black : Colors.white),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 32),

              // Preview section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.backgroundDark
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vista previa',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Icon examples row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildIconPreview(DuotoneIcon.home, 'Inicio', selectedColor, isDark),
                        _buildIconPreview(DuotoneIcon.check, 'Tareas', selectedColor, isDark),
                        _buildIconPreview(DuotoneIcon.bell, 'Alertas', selectedColor, isDark),
                        _buildIconPreview(DuotoneIcon.user, 'Perfil', selectedColor, isDark),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Button preview
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selectedColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Botón de acción',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selectedColor.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildIconPreview(String iconName, String label, Color color, bool isDark) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: DuotoneIcon(
              iconName,
              size: 22,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              accentColor: color,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildFontSelector(S l10n, bool isDark, Color currentAccent) {
    return Watch((context) {
      final currentIndex = settings.fontFamilyIndex.value;
      final currentFontName = settings.fontFamilyNames[currentIndex];
      return _buildSettingsItem(
        DuotoneIcon.feather,
        'Tipografía',
        currentFontName,
        () => _showFontModal(context, isDark),
        isDark,
        currentAccent,
      );
    });
  }

  void _showFontModal(BuildContext context, bool isDark) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Watch((context) {
        final currentIndex = settings.fontFamilyIndex.value;
        final accentColor = Theme.of(context).colorScheme.primary;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: EdgeInsets.only(bottom: bottomPadding),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                'Tipografía',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),

              const SizedBox(height: 24),

              // Font options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: List.generate(settings.fontFamilies.length, (index) {
                    final fontName = settings.fontFamilyNames[index];
                    final isSelected = currentIndex == index;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        settings.setFontFamily(index);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? accentColor.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? accentColor
                                : (isDark ? AppColors.borderDark : AppColors.border),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fontName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.foregroundDark
                                          : AppColors.foreground,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Aa Bb Cc 123',
                                    style: _getFontPreviewStyle(index, isDark),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              DuotoneIcon(
                                DuotoneIcon.check,
                                size: 20,
                                color: accentColor,
                                accentColor: accentColor,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }

  TextStyle _getFontPreviewStyle(int index, bool isDark) {
    final color = isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground;
    switch (index) {
      case 1: // Open Sans
        return GoogleFonts.openSans(fontSize: 14, color: color);
      case 2: // Roboto Slab
        return GoogleFonts.robotoSlab(fontSize: 14, color: color);
      case 3: // Caveat
        return GoogleFonts.caveat(fontSize: 16, color: color);
      default: // System (Inter)
        return GoogleFonts.inter(fontSize: 14, color: color);
    }
  }

  void _showLogoutConfirmation(BuildContext context, S l10n, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
        title: Text(
          l10n.logout,
          style: TextStyle(
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: TextStyle(
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _authService.signOut();
              if (mounted) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Sesión cerrada'),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 80,
                      left: 16,
                      right: 16,
                    ),
                  ),
                );
              }
            },
            child: Text(
              l10n.logout,
              style: const TextStyle(color: AppColors.destructive),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationsSettings(BuildContext context, S l10n, bool isDark) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final accentColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.notifications,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Recordatorios de tareas'),
              value: true,
              onChanged: (v) {},
              activeTrackColor: accentColor.withValues(alpha: 0.5),
              activeThumbColor: accentColor,
            ),
            SwitchListTile(
              title: const Text('Resumen diario'),
              value: false,
              onChanged: (v) {},
              activeTrackColor: accentColor.withValues(alpha: 0.5),
              activeThumbColor: accentColor,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, S l10n, bool isDark) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Watch((context) {
        final currentLocale = settings.locale.value;
        final isSpanish = currentLocale.languageCode == 'es';
        final accentColor = Theme.of(context).colorScheme.primary;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.language,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Text('🇪🇸', style: TextStyle(fontSize: 24)),
                title: Text(l10n.spanish),
                trailing: isSpanish
                    ? DuotoneIcon(DuotoneIcon.check, size: 20, strokeColor: isDark ? AppColors.foregroundDark : AppColors.foreground, fillColor: isDark ? AppColors.foregroundDark : AppColors.foreground, accentColor: accentColor)
                    : null,
                onTap: () {
                  settings.setLocale(const Locale('es'));
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                title: Text(l10n.english),
                trailing: !isSpanish
                    ? DuotoneIcon(DuotoneIcon.check, size: 20, strokeColor: isDark ? AppColors.foregroundDark : AppColors.foreground, fillColor: isDark ? AppColors.foregroundDark : AppColors.foreground, accentColor: accentColor)
                    : null,
                onTap: () {
                  settings.setLocale(const Locale('en'));
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showHelpPage(BuildContext context, S l10n, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Text(
                l10n.help,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 20),
              _buildHelpItem('¿Cómo creo una tarea?', 'Toca el botón + en la pantalla principal y completa el formulario con los detalles de tu tarea.', isDark),
              _buildHelpItem('¿Cómo comparto tareas con otros?', 'Crea un grupo desde la pestaña Tareas, luego invita a otros usando el código de grupo.', isDark),
              _buildHelpItem('¿Cómo activo los recordatorios?', 'Al crear o editar una tarea, activa el switch de recordatorio y selecciona la hora deseada.', isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpItem(String title, String content, bool isDark) {
    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
        ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context, S l10n, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const DuotoneIcon(
                DuotoneIcon.check,
                size: 20,
                color: AppColors.primaryForeground,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Taskly',
              style: TextStyle(
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versión: 1.0.0',
              style: TextStyle(
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu asistente de productividad personal para gestionar tareas diarias y hábitos.',
              style: TextStyle(
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
