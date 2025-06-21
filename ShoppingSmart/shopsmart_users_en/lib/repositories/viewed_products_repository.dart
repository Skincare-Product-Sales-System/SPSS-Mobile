import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/viewed_product.dart';
import '../models/api_response_model.dart';
import 'package:uuid/uuid.dart';

class ViewedProductsRepository {
  static const String _storageKey = 'viewed_products';
  final int _maxViewedProducts = 50; // Limit number of viewed products

  // Save viewed products to local storage
  Future<bool> _saveViewedProducts(List<ViewedProdModel> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert to list of maps for storage
      final List<Map<String, dynamic>> productsList =
          products
              .map(
                (product) => {
                  'viewedProdId': product.viewedProdId,
                  'productId': product.productId,
                  'timestamp': product.timestamp.toIso8601String(),
                },
              )
              .toList();

      // Save to SharedPreferences
      await prefs.setString(_storageKey, jsonEncode(productsList));
      return true;
    } catch (e) {
      print('Error saving viewed products: $e');
      return false;
    }
  }

  // Get viewed products from local storage
  Future<ApiResponse<List<ViewedProdModel>>> getViewedProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? storedData = prefs.getString(_storageKey);

      if (storedData == null) {
        return ApiResponse<List<ViewedProdModel>>.success(data: []);
      }

      final List<dynamic> productsList = jsonDecode(storedData);
      final List<ViewedProdModel> products = [];

      for (var item in productsList) {
        final viewedProduct = ViewedProdModel(
          viewedProdId: item['viewedProdId'],
          productId: item['productId'],
          timestamp: DateTime.parse(item['timestamp']),
        );

        products.add(viewedProduct);
      }

      // Sort by timestamp, newest first
      products.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return ApiResponse<List<ViewedProdModel>>.success(data: products);
    } catch (e) {
      return ApiResponse<List<ViewedProdModel>>.error(
        message: 'Error loading viewed products: $e',
      );
    }
  }

  // Add a product to viewed list
  Future<ApiResponse<bool>> addViewedProduct(String productId) async {
    try {
      final response = await getViewedProducts();
      if (!response.success) {
        return ApiResponse<bool>.error(
          message: response.message ?? 'Unknown error',
        );
      }

      final products = response.data ?? [];

      // Remove if exists to add to top
      products.removeWhere((p) => p.productId == productId);

      // Add new product at the beginning
      products.insert(
        0,
        ViewedProdModel(viewedProdId: const Uuid().v4(), productId: productId),
      );

      // Limit the number of products
      if (products.length > _maxViewedProducts) {
        products.removeRange(_maxViewedProducts, products.length);
      }

      final success = await _saveViewedProducts(products);

      if (success) {
        return ApiResponse<bool>.success(data: true);
      } else {
        return ApiResponse<bool>.error(
          message: 'Failed to save viewed product',
        );
      }
    } catch (e) {
      return ApiResponse<bool>.error(
        message: 'Error adding viewed product: $e',
      );
    }
  }

  // Remove a product from viewed list
  Future<ApiResponse<bool>> removeViewedProduct(String productId) async {
    try {
      final response = await getViewedProducts();
      if (!response.success) {
        return ApiResponse<bool>.error(
          message: response.message ?? 'Unknown error',
        );
      }

      final products = response.data ?? [];
      products.removeWhere((p) => p.productId == productId);

      final success = await _saveViewedProducts(products);

      if (success) {
        return ApiResponse<bool>.success(data: true);
      } else {
        return ApiResponse<bool>.error(
          message: 'Failed to remove viewed product',
        );
      }
    } catch (e) {
      return ApiResponse<bool>.error(
        message: 'Error removing viewed product: $e',
      );
    }
  }

  // Clear all viewed products
  Future<ApiResponse<bool>> clearViewedProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      return ApiResponse<bool>.success(data: true);
    } catch (e) {
      return ApiResponse<bool>.error(
        message: 'Error clearing viewed products: $e',
      );
    }
  }
}
