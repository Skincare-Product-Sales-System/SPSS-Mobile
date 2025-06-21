import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/enhanced_cart_view_model.dart';
import 'enhanced_bottom_checkout.dart';

class CartBottomSheetWidget extends StatelessWidget {
  const CartBottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the EnhancedCartViewModel from the provider
    final cartViewModel = Provider.of<EnhancedCartViewModel>(context);

    // Redirect to the enhanced version
    return EnhancedCartBottomSheetWidget(viewModel: cartViewModel);
  }
}
