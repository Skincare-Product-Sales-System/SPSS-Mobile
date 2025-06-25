import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/order_models.dart';
import '../models/view_state.dart';
import '../models/voucher_model.dart';
import '../repositories/order_repository.dart';
import '../services/error_handling_service.dart';
import 'base_view_model.dart';
import 'order_state.dart';

class EnhancedOrderViewModel extends BaseViewModel<OrderState> {
  final OrderRepository _orderRepository;

  EnhancedOrderViewModel({OrderRepository? orderRepository})
    : _orderRepository = orderRepository ?? OrderRepository(),
      super(const OrderState());

  // Getters tiện ích
  List<OrderModel> get orders => state.orders.data ?? [];
  OrderDetailModel? get selectedOrder => state.selectedOrder.data;
  List<VoucherModel> get vouchers => state.vouchers.data ?? [];
  bool get isLoading => state.orders.isLoading;
  bool get isLoadingOrderDetail => state.selectedOrder.isLoading;
  bool get isLoadingVouchers => state.vouchers.isLoading;
  bool get isCreatingOrder => state.isCreatingOrder;
  String? get creatingOrderError => state.creatingOrderError;
  VoucherModel? get selectedVoucher => state.selectedVoucher;

  // Review-related getters
  List<String> get reviewImages => state.reviewImages;
  bool get isSubmittingReview => state.isSubmittingReview;
  bool get isUploadingImage => state.isUploadingImage;
  bool get isDeletingImage => state.isDeletingImage;
  String? get reviewError => state.reviewError;
  bool get reviewSubmitted => state.reviewSubmitted;

  // Tải danh sách đơn hàng
  Future<void> loadOrders({bool refresh = false, String? status}) async {
    String? convertedStatus =
        status != null ? _convertStatusToEnglish(status) : null;

    if (refresh) {
      updateState(
        state.copyWith(
          orders: ViewState.loading(),
          currentPage: 1,
          hasMoreData: true,
          selectedOrderStatus: convertedStatus,
        ),
      );
    } else {
      updateState(state.copyWith(orders: ViewState.loadingMore(orders)));
    }

    try {
      final response = await _orderRepository.getOrders(
        pageNumber: refresh ? 1 : state.currentPage,
        pageSize: state.pageSize,
        status: convertedStatus,
      );

      if (response.success && response.data != null) {
        final paginatedData = response.data!;
        final List<OrderModel> loadedOrders =
            refresh ? paginatedData.items : [...orders, ...paginatedData.items];

        updateState(
          state.copyWith(
            orders: ViewState.loaded(loadedOrders),
            currentPage: refresh ? 2 : state.currentPage + 1,
            hasMoreData: loadedOrders.length < paginatedData.totalCount,
          ),
        );
      } else {
        updateState(
          state.copyWith(
            orders: ViewState.error(
              response.message ?? 'Failed to load orders',
              response.errors,
            ),
          ),
        );
      }
    } catch (e) {
      handleError(e, source: 'loadOrders');
      updateState(
        state.copyWith(
          orders: ViewState.error('Failed to load orders: ${e.toString()}'),
        ),
      );
    }
  }

  // Phương thức chuyển đổi trạng thái từ tiếng Việt sang tiếng Anh
  String _convertStatusToEnglish(String vietnameseStatus) {
    switch (vietnameseStatus) {
      case 'Đang xử lý':
        return 'processing';
      case 'Đã hủy':
        return 'cancelled';
      case 'Chờ thanh toán':
        return 'awaiting payment';
      case 'Đã hoàn tiền':
        return 'refunded';
      case 'Đang giao hàng':
        return 'shipping';
      case 'Đã giao hàng':
        return 'delivered';
      case 'Đã trả hàng':
        return 'returned';
      case 'Đang chờ hoàn tiền':
        return 'refund pending';
      default:
        return vietnameseStatus.toLowerCase();
    }
  }

  // Phương thức chuyển đổi trạng thái từ tiếng Anh sang tiếng Việt
  String getTranslatedStatus(String englishStatus) {
    String status = englishStatus.toLowerCase();
    switch (status) {
      case 'processing':
        return 'Đang xử lý';
      case 'cancelled':
        return 'Đã hủy';
      case 'awaiting payment':
        return 'Chờ thanh toán';
      case 'refunded':
        return 'Đã hoàn tiền';
      case 'shipping':
        return 'Đang giao hàng';
      case 'delivered':
        return 'Đã giao hàng';
      case 'returned':
        return 'Đã trả hàng';
      case 'refund pending':
        return 'Đang chờ hoàn tiền';
      default:
        return status.toUpperCase();
    }
  }

  // Lấy màu sắc dựa trên trạng thái đơn hàng
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFA500); // Orange
      case 'processing':
        return const Color(0xFF1E90FF); // Dodger Blue
      case 'shipped':
      case 'shipping':
        return const Color(0xFF4169E1); // Royal Blue
      case 'delivered':
        return const Color(0xFF32CD32); // Lime Green
      case 'cancelled':
        return const Color(0xFFFF0000); // Red
      case 'awaiting payment':
        return const Color(0xFFE69138); // Dark Orange
      case 'refunded':
        return const Color(0xFF8B008B); // Dark Magenta
      case 'returned':
        return const Color(0xFFB22222); // Firebrick
      case 'refund pending':
        return const Color(0xFFDC143C); // Crimson
      default:
        return const Color(0xFF808080); // Gray
    }
  }

  // Format tiền tệ
  String formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount.round())}₫';
  }

  // Format ngày tháng
  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // Tải thêm đơn hàng (phân trang)
  Future<void> loadMoreOrders() async {
    if (!state.hasMoreData || state.orders.isLoadingMore) {
      return;
    }

    await loadOrders(status: state.selectedOrderStatus);
  }

  // Tải chi tiết đơn hàng theo ID
  Future<void> loadOrderDetail(String orderId) async {
    updateState(state.copyWith(selectedOrder: ViewState.loading()));

    try {
      final response = await _orderRepository.getOrderDetail(orderId);

      if (response.success && response.data != null) {
        updateState(
          state.copyWith(selectedOrder: ViewState.loaded(response.data!)),
        );
      } else {
        updateState(
          state.copyWith(
            selectedOrder: ViewState.error(
              response.message ?? 'Failed to load order details',
              response.errors,
            ),
          ),
        );
      }
    } catch (e) {
      handleError(e, source: 'loadOrderDetail');
      updateState(
        state.copyWith(
          selectedOrder: ViewState.error(
            'Failed to load order details: ${e.toString()}',
          ),
        ),
      );
    }
  }

  // Tạo đơn hàng mới
  Future<OrderResponse?> createOrder(Map<String, dynamic> orderData) async {
    updateState(
      state.copyWith(isCreatingOrder: true, creatingOrderError: null),
    );

    try {
      final response = await _orderRepository.createOrderRaw(orderData);

      if (response.success && response.data != null) {
        updateState(state.copyWith(isCreatingOrder: false));
        return response.data;
      } else {
        updateState(
          state.copyWith(
            isCreatingOrder: false,
            creatingOrderError: response.message ?? 'Failed to create order',
          ),
        );
        return null;
      }
    } catch (e) {
      handleError(e, source: 'createOrder');
      updateState(
        state.copyWith(
          isCreatingOrder: false,
          creatingOrderError: 'Failed to create order: ${e.toString()}',
        ),
      );
      return null;
    }
  }

  // Hủy đơn hàng
  Future<bool> cancelOrder(String orderId) async {
    try {
      final response = await _orderRepository.cancelOrder(orderId: orderId);

      if (response.success && response.data == true) {
        // Cập nhật lại danh sách đơn hàng sau khi hủy
        await loadOrders(refresh: true, status: state.selectedOrderStatus);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      handleError(e, source: 'cancelOrder');
      return false;
    }
  }

  // Tải danh sách vouchers
  Future<void> loadVouchers({bool refresh = false}) async {
    if (refresh) {
      updateState(state.copyWith(vouchers: ViewState.loading()));
    }

    try {
      final response = await _orderRepository.getVouchers(
        pageNumber: 1,
        pageSize: 50, // Lấy nhiều voucher một lần
        status: 'Active',
      );

      if (response.success && response.data != null) {
        updateState(
          state.copyWith(vouchers: ViewState.loaded(response.data!.items)),
        );
      } else {
        updateState(
          state.copyWith(
            vouchers: ViewState.error(
              response.message ?? 'Failed to load vouchers',
              response.errors,
            ),
          ),
        );
      }
    } catch (e) {
      handleError(e, source: 'loadVouchers');
      updateState(
        state.copyWith(
          vouchers: ViewState.error('Failed to load vouchers: ${e.toString()}'),
        ),
      );
    }
  }

  // Xác thực voucher theo mã
  Future<bool> validateVoucher(String voucherCode) async {
    try {
      final response = await _orderRepository.validateVoucher(voucherCode);

      if (response.success && response.data != null) {
        updateState(state.copyWith(selectedVoucher: response.data));
        return true;
      } else {
        return false;
      }
    } catch (e) {
      handleError(e, source: 'validateVoucher');
      return false;
    }
  }

  // Xóa voucher đã chọn
  void clearSelectedVoucher() {
    updateState(state.clearSelectedVoucher());
  }

  // Xóa lỗi tạo đơn hàng
  void clearCreatingOrderError() {
    updateState(state.clearCreatingOrderError());
  }

  // Load checkout details
  Future<void> loadCheckoutDetails() async {
    // This is a placeholder method to satisfy the EnhancedCheckoutScreen
    // In a real implementation, this would load shipping details, payment methods, etc.
    await loadVouchers(refresh: true);
  }

  // Upload image for product review
  Future<String?> uploadReviewImage(XFile image) async {
    updateState(state.copyWith(isUploadingImage: true, reviewError: null));

    try {
      final file = File(image.path);
      final response = await _orderRepository.uploadReviewImage(file);

      if (response.success && response.data != null) {
        final imageUrl = response.data!;
        // Thêm ảnh vào state
        final updatedState = state.addReviewImage(imageUrl);
        updateState(updatedState.copyWith(isUploadingImage: false));
        return imageUrl;
      } else {
        updateState(
          state.copyWith(
            isUploadingImage: false,
            reviewError: response.message ?? 'Failed to upload image',
          ),
        );
        return null;
      }
    } catch (e) {
      handleError(e, source: 'uploadReviewImage');
      updateState(
        state.copyWith(
          isUploadingImage: false,
          reviewError: 'Failed to upload image: ${e.toString()}',
        ),
      );
      return null;
    }
  }

  // Delete review image
  Future<bool> deleteReviewImage(String imageUrl) async {
    updateState(state.copyWith(isDeletingImage: true, reviewError: null));

    try {
      final response = await _orderRepository.deleteReviewImage(imageUrl);

      if (response.success && response.data != null && response.data!) {
        // Xóa ảnh khỏi state
        final updatedState = state.removeReviewImage(imageUrl);
        updateState(updatedState.copyWith(isDeletingImage: false));
        return true;
      } else {
        updateState(
          state.copyWith(
            isDeletingImage: false,
            reviewError: response.message ?? 'Failed to delete image',
          ),
        );
        return false;
      }
    } catch (e) {
      handleError(e, source: 'deleteReviewImage');
      updateState(
        state.copyWith(
          isDeletingImage: false,
          reviewError: 'Failed to delete image: ${e.toString()}',
        ),
      );
      return false;
    }
  } // Create product review

  Future<bool> createProductReview({
    required String productItemId,
    required int rating,
    required String comment,
    String? orderId,
  }) async {
    // Đảm bảo trạng thái ban đầu đúng
    updateState(state.copyWith(isSubmittingReview: true, reviewError: null));

    try {
      // Lấy danh sách reviewImages hiện tại để gửi request (copy ra để tránh tham chiếu)
      final reviewImages = List<String>.from(state.reviewImages);

      debugPrint('SUBMITTING REVIEW WITH ${reviewImages.length} IMAGES');

      // Gửi request với ảnh hiện tại
      final response = await _orderRepository.createProductReview(
        productItemId: productItemId,
        rating: rating,
        comment: comment,
        reviewImages: reviewImages,
      );

      // Reset toàn bộ state liên quan đến review ngay lập tức, bất kể kết quả
      cleanupReviewImages();

      if (response.success && response.data != null && response.data!) {
        // If we have orderId, update the OrderDetail model locally before reloading from server
        if (orderId != null && state.selectedOrder.data != null) {
          final orderDetails = List<OrderDetail>.from(
            state.selectedOrder.data!.orderDetails,
          );

          // Find the item and update its reviewable status
          final index = orderDetails.indexWhere(
            (item) => item.productItemId == productItemId,
          );
          if (index >= 0) {
            orderDetails[index] = orderDetails[index].copyWith(
              isReviewable: false,
            );

            // Update the selectedOrder in state
            final updatedOrder = state.selectedOrder.data!.copyWith(
              orderDetails: orderDetails,
            );
            updateState(
              state.copyWith(selectedOrder: ViewState.loaded(updatedOrder)),
            );
          }

          // Still reload from server in background to ensure data consistency
          loadOrderDetail(orderId);
        }

        return true;
      } else {
        updateState(
          state.copyWith(
            reviewError: response.message ?? 'Failed to submit review',
          ),
        );
        return false;
      }
    } catch (e) {
      handleError(e, source: 'createProductReview');
      updateState(
        state.copyWith(reviewError: 'Failed to submit review: ${e.toString()}'),
      );
      return false;
    }
  }

  // Clean up review images if review was not submitted
  void cleanupReviewImages() {
    // Reset review state và lưu state mới
    final newState = state.resetReviewState();
    updateState(newState);

    // Debug log để xác nhận đã xóa
    debugPrint(
      'REVIEW IMAGES CLEANED UP: ${state.reviewImages.length} images (should be 0)',
    );
  }

  // Check if order can be reviewed
  bool canReviewOrder(String status) {
    final lowerStatus = status.toLowerCase();
    return lowerStatus == 'delivered';
  }

  // Lấy voucher theo mã
  Future<bool> getVoucherByCode(
    String voucherCode, {
    double? cartAmount,
  }) async {
    try {
      print(
        'EnhancedOrderViewModel.getVoucherByCode: Fetching voucher with code: $voucherCode',
      );
      final response = await _orderRepository.getVoucherByCode(voucherCode);
      print(
        'EnhancedOrderViewModel.getVoucherByCode: API Response success: ${response.success}',
      );

      if (response.success && response.data != null) {
        final voucher = response.data;
        print(
          'EnhancedOrderViewModel.getVoucherByCode: Voucher data: ${voucher?.toJson()}',
        );
        print(
          'EnhancedOrderViewModel.getVoucherByCode: Voucher minimumOrderValue: ${voucher?.minimumOrderValue}',
        );
        print(
          'EnhancedOrderViewModel.getVoucherByCode: Voucher isValid: ${voucher?.isValid}',
        );

        // Validate voucher against cart amount
        if (cartAmount != null && voucher != null) {
          String? validationError = voucher.getValidationError(cartAmount);
          if (validationError != null) {
            // Voucher is not valid for this order
            print(
              'EnhancedOrderViewModel.getVoucherByCode: Validation error: $validationError',
            );
            updateState(state.copyWith(creatingOrderError: validationError));
            return false;
          }
        }

        // Voucher is valid, save it to state
        updateState(
          state.copyWith(selectedVoucher: voucher, creatingOrderError: null),
        );
        return true;
      } else {
        // Cập nhật lỗi khi voucher không hợp lệ
        print(
          'EnhancedOrderViewModel.getVoucherByCode: Invalid voucher, message: ${response.message}',
        );
        updateState(
          state.copyWith(
            creatingOrderError: response.message ?? 'Mã giảm giá không hợp lệ',
          ),
        );
        return false;
      }
    } catch (e) {
      print('EnhancedOrderViewModel.getVoucherByCode: Error: ${e.toString()}');
      handleError(e, source: 'getVoucherByCode');
      updateState(
        state.copyWith(
          creatingOrderError: 'Lỗi khi kiểm tra mã giảm giá: ${e.toString()}',
        ),
      );
      return false;
    }
  }

  @override
  void handleError(
    dynamic error, {
    String? source,
    ErrorSeverity severity = ErrorSeverity.medium,
  }) {
    debugPrint(
      'Error in EnhancedOrderViewModel (${source ?? 'unknown'}): $error',
    );
    // Gọi phương thức của lớp cha để sử dụng xử lý lỗi tập trung
    super.handleError(error, source: source, severity: severity);
  }
}
