import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/view_state.dart';
import '../models/api_response_model.dart';
import '../repositories/cart_repository.dart';
import '../services/error_handling_service.dart';
import '../services/service_locator.dart';
import 'base_view_model.dart';
import 'cart_state.dart';

/// ViewModel cải tiến cho Cart, kế thừa từ BaseViewModel
class EnhancedCartViewModel extends BaseViewModel<CartState> {
  final CartRepository _cartRepository;

  /// Constructor với dependency injection cho repository
  EnhancedCartViewModel({CartRepository? cartRepository})
    : _cartRepository = cartRepository ?? sl<CartRepository>(),
      super(const CartState());

  /// Getters tiện ích
  Map<String, CartModel> get cartItems => state.cartItems.data ?? {};
  bool get isLoading => state.cartItems.isLoading;
  bool get isProcessing => state.isProcessing;
  String? get errorMessage => state.errorMessage;
  bool get hasError => state.errorMessage != null;
  int get totalQuantity => _calculateTotalQuantity();
  double get totalPrice => state.totalPrice;
  bool get isEmpty => cartItems.isEmpty;

  // For backward compatibility
  double get totalAmount => state.totalPrice;

  // Tính tổng số lượng sản phẩm trong giỏ hàng
  int _calculateTotalQuantity() {
    int total = 0;
    if (cartItems.isEmpty) return 0;

    for (var item in cartItems.values) {
      total += item.quantity;
    }

    return total;
  }

  /// Tải giỏ hàng từ server
  Future<void> fetchCartFromServer() async {
    debugPrint('Bắt đầu tải giỏ hàng từ server');

    updateState(
      state.copyWith(cartItems: ViewState.loading(), errorMessage: null),
    );

    try {
      final response = await _cartRepository.getCartItems();
      debugPrint('Nhận phản hồi từ server: success=${response.success}');

      if (response.success && response.data != null) {
        // Chuyển đổi dữ liệu từ API sang Map<String, CartModel>
        final Map<String, CartModel> items = {};

        // Xử lý dữ liệu từ PaginatedResponse
        if (response.data is PaginatedResponse) {
          final paginatedData = response.data as PaginatedResponse;
          final itemsList = paginatedData.items;
          debugPrint('Số sản phẩm trong giỏ hàng từ API: ${itemsList.length}');

          if (itemsList.isNotEmpty) {
            for (var item in itemsList) {
              if (item is Map<String, dynamic>) {
                final id = item['id']?.toString() ?? '';
                final productItemId = item['productItemId']?.toString() ?? '';
                final productId = item['productId']?.toString() ?? '';
                final title = item['productName']?.toString() ?? 'Sản phẩm';
                final imageUrl = item['productImageUrl']?.toString() ?? '';
                final price = (item['price'] ?? 0.0).toDouble();
                final marketPrice = (item['marketPrice'] ?? 0.0).toDouble();
                final quantity = item['quantity'] ?? 1;
                final stockQuantity = item['stockQuantity'] ?? 0;
                final totalPrice = (item['totalPrice'] ?? 0.0).toDouble();
                final inStock = item['inStock'] ?? true;
                final variationOptionValues =
                    (item['variationOptionValues'] as List<dynamic>?)
                        ?.map((e) => e.toString())
                        .toList() ??
                    [];

                items[productItemId] = CartModel(
                  cartId: id,
                  productId: productId,
                  productItemId: productItemId,
                  id: productId,
                  title: title,
                  price: price,
                  marketPrice: marketPrice,
                  quantity: quantity,
                  stockQuantity: stockQuantity,
                  productImageUrl: imageUrl,
                  inStock: inStock,
                  totalPrice: totalPrice,
                  variationOptionValues: variationOptionValues,
                );

                debugPrint(
                  'Đã thêm sản phẩm vào giỏ hàng: $title (ID: $productItemId), SL: $quantity',
                );
              }
            }
          }
        }

        debugPrint('Cập nhật state với ${items.length} sản phẩm');
        updateState(
          state.copyWith(
            cartItems: ViewState.loaded(items),
            isProcessing: false,
            errorMessage: null,
          ),
        );
      } else {
        // Nếu có lỗi "No cart items found for the specified user", hiển thị giỏ hàng rỗng thay vì báo lỗi
        if (response.message?.contains('No cart items found') == true ||
            response.statusCode == 404) {
          debugPrint('Không tìm thấy giỏ hàng, hiển thị giỏ hàng rỗng');
          updateState(
            state.copyWith(
              cartItems: ViewState.loaded({}),
              isProcessing: false,
              errorMessage: null,
            ),
          );
        } else {
          debugPrint('Lỗi khi tải giỏ hàng: ${response.message}');
          updateState(
            state.copyWith(
              cartItems: ViewState.error(
                response.message ?? 'Failed to load cart items',
                response.errors,
              ),
              isProcessing: false,
              errorMessage: response.message,
            ),
          );
          handleError(
            response.message ?? 'Failed to load cart items',
            source: 'fetchCartFromServer',
            severity: ErrorSeverity.medium,
          );
        }
      }
    } catch (e) {
      // Nếu có lỗi "No cart items found for the specified user", hiển thị giỏ hàng rỗng thay vì báo lỗi
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('no cart items found') ||
          errorMsg.contains('404')) {
        debugPrint('Không tìm thấy giỏ hàng, hiển thị giỏ hàng rỗng');
        updateState(
          state.copyWith(
            cartItems: ViewState.loaded({}),
            isProcessing: false,
            errorMessage: null,
          ),
        );
      } else {
        final errorMsg = 'Lỗi khi tải giỏ hàng: ${e.toString()}';
        debugPrint(errorMsg);
        updateState(
          state.copyWith(
            cartItems: ViewState.error(errorMsg),
            isProcessing: false,
            errorMessage: errorMsg,
          ),
        );
        handleError(
          e,
          source: 'fetchCartFromServer',
          severity: ErrorSeverity.medium,
        );
      }
    }
  }

  /// Thêm sản phẩm vào giỏ hàng
  Future<void> addToCart({
    required String productId,
    required String productItemId,
    required String title,
    required double price,
    String productImageUrl = '', // Cho phép truyền vào URL ảnh sản phẩm
    double marketPrice = 0, // Giá thị trường có thể khác giá bán
  }) async {
    assert(price > 0, 'Giá sản phẩm phải lớn hơn 0');
    assert(productId.isNotEmpty, 'ProductId không được để trống');
    assert(productItemId.isNotEmpty, 'ProductItemId không được để trống');

    updateState(state.copyWith(isProcessing: true, errorMessage: null));
    debugPrint('Đang thêm sản phẩm vào giỏ hàng: $title, ID: $productItemId');

    try {
      // Kiểm tra xem sản phẩm đã có trong giỏ hàng chưa
      final existingItem = cartItems[productItemId];
      final int newQuantity =
          existingItem != null ? existingItem.quantity + 1 : 1;
      final double finalMarketPrice = marketPrice > 0 ? marketPrice : price;

      // Tạo hoặc cập nhật CartModel
      final newCartItem = CartModel(
        cartId:
            existingItem?.cartId ??
            DateTime.now().millisecondsSinceEpoch
                .toString(), // Giữ cartId nếu đã tồn tại
        productId: productId,
        productItemId: productItemId,
        id: productId,
        title: title,
        price: price,
        marketPrice: finalMarketPrice,
        quantity: newQuantity,
        stockQuantity:
            existingItem?.stockQuantity ??
            100, // Giữ số lượng trong kho nếu đã biết
        productImageUrl:
            productImageUrl.isNotEmpty
                ? productImageUrl
                : existingItem?.productImageUrl ?? '',
        inStock: true,
        totalPrice: price * newQuantity,
        variationOptionValues: existingItem?.variationOptionValues ?? [],
      ); // Cập nhật state với sản phẩm mới trước khi gửi lên server
      final Map<String, CartModel> updatedCartItems = Map.from(cartItems);
      updatedCartItems[productItemId] = newCartItem;

      // Chỉ cập nhật cartItems, totalPrice sẽ được tính lại tự động từ getter trong CartState
      updateState(
        state.copyWith(
          cartItems: ViewState.loaded(updatedCartItems),
          errorMessage: null,
        ),
      );

      debugPrint(
        'Đã thêm sản phẩm vào giỏ hàng cục bộ: $title, SL: $newQuantity',
      );

      // Thêm vào giỏ hàng trên server
      final response = await _cartRepository.addToCart(
        productItemId: productItemId,
        quantity: 1,
      );
      if (response.success) {
        // Cập nhật trực tiếp state thay vì fetch từ server
        if (response.data != null && response.data is Map<String, dynamic>) {
          final responseData = response.data as Map<String, dynamic>;
          final cartId = responseData['id']?.toString() ?? '';

          // Cập nhật Map giỏ hàng hiện tại
          final updatedCartItems = Map<String, CartModel>.from(cartItems);

          // Tạo CartModel mới hoặc cập nhật CartModel hiện có
          final newCartModel = CartModel(
            cartId: cartId,
            productId: productId,
            productItemId: productItemId,
            id: productId,
            title: title,
            price: price,
            marketPrice: marketPrice,
            quantity: 1, // Mặc định là 1 khi thêm mới
            stockQuantity: 100, // Giá trị mặc định, sẽ được cập nhật sau
            productImageUrl: productImageUrl,
            inStock: true,
          );

          updatedCartItems[productItemId] = newCartModel;

          // Cập nhật state với ViewState.loaded thay vì fetchCartFromServer
          updateState(
            state.copyWith(
              cartItems: ViewState<Map<String, CartModel>>.loaded(
                updatedCartItems,
              ),
              isProcessing: false,
            ),
          );
        } else {
          // Nếu không có data từ response, fetch từ server
          await fetchCartFromServer();
        }
      } else {
        // Nếu thất bại với mã 404, không hiển thị lỗi
        if (response.statusCode == 404) {
          debugPrint('API trả về 404, bỏ qua lỗi này');
          await fetchCartFromServer(); // Vẫn cập nhật giỏ hàng từ server
        } else {
          updateState(
            state.copyWith(isProcessing: false, errorMessage: response.message),
          );
          handleError(
            response.message ?? 'Failed to add item to cart',
            source: 'addToCart',
            severity: ErrorSeverity.medium,
          );
        }
      }
    } catch (e) {
      // Vẫn cập nhật từ server để đảm bảo dữ liệu đồng bộ
      await fetchCartFromServer();

      // Không hiển thị lỗi nếu là lỗi mạng hoặc 404
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('404') || errorMsg.contains('network')) {
        debugPrint('Bỏ qua lỗi: ${e.toString()}');
      } else {
        final errorMsg = 'Lỗi khi thêm vào giỏ hàng: ${e.toString()}';
        updateState(
          state.copyWith(isProcessing: false, errorMessage: errorMsg),
        );
        handleError(e, source: 'addToCart', severity: ErrorSeverity.medium);
      }
    }
  }

  /// Cập nhật số lượng sản phẩm
  Future<void> updateQuantity({
    required String productItemId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      handleError(
        'Số lượng phải lớn hơn 0',
        source: 'updateQuantity',
        severity: ErrorSeverity.low,
      );
      return;
    }

    updateState(state.copyWith(isProcessing: true, errorMessage: null));

    try {
      // Lấy cartId từ productItemId
      final cartItem = cartItems[productItemId];
      if (cartItem == null) {
        updateState(
          state.copyWith(
            isProcessing: false,
            errorMessage: 'Không tìm thấy sản phẩm trong giỏ hàng',
          ),
        );
        handleError(
          'Không tìm thấy sản phẩm trong giỏ hàng',
          source: 'updateQuantity',
          severity: ErrorSeverity.medium,
        );
        return;
      }

      // Cập nhật số lượng trên server
      final response = await _cartRepository.updateCartItemQuantity(
        cartItemId: cartItem.cartId,
        quantity: quantity,
      );
      if (response.success) {
        // Cập nhật trực tiếp state mà không gọi fetchCartFromServer()
        final updatedCartItems = Map<String, CartModel>.from(cartItems);
        final oldItem = updatedCartItems[productItemId];
        if (oldItem != null) {
          // Tạo một CartModel mới với số lượng đã cập nhật
          updatedCartItems[productItemId] = CartModel(
            cartId: oldItem.cartId,
            productId: oldItem.productId,
            productItemId: oldItem.productItemId,
            id: oldItem.id,
            title: oldItem.title,
            price: oldItem.price,
            marketPrice: oldItem.marketPrice,
            quantity: quantity,
            stockQuantity: oldItem.stockQuantity,
            productImageUrl: oldItem.productImageUrl,
            inStock: oldItem.inStock,
            variationOptionValues: oldItem.variationOptionValues,
          );

          // Cập nhật state với ViewState.loaded thay vì fetchCartFromServer
          updateState(
            state.copyWith(
              cartItems: ViewState<Map<String, CartModel>>.loaded(
                updatedCartItems,
              ),
              isProcessing: false,
            ),
          );
        } else {
          // Nếu không tìm thấy item, fetch lại từ server (ít khi xảy ra)
          await fetchCartFromServer();
        }
      } else {
        updateState(
          state.copyWith(isProcessing: false, errorMessage: response.message),
        );
        handleError(
          response.message ?? 'Failed to update quantity',
          source: 'updateQuantity',
          severity: ErrorSeverity.medium,
        );
      }
    } catch (e) {
      final errorMsg = 'Lỗi khi cập nhật số lượng: ${e.toString()}';
      updateState(state.copyWith(isProcessing: false, errorMessage: errorMsg));
      handleError(e, source: 'updateQuantity', severity: ErrorSeverity.medium);
    }
  }

  /// Xóa sản phẩm khỏi giỏ hàng
  Future<void> removeFromCart(String productItemId) async {
    updateState(state.copyWith(isProcessing: true, errorMessage: null));

    try {
      // Lấy cartId từ productItemId
      final cartItem = cartItems[productItemId];
      if (cartItem == null) {
        updateState(
          state.copyWith(
            isProcessing: false,
            errorMessage: 'Không tìm thấy sản phẩm trong giỏ hàng',
          ),
        );
        return;
      }

      // Xóa khỏi giỏ hàng trên server
      final response = await _cartRepository.removeFromCart(cartItem.cartId);
      if (response.success) {
        // Cập nhật trực tiếp state mà không gọi fetchCartFromServer()
        final updatedCartItems = Map<String, CartModel>.from(cartItems);
        // Xóa item khỏi map
        updatedCartItems.remove(productItemId);

        // Cập nhật state với ViewState.loaded thay vì fetchCartFromServer
        updateState(
          state.copyWith(
            cartItems: ViewState<Map<String, CartModel>>.loaded(
              updatedCartItems,
            ),
            isProcessing: false,
          ),
        );
      } else {
        updateState(
          state.copyWith(isProcessing: false, errorMessage: response.message),
        );
        handleError(
          response.message ?? 'Failed to remove item from cart',
          source: 'removeFromCart',
          severity: ErrorSeverity.medium,
        );
      }
    } catch (e) {
      final errorMsg = 'Lỗi khi xóa sản phẩm: ${e.toString()}';
      updateState(state.copyWith(isProcessing: false, errorMessage: errorMsg));
      handleError(e, source: 'removeFromCart', severity: ErrorSeverity.medium);
    }
  }

  /// Kiểm tra xem sản phẩm có trong giỏ hàng không
  bool isInCart(String productItemId) {
    return state.hasProduct(productItemId);
  }

  /// Xóa lỗi
  void clearError() {
    if (state.errorMessage != null) {
      updateState(state.clearError());
    }
  }

  /// Xóa giỏ hàng
  Future<void> clearCart() async {
    updateState(state.copyWith(isProcessing: true, errorMessage: null));

    try {
      // Nếu giỏ hàng trống, không cần gọi API
      if (cartItems.isEmpty) {
        updateState(
          state.copyWith(cartItems: ViewState.loaded({}), isProcessing: false),
        );
        return;
      }

      // Xóa từng sản phẩm trong giỏ hàng
      for (final item in cartItems.values.toList()) {
        await _cartRepository.removeFromCart(item.cartId);
      }

      // Cập nhật state sau khi xóa thành công
      updateState(
        state.copyWith(cartItems: ViewState.loaded({}), isProcessing: false),
      );

      debugPrint('Đã xóa tất cả sản phẩm khỏi giỏ hàng');
    } catch (e) {
      final errorMsg = 'Lỗi khi xóa giỏ hàng: ${e.toString()}';
      updateState(state.copyWith(isProcessing: false, errorMessage: errorMsg));
      handleError(e, source: 'clearCart', severity: ErrorSeverity.medium);
    }
  }

  /// Xóa giỏ hàng cục bộ mà không ảnh hưởng đến dữ liệu trên máy chủ
  Future<void> clearLocalCart() async {
    updateState(
      state.copyWith(
        cartItems: ViewState.loaded({}),
        isProcessing: false,
        errorMessage: null,
      ),
    );
    debugPrint('Đã xóa giỏ hàng cục bộ');
  }
}
