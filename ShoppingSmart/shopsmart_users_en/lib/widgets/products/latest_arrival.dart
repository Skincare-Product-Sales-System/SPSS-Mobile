import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/providers/viewed_recently_provider.dart';
import 'package:shopsmart_users_en/screens/inner_screen/product_detail.dart';

import '../../models/product_model.dart';
import '../../models/detailed_product_model.dart';
import '../../providers/cart_provider.dart';
import 'heart_btn.dart';

class LatestArrivalProductsWidget extends StatelessWidget {
  const LatestArrivalProductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final productsModel = Provider.of<ProductModel>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final viewedProdProvider = Provider.of<ViewedProdProvider>(context);

    return Container(
      margin: const EdgeInsets.all(3.0),
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
              productId: productsModel.productId,
            );
            await Navigator.pushNamed(
              context,
              ProductDetailsScreen.routName,
              arguments: productsModel.productId,
            );
          },
          child: SizedBox(
            height: 280, // Tăng thêm 10px từ 270 lên 280
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image section with fixed height and proper layout
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: FancyShimmerImage(
                              imageUrl: productsModel.productImage,
                              boxFit: BoxFit.contain,
                              errorWidget: Container(
                                color: Theme.of(context).colorScheme.surface,
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 32,
                                  color: Theme.of(context).disabledColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (productsModel.discountPercentage > 0)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "-${productsModel.discountPercentage.toStringAsFixed(0)}%",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Product title - fixed height
                  SizedBox(
                    height: 36,
                    child: Text(
                      productsModel.productTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6), // Tăng từ 4px lên 6px
                  // Price section - fixed height
                  SizedBox(
                    height: 40, // Tăng từ 36px lên 40px
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${productsModel.formattedPrice} VND",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        if (productsModel.marketPrice >
                            productsModel.price) ...[
                          const SizedBox(height: 3), // Tăng từ 2px lên 3px
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${productsModel.formattedMarketPrice} VND",
                                  style: TextStyle(
                                    fontSize: 11,
                                    decoration: TextDecoration.lineThrough,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withOpacity(0.6),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Spacer(), // Sử dụng Spacer để đảm bảo nút luôn ở dưới cùng
                  // Action buttons - Smaller and more compact
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 26,
                        height: 26,
                        child: HeartButtonWidget(
                          productId: productsModel.productId,
                          size: 16,
                        ),
                      ),
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color:
                              cartProvider.isProdinCart(
                                    productId: productsModel.productId,
                                  )
                                  ? Colors.green.withOpacity(0.1)
                                  : Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            if (cartProvider.isProdinCart(
                              productId: productsModel.productId,
                            )) {
                              return;
                            }

                            debugPrint(
                              'Product ID: ${productsModel.productId}',
                            );
                            debugPrint(
                              'Product Items: ${productsModel.productItems.length}',
                            );
                            debugPrint(
                              'Product Items Data: ${productsModel.productItems}',
                            );

                            // Check if we have product items with valid data
                            if (productsModel.productItems.isEmpty) {
                              debugPrint(
                                'No product items available, using product model price',
                              );

                              // Fallback: use product model price when productItems is empty
                              if (productsModel.price <= 0) {
                                debugPrint('Invalid price in product model');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Sản phẩm không có giá. Vui lòng thử lại sau.',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              // Use a default productItemId when not available
                              cartProvider.addProductToCart(
                                productId: productsModel.productId,
                                productItemId:
                                    productsModel
                                        .productId, // Use productId as fallback
                                title: productsModel.productTitle,
                                price: productsModel.price.toDouble(),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã thêm vào giỏ hàng'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              return;
                            }

                            // Get the first product item with valid price and quantity
                            final validItem = productsModel.productItems
                                .firstWhere(
                                  (item) =>
                                      item.price > 0 &&
                                      item.quantityInStock > 0,
                                  orElse: () {
                                    debugPrint(
                                      'No valid item found, using first item',
                                    );
                                    return productsModel.productItems.first;
                                  },
                                );

                            debugPrint(
                              'Selected Item Price: ${validItem.price}',
                            );
                            debugPrint('Selected Item ID: ${validItem.id}');
                            debugPrint(
                              'Selected Item Quantity: ${validItem.quantityInStock}',
                            );

                            if (validItem.price <= 0) {
                              debugPrint('Invalid price for selected item');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Sản phẩm không có giá. Vui lòng thử lại sau.',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            if (validItem.quantityInStock <= 0) {
                              debugPrint(
                                'No stock available for selected item',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Sản phẩm đã hết hàng. Vui lòng thử lại sau.',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            cartProvider.addProductToCart(
                              productId: productsModel.productId,
                              productItemId: validItem.id,
                              title: productsModel.productTitle,
                              price: validItem.price.toDouble(),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã thêm vào giỏ hàng'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          icon: Icon(
                            cartProvider.isProdinCart(
                                  productId: productsModel.productId,
                                )
                                ? Icons.check
                                : Icons.add_shopping_cart_outlined,
                            size: 14,
                            color:
                                cartProvider.isProdinCart(
                                      productId: productsModel.productId,
                                    )
                                    ? Colors.green
                                    : Theme.of(context).primaryColor,
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
