import 'package:flutter/material.dart';
import '../screens/orders/order_detail_screen.dart';

class OrderDemoButton extends StatelessWidget {
  const OrderDemoButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: () {
          // Using the sample order ID from your API example
          Navigator.pushNamed(
            context,
            OrderDetailScreen.routeName,
            arguments: '4a07554a-3e9e-4ef0-9c1b-3aa36ea3439f',
          );
        },
        icon: const Icon(Icons.receipt_long),
        label: const Text('View Order Detail Demo'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
