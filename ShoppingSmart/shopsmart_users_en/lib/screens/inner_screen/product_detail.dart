import 'package:flutter/material.dart';
import 'enhanced_product_detail.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const routeName = '/ProductDetailsScreen';
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;

    // Redirect to the enhanced version
    return EnhancedProductDetailsScreen(productId: productId);
  }
}
