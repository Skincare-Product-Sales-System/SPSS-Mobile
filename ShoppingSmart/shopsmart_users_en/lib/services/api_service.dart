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
import '../services/jwt_service.dart';
import '../models/address_model.dart';
import '../models/payment_method_model.dart';

class ApiService {
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

  static Future<ApiResponse<PaginatedResponse<ProductModel>>> getProducts({
    int pageNumber = 1,
    int pageSize = 10,
    String? sortBy,
    String? categoryId,
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

  // Search products by name
  static Future<ApiResponse<PaginatedResponse<ProductModel>>> searchProducts({
    required String searchQuery,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      Map<String, String> queryParams = {
        'name': searchQuery,
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      };

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
          message: 'Search failed. Status code: ${response.statusCode}',
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

  // Get product by ID
  static Future<ApiResponse<DetailedProductModel>> getProductById(
    String productId,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/products/$productId');

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
          (data) => DetailedProductModel.fromJson(data),
        );
      } else {
        return ApiResponse<DetailedProductModel>(
          success: false,
          message:
              'Failed to load product. Status code: ${response.statusCode}',
          errors: ['HTTP Error: ${response.statusCode}'],
        );
      }
    } catch (e) {
      return ApiResponse<DetailedProductModel>(
        success: false,
        message: 'Failed to load product: ${e.toString()}',
        errors: [e.toString()],
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

  // Skin analysis API call
  static Future<ApiResponse<SkinAnalysisResult>> analyzeSkin(
    File imageFile,
  ) async {
    try {
      final token = await JwtService.getStoredToken();
      if (token == null) {
        return ApiResponse<SkinAnalysisResult>(
          success: false,
          message: 'Vui lòng đăng nhập để sử dụng tính năng này',
          errors: ['Người dùng chưa đăng nhập'],
        );
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/skin-analysis/analyze'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.files.add(
        await http.MultipartFile.fromPath('faceImage', imageFile.path),
      );

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse<SkinAnalysisResult>.fromJson(
          jsonData,
          (data) => SkinAnalysisResult.fromJson(data),
        );
      } else {
        Map<String, dynamic>? errorData;
        try {
          errorData = json.decode(response.body);
        } catch (e) {
          errorData = null;
        }

        String errorMessage = 'Không thể phân tích da';

        if (errorData != null && errorData['message'] != null) {
          errorMessage = errorData['message'];
        } else {
          // Provide specific error messages based on status code
          switch (response.statusCode) {
            case 400:
              errorMessage =
                  'Không thể nhận diện khuôn mặt trong ảnh. Vui lòng thử lại với ảnh khác.';
              break;
            case 401:
              errorMessage = 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
              break;
            case 500:
              errorMessage = 'Lỗi hệ thống. Vui lòng thử lại sau.';
              break;
            default:
              errorMessage =
                  'Không thể phân tích da. Vui lòng thử lại với ảnh khác.';
          }
        }

        List<String> errors = [];
        if (errorData != null && errorData['errors'] != null) {
          errors = List<String>.from(errorData['errors']);
        }

        if (errors.isEmpty) {
          errors.add(
            'Vui lòng thử lại với ảnh rõ nét và chụp trực diện khuôn mặt',
          );
        }

        return ApiResponse<SkinAnalysisResult>(
          success: false,
          message: errorMessage,
          errors: errors,
        );
      }
    } on SocketException {
      return ApiResponse<SkinAnalysisResult>(
        success: false,
        message: 'Không có kết nối mạng',
        errors: ['Vui lòng kiểm tra kết nối internet của bạn và thử lại'],
      );
    } on TimeoutException {
      return ApiResponse<SkinAnalysisResult>(
        success: false,
        message: 'Hệ thống phản hồi chậm',
        errors: ['Vui lòng thử lại sau'],
      );
    } catch (e) {
      return ApiResponse<SkinAnalysisResult>(
        success: false,
        message: 'Đã xảy ra lỗi khi phân tích da',
        errors: ['Vui lòng thử lại với ảnh khác'],
      );
    }
  }
}
