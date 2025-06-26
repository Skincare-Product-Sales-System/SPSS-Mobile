import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/enhanced_cart_view_model.dart';
import '../../services/currency_formatter.dart';
import '../checkout/enhanced_checkout_screen.dart';
import '../../services/jwt_service.dart';
import '../auth/enhanced_login.dart';
import '../../services/my_app_function.dart';

class EnhancedCartBottomSheetWidget extends StatefulWidget {
  const EnhancedCartBottomSheetWidget({super.key, required this.viewModel});

  final EnhancedCartViewModel viewModel;

  @override
  State<EnhancedCartBottomSheetWidget> createState() =>
      _EnhancedCartBottomSheetWidgetState();
}

class _EnhancedCartBottomSheetWidgetState
    extends State<EnhancedCartBottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    // Use Consumer to rebuild only this part when cart changes
    return Consumer<EnhancedCartViewModel>(
      builder: (context, viewModel, _) {
        final totalAmount = viewModel.totalAmount;
        final totalItems = viewModel.totalQuantity;
        final totalProducts = viewModel.cartItems.length;

        return Container(
          height: MediaQuery.of(context).size.height * 0.25,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(
                width: 1,
                color: Theme.of(context).dividerColor.withOpacity(0.3),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Order Summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tổng sản phẩm',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                '$totalProducts sản phẩm / $totalItems mặt hàng',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Tổng tiền',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                CurrencyFormatter.formatVND(totalAmount),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Checkout Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: totalAmount > 0
                          ? const LinearGradient(
                              colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: totalAmount > 0 ? null : Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: totalAmount > 0
                          ? () {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _handleCheckout(context);
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: Colors.transparent,
                      ),
                      icon: const Icon(Icons.shopping_cart_checkout, size: 20),
                      label: Text(
                        totalAmount > 0
                            ? 'Thanh toán • ${CurrencyFormatter.formatVND(totalAmount)}'
                            : 'Giỏ hàng trống',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Tách logic xử lý checkout thành một hàm riêng
  void _handleCheckout(BuildContext context) async {
    // Check if user is authenticated
    final isAuth = await JwtService.isAuthenticated();
    if (!mounted) return; // Check if widget is still mounted

    if (!isAuth) {
      // Show login required dialog
      MyAppFunctions.showErrorOrWarningDialog(
        context: context,
        subtitle: 'Bạn cần đăng nhập trước để tiến hành thanh toán',
        fct: () {
          Navigator.pushNamed(
            context,
            EnhancedLoginScreen.routeName,
            arguments:
                'checkout', // Pass argument to indicate coming from checkout
          );
        },
      );
    } else {
      // User is authenticated, proceed to checkout
      Navigator.pushNamed(context, EnhancedCheckoutScreen.routeName);
    }
  }
}
