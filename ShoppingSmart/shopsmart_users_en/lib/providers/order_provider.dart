import 'package:flutter/material.dart';
import '../models/order_models.dart';
import '../models/api_response_model.dart';
import '../repositories/order_repository.dart';

class OrderProvider with ChangeNotifier {
  final OrderRepository _orderRepository = OrderRepository();

  List<OrderModel> _orders = [];
  OrderDetailModel? _orderDetail;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  // Pagination properties
  int _currentPage = 1;
  final int _pageSize = 10;
  int _totalPages = 0;
  int _totalCount = 0;
  bool _hasMoreData = true;

  // Getters
  List<OrderModel> get orders => _orders;
  OrderDetailModel? get orderDetail => _orderDetail;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalCount => _totalCount;
  bool get hasMoreData => _hasMoreData;

  // Load orders with pagination
  Future<void> loadOrders({bool refresh = false, String? status}) async {
    if (refresh) {
      _orders.clear();
      _currentPage = 1;
      _hasMoreData = true;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    print('OrderProvider: Loading orders started, isLoading = $_isLoading');

    try {
      final response = await _orderRepository.getOrders(
        pageNumber: _currentPage,
        pageSize: _pageSize,
        status: status,
      );

      if (response.success && response.data != null) {
        final paginatedData = response.data!;

        if (refresh) {
          _orders = paginatedData.items;
        } else {
          _orders.addAll(paginatedData.items);
        }

        _totalPages = paginatedData.totalPages;
        _totalCount = paginatedData.totalCount;
        _hasMoreData = _currentPage < _totalPages;
        print(
          'OrderProvider: Orders loaded successfully, count = ${_orders.length}, totalCount = $_totalCount',
        );
      } else {
        _errorMessage = response.message;
        print('OrderProvider: Error loading orders: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = 'Failed to load orders: ${e.toString()}';
      print('OrderProvider: Exception loading orders: $_errorMessage');
    } finally {
      _isLoading = false;
      print('OrderProvider: Loading orders finished, isLoading = $_isLoading');
      notifyListeners();
    }
  }

  // Load more orders for pagination
  Future<void> loadMoreOrders({String? status}) async {
    if (_isLoadingMore || !_hasMoreData) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final response = await _orderRepository.getOrders(
        pageNumber: _currentPage,
        pageSize: _pageSize,
        status: status,
      );

      if (response.success && response.data != null) {
        final paginatedData = response.data!;
        _orders.addAll(paginatedData.items);
        _hasMoreData = _currentPage < paginatedData.totalPages;
      } else {
        _currentPage--; // Revert page number on error
        _errorMessage = response.message;
      }
    } catch (e) {
      _currentPage--; // Revert page number on error
      _errorMessage = 'Failed to load more orders: ${e.toString()}';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Get order detail by ID
  Future<void> getOrderDetail(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _orderRepository.getOrderDetail(orderId);

      if (response.success && response.data != null) {
        _orderDetail = response.data;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'Failed to load order detail: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel an order
  Future<ApiResponse<bool>> cancelOrder(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _orderRepository.cancelOrder(orderId: orderId);

      if (response.success) {
        // If order cancellation successful, update order detail
        if (_orderDetail != null && _orderDetail!.id == orderId) {
          // Update the order status to Cancelled
          _orderDetail = _orderDetail!.copyWith(
            status: 'Cancelled',
            statusChanges: [
              ..._orderDetail!.statusChanges,
              StatusChangeModel(date: DateTime.now(), status: 'Cancelled'),
            ],
          );
        }
      } else {
        _errorMessage = response.message;
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      final errorMsg = 'Failed to cancel order: ${e.toString()}';
      _errorMessage = errorMsg;
      _isLoading = false;
      notifyListeners();
      return ApiResponse<bool>(
        success: false,
        message: errorMsg,
        errors: [e.toString()],
        data: false,
      );
    }
  }

  // Create a new order
  Future<ApiResponse<OrderResponse>> createOrder(
    Map<String, dynamic> orderData,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _orderRepository.createOrderRaw(orderData);
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      final errorMsg = 'Failed to create order: ${e.toString()}';
      _errorMessage = errorMsg;
      _isLoading = false;
      notifyListeners();
      return ApiResponse<OrderResponse>(
        success: false,
        message: errorMsg,
        errors: [e.toString()],
      );
    }
  }

  // Reset state
  void reset() {
    _orders = [];
    _orderDetail = null;
    _currentPage = 1;
    _errorMessage = null;
    _hasMoreData = true;
    notifyListeners();
  }
}
