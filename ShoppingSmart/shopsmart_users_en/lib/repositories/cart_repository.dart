import 'package:shopsmart_users_en/models/api_response_model.dart';
import 'package:shopsmart_users_en/services/api_service.dart';

class CartRepository {
  // Get cart items
  Future<ApiResponse<dynamic>> getCartItems() async {
    return ApiService.getCartItems();
  }

  // Add to cart
  Future<ApiResponse<dynamic>> addToCart({
    required String productItemId,
    required int quantity,
  }) async {
    return ApiService.addToCart(
      productItemId: productItemId,
      quantity: quantity,
    );
  }

  // Update cart item quantity
  Future<ApiResponse<dynamic>> updateCartItemQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    return ApiService.updateCartItemQuantity(
      cartItemId: cartItemId,
      quantity: quantity,
    );
  }

  // Remove from cart
  Future<ApiResponse<dynamic>> removeFromCart(String cartItemId) async {
    return ApiService.removeFromCart(cartItemId);
  }
}
