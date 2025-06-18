import 'package:flutter/material.dart';

class CartModel with ChangeNotifier {
  final String cartId;
  final String productId;
  final String productItemId;
  final String id;
  final String title;
  final double price;
  final double marketPrice;
  final int quantity;
  final int stockQuantity;
  final String productImageUrl;
  final bool inStock;
  final double totalPrice;
  final List<String> variationOptionValues;

  CartModel({
    required this.cartId,
    required this.productId,
    required this.productItemId,
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    this.marketPrice = 0.0,
    this.stockQuantity = 0,
    this.productImageUrl = '',
    this.inStock = true,
    this.totalPrice = 0.0,
    this.variationOptionValues = const [],
  });
}

// DTO for API response from CartItem endpoints
class CartItemDto {
  final String id;
  final String productItemId;
  final int quantity;
  final int stockQuantity;
  final String productId;
  final String productName;
  final String productImageUrl;
  final bool inStock;
  final double price;
  final double marketPrice;
  final double totalPrice;
  final List<String> variationOptionValues;
  final DateTime lastUpdatedTime;

  CartItemDto({
    required this.id,
    required this.productItemId,
    required this.quantity,
    required this.stockQuantity,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.inStock,
    required this.price,
    required this.marketPrice,
    required this.totalPrice,
    required this.variationOptionValues,
    required this.lastUpdatedTime,
  });

  factory CartItemDto.fromJson(Map<String, dynamic> json) {
    return CartItemDto(
      id: json['id']?.toString() ?? '',
      productItemId: json['productItemId']?.toString() ?? '',
      quantity: json['quantity'] ?? 0,
      stockQuantity: json['stockQuantity'] ?? 0,
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      productImageUrl: json['productImageUrl']?.toString() ?? '',
      inStock: json['inStock'] ?? true,
      price: (json['price'] ?? 0.0).toDouble(),
      marketPrice: (json['marketPrice'] ?? 0.0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      variationOptionValues:
          (json['variationOptionValues'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      lastUpdatedTime:
          json['lastUpdatedTime'] != null
              ? DateTime.parse(json['lastUpdatedTime'])
              : DateTime.now(),
    );
  }
}
