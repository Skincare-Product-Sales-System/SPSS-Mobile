import 'package:flutter/material.dart';

class CartModel with ChangeNotifier {
  final String cartId;
  final String productId;
  final String id;
  final String title;
  final double price;
  final int quantity;

  CartModel({
    required this.cartId,
    required this.productId,
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
  });
}
