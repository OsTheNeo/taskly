import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'injection.dart';
import 'data_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Sincroniza el perfil del usuario a Supabase
  Future<void> _syncProfileToSupabase(User user) async {
    try {
      final dataService = getIt<DataService>();
      await dataService.upsertProfile(
        firebaseUid: user.uid,
        email: user.email,
        displayName: user.displayName,
        avatarUrl: user.photoURL,
      );
      debugPrint('[AuthService] Perfil sincronizado a Supabase');
    } catch (e) {
      debugPrint('[AuthService] Error sincronizando perfil: $e');
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      debugPrint('[AuthService] Paso 1: Llamando googleSignIn.signIn()...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      debugPrint('[AuthService] Paso 2: googleUser = $googleUser');

      if (googleUser == null) {
        debugPrint('[AuthService] Usuario canceló el login');
        return null;
      }

      debugPrint('[AuthService] Paso 3: Obteniendo authentication...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      debugPrint('[AuthService] Paso 4: accessToken = ${googleAuth.accessToken != null}');
      debugPrint('[AuthService] Paso 4: idToken = ${googleAuth.idToken != null}');

      debugPrint('[AuthService] Paso 5: Creando credential...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('[AuthService] Paso 6: Llamando signInWithCredential...');
      final result = await _firebaseAuth.signInWithCredential(credential);
      debugPrint('[AuthService] Paso 7: Login exitoso! User: ${result.user?.email}');

      // Sincronizar perfil a Supabase
      if (result.user != null) {
        await _syncProfileToSupabase(result.user!);
      }

      return result;
    } catch (e, stack) {
      debugPrint('[AuthService] ERROR: $e');
      debugPrint('[AuthService] STACK: $stack');
      rethrow;
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    final result = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Sincronizar perfil a Supabase
    if (result.user != null) {
      await _syncProfileToSupabase(result.user!);
    }

    return result;
  }

  Future<UserCredential> createUserWithEmail(
      String email, String password, {String? displayName}) async {
    final result = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Actualizar displayName si se proporciona
    if (displayName != null && result.user != null) {
      await result.user!.updateDisplayName(displayName);
    }

    // Sincronizar perfil a Supabase
    if (result.user != null) {
      await _syncProfileToSupabase(result.user!);
    }

    return result;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
