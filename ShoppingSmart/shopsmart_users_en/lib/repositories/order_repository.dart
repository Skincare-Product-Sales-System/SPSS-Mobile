import 'dart:io';
import 'package:shopsmart_users_en/models/api_response_model.dart';
import 'package:shopsmart_users_en/models/order_models.dart';
import 'package:shopsmart_users_en/services/api_service.dart';
import 'package:shopsmart_users_en/models/voucher_model.dart';

class OrderRepository {
  // Get orders with pagination
  Future<ApiResponse<PaginatedResponse<OrderModel>>> getOrders({
    int pageNumber = 1,
    int pageSize = 10,
    String? status,
  }) async {
    return ApiService.getOrders(
      pageNumber: pageNumber,
      pageSize: pageSize,
      status: status,
    );
  }

  // Get order details by ID
  Future<ApiResponse<OrderDetailModel>> getOrderDetail(String orderId) async {
    return ApiService.getOrderDetail(orderId);
  }

  // Create a new order
  Future<ApiResponse<OrderResponse>> createOrderRaw(
    Map<String, dynamic> data,
  ) async {
    return ApiService.createOrderRaw(data);
  }

  // Cancel an order
  Future<ApiResponse<bool>> cancelOrder({
    required String orderId,
    String cancelReasonId = '3b3a9749-3435-452e-bbbc-554a23b1f531',
  }) async {
    return ApiService.cancelOrder(
      orderId: orderId,
      cancelReasonId: cancelReasonId,
    );
  }

  // Get available vouchers
  Future<ApiResponse<PaginatedResponse<VoucherModel>>> getVouchers({
    int pageNumber = 1,
    int pageSize = 10,
    String? status,
  }) async {
    return ApiService.getVouchers(
      pageNumber: pageNumber,
      pageSize: pageSize,
      status: status,
    );
  }

  // Upload image for product review
  Future<ApiResponse<String>> uploadReviewImage(File imageFile) async {
    final requestUrl = '${ApiService.baseUrl}/images';
    return ApiService.uploadImageWithUrl(imageFile, requestUrl, 'files');
  }

  // Delete review image
  Future<ApiResponse<bool>> deleteReviewImage(String imageUrl) async {
    final requestUrl = '${ApiService.baseUrl}/images';
    return ApiService.deleteImageWithQuery(imageUrl, requestUrl);
  }

  // Create product review
  Future<ApiResponse<bool>> createProductReview({
    required String productItemId,
    required int rating,
    required String comment,
    required List<String> reviewImages,
  }) async {
    final requestUrl = '${ApiService.baseUrl}/reviews';
    return ApiService.createReview(
      productItemId: productItemId,
      rating: rating,
      comment: comment,
      reviewImages: reviewImages,
      url: requestUrl,
    );
  }

  // Get voucher by code
  Future<ApiResponse<VoucherModel>> getVoucherByCode(String voucherCode) async {
    return ApiService.getVoucherByCode(voucherCode);
  }

  // Validate voucher by code
  Future<ApiResponse<VoucherModel>> validateVoucher(String voucherCode) async {
    return ApiService.validateVoucher(voucherCode);
  }
}
