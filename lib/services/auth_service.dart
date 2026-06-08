import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../core/errors/app_exception.dart';

class AuthService {
  final _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<bool> signInWithGoogle() async {
    try {
      return await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'boloo://auth/callback',
      );
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<void> signInWithPhone(String phone) async {
    try {
      await _client.auth.signInWithOtp(phone: phone);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<AuthResponse> verifyPhoneOtp(String phone, String token) async {
    try {
      return await _client.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<AuthResponse> signUpWithEmail(String email, String password, String name) async {
    try {
      return await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
