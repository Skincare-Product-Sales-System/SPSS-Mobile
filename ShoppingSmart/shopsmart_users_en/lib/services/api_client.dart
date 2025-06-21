import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'jwt_service.dart';

/// Exception riêng cho các lỗi API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status Code: $statusCode)';
}

/// ApiClient xử lý các request HTTP cơ bản
class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;
  final Future<bool> Function() _isTokenValid;
  final Future<String?> Function() _getToken;

  // Timeout cho các request
  final Duration timeout;

  /// Constructor với dependency injection
  ApiClient({
    this.baseUrl =
        'https://api.example.com', // Default base URL, should be replaced with actual API URL
    http.Client? httpClient,
    Duration? timeout,
    Future<bool> Function()? isTokenValid,
    Future<String?> Function()? getToken,
  }) : _httpClient = httpClient ?? http.Client(),
       timeout = timeout ?? const Duration(seconds: 30),
       _isTokenValid = isTokenValid ?? JwtService.isAuthenticated,
       _getToken = getToken ?? JwtService.getStoredToken;

  /// Thực hiện HTTP GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParams);

      final headers = await _prepareHeaders(requiresAuth);

      final response = await _httpClient
          .get(uri, headers: headers)
          .timeout(timeout);

      return _processResponse(response);
    } on SocketException {
      throw ApiException('Không thể kết nối đến server');
    } on HttpException {
      throw ApiException('Không tìm thấy yêu cầu');
    } on FormatException {
      throw ApiException('Format phản hồi không hợp lệ');
    } on TimeoutException {
      throw ApiException('Yêu cầu quá thời gian');
    } catch (e) {
      throw ApiException('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  /// Thực hiện HTTP POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _prepareHeaders(requiresAuth);

      final response = await _httpClient
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _processResponse(response);
    } on SocketException {
      throw ApiException('Không thể kết nối đến server');
    } on HttpException {
      throw ApiException('Không tìm thấy yêu cầu');
    } on FormatException {
      throw ApiException('Format phản hồi không hợp lệ');
    } on TimeoutException {
      throw ApiException('Yêu cầu quá thời gian');
    } catch (e) {
      throw ApiException('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  /// Thực hiện HTTP PATCH request
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _prepareHeaders(requiresAuth);

      final response = await _httpClient
          .patch(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _processResponse(response);
    } on SocketException {
      throw ApiException('Không thể kết nối đến server');
    } on HttpException {
      throw ApiException('Không tìm thấy yêu cầu');
    } on FormatException {
      throw ApiException('Format phản hồi không hợp lệ');
    } on TimeoutException {
      throw ApiException('Yêu cầu quá thời gian');
    } catch (e) {
      throw ApiException('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  /// Thực hiện HTTP PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _prepareHeaders(requiresAuth);

      final response = await _httpClient
          .put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _processResponse(response);
    } on SocketException {
      throw ApiException('Không thể kết nối đến server');
    } on HttpException {
      throw ApiException('Không tìm thấy yêu cầu');
    } on FormatException {
      throw ApiException('Format phản hồi không hợp lệ');
    } on TimeoutException {
      throw ApiException('Yêu cầu quá thời gian');
    } catch (e) {
      throw ApiException('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  /// Thực hiện HTTP DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _prepareHeaders(requiresAuth);

      final response = await _httpClient
          .delete(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _processResponse(response);
    } on SocketException {
      throw ApiException('Không thể kết nối đến server');
    } on HttpException {
      throw ApiException('Không tìm thấy yêu cầu');
    } on FormatException {
      throw ApiException('Format phản hồi không hợp lệ');
    } on TimeoutException {
      throw ApiException('Yêu cầu quá thời gian');
    } catch (e) {
      throw ApiException('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  /// Tải lên file
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    File file, {
    String fileField = 'file',
    Map<String, String>? fields,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Thêm headers xác thực nếu cần
      final headers = await _prepareHeaders(requiresAuth);
      request.headers.addAll(headers);

      // Thêm file vào request
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      final multipartFile = http.MultipartFile(
        fileField,
        fileStream,
        fileLength,
        filename: file.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Thêm các trường khác nếu có
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Gửi request và lấy response
      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _processResponse(response);
    } on SocketException {
      throw ApiException('Không thể kết nối đến server');
    } on HttpException {
      throw ApiException('Không tìm thấy yêu cầu');
    } on FormatException {
      throw ApiException('Format phản hồi không hợp lệ');
    } on TimeoutException {
      throw ApiException('Yêu cầu quá thời gian');
    } catch (e) {
      throw ApiException('Đã xảy ra lỗi khi tải lên file: ${e.toString()}');
    }
  }

  /// Chuẩn bị headers cho request
  Future<Map<String, String>> _prepareHeaders(bool requiresAuth) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      if (!await _isTokenValid()) {
        throw ApiException('Token không hợp lệ hoặc hết hạn');
      }

      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        throw ApiException('Không tìm thấy token xác thực');
      }
    }

    return headers;
  }

  /// Xử lý response từ API
  Map<String, dynamic> _processResponse(http.Response response) {
    try {
      // Kiểm tra xem response có rỗng không
      if (response.body.isEmpty) {
        throw ApiException(
          'Response body is empty',
          statusCode: response.statusCode,
        );
      }

      try {
        final body = jsonDecode(response.body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return body;
        } else {
          final message =
              body != null && body['message'] != null
                  ? body['message']
                  : 'Unknown server error';
          throw ApiException(
            message,
            statusCode: response.statusCode,
            data: body,
          );
        }
      } on FormatException catch (e) {
        print("Error decoding JSON: ${e.toString()}");
        print("Response body: ${response.body}");
        print("Status code: ${response.statusCode}");
        throw ApiException(
          'Failed to process response: Invalid JSON format',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        'Failed to process response: ${e.toString()}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Đóng HTTP client khi không cần thiết nữa
  void dispose() {
    _httpClient.close();
  }
}
