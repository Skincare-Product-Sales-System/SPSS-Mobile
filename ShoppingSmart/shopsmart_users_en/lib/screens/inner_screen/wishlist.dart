import 'package:flutter/material.dart';
import 'enhanced_wishlist.dart';

class WishlistScreen extends StatelessWidget {
  static const routName = '/WishlistScreen';
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to the enhanced version
    return const EnhancedWishlistScreen();
  }
}
