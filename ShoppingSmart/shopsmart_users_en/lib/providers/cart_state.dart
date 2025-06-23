import '../models/cart_model.dart';
import '../models/view_state.dart';

/// Lớp quản lý state cho giỏ hàng
class CartState {
  /// Trạng thái giỏ hàng với ViewState để kiểm soát quá trình loading
  final ViewState<Map<String, CartModel>> cartItems;

  /// Chỉ báo hoạt động đang thực hiện
  final bool isProcessing;

  /// Thông báo lỗi khi thực hiện các thao tác trên giỏ hàng
  final String? errorMessage;

  /// Constructor với giá trị mặc định
  const CartState({
    this.cartItems = const ViewState<Map<String, CartModel>>(),
    this.isProcessing = false,
    this.errorMessage,
  });

  /// Phương thức tạo state mới với một số thuộc tính được thay đổi
  CartState copyWith({
    ViewState<Map<String, CartModel>>? cartItems,
    bool? isProcessing,
    String? errorMessage,
  }) {
    return CartState(
      cartItems: cartItems ?? this.cartItems,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Phương thức xóa thông báo lỗi
  CartState clearError() {
    return copyWith(errorMessage: null);
  }

  /// Tổng số lượng sản phẩm trong giỏ hàng
  int get totalQuantity {
    if (cartItems.data == null) return 0;

    int total = 0;
    cartItems.data!.forEach((key, value) {
      total += value.quantity;
    });
    return total;
  }

  /// Tổng giá trị giỏ hàng
  double get totalPrice {
    if (cartItems.data == null) return 0.0;

    double total = 0.0;
    cartItems.data!.forEach((key, value) {
      total += value.price * value.quantity;
    });
    return total;
  }

  /// Kiểm tra xem một sản phẩm có trong giỏ hàng hay không
  bool hasProduct(String productItemId) {
    return cartItems.data?.containsKey(productItemId) ?? false;
  }
}
