import 'package:flutter/material.dart';
import '../../widgets/title_text.dart';
import '../../widgets/subtitle_text.dart';
import '../orders/orders_screen.dart';
import '../home_screen.dart';

class VNPayFailureScreen extends StatelessWidget {
  static const routeName = '/vnpay-failure';
  
  final String? orderId;
  final String? errorMessage;

  const VNPayFailureScreen({
    super.key,
    this.orderId,
    this.errorMessage,
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
                  // Failure Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Failure Title
                  const TitlesTextWidget(
                    label: 'Thanh toán thất bại',
                    fontSize: 28,
                  ),
                  const SizedBox(height: 16),

                  // Failure Message
                  const SubtitleTextWidget(
                    label: 'Đã xảy ra lỗi trong quá trình thanh toán VNPay. Vui lòng thử lại hoặc sử dụng phương thức thanh toán khác.',
                    fontSize: 16,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Error Details Card
                  if (orderId != null || errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          if (errorMessage != null) ...[
                            const SubtitleTextWidget(
                              label: 'Lỗi:',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 8),
                            SubtitleTextWidget(
                              label: errorMessage!,
                              fontSize: 14,
                              color: Colors.red,
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
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const OrdersScreen(),
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
                            Icons.receipt_long,
                            size: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                          label: Text(
                            'Xem đơn hàng',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
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
                            side: BorderSide(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3) ?? Colors.grey,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(
                            Icons.shopping_bag_outlined,
                            size: 20,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          label: Text(
                            'Tiếp tục mua sắm',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
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