import 'package:flutter/material.dart';
import 'package:shopsmart_users_en/models/cart_model.dart';
import 'package:shopsmart_users_en/providers/products_provider.dart';
import 'package:uuid/uuid.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartModel> _cartItems = {};
  Map<String, CartModel> get getCartitems {
    return _cartItems;
  }

  void addProductToCart({required String productId, required String title, required double price}) {
    _cartItems.putIfAbsent(
      productId,
      () => CartModel(
        cartId: const Uuid().v4(),
        productId: productId,
        id: productId,
        title: title,
        price: price,
        quantity: 1,
      ),
    );
    notifyListeners();
  }

  void updateQty({required String productId, required int qty}) {
    final cartItem = _cartItems[productId];
    if (cartItem != null) {
      _cartItems.update(
        productId,
        (cartItem) => CartModel(
          cartId: cartItem.cartId,
          productId: productId,
          id: cartItem.id,
          title: cartItem.title,
          price: cartItem.price,
          quantity: qty,
        ),
      );
      notifyListeners();
    }
  }

  bool isProdinCart({required String productId}) {
    return _cartItems.containsKey(productId);
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

  void clearLocalCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void removeOneItem({required String productId}) {
    _cartItems.remove(productId);
    notifyListeners();
  }
}
