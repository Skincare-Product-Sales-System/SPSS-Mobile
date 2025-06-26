import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response_model.dart';
import '../models/auth_models.dart';

class AuthService {
  // Use different base URLs for different platforms
  static String get baseUrl {
    return 'https://spssapi-hxfzbchrcafgd2hg.southeastasia-01.azurewebsites.net/api';
  }

  static const Duration timeout = Duration(seconds: 30);

  // Login user
  static Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    try {
      final uri = Uri.parse('$baseUrl/authentications/login');

      print('Making login API request to: $uri'); // Debug log
      print('Request body: ${json.encode(request.toJson())}'); // Debug log

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);

      print('Login API Response Status: ${response.statusCode}'); // Debug log
      print('Login API Response Body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Check if the response contains accessToken and refreshToken
        if (jsonData.containsKey('accessToken') &&
            jsonData.containsKey('refreshToken')) {
          final accessToken = jsonData['accessToken'] as String;
          final refreshToken = jsonData['refreshToken'] as String;

          // Store tokens using JWT service
          await _storeTokens(accessToken, refreshToken);

          // Store user info from JWT token
          final userInfo = _getUserInfoFromToken(accessToken);
          if (userInfo != null) {
            await _storeUserInfoFromToken(userInfo);
          }

          return ApiResponse<AuthResponse>(
            success: true,
            message: 'Login successful',
            data: AuthResponse(
              token: accessToken,
              user: userInfo != null ? UserInfo.fromTokenData(userInfo) : null,
            ),
          );
        } else {
          // Fallback to old format
          final authResponse = ApiResponse.fromJson(
            jsonData,
            (data) => AuthResponse.fromJson(data),
          );

          // Store token in SharedPreferences if login is successful
          if (authResponse.success && authResponse.data?.token != null) {
            await _storeToken(authResponse.data!.token!);
            if (authResponse.data!.user != null) {
              await _storeUserInfo(authResponse.data!.user!);
            }
          }

          return authResponse;
        }
      } else {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse<AuthResponse>(
          success: false,
          message: jsonData['message'] ?? 'Login failed',
          errors:
              jsonData['errors'] != null
                  ? List<String>.from(jsonData['errors'])
                  : ['Login failed with status code: ${response.statusCode}'],
        );
      }
    } on SocketException catch (e) {
      print('Login SocketException: ${e.toString()}'); // Debug log
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'Connection failed: ${e.message}',
        errors: [
          'Cannot connect to server at $baseUrl',
          'Make sure your API server is running',
          'Error: ${e.toString()}',
        ],
      );
    } on HttpException catch (e) {
      print('Login HttpException: ${e.toString()}'); // Debug log
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'HTTP error occurred: ${e.message}',
        errors: ['HTTP request failed', e.toString()],
      );
    } on FormatException catch (e) {
      print('Login FormatException: ${e.toString()}'); // Debug log
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'Invalid response format: ${e.message}',
        errors: ['Server returned invalid data', e.toString()],
      );
    } catch (e) {
      print('Login Generic Exception: ${e.toString()}'); // Debug log
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Register user
  static Future<ApiResponse<AuthResponse>> register(
    RegisterRequest request,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/authentications/register');

      print('Making register API request to: $uri'); // Debug log
      print('Request body: ${json.encode(request.toJson())}'); // Debug log

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);

      print(
        'Register API Response Status: ${response.statusCode}',
      ); // Debug log
      print('Register API Response Body: ${response.body}'); // Debug log

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Kiểm tra nếu phản hồi chỉ có message "Registered successfully"
        if (jsonData.containsKey('message') &&
            jsonData['message'] == "Registered successfully") {
          // Trả về ApiResponse thành công với message
          return ApiResponse<AuthResponse>(
            success: true,
            message: jsonData['message'],
            data: null, // Không có token hoặc user data
          );
        }

        // Xử lý phản hồi thông thường
        final authResponse = ApiResponse.fromJson(
          jsonData,
          (data) => AuthResponse.fromJson(data),
        );

        // Store token in SharedPreferences if registration is successful
        if (authResponse.success && authResponse.data?.token != null) {
          await _storeToken(authResponse.data!.token!);
          if (authResponse.data!.user != null) {
            await _storeUserInfo(authResponse.data!.user!);
          }
        }

        return authResponse;
      } else {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse<AuthResponse>(
          success: false,
          message: jsonData['message'] ?? 'Registration failed',
          errors:
              jsonData['errors'] != null
                  ? List<String>.from(jsonData['errors'])
                  : [
                    'Registration failed with status code: ${response.statusCode}',
                  ],
        );
      }
    } on SocketException catch (e) {
      print('Register SocketException: ${e.toString()}'); // Debug log
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'Connection failed: ${e.message}',
        errors: [
          'Cannot connect to server at $baseUrl',
          'Make sure your API server is running',
          'Error: ${e.toString()}',
        ],
      );
    } on HttpException catch (e) {
      print('Register HttpException: ${e.toString()}'); // Debug log
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'HTTP error occurred: ${e.message}',
        errors: ['HTTP request failed', e.toString()],
      );
    } on FormatException catch (e) {
      print('Register FormatException: ${e.toString()}'); // Debug log
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'Invalid response format: ${e.message}',
        errors: ['Server returned invalid data', e.toString()],
      );
    } catch (e) {
      print('Register Generic Exception: ${e.toString()}'); // Debug log
      return ApiResponse<AuthResponse>(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Change password
  static Future<ApiResponse<String>> changePassword(
    ChangePasswordRequest request,
  ) async {
    try {
      final token = await getStoredToken();
      if (token == null) {
        return ApiResponse<String>(
          success: false,
          message: 'User not authenticated',
          errors: ['No authentication token found'],
        );
      }

      // Use query parameters as requested:
      // http://localhost:5041/api/authentications/change-password?currentPassword=sada&newPassword=asdad
      final uri = Uri.parse('$baseUrl/authentications/change-password').replace(
        queryParameters: {
          'currentPassword': request.currentPassword,
          'newPassword': request.newPassword,
        },
      );

      print('Making change password API request to: $uri'); // Debug log

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        return ApiResponse<String>(
          success: jsonData['success'] ?? true,
          message: jsonData['message'] ?? 'Password changed successfully',
          data: jsonData['message'] ?? 'Password changed successfully',
        );
      } else {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse<String>(
          success: false,
          message: jsonData['message'] ?? 'Failed to change password',
          errors:
              jsonData['errors'] != null
                  ? List<String>.from(jsonData['errors'])
                  : [
                    'Password change failed with status code: ${response.statusCode}',
                  ],
        );
      }
    } on SocketException catch (e) {
      return ApiResponse<String>(
        success: false,
        message: 'Connection failed: ${e.message}',
        errors: [
          'Cannot connect to server at $baseUrl',
          'Make sure your API server is running',
          'Error: ${e.toString()}',
        ],
      );
    } on HttpException catch (e) {
      return ApiResponse<String>(
        success: false,
        message: 'HTTP error occurred: ${e.message}',
        errors: ['HTTP request failed', e.toString()],
      );
    } on FormatException catch (e) {
      return ApiResponse<String>(
        success: false,
        message: 'Invalid response format: ${e.message}',
        errors: ['Server returned invalid data', e.toString()],
      );
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Helper methods for token management
  static Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> _storeTokens(
    String accessToken,
    String refreshToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  static Map<String, dynamic>? _getUserInfoFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> tokenData = json.decode(decoded);

      return {
        'id': tokenData['Id'],
        'userName': tokenData['UserName'],
        'email': tokenData['Email'],
        'avatarUrl': tokenData['AvatarUrl'],
        'role': tokenData['Role'],
      };
    } catch (e) {
      return null;
    }
  }

  static Future<void> _storeUserInfo(UserInfo user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_info', json.encode(user.toJson()));
  }

  static Future<void> _storeUserInfoFromToken(
    Map<String, dynamic> userInfo,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_info', json.encode(userInfo));
  }

  static Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<UserInfo?> getStoredUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoString = prefs.getString('user_info');
    if (userInfoString != null) {
      final userInfoJson = json.decode(userInfoString);
      return UserInfo.fromJson(userInfoJson);
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    final token = await getStoredToken();
    return token != null;
  }

  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear all authentication related data
      await prefs.remove('auth_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_info');
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.remove('user_avatar');

      // Clear only local app-specific user data except cart data
      // Note: We're keeping cart_items intentionally
      await prefs.remove('wishlist_items');
      await prefs.remove('viewed_products');
      await prefs.remove('user_preferences');
      await prefs.remove('delivery_addresses');

      print(
        'User logged out and data cleared successfully (cart data preserved)',
      );
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Clear all user data (for app shutdown)
  static Future<void> clearAllUserData() async {
    await logout(); // Use the same comprehensive logout function
  }
}
