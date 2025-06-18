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

  // Validate a voucher by code
  Future<ApiResponse<VoucherModel>> validateVoucher(String voucherCode) async {
    return ApiService.validateVoucher(voucherCode);
  }
}
