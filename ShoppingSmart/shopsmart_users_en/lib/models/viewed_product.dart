import 'package:flutter/material.dart';

class ViewedProdModel with ChangeNotifier {
  final String viewedProdId;
  final String productId;
  final DateTime timestamp;

  ViewedProdModel({
    required this.viewedProdId,
    required this.productId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
