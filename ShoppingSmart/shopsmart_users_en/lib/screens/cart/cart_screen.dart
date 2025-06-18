import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/providers/cart_provider.dart';
import 'package:shopsmart_users_en/screens/cart/bottom_checkout.dart';
import 'package:shopsmart_users_en/screens/cart/cart_widget.dart';
import 'package:shopsmart_users_en/services/assets_manager.dart';
import 'package:shopsmart_users_en/services/currency_formatter.dart';
import 'package:shopsmart_users_en/widgets/empty_bag.dart';
import 'package:shopsmart_users_en/widgets/loading_widget.dart';
import 'package:shopsmart_users_en/widgets/title_text.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _refreshCartData();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  Future<void> _refreshCartData() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    await cartProvider.fetchCartFromServer();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const TitlesTextWidget(label: "Giỏ hàng", fontSize: 20),
        actions: [
          if (cartProvider.getCartitems.isNotEmpty)
            IconButton(
              onPressed: () {
                _showConfirmationDialog(context);
              },
              icon: const Icon(Icons.delete_forever_rounded),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCartData,
        child:
            cartProvider.isLoading
                ? const LoadingWidget(message: "Đang tải giỏ hàng...")
                : _buildCartBody(cartProvider),
      ),
    );
  }

  Widget _buildCartBody(CartProvider cartProvider) {
    if (cartProvider.errorMessage != null &&
        cartProvider.getCartitems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                cartProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshCartData,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (cartProvider.getCartitems.isEmpty) {
      return EmptyBagWidget(
        imagePath: AssetsManager.shoppingBasket,
        title: 'Giỏ hàng của bạn trống',
        subtitle: 'Hãy thêm sản phẩm vào giỏ hàng',
        buttonText: 'Mua sắm ngay',
      );
    }

    return Stack(
      children: [
        // Danh sách sản phẩm trong giỏ
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              children:
                  cartProvider.getCartitems.entries.map((entry) {
                    return ChangeNotifierProvider.value(
                      value: entry.value,
                      child: const CartWidget(),
                    );
                  }).toList(),
            ),
          ),
        ),

        // Footer thanh toán
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: const CartBottomSheetWidget(),
          ),
        ),
      ],
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text(
            'Bạn có chắc muốn xóa tất cả sản phẩm khỏi giỏ hàng?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Xóa tất cả',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                final cartProvider = Provider.of<CartProvider>(
                  context,
                  listen: false,
                );
                cartProvider.clearLocalCart();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
