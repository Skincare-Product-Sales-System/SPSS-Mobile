import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/providers/cart_provider.dart';
import 'package:shopsmart_users_en/screens/cart/cart_widget.dart';
import 'package:shopsmart_users_en/services/assets_manager.dart';
import 'package:shopsmart_users_en/services/my_app_function.dart';
import 'package:shopsmart_users_en/widgets/empty_bag.dart';
import 'package:shopsmart_users_en/widgets/title_text.dart';

import 'bottom_checkout.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  final bool isEmpty = false;
  @override
  Widget build(BuildContext context) {
    // final productsProvider = Provider.of<ProductsProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    return cartProvider.getCartitems.isEmpty
        ? Scaffold(
          body: EmptyBagWidget(
            imagePath: AssetsManager.shoppingBasket,
            title: "Your cart is empty",
            subtitle:
                "Looks like your cart is empty add something and make me happy",
            buttonText: "Shop now",
          ),
        )
        : Scaffold(
          bottomSheet: const CartBottomSheetWidget(),
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(AssetsManager.shoppingCart),
            ),
            title: TitlesTextWidget(
              label: "Cart (${cartProvider.getCartitems.length})",
            ),
            actions: [
              IconButton(
                onPressed: () {
                  MyAppFunctions.showErrorOrWarningDialog(
                    isError: false,
                    context: context,
                    subtitle: "Clear cart?",
                    fct: () {
                      cartProvider.clearLocalCart();
                    },
                  );
                },
                icon: const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartProvider.getCartitems.length,
                  itemBuilder: (context, index) {
                    return ChangeNotifierProvider.value(
                      value: cartProvider.getCartitems.values.toList()[index],
                      child: const CartWidget(),
                    );
                  },
                ),
              ),
              const SizedBox(height: kBottomNavigationBarHeight + 10),
            ],
          ),
        );
  }
}
