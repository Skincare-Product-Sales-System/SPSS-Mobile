import 'dart:convert';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final List<String>? errors;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errors,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    try {
      return ApiResponse<T>(
        success: json['success'] ?? false,
        data: json['data'] != null ? fromJsonT(json['data']) : null,
        message: json['message'] ?? '',
        errors:
            json['errors'] != null ? List<String>.from(json['errors']) : null,
        statusCode: json['statusCode'] as int?,
      );
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Lỗi xử lý dữ liệu: ${e.toString()}',
        errors: ['Format error: ${e.toString()}'],
      );
    }
  }

  // Factory constructor for success responses
  factory ApiResponse.success({T? data, String? message, int? statusCode}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  // Factory constructor for error responses
  factory ApiResponse.error({
    String? message,
    List<String>? errors,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
      statusCode: statusCode,
    );
  }

  // Phương thức xử lý an toàn cho phản hồi JSON
  static ApiResponse<T> safelyParseJson<T>(
    String? jsonString,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    try {
      if (jsonString == null || jsonString.isEmpty) {
        return ApiResponse<T>(
          success: false,
          message: 'Phản hồi từ server rỗng',
          errors: ['Empty response body'],
        );
      }

      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      return ApiResponse.fromJson(jsonData, fromJsonT);
    } on FormatException catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Lỗi định dạng: ${e.message}',
        errors: [
          'Cannot parse response: ${e.toString()}',
          'Response content: $jsonString',
        ],
      );
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Lỗi xử lý phản hồi: ${e.toString()}',
        errors: ['Error: ${e.toString()}'],
      );
    }
  }
}

class PaginatedResponse<T> {
  final List<T> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  PaginatedResponse({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    try {
      return PaginatedResponse<T>(
        items:
            (json['items'] as List<dynamic>?)
                ?.map((item) => fromJsonT(item as Map<String, dynamic>))
                .toList() ??
            [],
        totalCount: json['totalCount'] ?? 0,
        pageNumber: json['pageNumber'] ?? 1,
        pageSize: json['pageSize'] ?? 10,
        totalPages: json['totalPages'] ?? 0,
      );
    } catch (e) {
      // Return empty paginated response on error
      print('Error parsing paginated response: $e');
      return PaginatedResponse<T>(
        items: [],
        totalCount: 0,
        pageNumber: 1,
        pageSize: 10,
        totalPages: 0,
      );
    }
  }
}
