import 'package:flutter/material.dart';
import 'package:shopsmart_users_en/root_screen.dart';
import 'package:shopsmart_users_en/screens/orders/enhanced_order_detail_screen.dart';
import 'package:shopsmart_users_en/widgets/title_text.dart';

class VnPayWaitingScreen extends StatelessWidget {
  static const routeName = '/vnpay-waiting-screen';
  final String orderId;

  const VnPayWaitingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TitlesTextWidget(label: 'Chờ thanh toán'),
        automaticallyImplyLeading: false, // Prevent back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 30),
              const Text(
                'Đang chờ xác nhận thanh toán từ VNPay...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                'Mã đơn hàng của bạn: $orderId',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              const Text(
                'Vui lòng hoàn tất thanh toán trên trình duyệt hoặc ứng dụng VNPay. Ứng dụng sẽ tự động cập nhật khi thanh toán thành công.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Navigate to order details to allow re-payment
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => EnhancedOrderDetailScreen(orderId: orderId),
                    ),
                  );
                },
                child: const Text('Kiểm tra lại đơn hàng'),
              ),
              TextButton(
                onPressed: () {
                   Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const RootScreen()),
                      (route) => false);
                },
                child: const Text('Hủy và quay về trang chủ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 