import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class JwtService {
  // Decode JWT token payload
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return json.decode(decoded);
    } catch (e) {
      print('Error decoding JWT token: $e');
      return null;
    }
  }

  // Check if token is expired
  static bool isTokenExpired(String token) {
    try {
      final payload = decodeToken(token);
      if (payload == null || payload['exp'] == null) {
        return true;
      }

      final expirationTime = DateTime.fromMillisecondsSinceEpoch(
        (payload['exp'] as int) * 1000,
      );
      return DateTime.now().isAfter(expirationTime);
    } catch (e) {
      return true;
    }
  }

  // Get user info from token
  static Map<String, dynamic>? getUserFromToken(String token) {
    try {
      final payload = decodeToken(token);
      if (payload == null) return null;

      return {
        'id': payload['Id'],
        'userName': payload['UserName'],
        'email': payload['Email'],
        'avatarUrl': payload['AvatarUrl'],
        'role': payload['Role'],
      };
    } catch (e) {
      return null;
    }
  }

  // Check if user is authenticated with valid token
  static Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return false;

      return !isTokenExpired(token);
    } catch (e) {
      return false;
    }
  }

  // Get stored token
  static Future<String?> getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      return null;
    }
  }

  // Store tokens
  static Future<void> storeTokens(
    String accessToken,
    String refreshToken,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', accessToken);
      await prefs.setString('refresh_token', refreshToken);
    } catch (e) {
      print('Error storing tokens: $e');
    }
  }

  // Clear stored tokens
  static Future<void> clearTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('refresh_token');
    } catch (e) {
      print('Error clearing tokens: $e');
    }
  }

  // Clear all user data and tokens (for app termination)
  static Future<void> clearAllUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Clear all authentication related data
      await prefs.remove('auth_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      // You can add more user-related keys here if needed
      print('All user data cleared successfully');
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }
}
