import 'package:flutter/material.dart';
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
