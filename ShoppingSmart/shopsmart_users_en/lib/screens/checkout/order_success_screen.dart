import 'package:flutter/material.dart';
import 'enhanced_order_success_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  static const routeName = '/order-success';

  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to the enhanced version
    return const EnhancedOrderSuccessScreen();
  }
}
