import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/models/cart_model.dart';
import 'package:shopsmart_users_en/widgets/subtitle_text.dart';
import 'package:shopsmart_users_en/widgets/title_text.dart';
import 'package:shopsmart_users_en/services/currency_formatter.dart';

import '../../providers/cart_provider.dart';
import '../../providers/products_provider.dart';

class CartWidget extends StatefulWidget {
  const CartWidget({super.key});

  @override
  State<CartWidget> createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cartModel = Provider.of<CartModel>(context);
    _quantityController.text = cartModel.quantity.toString();
  }

  @override
  void didUpdateWidget(CartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final cartModel = Provider.of<CartModel>(context, listen: false);
    // Cập nhật controller nếu số lượng thay đổi từ nguồn khác
    if (int.tryParse(_quantityController.text) != cartModel.quantity) {
      _quantityController.text = cartModel.quantity.toString();
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _updateQuantity(
    CartProvider cartProvider,
    String productItemId,
    int quantity,
  ) async {
    if (quantity <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Số lượng phải lớn hơn 0')));
      return;
    }

    await cartProvider.updateQty(productItemId: productItemId, qty: quantity);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final cartModel = Provider.of<CartModel>(context);
    final productsProvider = Provider.of<ProductsProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    // Tìm sản phẩm trong ProductsProvider
    final getCurrProduct = productsProvider.findByProdId(cartModel.productId);

    // Sử dụng hình ảnh và tên từ CartModel (từ server)
    final productTitle = cartModel.title;
    final productImage = cartModel.productImageUrl;
    final variations = cartModel.variationOptionValues;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hình ảnh sản phẩm
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child:
                    productImage.isNotEmpty
                        ? FancyShimmerImage(
                          imageUrl: productImage,
                          height: size.height * 0.15,
                          width: size.height * 0.15,
                          boxFit: BoxFit.contain,
                        )
                        : Container(
                          height: size.height * 0.15,
                          width: size.height * 0.15,
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
              ),
              const SizedBox(width: 10),
              // Thông tin sản phẩm
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề và nút xóa
                    Row(
                      children: [
                        Expanded(
                          child: TitlesTextWidget(
                            label: productTitle,
                            maxLines: 2,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          onPressed:
                              cartProvider.isLoading
                                  ? null
                                  : () {
                                    cartProvider.removeOneItem(
                                      productItemId: cartModel.productItemId,
                                    );
                                  },
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.red,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    // Phiên bản sản phẩm (nếu có)
                    if (variations.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Phiên bản: ${variations.join(", ")}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    // Giá
                    SubtitleTextWidget(
                      label: CurrencyFormatter.formatVND(cartModel.price),
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 8),
                    // Số lượng
                    Row(
                      children: [
                        // Nút giảm
                        InkWell(
                          onTap:
                              cartProvider.isLoading
                                  ? null
                                  : () {
                                    final newQty = cartModel.quantity - 1;
                                    if (newQty >= 1) {
                                      _quantityController.text =
                                          newQty.toString();
                                      _updateQuantity(
                                        cartProvider,
                                        cartModel.productItemId,
                                        newQty,
                                      );
                                    }
                                  },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            width: 28,
                            height: 28,
                            child: Icon(
                              Icons.remove,
                              size: 16,
                              color:
                                  cartModel.quantity <= 1 ||
                                          cartProvider.isLoading
                                      ? Colors.grey
                                      : Colors.black,
                            ),
                          ),
                        ),
                        // Trường nhập số lượng
                        Container(
                          width: 50,
                          height: 28,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextField(
                            controller: _quantityController,
                            enabled: !cartProvider.isLoading,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 3,
                            decoration: const InputDecoration(
                              counterText: '',
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onSubmitted:
                                cartProvider.isLoading
                                    ? null
                                    : (value) {
                                      if (value.isEmpty) {
                                        _quantityController.text = '1';
                                        _updateQuantity(
                                          cartProvider,
                                          cartModel.productItemId,
                                          1,
                                        );
                                        return;
                                      }

                                      final newQty = int.tryParse(value) ?? 1;
                                      if (newQty > cartModel.stockQuantity) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Chỉ có ${cartModel.stockQuantity} sản phẩm trong kho',
                                            ),
                                          ),
                                        );
                                        _quantityController.text =
                                            cartModel.stockQuantity.toString();
                                        _updateQuantity(
                                          cartProvider,
                                          cartModel.productItemId,
                                          cartModel.stockQuantity,
                                        );
                                        return;
                                      }

                                      if (newQty != cartModel.quantity) {
                                        _updateQuantity(
                                          cartProvider,
                                          cartModel.productItemId,
                                          newQty,
                                        );
                                      }
                                    },
                          ),
                        ),
                        // Nút tăng
                        InkWell(
                          onTap:
                              cartProvider.isLoading
                                  ? null
                                  : () {
                                    final newQty = cartModel.quantity + 1;
                                    if (newQty <= cartModel.stockQuantity) {
                                      _quantityController.text =
                                          newQty.toString();
                                      _updateQuantity(
                                        cartProvider,
                                        cartModel.productItemId,
                                        newQty,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Chỉ có ${cartModel.stockQuantity} sản phẩm trong kho',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            width: 28,
                            height: 28,
                            child: Icon(
                              Icons.add,
                              size: 16,
                              color:
                                  cartModel.quantity >=
                                              cartModel.stockQuantity ||
                                          cartProvider.isLoading
                                      ? Colors.grey
                                      : Colors.black,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Tổng tiền
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Thành tiền',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SubtitleTextWidget(
                              label: CurrencyFormatter.formatVND(
                                cartModel.price * cartModel.quantity,
                              ),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Hiển thị đang tải
                    if (cartProvider.isLoading)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Đang cập nhật...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
