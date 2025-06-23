import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart_model.dart';
import '../../providers/enhanced_cart_view_model.dart';
import 'enhanced_cart_widget.dart';

class CartWidget extends StatelessWidget {
  const CartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the CartModel from the provider
    final cartModel = Provider.of<CartModel>(context);

    // Get the EnhancedCartViewModel from the provider
    final cartViewModel = Provider.of<EnhancedCartViewModel>(context);

    // Redirect to the enhanced version
    return EnhancedCartWidget(cartModel: cartModel, viewModel: cartViewModel);
  }
}
