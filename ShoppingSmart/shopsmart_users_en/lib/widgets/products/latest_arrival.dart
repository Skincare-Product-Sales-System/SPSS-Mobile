import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/providers/viewed_recently_provider.dart';
import 'package:shopsmart_users_en/screens/inner_screen/product_detail.dart';

import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import 'heart_btn.dart';

class LatestArrivalProductsWidget extends StatelessWidget {
  const LatestArrivalProductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final productsModel = Provider.of<ProductModel>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final viewedProdProvider = Provider.of<ViewedProdProvider>(context);

    return Container(
      margin: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10.0),
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
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image section - Reduced height
                  SizedBox(
                    height: 85,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6.0),
                      child: FancyShimmerImage(
                        imageUrl: productsModel.productImage,
                        width: double.infinity,
                        height: 85,
                        boxFit: BoxFit.cover,
                        errorWidget: Container(
                          height: 85,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            color: Colors.grey[100],
                          ),
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 24,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Product title - Reduced height and compact
                  SizedBox(
                    height: 28,
                    child: Text(
                      productsModel.productTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Price section - More compact
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${productsModel.formattedPrice} VND",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue[600],
                          ),
                        ),
                        if (productsModel.marketPrice >
                            productsModel.price) ...[
                          const SizedBox(height: 1),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${productsModel.formattedMarketPrice} VND",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (productsModel.discountPercentage > 0) ...[
                                const SizedBox(width: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red[500],
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    "-${productsModel.discountPercentage.toStringAsFixed(0)}%",
                                    style: const TextStyle(
                                      fontSize: 8,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Action buttons - Smaller and more compact
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: HeartButtonWidget(
                          productId: productsModel.productId,
                          size: 14,
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color:
                              cartProvider.isProdinCart(
                                    productId: productsModel.productId,
                                  )
                                  ? Colors.green[50]
                                  : Colors.blue[50],
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
                            cartProvider.addProductToCart(
                              productId: productsModel.productId,
                            );
                          },
                          icon: Icon(
                            cartProvider.isProdinCart(
                                  productId: productsModel.productId,
                                )
                                ? Icons.check
                                : Icons.add_shopping_cart_outlined,
                            size: 12,
                            color:
                                cartProvider.isProdinCart(
                                      productId: productsModel.productId,
                                    )
                                    ? Colors.green[600]
                                    : Colors.blue[600],
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
