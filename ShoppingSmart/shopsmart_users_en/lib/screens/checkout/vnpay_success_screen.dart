import 'package:flutter/material.dart';
import '../../widgets/title_text.dart';
import '../../widgets/subtitle_text.dart';
import '../orders/orders_screen.dart';
import '../home_screen.dart';

class VNPaySuccessScreen extends StatelessWidget {
  static const routeName = '/vnpay-success';
  
  final String? orderId;
  final String? amount;

  const VNPaySuccessScreen({
    super.key,
    this.orderId,
    this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Success Title
                  const TitlesTextWidget(
                    label: 'Thanh toán thành công!',
                    fontSize: 28,
                  ),
                  const SizedBox(height: 16),

                  // Success Message
                  const SubtitleTextWidget(
                    label: 'Cảm ơn bạn đã thanh toán qua VNPay. Đơn hàng của bạn đang được xử lý.',
                    fontSize: 16,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Order Details Card
                  if (orderId != null || amount != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          if (orderId != null) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SubtitleTextWidget(
                                  label: 'Mã đơn hàng:',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: SelectableText(
                                    orderId!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (amount != null) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SubtitleTextWidget(
                                  label: 'Tổng tiền:',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                SubtitleTextWidget(
                                  label: '$amount VND',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Column(
                    children: [
                      // View Orders Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const OrdersScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.receipt_long, size: 20),
                          label: const Text(
                            'Xem đơn hàng',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Continue Shopping Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Theme.of(context).primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(
                            Icons.shopping_bag_outlined,
                            size: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                          label: Text(
                            'Tiếp tục mua sắm',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 