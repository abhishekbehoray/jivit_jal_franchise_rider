import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jivit_jal_2/Utils/ApiConstants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton that silently refreshes the access token.
/// Call [refreshIfNeeded] from any repository when a 401 is received.
/// If the refresh also fails, tokens are cleared and the app is redirected
/// to the login/welcome screen via the provided [navigatorKey].
class TokenRefreshService {
  TokenRefreshService._();
  static final TokenRefreshService instance = TokenRefreshService._();

  /// Set this in main.dart so the service can navigate on session expiry.
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool _isRefreshing = false;

  /// Attempts to refresh the token for [role] ('rider' or 'franchise').
  /// Returns `true` if a new access token was saved, `false` otherwise.
  Future<bool> refreshIfNeeded(String role) async {
    if (_isRefreshing) {
      // Wait until the in-flight refresh completes.
      await Future.delayed(const Duration(milliseconds: 500));
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getString('accessToken') ?? '').isNotEmpty;
    }

    _isRefreshing = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refreshToken') ?? '';
      if (refreshToken.isEmpty) {
        await _onSessionExpired();
        return false;
      }

      final url = role == 'rider'
          ? ApiConstants.riderRefreshToken
          : ApiConstants.franchiseRefreshToken;

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && json['success'] == true) {
        await prefs.setString('accessToken', json['accessToken'] as String);
        await prefs.setString('refreshToken', json['refreshToken'] as String);
        return true;
      }

      await _onSessionExpired();
      return false;
    } catch (_) {
      await _onSessionExpired();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _onSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('userRole');

    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Pop everything and go to the root (OnboardingScreenOne re-routes to login).
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (_) => false);
  }
}
