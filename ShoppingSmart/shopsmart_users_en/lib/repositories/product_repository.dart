import 'dart:io';

import 'package:shopsmart_users_en/models/product_model.dart';
import 'package:shopsmart_users_en/models/detailed_product_model.dart';
import 'package:shopsmart_users_en/models/api_response_model.dart';
import 'package:shopsmart_users_en/models/review_models.dart';
import 'package:shopsmart_users_en/services/api_service.dart';

class ProductRepository {
  // Get all products with pagination
  Future<ApiResponse<PaginatedResponse<ProductModel>>> getProducts({
    int pageNumber = 1,
    int pageSize = 10,
    String? sortBy,
    String? categoryId,
  }) async {
    return ApiService.getProducts(
      pageNumber: pageNumber,
      pageSize: pageSize,
      sortBy: sortBy,
      categoryId: categoryId,
    );
  }

  // Get best sellers products
  Future<ApiResponse<PaginatedResponse<ProductModel>>> getBestSellers({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return ApiService.getBestSellers(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  // Get latest products
  Future<ApiResponse<PaginatedResponse<ProductModel>>> getLatestProducts({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return ApiService.getLatestProducts(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  // Get product details by ID
  Future<ApiResponse<DetailedProductModel>> getProductById(
    String productId,
  ) async {
    return ApiService.getProductById(productId);
  }

  // Get product reviews
  Future<ApiResponse<ReviewResponse>> getProductReviews(
    String productId, {
    int? ratingFilter,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return ApiService.getProductReviews(
      productId,
      ratingFilter: ratingFilter,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  // Post product review - method signature matches ApiService
  Future<ApiResponse<Map<String, dynamic>>> postReview({
    required String productItemId,
    required List<String> reviewImages,
    required int ratingValue,
    required String comment,
  }) async {
    return ApiService.postReview(
      productItemId: productItemId,
      reviewImages: reviewImages,
      ratingValue: ratingValue,
      comment: comment,
    );
  }

  // Upload review image
  Future<ApiResponse<String>> uploadReviewImage(File imageFile) async {
    return ApiService.uploadReviewImage(imageFile);
  }

  // Search products
  Future<ApiResponse<PaginatedResponse<ProductModel>>> searchProducts({
    required String searchQuery,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return ApiService.searchProducts(
      searchQuery: searchQuery,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
