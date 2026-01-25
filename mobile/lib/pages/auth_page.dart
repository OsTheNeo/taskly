import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../services/injection.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/ui/ui.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  AuthService get _authService => getIt<AuthService>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = S.of(context)!;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              // Logo / Title
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DuotoneIcon(
                        DuotoneIcon.check,
                        size: 28,
                        color: isDark ? AppColors.primaryForegroundDark : AppColors.primaryForeground,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isLogin ? l10n.welcomeBack : l10n.createYourAccount,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isLogin
                          ? 'Ingresa tus credenciales'
                          : 'Completa los datos para comenzar',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Email/Password Form First
              if (!_isLogin) ...[
                AppInput(
                  label: l10n.name,
                  placeholder: l10n.namePlaceholder,
                  controller: _nameController,
                  prefixIconName: DuotoneIcon.user,
                ),
                const SizedBox(height: 16),
              ],

              AppInput(
                label: l10n.email,
                placeholder: l10n.emailPlaceholder,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIconName: DuotoneIcon.mail,
              ),
              const SizedBox(height: 16),

              AppInput(
                label: l10n.password,
                placeholder: l10n.passwordPlaceholder,
                controller: _passwordController,
                obscureText: true,
                prefixIconName: DuotoneIcon.password,
              ),

              if (_isLogin) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _handleForgotPassword,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.forgotPassword,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Submit Button
              AppButton(
                label: _isLogin ? l10n.login : l10n.createAccount,
                fullWidth: true,
                isLoading: _isLoading,
                onPressed: _handleEmailAuth,
              ),

              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'o',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Google Sign In Button
              _GoogleSignInButton(
                onPressed: _handleGoogleAuth,
                isLoading: _isGoogleLoading,
              ),

              const SizedBox(height: 32),

              // Toggle Login/Register
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin ? l10n.noAccount : l10n.haveAccount,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _isLogin ? l10n.register : l10n.login,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleAuth() async {
    setState(() => _isGoogleLoading = true);

    try {
      debugPrint('=== GOOGLE SIGN IN: Iniciando ===');
      final userCredential = await _authService.signInWithGoogle();
      debugPrint('=== GOOGLE SIGN IN: Resultado: $userCredential ===');

      if (userCredential != null && mounted) {
        debugPrint('=== GOOGLE SIGN IN: Éxito, navegando a home ===');
        context.go('/');
      } else {
        debugPrint('=== GOOGLE SIGN IN: userCredential es null ===');
      }
    } catch (e, stackTrace) {
      debugPrint('=== GOOGLE SIGN IN ERROR ===');
      debugPrint('Error tipo: ${e.runtimeType}');
      debugPrint('Error mensaje: $e');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('=== FIN ERROR ===');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar sesión: $e'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  void _handleForgotPassword() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = S.of(context)!;
    final resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
        title: Text(
          l10n.forgotPassword,
          style: TextStyle(
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ingresa tu correo electrónico y te enviaremos instrucciones para restablecer tu contraseña.',
              style: TextStyle(
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              decoration: InputDecoration(
                labelText: l10n.email,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) {
                return;
              }

              Navigator.pop(ctx);

              try {
                await _authService.sendPasswordResetEmail(email);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Instrucciones enviadas a tu correo'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } on FirebaseAuthException catch (e) {
                if (mounted) {
                  String message;
                  switch (e.code) {
                    case 'user-not-found':
                      message = 'No existe una cuenta con este email';
                      break;
                    case 'invalid-email':
                      message = 'El email no es valido';
                      break;
                    default:
                      message = 'Error: ${e.message}';
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: AppColors.destructive,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.destructive,
                    ),
                  );
                }
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEmailAuth() async {
    final l10n = S.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    // Validacion
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fillAllFields)),
      );
      return;
    }

    if (!_isLogin && name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa tu nombre')),
      );
      return;
    }

    // Validar formato de email
    if (!RegExp(r'^[\w\.\-\+]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un email valido')),
      );
      return;
    }

    // Validar password minimo 6 caracteres
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña debe tener al menos 6 caracteres')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // Login
        await _authService.signInWithEmail(email, password);
      } else {
        // Registro
        await _authService.createUserWithEmail(
          email,
          password,
          displayName: name,
        );
      }

      if (mounted) {
        context.go('/');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message;
        switch (e.code) {
          case 'user-not-found':
            message = 'No existe una cuenta con este email';
            break;
          case 'wrong-password':
            message = 'Contraseña incorrecta';
            break;
          case 'email-already-in-use':
            message = 'Ya existe una cuenta con este email';
            break;
          case 'weak-password':
            message = 'La contraseña es muy débil';
            break;
          case 'invalid-email':
            message = 'El email no es valido';
            break;
          case 'too-many-requests':
            message = 'Demasiados intentos. Intenta mas tarde';
            break;
          default:
            message = 'Error: ${e.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

}

class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const _GoogleSignInButton({
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
          side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/google.svg',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Continuar con Google',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
