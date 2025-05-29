import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response_model.dart';
import '../models/auth_models.dart';

class AuthService {
  // Use different base URLs for different platforms
  static String get baseUrl {
    if (Platform.isAndroid) {
      // For Android emulator, use 10.0.2.2 instead of localhost
      return 'http://10.0.2.2:5041/api';
    } else if (Platform.isIOS) {
      // For iOS simulator, use localhost (or your machine's IP)
      return 'http://localhost:5041/api';
      // Alternative: return 'http://YOUR_MACHINE_IP:5041/api';
    } else {
      // For web or other platforms
      return 'http://localhost:5041/api';
    }
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

      final uri = Uri.parse('$baseUrl/authentications/change-password');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(request.toJson()),
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

  static Future<void> _storeUserInfo(UserInfo user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_info', json.encode(user.toJson()));
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_info');
  }
}
