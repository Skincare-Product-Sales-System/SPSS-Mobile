import 'package:flutter/material.dart';
import '../../providers/enhanced_order_view_model.dart';
import '../../providers/order_state.dart';
import '../orders/enhanced_orders_screen.dart';
import '../mvvm_screen_template.dart';

class EnhancedOrderSuccessScreen extends StatefulWidget {
  static const routeName = '/enhanced-order-success';

  const EnhancedOrderSuccessScreen({super.key});

  @override
  State<EnhancedOrderSuccessScreen> createState() =>
      _EnhancedOrderSuccessScreenState();
}

class _EnhancedOrderSuccessScreenState
    extends State<EnhancedOrderSuccessScreen> {
  String? _orderId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the order ID from route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      _orderId = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MvvmScreenTemplate<EnhancedOrderViewModel, OrderState>(
      title: 'Đặt hàng thành công',
      buildAppBar:
          (context, viewModel) => AppBar(
            title: const Text('Đơn hàng thành công'),
            automaticallyImplyLeading: false,
            centerTitle: true,
          ),
      buildContent: (context, viewModel) => _buildSuccessContent(context),
    );
  }

  Widget _buildSuccessContent(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animation or large success icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 100,
              ),
            ),
            const SizedBox(height: 24),

            // Success text
            const Text(
              'Đặt hàng thành công!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Order ID if available
            if (_orderId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Mã đơn hàng: $_orderId',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // Thank you message
            const Text(
              'Cảm ơn bạn đã đặt hàng. Chúng tôi sẽ xử lý đơn hàng của bạn và giao hàng sớm nhất có thể.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
            ),

            const SizedBox(height: 40),

            // View orders button
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  EnhancedOrdersScreen.routeName,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Xem đơn hàng của tôi',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),

            // Continue shopping button
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tiếp tục mua sắm',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
