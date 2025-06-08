import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/screens/inner_screen/product_detail.dart';
import 'package:shopsmart_users_en/widgets/subtitle_text.dart';
import 'package:shopsmart_users_en/widgets/title_text.dart';

import '../../providers/cart_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/viewed_recently_provider.dart';
import 'heart_btn.dart';

class ProductWidget extends StatefulWidget {
  const ProductWidget({super.key, required this.productId});
  final String productId;
  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  @override
  Widget build(BuildContext context) {
    // final productModelProvider = Provider.of<ProductModel>(context);
    final productsProvider = Provider.of<ProductsProvider>(context);
    final getCurrProduct = productsProvider.findByProdId(widget.productId);
    final cartProvider = Provider.of<CartProvider>(context);
    Size size = MediaQuery.of(context).size;
    final viewedProdProvider = Provider.of<ViewedProdProvider>(context);

    return getCurrProduct == null
        ? const SizedBox.shrink()
        : Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                viewedProdProvider.addViewedProd(
                  productId: getCurrProduct.productId,
                );
                await Navigator.pushNamed(
                  context,
                  ProductDetailsScreen.routName,
                  arguments: getCurrProduct.productId,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FancyShimmerImage(
                      imageUrl: getCurrProduct.productImage,
                      height: size.height * 0.22,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 12.0),
                    Row(
                      children: [
                        Flexible(
                          flex: 5,
                          child: TitlesTextWidget(
                            label: getCurrProduct.productTitle,
                            fontSize: 18,
                            maxLines: 2,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: HeartButtonWidget(
                            productId: getCurrProduct.productId,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SubtitleTextWidget(
                                label: "${getCurrProduct.formattedPrice} VND",
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).primaryColor,
                                fontSize: 16,
                              ),
                              if (getCurrProduct.marketPrice >
                                  getCurrProduct.price) ...[
                                const SizedBox(height: 4),
                                SubtitleTextWidget(
                                  label:
                                      "${getCurrProduct.formattedMarketPrice} VND",
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withOpacity(0.6),
                                  fontSize: 13,
                                  textDecoration: TextDecoration.lineThrough,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Flexible(
                          child: Material(
                            borderRadius: BorderRadius.circular(8.0),
                            color:
                                cartProvider.isProdinCart(
                                      productId: getCurrProduct.productId,
                                    )
                                    ? Colors.green
                                    : Theme.of(context).primaryColor,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8.0),
                              onTap: () {
                                if (cartProvider.isProdinCart(
                                  productId: getCurrProduct.productId,
                                )) {
                                  return;
                                }
                                debugPrint('Product ID: ${getCurrProduct.productId}');
                                debugPrint('Product Items: ${getCurrProduct.productItems.length}');
                                debugPrint('Product Items Data: ${getCurrProduct.productItems}');
                                
                                if (getCurrProduct.productItems.isEmpty) {
                                  debugPrint('No product items available');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Sản phẩm hiện không có sẵn. Vui lòng chọn sản phẩm khác.'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }

                                // Get the first product item with valid price and quantity
                                final validItem = getCurrProduct.productItems.firstWhere(
                                  (item) => item.price > 0 && item.quantityInStock > 0,
                                  orElse: () {
                                    debugPrint('No valid item found, using first item');
                                    return getCurrProduct.productItems.first;
                                  },
                                );

                                debugPrint('Selected Item Price: ${validItem.price}');
                                debugPrint('Selected Item ID: ${validItem.id}');
                                debugPrint('Selected Item Quantity: ${validItem.quantityInStock}');
                                
                                if (validItem.price <= 0) {
                                  debugPrint('Invalid price for selected item');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Sản phẩm không có giá. Vui lòng thử lại sau.'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }

                                if (validItem.quantityInStock <= 0) {
                                  debugPrint('No stock available for selected item');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Sản phẩm đã hết hàng. Vui lòng thử lại sau.'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }

                                cartProvider.addProductToCart(
                                  productId: getCurrProduct.productId,
                                  productItemId: validItem.id,
                                  title: getCurrProduct.productTitle,
                                  price: validItem.price.toDouble(),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã thêm vào giỏ hàng'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  cartProvider.isProdinCart(
                                        productId: getCurrProduct.productId,
                                      )
                                      ? Icons.check
                                      : Icons.add_shopping_cart_outlined,
                                  size: 22,
                                  color: Colors.white,
                                ),
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
        );
  }
}
