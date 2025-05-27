import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_response_model.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/detailed_product_model.dart';
import '../models/blog_model.dart';

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

  // Get products with pagination and optional sorting
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

      print('Making API request to: $uri'); // Debug log

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(timeout);

      print('API Response Status: ${response.statusCode}'); // Debug log
      print('API Response Body: ${response.body}'); // Debug log

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
      print('SocketException: ${e.toString()}'); // Debug log
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
      print('HttpException: ${e.toString()}'); // Debug log
      return ApiResponse<PaginatedResponse<ProductModel>>(
        success: false,
        message: 'HTTP error occurred: ${e.message}',
        errors: ['HTTP request failed', e.toString()],
      );
    } on FormatException catch (e) {
      print('FormatException: ${e.toString()}'); // Debug log
      return ApiResponse<PaginatedResponse<ProductModel>>(
        success: false,
        message: 'Invalid response format: ${e.message}',
        errors: ['Server returned invalid data', e.toString()],
      );
    } catch (e) {
      print('Generic Exception: ${e.toString()}'); // Debug log
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

      print('Making best-sellers API request to: $uri'); // Debug log

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(timeout);

      print(
        'Best-sellers API Response Status: ${response.statusCode}',
      ); // Debug log
      print('Best-sellers API Response Body: ${response.body}'); // Debug log

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
      print('Best-sellers SocketException: ${e.toString()}'); // Debug log
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
      print('Best-sellers Exception: ${e.toString()}'); // Debug log
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

      print('Making categories API request to: $uri'); // Debug log

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(timeout);

      print(
        'Categories API Response Status: ${response.statusCode}',
      ); // Debug log
      print('Categories API Response Body: ${response.body}'); // Debug log

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
      print('Categories SocketException: ${e.toString()}'); // Debug log
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
      print('Categories Exception: ${e.toString()}'); // Debug log
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

  // Search products with pagination
  static Future<ApiResponse<PaginatedResponse<ProductModel>>> searchProducts({
    required String searchQuery,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/products').replace(
        queryParameters: {
          'name': searchQuery,
          'pageNumber': pageNumber.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      print('Making search API request to: $uri'); // Debug log

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
          'Error: ${e.toString()}',
        ],
      );
    } catch (e) {
      return ApiResponse<PaginatedResponse<ProductModel>>(
        success: false,
        message: 'Search failed: ${e.toString()}',
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

      print('Making blogs API request to: $uri'); // Debug log

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(timeout);

      print('Blogs API Response Status: ${response.statusCode}'); // Debug log
      print('Blogs API Response Body: ${response.body}'); // Debug log

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
      print('Blogs SocketException: ${e.toString()}'); // Debug log
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
      print('Blogs Exception: ${e.toString()}'); // Debug log
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
      print('Testing connection to: $baseUrl');

      final uri = Uri.parse(
        '$baseUrl/products',
      ).replace(queryParameters: {'pageNumber': '1', 'pageSize': '1'});

      print('Test request URL: $uri');

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('Test Response Status: ${response.statusCode}');
      print('Test Response Headers: ${response.headers}');
      print(
        'Test Response Body (first 200 chars): ${response.body.length > 200 ? "${response.body.substring(0, 200)}..." : response.body}',
      );

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
      print('Test SocketException: ${e.toString()}');
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
      print('Test Exception: ${e.toString()}');
      return ApiResponse<String>(
        success: false,
        data: null,
        message: 'Connection test failed',
        errors: [e.toString()],
      );
    }
  }
}
