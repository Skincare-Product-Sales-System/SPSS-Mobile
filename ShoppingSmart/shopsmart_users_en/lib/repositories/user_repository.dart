import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shopsmart_users_en/models/api_response_model.dart';
import 'package:shopsmart_users_en/models/user_profile_model.dart';
import 'package:shopsmart_users_en/models/address_model.dart';
import 'package:shopsmart_users_en/models/payment_method_model.dart';
import 'package:shopsmart_users_en/services/api_client.dart';
import 'package:shopsmart_users_en/services/jwt_service.dart';
import 'package:shopsmart_users_en/services/api_service.dart';

/// Repository để xử lý các thao tác liên quan đến profile người dùng
class UserRepository {
  final ApiClient _apiClient;

  /// Constructor với dependency injection
  UserRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(baseUrl: ApiService.baseUrl);

  /// Lấy thông tin profile người dùng
  Future<ApiResponse<UserProfileModel>> getUserProfile() async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Không có token xác thực');
      }

      try {
        final response = await _apiClient.get('accounts', requiresAuth: true);

        // Check if response is not null and has the expected structure
        if (response['success'] == true && response['data'] != null) {
          final userData = response['data'];
          final userProfile = UserProfileModel.fromJson(userData);
          return ApiResponse(
            success: true,
            data: userProfile,
            message: 'Lấy thông tin người dùng thành công',
          );
        } else {
          return ApiResponse(
            success: false,
            message:
                response['message'] ?? 'Không thể lấy thông tin người dùng',
          );
        }
      } catch (e) {
        // Nếu ApiClient gặp lỗi, thử dùng http package trực tiếp
        print(
          'ApiClient error: ${e.toString()}. Trying direct HTTP request...',
        );

        // Fallback using direct HTTP request
        final response = await http
            .get(
              Uri.parse('${_apiClient.baseUrl}/accounts'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200 && response.body.isNotEmpty) {
          try {
            final jsonData = json.decode(response.body);
            if (jsonData['success'] == true && jsonData['data'] != null) {
              final userData = jsonData['data'];
              final userProfile = UserProfileModel.fromJson(userData);
              return ApiResponse(
                success: true,
                data: userProfile,
                message: 'Lấy thông tin người dùng thành công',
              );
            }
          } catch (jsonError) {
            print('JSON parsing error: $jsonError');
            print('Response body: ${response.body}');
          }
        }

        // If fallback fails too, return error response
        return ApiResponse(
          success: false,
          message: 'Lỗi khi lấy thông tin người dùng: ${e.toString()}',
          errors: [
            'Status code: ${response.statusCode}',
            'Body: ${response.body}',
          ],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi khi lấy thông tin người dùng: ${e.toString()}',
      );
    }
  }

  /// Cập nhật thông tin profile người dùng
  Future<ApiResponse<UserProfileModel>> updateUserProfile(
    UpdateProfileRequest request,
  ) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Không có token xác thực');
      }
      final response = await _apiClient.patch(
        '/accounts',
        body: request.toJson(),
        requiresAuth: true,
      );

      if (response['success'] && response['data'] != null) {
        final userData = response['data'];
        final userProfile = UserProfileModel.fromJson(userData);
        return ApiResponse(
          success: true,
          data: userProfile,
          message: 'Cập nhật thông tin người dùng thành công',
        );
      } else {
        return ApiResponse(
          success: false,
          message:
              response['message'] ?? 'Không thể cập nhật thông tin người dùng',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi khi cập nhật thông tin người dùng: ${e.toString()}',
      );
    }
  }

  /// Cập nhật ảnh đại diện
  Future<ApiResponse<String>> updateAvatar(String imagePath) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Không có token xác thực');
      }

      // Tạo multipart request để upload ảnh
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${_apiClient.baseUrl}/accounts/avatar'),
      );

      // Thêm header authorization
      request.headers['Authorization'] = 'Bearer $token';

      // Thêm file ảnh
      request.files.add(await http.MultipartFile.fromPath('avatar', imagePath));

      // Gửi request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final avatarUrl = responseData['data'];

        return ApiResponse(
          success: true,
          data: avatarUrl,
          message: 'Cập nhật ảnh đại diện thành công',
        );
      } else {
        final responseData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: responseData['message'] ?? 'Không thể cập nhật ảnh đại diện',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi khi cập nhật ảnh đại diện: ${e.toString()}',
      );
    }
  }

  /// Đổi mật khẩu
  Future<ApiResponse<bool>> changePassword(
    String currentPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Không có token xác thực');
      }

      final response = await _apiClient.post(
        'accounts/change-password',
        body: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmNewPassword': confirmNewPassword,
        },
        requiresAuth: true,
      );

      return ApiResponse(
        success: response['success'],
        data: response['success'],
        message: response['message'] ?? 'Đổi mật khẩu thành công',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi khi đổi mật khẩu: ${e.toString()}',
      );
    }
  }

  /// Lấy danh sách địa chỉ
  Future<ApiResponse<PaginatedResponse<AddressModel>>> getAddresses() async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Không có token xác thực');
      }

      final response = await _apiClient.get(
        '/addresses/user?pageNumber=1&pageSize=10',
        requiresAuth: true,
      );

      if (response['success'] && response['data'] != null) {
        final data = response['data'];
        final items =
            (data['items'] as List)
                .map((item) => AddressModel.fromJson(item))
                .toList();

        final paginatedResponse = PaginatedResponse<AddressModel>(
          items: items,
          pageNumber: data['pageNumber'] ?? 1,
          pageSize: data['pageSize'] ?? 10,
          totalCount: data['totalCount'] ?? items.length,
          totalPages: data['totalPages'] ?? 1,
        );

        return ApiResponse(
          success: true,
          data: paginatedResponse,
          message: 'Lấy danh sách địa chỉ thành công',
        );
      } else {
        return ApiResponse(
          success: false,
          message: response['message'] ?? 'Không thể lấy danh sách địa chỉ',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi khi lấy danh sách địa chỉ: ${e.toString()}',
      );
    }
  }

  /// Thêm địa chỉ mới
  Future<ApiResponse<AddressModel>> addAddress(AddressModel address) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Không có token xác thực');
      }

      final response = await _apiClient.post(
        '/addresses',
        body: address.toMap(),
        requiresAuth: true,
      );

      if (response['success'] && response['data'] != null) {
        final addressData = AddressModel.fromJson(response['data']);
        return ApiResponse(
          success: true,
          data: addressData,
          message: 'Thêm địa chỉ thành công',
        );
      } else {
        return ApiResponse(
          success: false,
          message: response['message'] ?? 'Không thể thêm địa chỉ',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi khi thêm địa chỉ: ${e.toString()}',
      );
    }
  }

  /// Cập nhật địa chỉ
  Future<ApiResponse<AddressModel>> updateAddress(AddressModel address) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Không có token xác thực');
      }

      final response = await _apiClient.put(
        '/addresses/${address.id}',
        body: address.toMap(),
        requiresAuth: true,
      );

      if (response['success'] && response['data'] != null) {
        final addressData = AddressModel.fromJson(response['data']);
        return ApiResponse(
          success: true,
          data: addressData,
          message: 'Cập nhật địa chỉ thành công',
        );
      } else {
        return ApiResponse(
          success: false,
          message: response['message'] ?? 'Không thể cập nhật địa chỉ',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi khi cập nhật địa chỉ: ${e.toString()}',
      );
    }
  }

  /// Xóa địa chỉ
  Future<ApiResponse<bool>> deleteAddress(String addressId) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Không có token xác thực');
      }

      final response = await _apiClient.delete(
        '/addresses/$addressId',
        requiresAuth: true,
      );

      return ApiResponse(
        success: response['success'],
        data: response['success'],
        message: response['message'] ?? 'Xóa địa chỉ thành công',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi khi xóa địa chỉ: ${e.toString()}',
      );
    }
  }

  /// Đặt địa chỉ mặc định
  Future<ApiResponse<bool>> setDefaultAddress(String addressId) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Không có token xác thực');
      }

      final response = await _apiClient.put(
        '/addresses/$addressId/default',
        requiresAuth: true,
      );

      return ApiResponse(
        success: response['success'],
        data: response['success'],
        message: response['message'] ?? 'Đặt địa chỉ mặc định thành công',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi khi đặt địa chỉ mặc định: ${e.toString()}',
      );
    }
  }

  /// Lấy danh sách phương thức thanh toán
  Future<ApiResponse<PaginatedResponse<PaymentMethodModel>>>
  getPaymentMethods() async {
    try {
      final response = await _apiClient.get(
        '/payment-methods?pageNumber=1&pageSize=10',
        requiresAuth: true,
      );

      if (response['success'] && response['data'] != null) {
        final data = response['data'];
        final items =
            (data['items'] as List)
                .map((item) => PaymentMethodModel.fromJson(item))
                .toList();

        final paginatedResponse = PaginatedResponse<PaymentMethodModel>(
          items: items,
          pageNumber: data['pageNumber'] ?? 1,
          pageSize: data['pageSize'] ?? 10,
          totalCount: data['totalCount'] ?? items.length,
          totalPages: data['totalPages'] ?? 1,
        );

        return ApiResponse(
          success: true,
          data: paginatedResponse,
          message: 'Lấy danh sách phương thức thanh toán thành công',
        );
      } else {
        return ApiResponse(
          success: false,
          message:
              response['message'] ??
              'Không thể lấy danh sách phương thức thanh toán',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message:
            'Lỗi khi lấy danh sách phương thức thanh toán: ${e.toString()}',
      );
    }
  }

  /// Thêm phương thức thanh toán mới
  Future<ApiResponse<PaymentMethodModel>> addPaymentMethod(
    PaymentMethodModel paymentMethod,
  ) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Không có token xác thực');
      }

      final response = await _apiClient.post(
        '/payment-methods',
        body: paymentMethod.toMap(),
        requiresAuth: true,
      );

      if (response['success'] && response['data'] != null) {
        final data = PaymentMethodModel.fromJson(response['data']);
        return ApiResponse(
          success: true,
          data: data,
          message: 'Thêm phương thức thanh toán thành công',
        );
      } else {
        return ApiResponse(
          success: false,
          message:
              response['message'] ?? 'Không thể thêm phương thức thanh toán',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi khi thêm phương thức thanh toán: ${e.toString()}',
      );
    }
  }

  /// Cập nhật phương thức thanh toán
  Future<ApiResponse<PaymentMethodModel>> updatePaymentMethod(
    PaymentMethodModel paymentMethod,
  ) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Không có token xác thực');
      }

      final response = await _apiClient.put(
        '/payment-methods/${paymentMethod.id}',
        body: paymentMethod.toMap(),
        requiresAuth: true,
      );

      if (response['success'] && response['data'] != null) {
        final data = PaymentMethodModel.fromJson(response['data']);
        return ApiResponse(
          success: true,
          data: data,
          message: 'Cập nhật phương thức thanh toán thành công',
        );
      } else {
        return ApiResponse(
          success: false,
          message:
              response['message'] ??
              'Không thể cập nhật phương thức thanh toán',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi khi cập nhật phương thức thanh toán: ${e.toString()}',
      );
    }
  }

  /// Xóa phương thức thanh toán
  Future<ApiResponse<bool>> deletePaymentMethod(String paymentMethodId) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Không có token xác thực');
      }

      final response = await _apiClient.delete(
        '/payment-methods/$paymentMethodId',
        requiresAuth: true,
      );

      return ApiResponse(
        success: response['success'],
        data: response['success'],
        message: response['message'] ?? 'Xóa phương thức thanh toán thành công',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi khi xóa phương thức thanh toán: ${e.toString()}',
      );
    }
  }

  /// Đặt phương thức thanh toán mặc định
  Future<ApiResponse<bool>> setDefaultPaymentMethod(
    String paymentMethodId,
  ) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Không có token xác thực');
      }

      final response = await _apiClient.put(
        '/payment-methods/$paymentMethodId/default',
        requiresAuth: true,
      );

      return ApiResponse(
        success: response['success'],
        data: response['success'],
        message:
            response['message'] ??
            'Đặt phương thức thanh toán mặc định thành công',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi khi đặt phương thức thanh toán mặc định: ${e.toString()}',
      );
    }
  }
}
