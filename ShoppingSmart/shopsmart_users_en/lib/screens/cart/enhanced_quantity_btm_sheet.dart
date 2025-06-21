import 'package:flutter/material.dart';
import '../../models/cart_model.dart';
import '../../widgets/subtitle_text.dart';
import '../../providers/enhanced_cart_view_model.dart';

class EnhancedQuantityBottomSheetWidget extends StatelessWidget {
  const EnhancedQuantityBottomSheetWidget({
    super.key,
    required this.cartModel,
    required this.viewModel,
  });

  final CartModel cartModel;
  final EnhancedCartViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          height: 6,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: 25,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  viewModel.updateQuantity(
                    productItemId: cartModel.productItemId,
                    quantity: index + 1,
                  );
                  Navigator.pop(context);
                },
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SubtitleTextWidget(label: "${index + 1}"),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
