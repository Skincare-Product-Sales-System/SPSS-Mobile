import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart_model.dart';
import '../../providers/enhanced_cart_view_model.dart';
import 'enhanced_quantity_btm_sheet.dart';

class QuantityBottomSheetWidget extends StatelessWidget {
  const QuantityBottomSheetWidget({super.key, required this.cartModel});
  final CartModel cartModel;

  @override
  Widget build(BuildContext context) {
    // Get the EnhancedCartViewModel from the provider
    final cartViewModel = Provider.of<EnhancedCartViewModel>(context);

    // Redirect to the enhanced version
    return EnhancedQuantityBottomSheetWidget(
      cartModel: cartModel,
      viewModel: cartViewModel,
    );
  }
}
