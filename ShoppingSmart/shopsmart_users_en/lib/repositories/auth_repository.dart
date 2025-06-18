import 'package:shopsmart_users_en/models/api_response_model.dart';
import 'package:shopsmart_users_en/models/auth_models.dart';
import 'package:shopsmart_users_en/services/auth_service.dart';
import 'package:shopsmart_users_en/models/address_model.dart';
import 'package:shopsmart_users_en/services/api_service.dart';

class AuthRepository {
  // Login user
  Future<ApiResponse<AuthResponse>> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    final request = LoginRequest(
      usernameOrEmail: usernameOrEmail,
      password: password,
    );
    return AuthService.login(request);
  }

  // Register user
  Future<ApiResponse<AuthResponse>> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    final request = RegisterRequest(
      userName: email,
      surName: firstName,
      lastName: lastName,
      emailAddress: email,
      phoneNumber: phone ?? '',
      password: password,
      confirmPassword: confirmPassword,
    );
    return AuthService.register(request);
  }

  // Get user addresses
  Future<ApiResponse<PaginatedResponse<AddressModel>>> getAddresses({
    required int pageNumber,
    required int pageSize,
  }) async {
    return ApiService.getAddresses(pageNumber: pageNumber, pageSize: pageSize);
  }
}
