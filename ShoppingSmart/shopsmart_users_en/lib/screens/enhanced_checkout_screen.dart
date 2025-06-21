import 'package:flutter/material.dart';
import '../providers/enhanced_order_view_model.dart';
import '../providers/order_state.dart';
import './checkout/enhanced_order_success_screen.dart';
import './mvvm_screen_template.dart';
import '../widgets/app_name_text.dart';

class EnhancedCheckoutScreen extends StatefulWidget {
  static const routeName = "/enhanced-checkout";
  const EnhancedCheckoutScreen({super.key});

  @override
  State<EnhancedCheckoutScreen> createState() => _EnhancedCheckoutScreenState();
}

class _EnhancedCheckoutScreenState extends State<EnhancedCheckoutScreen> {
  @override
  Widget build(BuildContext context) {
    return MvvmScreenTemplate<EnhancedOrderViewModel, OrderState>(
      title: "Thanh toán",
      onInit: (viewModel) {
        viewModel.loadCheckoutDetails();
      },
      isLoading: (viewModel) => viewModel.isLoading,
      getErrorMessage: (viewModel) => viewModel.state.creatingOrderError,
      buildAppBar:
          (context, viewModel) =>
              AppBar(title: const AppNameTextWidget(fontSize: 22)),
      buildContent: (context, viewModel) {
        return Column(
          children: [
            // Checkout UI implementation would go here
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Process order and navigate to success screen
                  Navigator.pushReplacementNamed(
                    context,
                    EnhancedOrderSuccessScreen.routeName,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Hoàn tất đơn hàng',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
