import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/api_response_model.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/detailed_product_model.dart';
import '../models/blog_model.dart';
import '../models/review_models.dart';
import '../models/order_models.dart';
import '../models/skin_analysis_models.dart';
import '../models/voucher_model.dart';
import '../services/jwt_service.dart';
import '../models/address_model.dart' as address_lib;
import '../models/payment_method_model.dart';
import '../models/transaction_model.dart';
import '../models/cart_model.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // Use different base URLs for different platforms
  static String get baseUrl {
    return 'http://10.0.2.2:5041/api';
  }

  static const Duration timeout = Duration(seconds: 30);

  static Future<ApiResponse<PaginatedResponse<ProductModel>>> getProducts({
    int pageNumber = 1,
    int pageSize = 10,
    String? sortBy,
    String? categoryId,
    String? brandId,
    String? skinTypeId,
  }) async {
    try {
      Map<String, String> queryParams = {
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      };

      if (sortBy != null) {
        queryParams['sortBy'] = sortBy;
      }

      if (categoryId != null) {
        queryParams['categoryId'] = categoryId;
      }

      if (brandId != null) {
        queryParams['brandId'] = brandId;
      }

      if (skinTypeId != null) {
        queryParams['skinTypeId'] = skinTypeId;
      }

      final uri = Uri.parse(
        '$baseUrl/products',
      ).replace(queryParameters: queryParams);

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        return ApiResponse.fromJson(
          jsonData,
          (data) => PaginatedResponse.fromJson(
            data,
            (item) => ProductModel.fromJson(item),
          ),
        );
      } else {
        return ApiResponse<PaginatedResponse<ProductModel>>(
          success: false,
          message:
              'Failed to load products. Status code: ${response.statusCode}',
          errors: [
            'HTTP Error: ${response.statusCode}',
            'Response: ${response.body}',
          ],
        );
      }
    } on SocketException catch (e) {
      return ApiResponse<PaginatedResponse<ProductModel>>(
        success: false,
        message: 'Connection failed: ${e.message}',
        errors: [
          'Cannot connect to server at $baseUrl',
          'Make sure your API server is running',
          'Error: ${e.toString()}',
        ],
      );
    } on HttpException catch (e) {
      return ApiResponse<PaginatedResponse<ProductModel>>(
        success: false,
        message: 'HTTP error occurred: ${e.message}',
        errors: ['HTTP request failed', e.toString()],
      );
    } on FormatException catch (e) {
      return ApiResponse<PaginatedResponse<ProductModel>>(
        success: false,
        message: 'Invalid response format: ${e.message}',
        errors: ['Server returned invalid data', e.toString()],
      );
    } catch (e) {
      return ApiResponse<PaginatedResponse<ProductModel>>(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Get latest products (using sortBy=newest)
  static Future<ApiResponse<PaginatedResponse<ProductModel>>>
  getLatestProducts({int pageNumber = 1, int pageSize = 10}) async {
    return getProducts(
      pageNumber: pageNumber,
      pageSize: pageSize,
      sortBy: 'newest',
    );
  }

  // Get best seller products
  static Future<ApiResponse<PaginatedResponse<ProductModel>>> getBestSellers({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/products/best-sellers').replace(
        queryParameters: {
          'pageNumber': pageNumber.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        return ApiResponse.fromJson(
          jsonData,
          (data) => PaginatedResponse.fromJson(
            data,
            (item) => ProductModel.fromJson(item),
          ),
        );
      } else {
        return ApiResponse<PaginatedResponse<ProductModel>>(
          success: false,
          message:
              'Failed to load best sellers. Status code: ${response.statusCode}',
          errors: [
            'HTTP Error: ${response.statusCode}',
            'Response: ${response.body}',
          ],
        );
      }
    } on SocketException catch (e) {
      return ApiResponse<PaginatedResponse<ProductModel>>(
        success: false,
        message: 'Connection failed: ${e.message}',
        errors: [
          'Cannot connect to server at $baseUrl',
          'Make sure your API server is running',
          'Error: ${e.toString()}',
        ],
      );
    } catch (e) {
      return ApiResponse<PaginatedResponse<ProductModel>>(
        success: false,
        message: 'Failed to load best sellers: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Get product categories
  static Future<ApiResponse<PaginatedResponse<CategoryModel>>> getCategories({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/product-categories').replace(
        queryParameters: {
          'pageNumber': pageNumber.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        return ApiResponse.fromJson(
          jsonData,
          (data) => PaginatedResponse.fromJson(
            data,
            (item) => CategoryModel.fromJson(item),
          ),
        );
      } else {
        return ApiResponse<PaginatedResponse<CategoryModel>>(
          success: false,
          message:
              'Failed to load categories. Status code: ${response.statusCode}',
          errors: [
            'HTTP Error: ${response.statusCode}',
            'Response: ${response.body}',
          ],
        );
      }
    } on SocketException catch (e) {
      return ApiResponse<PaginatedResponse<CategoryModel>>(
        success: false,
        message: 'Connection failed: ${e.message}',
        errors: [
          'Cannot connect to server at $baseUrl',
          'Make sure your API server is running',
          'Error: ${e.toString()}',
        ],
      );
    } catch (e) {
      return ApiResponse<PaginatedResponse<CategoryModel>>(
        success: false,
        message: 'Failed to load categories: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Get products by category
  static Future<ApiResponse<PaginatedResponse<ProductModel>>>
  getProductsByCategory({
    required String categoryId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return getProducts(
      pageNumber: pageNumber,
      pageSize: pageSize,
      categoryId: categoryId,
    );
  }

  // Search products
  static Future<ApiResponse<PaginatedResponse<ProductModel>>> searchProducts({
    required String searchText,
    String? sortBy,
    String? brandId,
    String? skinTypeId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      Map<String, String> queryParams = {
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
        'name': searchText,
      };

      if (sortBy != null) {
        queryParams['sortBy'] = sortBy;
      }

      if (brandId != null) {
        queryParams['brandId'] = brandId;
      }

      if (skinTypeId != null) {
        queryParams['skinTypeId'] = skinTypeId;
      }

      final uri = Uri.parse(
        '$baseUrl/products',
      ).replace(queryParameters: queryParams);

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        return ApiResponse.fromJson(
          jsonData,
          (data) => PaginatedResponse.fromJson(
            data,
            (item) => ProductModel.fromJson(item),
          ),
        );
      } else {
        return ApiResponse<PaginatedResponse<ProductModel>>(
          success: false,
          message:
              'Failed to search products. Status code: ${response.statusCode}',
          errors: [
            'HTTP Error: ${response.statusCode}',
            'Response: ${response.body}',
          ],
        );
      }
    } on SocketException catch (e) {
      return ApiResponse<PaginatedResponse<ProductModel>>(
        success: false,
        message: 'Connection failed: ${e.message}',
        errors: [
          'Cannot connect to server at $baseUrl',
          'Make sure your API server is running',
          'Error: ${e.toString()}',
        ],
      );
    } catch (e) {
      return ApiResponse<PaginatedResponse<ProductModel>>(
        success: false,
        message: 'Failed to search products: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Get product by ID
  static Future<ApiResponse<DetailedProductModel>> getProductById(
    String productId,
  ) async {
    try {
      final token = await JwtService.getStoredToken();
      final response = await http
          .get(
            Uri.parse('$baseUrl/products/$productId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(timeout);

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return ApiResponse<DetailedProductModel>(
          success: true,
          data: DetailedProductModel.fromJson(responseData['data']),
          message: responseData['message'],
        );
      } else {
        return ApiResponse<DetailedProductModel>(
          success: false,
          data: null,
          message: responseData['message'] ?? 'Failed to get product details',
          errors: responseData['errors'],
        );
      }
    } on SocketException {
      return ApiResponse<DetailedProductModel>(
        success: false,
        data: null,
        message: 'No internet connection',
      );
    } on TimeoutException {
      return ApiResponse<DetailedProductModel>(
        success: false,
        data: null,
        message: 'Request timed out',
      );
    } catch (e) {
      debugPrint('Error getting product details: ${e.toString()}');
      return ApiResponse<DetailedProductModel>(
        success: false,
        data: null,
        message: 'An error occurred: ${e.toString()}',
      );
    }
  }

  // Get blogs with pagination
  static Future<ApiResponse<PaginatedResponse<BlogModel>>> getBlogs({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/blogs').replace(
        queryParameters: {
          'pageNumber': pageNumber.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        return ApiResponse.fromJson(
          jsonData,
          (data) => PaginatedResponse.fromJson(
            data,
            (item) => BlogModel.fromJson(item),
          ),
        );
      } else {
        return ApiResponse<PaginatedResponse<BlogModel>>(
          success: false,
          message: 'Failed to load blogs. Status code: ${response.statusCode}',
          errors: [
            'HTTP Error: ${response.statusCode}',
            'Response: ${response.body}',
          ],
        );
      }
    } on SocketException catch (e) {
      return ApiResponse<PaginatedResponse<BlogModel>>(
        success: false,
        message: 'Connection failed: ${e.message}',
        errors: [
          'Cannot connect to server at $baseUrl',
          'Make sure your API server is running',
          'Error: ${e.toString()}',
        ],
      );
    } catch (e) {
      return ApiResponse<PaginatedResponse<BlogModel>>(
        success: false,
        message: 'Failed to load blogs: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Get blog by ID
  static Future<ApiResponse<DetailedBlogModel>> getBlogById(
    String blogId,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/blogs/$blogId');

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        return ApiResponse.fromJson(
          jsonData,
          (data) => DetailedBlogModel.fromJson(data),
        );
      } else {
        return ApiResponse<DetailedBlogModel>(
          success: false,
          message: 'Failed to load blog. Status code: ${response.statusCode}',
          errors: ['HTTP Error: ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse<DetailedBlogModel>(
        success: false,
        message: 'Failed to load blog: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Test API connectivity
  static Future<ApiResponse<String>> testConnection() async {
    try {
      final uri = Uri.parse(
        '$baseUrl/products',
      ).replace(queryParameters: {'pageNumber': '1', 'pageSize': '1'});

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return ApiResponse<String>(
          success: true,
          data: 'Connection successful!',
          message: 'API is reachable. Status: ${response.statusCode}',
        );
      } else {
        return ApiResponse<String>(
          success: false,
          data: null,
          message: 'API returned status: ${response.statusCode}',
          errors: ['Response: ${response.body}'],
        );
      }
    } on SocketException catch (e) {
      return ApiResponse<String>(
        success: false,
        data: null,
        message: 'Cannot connect to $baseUrl',
        errors: [
          'SocketException: ${e.message}',
          'Make sure your API server is running on port 5041',
          'URL being tested: $baseUrl/products',
        ],
      );
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        data: null,
        message: 'Connection test failed',
        errors: [e.toString()],
      );
    }
  }

  // Get product reviews
  static Future<ApiResponse<ReviewResponse>> getProductReviews(
    String productId, {
    int? ratingFilter,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final queryParams = {
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      };

      if (ratingFilter != null) {
        queryParams['ratingFilter'] = ratingFilter.toString();
      }

      final uri = Uri.parse(
        '$baseUrl/reviews/product/$productId',
      ).replace(queryParameters: queryParams);

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        return ApiResponse.fromJson(
          jsonData,
          (data) => ReviewResponse.fromJson(data),
        );
      } else {
        return ApiResponse<ReviewResponse>(
          success: false,
          message:
              'Failed to load reviews. Status code: ${response.statusCode}',
          errors: ['HTTP Error: ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse<ReviewResponse>(
        success: false,
        message: 'Failed to load reviews: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Create new order
  static Future<ApiResponse<OrderResponse>> createOrder(
    CreateOrderRequest request,
  ) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse<OrderResponse>(
          success: false,
          message: 'User not authenticated',
          errors: ['No authentication token found'],
        );
      }

      final uri = Uri.parse('$baseUrl/orders');

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        return ApiResponse.fromJson(
          jsonData,
          (data) => OrderResponse.fromJson(data),
        );
      } else {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse<OrderResponse>(
          success: false,
          message: jsonData['message'] ?? 'Failed to create order',
          errors:
              jsonData['errors'] != null
                  ? List<String>.from(jsonData['errors'])
                  : ['Failed with status code: ${response.statusCode}'],
        );
      }
    } on SocketException catch (e) {
      return ApiResponse<OrderResponse>(
        success: false,
        message: 'Connection failed: ${e.message}',
        errors: [
          'Cannot connect to server at $baseUrl',
          'Make sure your API server is running',
          'Error: ${e.toString()}',
        ],
      );
    } on HttpException catch (e) {
      return ApiResponse<OrderResponse>(
        success: false,
        message: 'HTTP error occurred: ${e.message}',
        errors: ['HTTP request failed', e.toString()],
      );
    } on FormatException catch (e) {
      return ApiResponse<OrderResponse>(
        success: false,
        message: 'Invalid response format: ${e.message}',
        errors: ['Server returned invalid data', e.toString()],
      );
    } catch (e) {
      return ApiResponse<OrderResponse>(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Get orders with pagination
  static Future<ApiResponse<PaginatedResponse<OrderModel>>> getOrders({
    required int pageNumber,
    required int pageSize,
    String? status,
  }) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        print('No token found'); // Debug log
        return ApiResponse<PaginatedResponse<OrderModel>>(
          success: false,
          message: 'Not authenticated',
          errors: ['No authentication token found'],
        );
      }

      final queryParams = {
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      };

      if (status != null) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse(
        '$baseUrl/orders/user',
      ).replace(queryParameters: queryParams);

      print('Request URL: ${uri.toString()}'); // Debug log

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(timeout);

      print('Response Status Code: ${response.statusCode}'); // Debug log
      print('Response Body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print('Parsed JSON Data: $jsonData'); // Debug log

        return ApiResponse.fromJson(
          jsonData,
          (data) => PaginatedResponse.fromJson(
            data,
            (item) => OrderModel.fromJson(item),
          ),
        );
      } else {
        try {
          final Map<String, dynamic> jsonData = json.decode(response.body);
          print('Error response data: $jsonData'); // Debug log
          return ApiResponse<PaginatedResponse<OrderModel>>(
            success: false,
            message: jsonData['message'] ?? 'Failed to get orders',
            errors:
                jsonData['errors'] != null
                    ? List<String>.from(jsonData['errors'])
                    : ['Failed with status code: ${response.statusCode}'],
          );
        } catch (e) {
          print('Error parsing error response: $e'); // Debug log
          return ApiResponse<PaginatedResponse<OrderModel>>(
            success: false,
            message: 'Failed to get orders',
            errors: ['Invalid error response format'],
          );
        }
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e'); // Debug log
      return ApiResponse<PaginatedResponse<OrderModel>>(
        success: false,
        message: 'Connection failed: ${e.message}',
        errors: [
          'Cannot connect to server at $baseUrl',
          'Make sure your API server is running',
          'Error: ${e.toString()}',
        ],
      );
    } on HttpException catch (e) {
      print('HTTP Exception: $e'); // Debug log
      return ApiResponse<PaginatedResponse<OrderModel>>(
        success: false,
        message: 'HTTP error occurred: ${e.message}',
        errors: ['HTTP request failed', e.toString()],
      );
    } on FormatException catch (e) {
      print('Format Exception: $e'); // Debug log
      return ApiResponse<PaginatedResponse<OrderModel>>(
        success: false,
        message: 'Invalid response format: ${e.message}',
        errors: ['Server returned invalid data', e.toString()],
      );
    } catch (e, stackTrace) {
      print('Unexpected Error: $e'); // Debug log
      print('Stack trace: $stackTrace'); // Debug log
      return ApiResponse<PaginatedResponse<OrderModel>>(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Get order detail by ID
  static Future<ApiResponse<OrderDetailModel>> getOrderDetail(
    String orderId,
  ) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse<OrderDetailModel>(
          success: false,
          message: 'User not authenticated',
          errors: ['No authentication token found'],
        );
      }

      final uri = Uri.parse('$baseUrl/orders/$orderId');

      final response = await http
          .get(
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

        return ApiResponse.fromJson(
          jsonData,
          (data) => OrderDetailModel.fromJson(data),
        );
      } else {
        try {
          final Map<String, dynamic> jsonData = json.decode(response.body);
          return ApiResponse<OrderDetailModel>(
            success: false,
            message: jsonData['message'] ?? 'Failed to get order detail',
            errors:
                jsonData['errors'] != null
                    ? List<String>.from(jsonData['errors'])
                    : ['Failed with status code: ${response.statusCode}'],
          );
        } catch (e) {
          return ApiResponse<OrderDetailModel>(
            success: false,
            message: 'Failed to get order detail',
            errors: ['Invalid error response format'],
          );
        }
      }
    } on SocketException catch (e) {
      return ApiResponse<OrderDetailModel>(
        success: false,
        message: 'Connection failed: ${e.message}',
        errors: [
          'Cannot connect to server at $baseUrl',
          'Make sure your API server is running',
          'Error: ${e.toString()}',
        ],
      );
    } on HttpException catch (e) {
      return ApiResponse<OrderDetailModel>(
        success: false,
        message: 'HTTP error occurred: ${e.message}',
        errors: ['HTTP request failed', e.toString()],
      );
    } on FormatException catch (e) {
      return ApiResponse<OrderDetailModel>(
        success: false,
        message: 'Invalid response format: ${e.message}',
        errors: ['Server returned invalid data', e.toString()],
      );
    } catch (e) {
      return ApiResponse<OrderDetailModel>(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Get vouchers with pagination
  static Future<ApiResponse<PaginatedResponse<VoucherModel>>> getVouchers({
    int pageNumber = 1,
    int pageSize = 10,
    String? status,
  }) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse<PaginatedResponse<VoucherModel>>(
          success: false,
          message: 'User not authenticated',
          errors: ['No authentication token found'],
        );
      }

      final queryParams = {
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      };

      if (status != null) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse(
        '$baseUrl/voucher',
      ).replace(queryParameters: queryParams);

      final response = await http
          .get(
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

        return ApiResponse.fromJson(
          jsonData,
          (data) => PaginatedResponse.fromJson(
            data,
            (item) => VoucherModel.fromJson(item),
          ),
        );
      } else {
        try {
          final Map<String, dynamic> jsonData = json.decode(response.body);
          return ApiResponse<PaginatedResponse<VoucherModel>>(
            success: false,
            message: jsonData['message'] ?? 'Failed to get vouchers',
            errors:
                jsonData['errors'] != null
                    ? List<String>.from(jsonData['errors'])
                    : ['Failed with status code: ${response.statusCode}'],
          );
        } catch (e) {
          return ApiResponse<PaginatedResponse<VoucherModel>>(
            success: false,
            message: 'Failed to get vouchers',
            errors: ['Invalid error response format'],
          );
        }
      }
    } on SocketException catch (e) {
      return ApiResponse<PaginatedResponse<VoucherModel>>(
        success: false,
        message: 'Connection failed: ${e.message}',
        errors: [
          'Cannot connect to server at $baseUrl',
          'Make sure your API server is running',
          'Error: ${e.toString()}',
        ],
      );
    } on HttpException catch (e) {
      return ApiResponse<PaginatedResponse<VoucherModel>>(
        success: false,
        message: 'HTTP error occurred: ${e.message}',
        errors: ['HTTP request failed', e.toString()],
      );
    } on FormatException catch (e) {
      return ApiResponse<PaginatedResponse<VoucherModel>>(
        success: false,
        message: 'Invalid response format: ${e.message}',
        errors: ['Server returned invalid data', e.toString()],
      );
    } catch (e) {
      return ApiResponse<PaginatedResponse<VoucherModel>>(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Validate voucher by code
  static Future<ApiResponse<VoucherModel>> validateVoucher(
    String voucherCode,
  ) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse<VoucherModel>(
          success: false,
          message: 'User not authenticated',
          errors: ['No authentication token found'],
        );
      }

      final uri = Uri.parse('$baseUrl/voucher/validate/$voucherCode');

      final response = await http
          .get(
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

        return ApiResponse.fromJson(
          jsonData,
          (data) => VoucherModel.fromJson(data),
        );
      } else {
        try {
          final Map<String, dynamic> jsonData = json.decode(response.body);
          return ApiResponse<VoucherModel>(
            success: false,
            message: jsonData['message'] ?? 'Voucher not valid',
            errors:
                jsonData['errors'] != null
                    ? List<String>.from(jsonData['errors'])
                    : ['Failed with status code: ${response.statusCode}'],
          );
        } catch (e) {
          return ApiResponse<VoucherModel>(
            success: false,
            message: 'Failed to validate voucher',
            errors: ['Invalid error response format'],
          );
        }
      }
    } on SocketException catch (e) {
      return ApiResponse<VoucherModel>(
        success: false,
        message: 'Connection failed: ${e.message}',
        errors: [
          'Cannot connect to server at $baseUrl',
          'Make sure your API server is running',
          'Error: ${e.toString()}',
        ],
      );
    } catch (e) {
      return ApiResponse<VoucherModel>(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Post a review
  static Future<ApiResponse<Map<String, dynamic>>> postReview({
    required String productItemId,
    required List<String> reviewImages,
    required int ratingValue,
    required String comment,
  }) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'User not authenticated',
          errors: ['No authentication token found'],
        );
      }

      final requestBody = {
        'productItemId': productItemId,
        'reviewImages': reviewImages,
        'ratingValue': ratingValue,
        'comment': comment,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/reviews'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(requestBody),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: 'Review posted successfully',
          data: jsonData,
        );
      } else {
        Map<String, dynamic>? errorData;
        try {
          errorData = json.decode(response.body);
        } catch (e) {
          errorData = null;
        }

        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message:
              errorData?['message'] ??
              'Failed to post review. Status code: ${response.statusCode}',
          errors:
              errorData?['errors'] ?? ['HTTP Error: ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Failed to post review: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  static Future<ApiResponse<PaginatedResponse<address_lib.AddressModel>>>
  getAddresses({required int pageNumber, required int pageSize}) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse<PaginatedResponse<address_lib.AddressModel>>(
          success: false,
          message: 'Not authenticated',
          errors: ['No authentication token found'],
        );
      }

      final uri = Uri.parse('$baseUrl/addresses/user').replace(
        queryParameters: {
          'pageNumber': pageNumber.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(timeout);

      print('getAddresses response.body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse.fromJson(
          jsonData,
          (data) => PaginatedResponse.fromJson(
            data,
            (item) => address_lib.AddressModel.fromJson(item),
          ),
        );
      } else {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse<PaginatedResponse<address_lib.AddressModel>>(
          success: false,
          message: jsonData['message'] ?? 'Failed to load addresses',
          errors:
              jsonData['errors'] != null
                  ? List<String>.from(jsonData['errors'])
                  : ['Failed with status code: ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse<PaginatedResponse<address_lib.AddressModel>>(
        success: false,
        message: e.toString(),
        errors: [e.toString()],
      );
    }
  }

  static Future<ApiResponse<PaginatedResponse<PaymentMethodModel>>>
  getPaymentMethods({required int pageNumber, required int pageSize}) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse<PaginatedResponse<PaymentMethodModel>>(
          success: false,
          message: 'Not authenticated',
          errors: ['No authentication token found'],
        );
      }

      final uri = Uri.parse('$baseUrl/payment-methods').replace(
        queryParameters: {
          'pageNumber': pageNumber.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(timeout);

      print('getPaymentMethods response.body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse.fromJson(
          jsonData,
          (data) => PaginatedResponse.fromJson(
            data,
            (item) => PaymentMethodModel.fromJson(item),
          ),
        );
      } else {
        final Map<String, dynamic> jsonData =
            response.body.isNotEmpty
                ? json.decode(response.body)
                : {'message': 'Status code: ${response.statusCode}'};
        return ApiResponse<PaginatedResponse<PaymentMethodModel>>(
          success: false,
          message: jsonData['message'] ?? 'Failed to load payment methods',
          errors:
              jsonData['errors'] != null
                  ? List<String>.from(jsonData['errors'])
                  : ['Failed with status code: ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse<PaginatedResponse<PaymentMethodModel>>(
        success: false,
        message: 'Error loading payment methods: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  static Future<ApiResponse<OrderResponse>> createOrderRaw(
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse<OrderResponse>(
          success: false,
          message: 'User not authenticated',
          errors: ['No authentication token found'],
        );
      }
      final uri = Uri.parse('$baseUrl/orders');
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(data),
          )
          .timeout(timeout);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse.fromJson(
          jsonData,
          (data) => OrderResponse.fromJson(data),
        );
      } else {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse<OrderResponse>(
          success: false,
          message: jsonData['message'] ?? 'Failed to create order',
          errors:
              jsonData['errors'] != null
                  ? List<String>.from(jsonData['errors'])
                  : ['Failed with status code: ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse<OrderResponse>(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Upload image for review (if you have a separate endpoint for image upload)
  static Future<ApiResponse<String>> uploadReviewImage(File imageFile) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse<String>(
          success: false,
          message: 'User not authenticated',
          errors: ['No authentication token found'],
        );
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload/review-image'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse<String>(
          success: true,
          message: 'Image uploaded successfully',
          data: jsonData['imageUrl'] ?? jsonData['url'] ?? '',
        );
      } else {
        return ApiResponse<String>(
          success: false,
          message:
              'Failed to upload image. Status code: ${response.statusCode}',
          errors: ['HTTP Error: ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        message: 'Failed to upload image: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Phân tích da
  static Future<ApiResponse<SkinAnalysisResult>> analyzeSkin(
    File imageFile,
  ) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Bạn cần đăng nhập để sử dụng tính năng này',
          errors: ['Không tìm thấy token người dùng'],
        );
      }

      final url = Uri.parse('$baseUrl/skin-analysis/analyze');
      final request =
          http.MultipartRequest('POST', url)
            ..headers.addAll({'Authorization': 'Bearer $token'})
            ..files.add(
              await http.MultipartFile.fromPath('faceImage', imageFile.path),
            );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Parse response data
      Map<String, dynamic> responseData = {};
      try {
        responseData = json.decode(response.body);
      } catch (e) {
        print('Lỗi khi parse response data: $e');
        return ApiResponse(
          success: false,
          message: 'Lỗi khi xử lý dữ liệu từ server',
          errors: ['Lỗi parse JSON'],
        );
      }

      // Thành công
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['success'] == true) {
        return ApiResponse<SkinAnalysisResult>(
          success: true,
          message: responseData['message'] ?? 'Phân tích da thành công',
          data:
              responseData['data'] != null
                  ? SkinAnalysisResult.fromJson(responseData['data'])
                  : null,
          errors: null,
        );
      }
      // Lỗi từ server với status code 200 nhưng success = false
      else if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<SkinAnalysisResult>(
          success: false,
          message: responseData['message'] ?? 'Có lỗi xảy ra khi phân tích da',
          data: null,
          errors:
              responseData['errors'] != null
                  ? List<String>.from(responseData['errors'])
                  : null,
        );
      }
      // Lỗi từ server với status code khác 200
      else {
        return ApiResponse<SkinAnalysisResult>(
          success: false,
          message: responseData['message'] ?? 'Có lỗi xảy ra khi phân tích da',
          data: null,
          errors:
              responseData['errors'] != null
                  ? List<String>.from(responseData['errors'])
                  : ['Lỗi server: ${response.statusCode}'],
        );
      }
    } catch (e) {
      print('Lỗi ngoại lệ khi phân tích da: $e');
      return ApiResponse<SkinAnalysisResult>(
        success: false,
        message: 'Lỗi khi phân tích da: ${e.toString()}',
        data: null,
        errors: ['Lỗi không xác định'],
      );
    }
  }

  // Tạo yêu cầu thanh toán cho phân tích da
  static Future<ApiResponse<TransactionDto>> createSkinAnalysisPayment() async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Bạn cần đăng nhập để sử dụng tính năng này',
          errors: ['Không tìm thấy token người dùng'],
        );
      }

      final url = Uri.parse('$baseUrl/skin-analysis/create-payment');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        return ApiResponse<TransactionDto>(
          success: responseData['success'] ?? false,
          message: responseData['message'] ?? 'Unknown message',
          data:
              responseData['success'] == true && responseData['data'] != null
                  ? TransactionDto.fromJson(responseData['data'])
                  : null,
          errors:
              responseData['errors'] != null
                  ? List<String>.from(responseData['errors'])
                  : null,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Có lỗi xảy ra: ${response.statusCode}',
          errors: ['Lỗi kết nối API'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi: ${e.toString()}',
        errors: ['Lỗi không xác định'],
      );
    }
  }

  // Phân tích da sau khi thanh toán được duyệt
  static Future<ApiResponse<SkinAnalysisResult>> analyzeSkinWithPayment(
    File imageFile,
  ) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Bạn cần đăng nhập để sử dụng tính năng này',
          errors: ['Không tìm thấy token người dùng'],
        );
      }

      final url = Uri.parse('$baseUrl/skin-analysis/analyze-with-payment');
      final request =
          http.MultipartRequest('POST', url)
            ..headers.addAll({'Authorization': 'Bearer $token'})
            ..files.add(
              await http.MultipartFile.fromPath('faceImage', imageFile.path),
            );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        return ApiResponse<SkinAnalysisResult>(
          success: responseData['success'] ?? false,
          message: responseData['message'] ?? 'Unknown message',
          data:
              responseData['success'] == true && responseData['data'] != null
                  ? SkinAnalysisResult.fromJson(responseData['data'])
                  : null,
          errors:
              responseData['errors'] != null
                  ? List<String>.from(responseData['errors'])
                  : null,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Có lỗi xảy ra: ${response.statusCode}',
          errors: ['Lỗi kết nối API'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi: ${e.toString()}',
        errors: ['Lỗi không xác định'],
      );
    }
  }

  // Lấy lịch sử phân tích da của người dùng (có phân trang)
  static Future<ApiResponse<List<SkinAnalysisResult>>> getSkinAnalysisHistory({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Bạn cần đăng nhập để xem lịch sử phân tích da',
          errors: ['Không tìm thấy token người dùng'],
          data: [], // Trả về danh sách rỗng thay vì null
        );
      }

      final url = Uri.parse('$baseUrl/skin-analysis/user').replace(
        queryParameters: {
          'pageNumber': pageNumber.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        return ApiResponse<List<SkinAnalysisResult>>(
          success: responseData['success'] ?? false,
          message: responseData['message'] ?? 'Unknown message',
          data:
              responseData['success'] == true && responseData['data'] != null
                  ? (responseData['data'] as List)
                      .map((item) => SkinAnalysisResult.fromJson(item))
                      .toList()
                  : [], // Trả về danh sách rỗng thay vì null
          errors:
              responseData['errors'] != null
                  ? List<String>.from(responseData['errors'])
                  : null,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Có lỗi xảy ra: ${response.statusCode}',
          errors: ['Lỗi kết nối API'],
          data: [], // Trả về danh sách rỗng thay vì null
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi: ${e.toString()}',
        errors: ['Lỗi không xác định'],
        data: [], // Trả về danh sách rỗng thay vì null
      );
    }
  }

  // Lấy chi tiết phân tích da theo ID
  static Future<ApiResponse<SkinAnalysisResult>> getSkinAnalysisById(
    String id,
  ) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Bạn cần đăng nhập để xem chi tiết phân tích da',
          errors: ['Không tìm thấy token người dùng'],
        );
      }

      final url = Uri.parse('$baseUrl/skin-analysis/$id');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        return ApiResponse<SkinAnalysisResult>(
          success: responseData['success'] ?? false,
          message: responseData['message'] ?? 'Unknown message',
          data:
              responseData['success'] == true && responseData['data'] != null
                  ? SkinAnalysisResult.fromJson(responseData['data'])
                  : null,
          errors:
              responseData['errors'] != null
                  ? List<String>.from(responseData['errors'])
                  : null,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Có lỗi xảy ra: ${response.statusCode}',
          errors: ['Lỗi kết nối API'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi: ${e.toString()}',
        errors: ['Lỗi không xác định'],
      );
    }
  }

  // Các phương thức API cho giỏ hàng

  // Lấy danh sách sản phẩm trong giỏ hàng
  static Future<ApiResponse<PaginatedResponse<Map<String, dynamic>>>>
  getCartItems() async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Bạn cần đăng nhập để xem giỏ hàng',
          errors: ['Không tìm thấy token người dùng'],
          data: null,
        );
      }

      final url = Uri.parse('$baseUrl/cart-items/user/cart');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);

        // Xử lý dữ liệu theo cấu trúc mới
        if (responseData['success'] == true && responseData['data'] != null) {
          final paginatedData = responseData['data'];
          final items = (paginatedData['items'] as List<dynamic>?) ?? [];

          return ApiResponse<PaginatedResponse<Map<String, dynamic>>>(
            success: true,
            message: responseData['message'] ?? 'Lấy giỏ hàng thành công',
            data: PaginatedResponse<Map<String, dynamic>>(
              items:
                  items
                      .map((item) => Map<String, dynamic>.from(item as Map))
                      .toList(),
              totalCount: paginatedData['totalCount'] ?? 0,
              pageNumber: paginatedData['pageNumber'] ?? 1,
              pageSize: paginatedData['pageSize'] ?? 10,
              totalPages: paginatedData['totalPages'] ?? 1,
            ),
            errors: null,
          );
        } else {
          return ApiResponse<PaginatedResponse<Map<String, dynamic>>>(
            success: false,
            message: responseData['message'] ?? 'Không thể lấy giỏ hàng',
            data: null,
            errors:
                responseData['errors'] != null
                    ? List<String>.from(responseData['errors'])
                    : null,
          );
        }
      } else {
        Map<String, dynamic>? errorData;
        try {
          errorData = json.decode(response.body);
        } catch (e) {
          errorData = null;
        }

        return ApiResponse<PaginatedResponse<Map<String, dynamic>>>(
          success: false,
          message:
              errorData?['message'] ?? 'Có lỗi xảy ra: ${response.statusCode}',
          data: null,
          errors: errorData?['errors'] ?? ['Lỗi kết nối API'],
        );
      }
    } catch (e) {
      return ApiResponse<PaginatedResponse<Map<String, dynamic>>>(
        success: false,
        message: 'Lỗi: ${e.toString()}',
        data: null,
        errors: ['Lỗi không xác định'],
      );
    }
  }

  // Thêm sản phẩm vào giỏ hàng
  static Future<ApiResponse<bool>> addToCart({
    required String productItemId,
    required int quantity,
  }) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Bạn cần đăng nhập để thêm sản phẩm vào giỏ hàng',
          errors: ['Không tìm thấy token người dùng'],
          data: false,
        );
      }

      final url = Uri.parse('$baseUrl/cart-items');
      final requestBody = {
        'productItemId': productItemId,
        'quantity': quantity,
      };

      debugPrint('Đang thêm sản phẩm vào giỏ hàng: $requestBody');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(requestBody),
          )
          .timeout(timeout);

      debugPrint('Phản hồi API [${response.statusCode}]: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        return ApiResponse<bool>(
          success: responseData['success'] ?? false,
          message: responseData['message'] ?? 'Đã thêm sản phẩm vào giỏ hàng',
          data: true,
          errors:
              responseData['errors'] != null
                  ? List<String>.from(responseData['errors'])
                  : null,
        );
      } else {
        Map<String, dynamic>? errorData;
        try {
          errorData = json.decode(response.body);
          debugPrint(
            'Lỗi khi thêm sản phẩm vào giỏ hàng: ${errorData?['message']}',
          );
        } catch (e) {
          errorData = null;
          debugPrint('Không thể phân tích phản hồi lỗi: $e');
        }

        return ApiResponse<bool>(
          success: false,
          message:
              errorData?['message'] ??
              'Không thể thêm sản phẩm vào giỏ hàng. Mã lỗi: ${response.statusCode}',
          errors:
              errorData?['errors'] != null
                  ? List<String>.from(errorData!['errors'])
                  : ['Lỗi HTTP: ${response.statusCode}'],
          data: false,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('Ngoại lệ khi thêm sản phẩm vào giỏ hàng: $e');
      return ApiResponse<bool>(
        success: false,
        message: 'Lỗi khi thêm sản phẩm vào giỏ hàng: ${e.toString()}',
        errors: [e.toString()],
        data: false,
      );
    }
  }

  // Cập nhật số lượng sản phẩm trong giỏ hàng
  static Future<ApiResponse<CartItemDto>> updateCartItemQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Bạn cần đăng nhập để cập nhật giỏ hàng',
          errors: ['Không tìm thấy token người dùng'],
        );
      }

      // Thay đổi URI để phù hợp với API endpoint
      final url = Uri.parse('$baseUrl/cart-items/$cartItemId');
      final requestBody = {'quantity': quantity};

      debugPrint(
        'Đang cập nhật số lượng sản phẩm, cartItemId: $cartItemId, SL: $quantity',
      );

      final response = await http
          .patch(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(requestBody),
          )
          .timeout(timeout);

      debugPrint('Phản hồi API [${response.statusCode}]: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);

        // API trả về boolean thay vì object khi thành công
        // Không cần chuyển đổi sang CartItemDto
        return ApiResponse<CartItemDto>(
          success: responseData['success'] ?? false,
          message: responseData['message'] ?? 'Đã cập nhật giỏ hàng',
          data: null, // Không có dữ liệu CartItemDto từ API
          errors:
              responseData['errors'] != null
                  ? List<String>.from(responseData['errors'])
                  : null,
        );
      } else {
        Map<String, dynamic>? errorData;
        try {
          errorData = json.decode(response.body);
          debugPrint('Lỗi khi cập nhật giỏ hàng: ${errorData?['message']}');
        } catch (e) {
          errorData = null;
          debugPrint('Không thể phân tích phản hồi lỗi: $e');
        }

        return ApiResponse<CartItemDto>(
          success: false,
          message:
              errorData?['message'] ??
              'Không thể cập nhật giỏ hàng. Mã lỗi: ${response.statusCode}',
          errors:
              errorData?['errors'] != null
                  ? List<String>.from(errorData!['errors'])
                  : ['Lỗi HTTP: ${response.statusCode}'],
        );
      }
    } catch (e) {
      debugPrint('Ngoại lệ khi cập nhật giỏ hàng: $e');
      return ApiResponse<CartItemDto>(
        success: false,
        message: 'Lỗi khi cập nhật giỏ hàng: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Xóa sản phẩm khỏi giỏ hàng
  static Future<ApiResponse<bool>> removeFromCart(String cartItemId) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Bạn cần đăng nhập để xóa sản phẩm khỏi giỏ hàng',
          errors: ['Không tìm thấy token người dùng'],
        );
      }

      final url = Uri.parse('$baseUrl/cart-items/$cartItemId');

      debugPrint('Đang xóa sản phẩm khỏi giỏ hàng với cartItemId: $cartItemId');

      final response = await http
          .delete(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(timeout);

      debugPrint('Phản hồi API [${response.statusCode}]: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Map<String, dynamic>? responseData;
        try {
          responseData = json.decode(response.body);
        } catch (e) {
          debugPrint(
            'Phản hồi không phải JSON, nhưng thành công với statusCode=${response.statusCode}',
          );
          return ApiResponse<bool>(
            success: true,
            message: 'Đã xóa sản phẩm khỏi giỏ hàng',
            data: true,
          );
        }

        return ApiResponse<bool>(
          success: responseData?['success'] ?? true,
          message: responseData?['message'] ?? 'Đã xóa sản phẩm khỏi giỏ hàng',
          data: true,
          errors:
              responseData?['errors'] != null
                  ? List<String>.from(responseData!['errors'])
                  : null,
        );
      } else {
        Map<String, dynamic>? errorData;
        try {
          errorData = json.decode(response.body);
          debugPrint(
            'Lỗi khi xóa sản phẩm khỏi giỏ hàng: ${errorData?['message']}',
          );
        } catch (e) {
          errorData = null;
          debugPrint('Không thể phân tích phản hồi lỗi: $e');
        }

        return ApiResponse<bool>(
          success: false,
          message:
              errorData?['message'] ??
              'Không thể xóa sản phẩm khỏi giỏ hàng. Mã lỗi: ${response.statusCode}',
          errors:
              errorData?['errors'] != null
                  ? List<String>.from(errorData!['errors'])
                  : ['Lỗi HTTP: ${response.statusCode}'],
          data: false,
        );
      }
    } catch (e) {
      debugPrint('Ngoại lệ khi xóa sản phẩm khỏi giỏ hàng: $e');
      return ApiResponse<bool>(
        success: false,
        message: 'Lỗi khi xóa sản phẩm khỏi giỏ hàng: ${e.toString()}',
        errors: [e.toString()],
        data: false,
      );
    }
  }

  // Phương thức để hủy đơn hàng
  static Future<ApiResponse<bool>> cancelOrder({
    required String orderId,
    String cancelReasonId = '3b3a9749-3435-452e-bbbc-554a23b1f531',
  }) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse<bool>(
          success: false,
          message: 'Bạn cần đăng nhập để hủy đơn hàng',
          errors: ['Không tìm thấy token người dùng'],
        );
      }

      final url = Uri.parse('$baseUrl/orders/$orderId/status');
      final requestBody = {
        'newStatus': 'Cancelled',
        'cancelReasonId': cancelReasonId,
      };

      debugPrint('Đang gửi yêu cầu hủy đơn hàng: $orderId');

      final response = await http
          .patch(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(requestBody),
          )
          .timeout(timeout);

      debugPrint('Phản hồi API [${response.statusCode}]: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Map<String, dynamic>? responseData;
        try {
          responseData = json.decode(response.body);
          return ApiResponse<bool>(
            success: responseData?['success'] ?? true,
            message: responseData?['message'] ?? 'Đã hủy đơn hàng thành công',
            data: true,
            errors:
                responseData?['errors'] != null
                    ? List<String>.from(responseData!['errors'])
                    : null,
          );
        } catch (e) {
          return ApiResponse<bool>(
            success: true,
            message: 'Đã hủy đơn hàng thành công',
            data: true,
          );
        }
      } else {
        Map<String, dynamic>? errorData;
        try {
          errorData = json.decode(response.body);
        } catch (e) {
          errorData = null;
        }

        return ApiResponse<bool>(
          success: false,
          message:
              errorData?['message'] ??
              'Không thể hủy đơn hàng. Mã lỗi: ${response.statusCode}',
          errors: errorData?['errors'] ?? ['Lỗi HTTP: ${response.statusCode}'],
          data: false,
        );
      }
    } catch (e) {
      debugPrint('Ngoại lệ khi hủy đơn hàng: $e');
      return ApiResponse<bool>(
        success: false,
        message: 'Lỗi khi hủy đơn hàng: ${e.toString()}',
        errors: [e.toString()],
        data: false,
      );
    }
  }

  // Get brands
  static Future<ApiResponse<PaginatedResponse<dynamic>>> getBrands({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/brands').replace(
        queryParameters: {
          'pageNumber': pageNumber.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        return ApiResponse.fromJson(
          jsonData,
          (data) => PaginatedResponse.fromJson(data, (item) => item),
        );
      } else {
        return ApiResponse<PaginatedResponse<dynamic>>(
          success: false,
          message: 'Failed to load brands. Status code: ${response.statusCode}',
          errors: [
            'HTTP Error: ${response.statusCode}',
            'Response: ${response.body}',
          ],
        );
      }
    } on SocketException catch (e) {
      return ApiResponse<PaginatedResponse<dynamic>>(
        success: false,
        message: 'Connection failed: ${e.message}',
        errors: [
          'Cannot connect to server at $baseUrl',
          'Make sure your API server is running',
          'Error: ${e.toString()}',
        ],
      );
    } catch (e) {
      return ApiResponse<PaginatedResponse<dynamic>>(
        success: false,
        message: 'Failed to load brands: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Get skin types
  static Future<ApiResponse<PaginatedResponse<dynamic>>> getSkinTypes({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/skin-types').replace(
        queryParameters: {
          'pageNumber': pageNumber.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        return ApiResponse.fromJson(
          jsonData,
          (data) => PaginatedResponse.fromJson(data, (item) => item),
        );
      } else {
        return ApiResponse<PaginatedResponse<dynamic>>(
          success: false,
          message:
              'Failed to load skin types. Status code: ${response.statusCode}',
          errors: [
            'HTTP Error: ${response.statusCode}',
            'Response: ${response.body}',
          ],
        );
      }
    } on SocketException catch (e) {
      return ApiResponse<PaginatedResponse<dynamic>>(
        success: false,
        message: 'Connection failed: ${e.message}',
        errors: [
          'Cannot connect to server at $baseUrl',
          'Make sure your API server is running',
          'Error: ${e.toString()}',
        ],
      );
    } catch (e) {
      return ApiResponse<PaginatedResponse<dynamic>>(
        success: false,
        message: 'Failed to load skin types: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Upload image with customizable URL and form field name
  static Future<ApiResponse<String>> uploadImageWithUrl(
    File imageFile,
    String url,
    String formFieldName,
  ) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse<String>(
          success: false,
          message: 'User not authenticated',
          errors: ['No authentication token found'],
        );
      }

      print('DEBUG UPLOAD IMAGE - Request URL: $url');

      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.files.add(
        await http.MultipartFile.fromPath(formFieldName, imageFile.path),
      );

      print(
        'DEBUG UPLOAD IMAGE - File path: ${imageFile.path}, formField: $formFieldName',
      );
      print('DEBUG UPLOAD IMAGE - Sending request...');

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      print('DEBUG UPLOAD IMAGE - Response status: ${response.statusCode}');
      print('DEBUG UPLOAD IMAGE - Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        String? imageUrl;
        if (jsonData['data'] is List) {
          final urls = jsonData['data'] as List;
          if (urls.isNotEmpty) {
            imageUrl = urls.first as String;
          }
        } else {
          imageUrl =
              jsonData['data'] ?? jsonData['imageUrl'] ?? jsonData['url'];
        }

        if (imageUrl != null) {
          print('DEBUG UPLOAD IMAGE - Uploaded successfully: $imageUrl');
          return ApiResponse<String>(
            success: true,
            message: 'Image uploaded successfully',
            data: imageUrl,
          );
        } else {
          return ApiResponse<String>(
            success: false,
            message: 'Failed to extract image URL from response',
            errors: ['No image URL in response'],
          );
        }
      } else {
        return ApiResponse<String>(
          success: false,
          message:
              'Failed to upload image. Status code: ${response.statusCode}',
          errors: ['HTTP Error: ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        message: 'Failed to upload image: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Delete image with query parameter
  static Future<ApiResponse<bool>> deleteImageWithQuery(
    String imageUrl,
    String url,
  ) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse<bool>(
          success: false,
          message: 'User not authenticated',
          errors: ['No authentication token found'],
        );
      }

      final uri = Uri.parse(
        url,
      ).replace(queryParameters: {'imageUrl': imageUrl});
      print('DEBUG DELETE IMAGE - Request URL: $uri');

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      print('DEBUG DELETE IMAGE - Headers: $headers');
      print('DEBUG DELETE IMAGE - Deleting image: $imageUrl');

      final response = await http
          .delete(uri, headers: headers)
          .timeout(timeout);

      print('DEBUG DELETE IMAGE - Response status: ${response.statusCode}');
      print('DEBUG DELETE IMAGE - Response body: ${response.body}');

      final success = response.statusCode == 200;
      print('DEBUG DELETE IMAGE - Delete ${success ? 'successful' : 'failed'}');

      return ApiResponse<bool>(
        success: success,
        message:
            success ? 'Image deleted successfully' : 'Failed to delete image',
        data: success,
      );
    } catch (e) {
      return ApiResponse<bool>(
        success: false,
        message: 'Failed to delete image: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Create product review
  static Future<ApiResponse<bool>> createReview({
    required String productItemId,
    required int rating,
    required String comment,
    required List<String> reviewImages,
    required String url,
  }) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse<bool>(
          success: false,
          message: 'User not authenticated',
          errors: ['No authentication token found'],
        );
      }

      print('DEBUG CREATE REVIEW - Request URL: $url');

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      print('DEBUG CREATE REVIEW - Headers: $headers');

      final requestBody = {
        'productItemId': productItemId,
        'ratingValue': rating,
        'comment': comment,
        'reviewImages': reviewImages,
      };
      final encodedBody = json.encode(requestBody);
      print('DEBUG CREATE REVIEW - Request body: $encodedBody');

      print('DEBUG CREATE REVIEW - Sending request...');
      final response = await http
          .post(Uri.parse(url), headers: headers, body: encodedBody)
          .timeout(timeout);

      print('DEBUG CREATE REVIEW - Response status: ${response.statusCode}');
      print('DEBUG CREATE REVIEW - Response body: ${response.body}');

      final success = response.statusCode == 200 || response.statusCode == 201;
      print(
        'DEBUG CREATE REVIEW - Review creation ${success ? 'successful' : 'failed'}',
      );

      return ApiResponse<bool>(
        success: success,
        message:
            success ? 'Review created successfully' : 'Failed to create review',
        data: success,
      );
    } catch (e) {
      return ApiResponse<bool>(
        success: false,
        message: 'Failed to create review: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Get user reviews
  static Future<ApiResponse<ReviewResponse>> getUserReviews({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse<ReviewResponse>(
          success: false,
          message: 'User not authenticated',
          errors: ['No authentication token found'],
        );
      }

      Map<String, String> queryParams = {
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      };

      final queryString = Uri(queryParameters: queryParams).query;
      final url = '$baseUrl/reviews/user?$queryString';

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return ApiResponse<ReviewResponse>.fromJson(
            jsonResponse,
            (data) => ReviewResponse.fromJson(data),
          );
        }
        return ApiResponse<ReviewResponse>(
          success: false,
          message:
              'Failed to load user reviews. Status code: ${response.statusCode}',
          errors: ['Invalid response format'],
        );
      }
      return ApiResponse<ReviewResponse>(
        success: false,
        message: 'Failed to load user reviews: ${response.statusCode}',
        errors: [response.body],
      );
    } catch (e) {
      return ApiResponse<ReviewResponse>(
        success: false,
        message: 'Failed to load user reviews: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Delete review
  static Future<ApiResponse<bool>> deleteReview(String reviewId) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse<bool>(
          success: false,
          message: 'User not authenticated',
          errors: ['No authentication token found'],
        );
      }

      final response = await http
          .delete(
            Uri.parse('$baseUrl/reviews/$reviewId'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return ApiResponse<bool>(
          success: jsonResponse['success'] ?? false,
          message: jsonResponse['message'] ?? 'Review deleted successfully',
          data: jsonResponse['data'] ?? true,
          errors:
              jsonResponse['errors'] != null
                  ? List<String>.from(jsonResponse['errors'])
                  : null,
        );
      }
      return ApiResponse<bool>(
        success: false,
        message: 'Failed to delete review. Status code: ${response.statusCode}',
        errors: [response.body],
      );
    } catch (e) {
      return ApiResponse<bool>(
        success: false,
        message: 'Failed to delete review: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Update review
  static Future<ApiResponse<bool>> updateReview({
    required String reviewId,
    required List<String> reviewImages,
    required int ratingValue,
    required String comment,
  }) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse<bool>(
          success: false,
          message: 'User not authenticated',
          errors: ['No authentication token found'],
        );
      }

      final Map<String, dynamic> reviewData = {
        'reviewImages': reviewImages,
        'ratingValue': ratingValue,
        'comment': comment,
      };

      final response = await http
          .patch(
            Uri.parse('$baseUrl/reviews/$reviewId'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode(reviewData),
          )
          .timeout(timeout);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        // Luôn đảm bảo trả về kiểu boolean cho data
        bool result = true;
        // Nếu server trả về data là một object, chỉ quan tâm đến việc request có thành công hay không
        return ApiResponse<bool>(
          success: jsonResponse['success'] ?? false,
          message: jsonResponse['message'] ?? 'Review updated successfully',
          data: result,
          errors:
              jsonResponse['errors'] != null
                  ? List<String>.from(jsonResponse['errors'])
                  : null,
        );
      }
      return ApiResponse<bool>(
        success: false,
        message: 'Failed to update review. Status code: ${response.statusCode}',
        errors: [response.body],
      );
    } catch (e) {
      return ApiResponse<bool>(
        success: false,
        message: 'Failed to update review: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }

  // Delete review image
  static Future<ApiResponse<bool>> deleteReviewImage(String imageUrl) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse<bool>(
          success: false,
          message: 'User not authenticated',
          errors: ['No authentication token found'],
        );
      }

      // Extract the image name from the URL to pass as a query parameter
      final Uri uri = Uri.parse(imageUrl);
      final String imageName = uri.pathSegments.last;

      final response = await http
          .delete(
            Uri.parse('$baseUrl/reviews/images?imageUrl=$imageName'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return ApiResponse<bool>(
          success: jsonResponse['success'] ?? false,
          message: jsonResponse['message'] ?? 'Image deleted successfully',
          data: jsonResponse['data'] ?? true,
          errors:
              jsonResponse['errors'] != null
                  ? List<String>.from(jsonResponse['errors'])
                  : null,
        );
      }
      return ApiResponse<bool>(
        success: false,
        message: 'Failed to delete image. Status code: ${response.statusCode}',
        errors: [response.body],
      );
    } catch (e) {
      return ApiResponse<bool>(
        success: false,
        message: 'Failed to delete image: ${e.toString()}',
        errors: [e.toString()],
      );
    }
  }
}
