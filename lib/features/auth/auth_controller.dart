import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(Supabase.instance.client);
});

class AuthController {
  final SupabaseClient _client;

  AuthController(this._client);

  // GOOGLE SIGN IN
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://login-callback/',
    );
  }

  // EMAIL SIGN IN
  Future<void> signInWithEmail(String email) async {
    await _client.auth.signInWithOtp(
      email: email,
    );
  }

  // PHONE SIGN IN
  Future<void> signInWithPhone(String phone) async {
    await _client.auth.signInWithOtp(
      phone: phone,
    );
  }

  //OPT Verification
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


  User? get currentUser => _client.auth.currentUser;
}
