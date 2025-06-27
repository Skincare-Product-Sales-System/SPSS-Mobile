import 'package:flutter/material.dart';
import 'enhanced_order_success_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  static const routeName = '/order-success';
  final String? orderId;

  const OrderSuccessScreen({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    // Get orderId from route arguments if not provided in constructor
    String? finalOrderId = orderId;
    if (finalOrderId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is String) {
        finalOrderId = args;
      }
    }
    
    // Redirect to the enhanced version
    return EnhancedOrderSuccessScreen(orderId: finalOrderId);
  }
}
