import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';

final supabaseProvider = Provider((ref) => Supabase.instance.client);

final authProvider = ChangeNotifierProvider((ref) {
  final supabase = ref.watch(supabaseProvider);
  return AuthNotifier(supabase);
});


class AuthNotifier extends ChangeNotifier {
  final SupabaseClient _supabase;
  User? _state;

  AuthNotifier(this._supabase) : _state = null {
    checkAuthStatus();
  }

  User? get user => _state;

  void _setUser(User? newUser) {
    _state = newUser;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    final user = response.user;
    if (user == null) throw 'No user returned from Supabase';
    
    _setUser(user);
  }

  Future<void> signUp(String email, String password) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );
    
    final user = response.user;
    if (user == null) throw 'No user returned from Supabase';
    
    _setUser(user);
  }

  String _generateRandomString() {
    final random = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signInWithApple(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    final rawNonce = _generateRandomString();
    final nonce = _sha256ofString(rawNonce);
    
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );
    
    final idToken = credential.identityToken;
    if (idToken == null) {
      throw 'No identity token returned from Apple';
    }
    
    final response = await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
    
    final user = response.user;
    if (user == null) {
      throw 'No user returned from Supabase';
    }
    
    if (context.mounted) Navigator.of(context).pop();
    
    _setUser(user);
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    
    if (googleUser == null) {
      throw 'Google Sign In was canceled';
    }
    
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;
    
    if (accessToken == null || idToken == null) {
      throw 'Could not get auth tokens from Google Sign In';
    }
    
    final response = await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
    
    final user = response.user;
    if (user == null) {
      throw 'No user returned from Supabase';
    }
    
    if (context.mounted) Navigator.of(context).pop();
    
    _setUser(user);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _setUser(null);
  }

  Future<void> checkAuthStatus() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      _setUser(currentUser);
    } catch (e) {
      _setUser(null);
    }
  }

  Future<void> signInWithPhone(String phoneNumber) async {
    await _supabase.auth.signInWithOtp(
      phone: phoneNumber,
    );
    print('OTP sent successfully');
  }

  Future<void> verifyOTP(String phoneNumber, String otp) async {
    final response = await _supabase.auth.verifyOTP(
      phone: phoneNumber,
      token: otp,
      type: OtpType.sms,
    );
    
    final user = response.user;
    if (user == null) throw 'No user returned from Supabase';
    // LogController.signedInCallback().then((value) {
    //   print('User ${user.phone} signed in');
    //   LogController.logNavigation('User ${user.phone} signed in');
    // });
    _setUser(user);
  }
} 