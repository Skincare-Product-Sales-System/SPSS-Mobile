import 'package:flutter/material.dart';
import 'package:shopsmart_users_en/models/cart_model.dart';
import 'package:shopsmart_users_en/providers/products_provider.dart';
import 'package:shopsmart_users_en/repositories/cart_repository.dart';

class CartProvider with ChangeNotifier {
  final CartRepository _cartRepository = CartRepository();

  final Map<String, CartModel> _cartItems = {};
  Map<String, CartModel> get getCartitems {
    return _cartItems;
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Tải giỏ hàng từ server khi ứng dụng khởi động
  Future<void> fetchCartFromServer() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _cartRepository.getCartItems();
      if (response.success && response.data != null) {
        // Xóa giỏ hàng cục bộ
        _cartItems.clear();

        // Thêm từng sản phẩm vào giỏ hàng cục bộ từ dữ liệu server
        if (response.data!.items.isNotEmpty) {
          for (var item in response.data!.items) {
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

            _cartItems[productItemId] = CartModel(
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
              'Đã thêm sản phẩm vào giỏ hàng cục bộ: $title, SL: $quantity',
            );
          }
        }
        _errorMessage = null;
        debugPrint(
          'Đồng bộ giỏ hàng thành công: ${_cartItems.length} sản phẩm',
        );
      } else {
        _errorMessage = response.message;
        debugPrint('Không thể lấy giỏ hàng: ${response.message}');
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi tải giỏ hàng: ${e.toString()}';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProductToCart({
    required String productId,
    required String productItemId,
    required String title,
    required double price,
  }) async {
    assert(price > 0, 'Giá sản phẩm phải lớn hơn 0');
    assert(productId.isNotEmpty, 'ProductId không được để trống');
    assert(productItemId.isNotEmpty, 'ProductItemId không được để trống');

    _isLoading = true;
    notifyListeners();

    try {
      // Thêm vào giỏ hàng trên server
      final response = await _cartRepository.addToCart(
        productItemId: productItemId,
        quantity: 1,
      );

      if (response.success) {
        // Nếu thành công, cập nhật giỏ hàng cục bộ từ server
        await fetchCartFromServer();
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
        debugPrint('Lỗi khi thêm vào giỏ hàng: ${response.message}');
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi thêm vào giỏ hàng: ${e.toString()}';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQty({
    required String productItemId,
    required int qty,
  }) async {
    if (qty <= 0) {
      debugPrint('Số lượng phải lớn hơn 0');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Lấy cartId từ productItemId
      final cartItem = _cartItems[productItemId];
      if (cartItem == null) {
        _errorMessage = 'Không tìm thấy sản phẩm trong giỏ hàng';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final cartId = cartItem.cartId;

      // Cập nhật số lượng trên server
      final response = await _cartRepository.updateCartItemQuantity(
        cartItemId: cartId,
        quantity: qty,
      );

      if (response.success) {
        // Sau khi cập nhật thành công, lấy lại dữ liệu từ server để đồng bộ
        await fetchCartFromServer();
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
        debugPrint('Lỗi khi cập nhật số lượng: ${response.message}');
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi cập nhật số lượng: ${e.toString()}';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isProdinCart({required String productItemId}) {
    return _cartItems.containsKey(productItemId);
  }

  double getTotal({required ProductsProvider productsProvider}) {
    double total = 0.0;

    _cartItems.forEach((key, value) {
      total += value.price * value.quantity;
    });
    return total;
  }

  int getQty() {
    int total = 0;
    _cartItems.forEach((key, value) {
      total += value.quantity;
    });
    return total;
  }

  Future<void> clearLocalCart() async {
    _cartItems.clear();
    notifyListeners();
  }

  Future<void> removeOneItem({required String productItemId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Lấy cartId từ productItemId
      final cartItem = _cartItems[productItemId];
      if (cartItem == null) {
        _errorMessage = 'Không tìm thấy sản phẩm trong giỏ hàng';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final cartId = cartItem.cartId;

      // Xóa sản phẩm khỏi giỏ hàng trên server
      final response = await _cartRepository.removeFromCart(cartId);

      if (response.success) {
        // Nếu thành công, xóa khỏi giỏ hàng cục bộ
        _cartItems.remove(productItemId);
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
        debugPrint('Lỗi khi xóa sản phẩm khỏi giỏ hàng: ${response.message}');
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi xóa sản phẩm khỏi giỏ hàng: ${e.toString()}';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
