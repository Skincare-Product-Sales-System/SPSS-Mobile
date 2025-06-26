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
          (context, viewModel) => PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Text(
                      'Đơn hàng thành công',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      buildContent: (context, viewModel) => _buildSuccessContent(context),
    );
  }

  Widget _buildSuccessContent(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                const Text(
                  'Đặt hàng thành công!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (_orderId != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Mã đơn hàng: $_orderId',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const Text(
                  'Cảm ơn bạn đã đặt hàng. Chúng tôi sẽ xử lý đơn hàng của bạn và giao hàng sớm nhất có thể.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
                ),
                const SizedBox(height: 40),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const EnhancedOrdersScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Xem đơn hàng của tôi',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 18,
                        color: Color(0xFF8F5CFF),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Tiếp tục mua sắm',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8F5CFF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
