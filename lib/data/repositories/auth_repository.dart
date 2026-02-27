import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../services/api_service.dart';
import '../services/secure_storage_service.dart';
import '../../core/constants/app_constants.dart';

class AuthRepository {
  final ApiService _api;
  AuthRepository({ApiService? api}) : _api = api ?? ApiService();

  /// Google Sign-In — sends ID token to backend, saves JWT tokens
  Future<void> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'profile',
      ],
      serverClientId: AppConstants.googleWebClientId.isNotEmpty
          ? AppConstants.googleWebClientId
          : null,
    );

    final account = await googleSignIn.signIn();
    if (account == null) {
      throw ApiException(message: 'Google Sign-In cancelled', statusCode: 0);
    }

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) {
      throw ApiException(message: 'No ID token from Google', statusCode: 0);
    }

    debugPrint('[AUTH] Google sign-in: email=${account.email}, serverAuthCode=${account.serverAuthCode != null}');

    final resp = await _api.post(
      '${AppConstants.authEndpoint}/google',
      data: {
        'id_token': idToken,
        if (account.serverAuthCode != null)
          'server_auth_code': account.serverAuthCode,
      },
    );
    final data = resp.data as Map<String, dynamic>;
    final accessToken = data['access_token'] as String;
    final refreshToken = data['refresh_token'] as String;

    await SecureStorageService.saveAccessToken(accessToken);
    await SecureStorageService.saveRefreshToken(refreshToken);
  }

  /// Send OTP to phone number. Returns OTP string if server returns it (debug mode).
  Future<String?> sendOtp(String phone) async {
    final resp = await _api.post(
      '${AppConstants.authEndpoint}/send-otp',
      data: {'phone_number': phone},
    );
    await SecureStorageService.savePhone(phone);
    final data = resp.data;
    if (data is Map && data['otp'] != null) {
      return data['otp'].toString();
    }
    return null;
  }

  /// Verify OTP — saves tokens to secure storage (user profile fetched separately)
  Future<void> verifyOtp(String phone, String otp) async {
    final resp = await _api.post(
      '${AppConstants.authEndpoint}/verify-otp',
      data: {'phone_number': phone, 'otp': otp},
    );
    final data = resp.data as Map<String, dynamic>;
    final accessToken = data['access_token'] as String;
    final refreshToken = data['refresh_token'] as String;

    await SecureStorageService.saveAccessToken(accessToken);
    await SecureStorageService.saveRefreshToken(refreshToken);
  }

  Future<bool> isAuthenticated() => SecureStorageService.hasValidAuth();

  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await SecureStorageService.clearAll();
  }
}
