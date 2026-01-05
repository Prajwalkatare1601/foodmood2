import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';


final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(Supabase.instance.client);
});

class AuthController {
  final SupabaseClient _client;

  static const String _webClientId =
      "480093477681-9jotg4seg4ki2nm6uuqrlhgrb2vm6d4c.apps.googleusercontent.com";

  AuthController(this._client);

  // ================= GOOGLE SIGN IN =================

  Future<bool> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn.instance;

      // REQUIRED for google_sign_in v6+
      await googleSignIn.initialize(
        serverClientId: _webClientId,
      );

      final googleUser = await googleSignIn.authenticate();
      if (googleUser == null) {
        return false;
      }

      final googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw 'Missing Google ID token';
      }

final response = await _client.auth.signInWithIdToken(
  provider: OAuthProvider.google,
  idToken: googleAuth.idToken!,
);


      return response.session != null;
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      return false;
    }
  }

  // ================= EMAIL SIGN IN =================

  Future<void> signInWithEmail(String email) async {
    await _client.auth.signInWithOtp(email: email);
  }

  // ================= PHONE SIGN IN =================

  Future<void> signInWithPhone(String phone) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  // ================= OTP VERIFICATION =================

  Future<void> verifyOtp({
    required String otp,
    required String phoneOrEmail,
    required bool isPhone,
  }) async {
    await _client.auth.verifyOTP(
      token: otp,
      type: isPhone ? OtpType.sms : OtpType.email,
      phone: isPhone ? phoneOrEmail : null,
      email: isPhone ? null : phoneOrEmail,
    );
  }

  // ================= First Time user =================
  Future<bool> isFirstTimeUser() async {
  final user = _client.auth.currentUser;
  if (user == null) return true;

  final response = await _client
      .from('profiles')
      .select('onboarding_completed')
      .eq('id', user.id)
      .maybeSingle();

  // If no profile row → first time
  if (response == null) return true;

  return response['onboarding_completed'] != true;
}


  // ================= CURRENT USER =================

  User? get currentUser => _client.auth.currentUser;
}
