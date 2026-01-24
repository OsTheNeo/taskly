import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:radix_icons/radix_icons.dart';
import 'package:signals/signals_flutter.dart';
import '../services/injection.dart';
import '../services/auth_service.dart';
import '../state/settings_state.dart' as settings;
import '../l10n/app_localizations.dart';
import '../widgets/ui/ui.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  final _picker = ImagePicker();

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
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(RadixIcons.Camera),
              title: Text(l10n.camera),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(RadixIcons.Image),
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
    final l10n = S.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        elevation: 0,
        title: Text(
          l10n.profile,
          style: TextStyle(
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoggedIn ? _buildLoggedInView(context, isDark) : _buildLoggedOutView(context, isDark),
    );
  }

  Widget _buildLoggedOutView(BuildContext context, bool isDark) {
    final l10n = S.of(context)!;

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
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              RadixIcons.Person,
              size: 32,
              color: AppColors.primary,
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
            RadixIcons.Update,
            l10n.cloudSync,
            l10n.cloudSyncDesc,
            isDark,
          ),
          _buildBenefitItem(
            RadixIcons.Download,
            l10n.autoBackup,
            l10n.autoBackupDesc,
            isDark,
          ),
          _buildBenefitItem(
            RadixIcons.Person,
            l10n.sharedTasks,
            l10n.sharedTasksDesc,
            isDark,
          ),
          _buildBenefitItem(
            RadixIcons.Dashboard,
            l10n.advancedStats,
            l10n.advancedStatsDesc,
            isDark,
          ),

          const SizedBox(height: 32),

          AppButton(
            label: l10n.login,
            fullWidth: true,
            icon: RadixIcons.Enter,
            onPressed: () => context.push('/auth'),
          ),

          const SizedBox(height: 12),

          AppButton(
            label: l10n.createAccount,
            fullWidth: true,
            variant: AppButtonVariant.outline,
            icon: RadixIcons.Plus,
            onPressed: () => context.push('/auth'),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String subtitle, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? AppColors.secondaryDark : AppColors.secondary,
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
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

    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        children: [
          // Profile header with photo
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
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
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryForeground,
                            ),
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.backgroundDark : AppColors.background,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      RadixIcons.Camera,
                      size: 14,
                      color: AppColors.primaryForeground,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            _currentUser?.displayName ?? 'Usuario',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),

          Text(
            _currentUser?.email ?? '',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),

          const SizedBox(height: 32),

          // Settings
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildSettingsItem(
                  RadixIcons.Bell,
                  l10n.notifications,
                  null,
                  () => _showNotificationsSettings(context, l10n, isDark),
                  isDark,
                ),
                _buildDivider(isDark),
                Watch((context) {
                  final currentThemeMode = settings.themeMode.value;
                  return _buildSettingsItem(
                    RadixIcons.Moon,
                    l10n.darkTheme,
                    null,
                    () {},
                    isDark,
                    trailing: Switch(
                      value: currentThemeMode == ThemeMode.dark ||
                          (currentThemeMode == ThemeMode.system && isDark),
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
                  RadixIcons.Globe,
                  l10n.language,
                  l10n.spanish,
                  () => _showLanguageSelector(context, l10n, isDark),
                  isDark,
                ),
                _buildDivider(isDark),
                _buildColorSelector(l10n, isDark),
              ],
            ),
          ),

          const SizedBox(height: 16),

          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildSettingsItem(
                  RadixIcons.Question_Mark_Circled,
                  l10n.help,
                  null,
                  () => _showHelpPage(context, l10n, isDark),
                  isDark,
                ),
                _buildDivider(isDark),
                _buildSettingsItem(
                  RadixIcons.Info_Circled,
                  l10n.about,
                  null,
                  () => _showAboutDialog(context, l10n, isDark),
                  isDark,
                ),
                _buildDivider(isDark),
                _buildSettingsItem(
                  RadixIcons.Exit,
                  l10n.logout,
                  null,
                  () => _showLogoutConfirmation(context, l10n, isDark),
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    String? subtitle,
    VoidCallback onTap,
    bool isDark, {
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
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
              Icon(
                RadixIcons.Chevron_Right,
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

  Widget _buildColorSelector(S l10n, bool isDark) {
    return Watch((context) {
      final currentIndex = settings.accentColorIndex.value;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  RadixIcons.Color_Wheel,
                  size: 22,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
                const SizedBox(width: 12),
                Text(
                  'Color de acento',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(settings.accentColors.length, (index) {
                final color = settings.accentColors[index];
                final isSelected = currentIndex == index;

                return GestureDetector(
                  onTap: () => settings.setAccentColor(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                              width: 2,
                            )
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            RadixIcons.Check,
                            size: 14,
                            color: index == 0
                                ? Colors.white
                                : (color.computeLuminance() > 0.5 ? Colors.black : Colors.white),
                          )
                        : null,
                  ),
                );
              }),
            ),
          ],
        ),
      );
    });
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
                  const SnackBar(content: Text('Sesión cerrada')),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
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
              activeTrackColor: AppColors.primary,
            ),
            SwitchListTile(
              title: const Text('Resumen diario'),
              value: false,
              onChanged: (v) {},
              activeTrackColor: AppColors.primary,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, S l10n, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Watch((context) {
        final currentLocale = settings.locale.value;
        final isSpanish = currentLocale.languageCode == 'es';
        return Padding(
          padding: const EdgeInsets.all(20),
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
                leading: const Text('', style: TextStyle(fontSize: 24)),
                title: Text(l10n.spanish),
                trailing: isSpanish
                    ? Icon(RadixIcons.Check, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  settings.setLocale(const Locale('es'));
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Text('', style: TextStyle(fontSize: 24)),
                title: Text(l10n.english),
                trailing: !isSpanish
                    ? Icon(RadixIcons.Check, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  settings.setLocale(const Locale('en'));
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 16),
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
              child: const Icon(
                RadixIcons.Check,
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
