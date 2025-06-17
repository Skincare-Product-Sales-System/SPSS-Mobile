import 'package:flutter/material.dart';
import 'detailed_product_model.dart';

class ProductModel with ChangeNotifier {
  final String id;
  final String thumbnail;
  final String name;
  final String description;
  final int price;
  final int marketPrice;
  final int soldCount;
  final List<ProductItem> productItems;

  ProductModel({
    required this.id,
    required this.thumbnail,
    required this.name,
    required this.description,
    required this.price,
    required this.marketPrice,
    required this.soldCount,
    required this.productItems,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing product JSON: ${json['id']}');
    debugPrint('Raw product items: ${json['productItems']}');
    
    List<ProductItem> parsedItems = [];
    if (json['productItems'] != null) {
      try {
        parsedItems = (json['productItems'] as List<dynamic>)
            .map((e) {
              debugPrint('Parsing product item: $e');
              return ProductItem.fromJson(e as Map<String, dynamic>);
            })
            .toList();
        debugPrint('Successfully parsed ${parsedItems.length} product items');
      } catch (e) {
        debugPrint('Error parsing product items: $e');
      }
    }
    
    return ProductModel(
      id: json['id']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: _parseIntFromDynamic(json['price']),
      marketPrice: _parseIntFromDynamic(json['marketPrice']),
      soldCount: _parseIntFromDynamic(json['soldCount']),
      productItems: parsedItems,
    );
  }

  static int _parseIntFromDynamic(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        debugPrint('Error parsing int from string: $value');
        return 0;
      }
    }
    debugPrint('Unknown type for price: ${value.runtimeType}');
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'thumbnail': thumbnail,
      'name': name,
      'description': description,
      'price': price,
      'marketPrice': marketPrice,
      'soldCount': soldCount,
      'productItems': productItems.map((item) => item.toJson()).toList(),
    };
  }

  // Helper methods for backward compatibility
  String get productId => id;
  String get productTitle => name;
  String get productPrice => price.toString();
  String get productImage => thumbnail;
  String get productDescription => description;

  // For categories, we'll need to add this separately or derive from API
  String get productCategory => "Cosmetics"; // Default for now
  String get productQuantity => "Available"; // Default for now

  // Helper method to get formatted price with currency
  String get formattedPrice {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String get formattedMarketPrice {
    return marketPrice.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  // Calculate discount percentage
  double get discountPercentage {
    if (marketPrice <= price) return 0.0;
    return ((marketPrice - price) / marketPrice * 100);
  }
}
