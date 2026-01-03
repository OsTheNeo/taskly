# Integracion de Autenticacion Social

Este documento explica como configurar la autenticacion con Google y Apple en Taskly.

## Requisitos Previos

1. Tener configurado Supabase con las credenciales en `lib/core/config/supabase_config.dart`
2. Configurar las apps en las consolas de desarrollador correspondientes

## Google Sign In

### 1. Configurar en Google Cloud Console

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Ve a **APIs & Services > Credentials**
4. Crea credenciales **OAuth 2.0 Client ID**:
   - Para Android: Necesitas el SHA-1 de tu keystore
   - Para iOS: Necesitas el Bundle ID

### 2. Configurar en Supabase

1. En el dashboard de Supabase, ve a **Authentication > Providers**
2. Habilita **Google**
3. Ingresa el **Client ID** y **Client Secret** de Google Cloud

### 3. Agregar dependencia

```yaml
dependencies:
  google_sign_in: ^6.2.1
```

### 4. Implementar en Flutter

```dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> signInWithGoogle() async {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: 'TU_GOOGLE_CLIENT_ID.apps.googleusercontent.com',
  );

  final googleUser = await googleSignIn.signIn();
  if (googleUser == null) return;

  final googleAuth = await googleUser.authentication;
  final accessToken = googleAuth.accessToken;
  final idToken = googleAuth.idToken;

  if (accessToken == null || idToken == null) {
    throw Exception('No se pudo obtener tokens de Google');
  }

  await Supabase.instance.client.auth.signInWithIdToken(
    provider: OAuthProvider.google,
    idToken: idToken,
    accessToken: accessToken,
  );
}
```

### 5. Configuracion Android

En `android/app/build.gradle.kts`:

```kotlin
defaultConfig {
    // ...
}
```

En `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <application>
        <!-- ... -->
    </application>
</manifest>
```

## Apple Sign In

### 1. Configurar en Apple Developer

1. Ve a [Apple Developer](https://developer.apple.com/)
2. En **Certificates, Identifiers & Profiles**
3. Crea un **App ID** con Sign In with Apple habilitado
4. Crea un **Service ID** para web (necesario para Supabase)
5. Crea una **Key** para Sign In with Apple

### 2. Configurar en Supabase

1. En el dashboard de Supabase, ve a **Authentication > Providers**
2. Habilita **Apple**
3. Ingresa:
   - **Service ID** (Bundle ID para iOS)
   - **Team ID**
   - **Key ID**
   - **Private Key** (el contenido del archivo .p8)

### 3. Agregar dependencia

```yaml
dependencies:
  sign_in_with_apple: ^6.1.1
```

### 4. Implementar en Flutter

```dart
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> signInWithApple() async {
  final credential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
  );

  final idToken = credential.identityToken;
  if (idToken == null) {
    throw Exception('No se pudo obtener el token de Apple');
  }

  await Supabase.instance.client.auth.signInWithIdToken(
    provider: OAuthProvider.apple,
    idToken: idToken,
  );
}
```

### 5. Configuracion iOS

En `ios/Runner/Runner.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.applesignin</key>
    <array>
        <string>Default</string>
    </array>
</dict>
</plist>
```

## Flujo Completo de Auth

```dart
class AuthService {
  final _supabase = Supabase.instance.client;

  // Estado del usuario
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
  User? get currentUser => _supabase.auth.currentUser;

  // Login con email
  Future<void> signInWithEmail(String email, String password) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Registro con email
  Future<void> signUpWithEmail(String email, String password, String name) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
  }

  // Logout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Recuperar contrasena
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}
```

## Notas Importantes

- Para desarrollo local, puedes usar el emulador de Supabase
- En produccion, asegurate de configurar las URLs de callback correctamente
- Apple Sign In solo funciona en dispositivos iOS fisicos, no en simulador
- Google Sign In requiere la configuracion del SHA-1 fingerprint para Android

## Recursos

- [Supabase Auth Docs](https://supabase.com/docs/guides/auth)
- [Google Sign In Flutter](https://pub.dev/packages/google_sign_in)
- [Sign In with Apple Flutter](https://pub.dev/packages/sign_in_with_apple)
