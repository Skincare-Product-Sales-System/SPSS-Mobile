import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/providers/enhanced_products_view_model.dart';
import 'package:shopsmart_users_en/screens/inner_screen/enhanced_product_detail.dart';
import 'package:shopsmart_users_en/widgets/subtitle_text.dart';
import 'package:shopsmart_users_en/widgets/title_text.dart';

import '../../providers/enhanced_viewed_products_provider.dart';
import 'heart_btn.dart';

class EnhancedProductWidget extends StatefulWidget {
  const EnhancedProductWidget({super.key, required this.productId});
  final String productId;
  @override
  State<EnhancedProductWidget> createState() => _EnhancedProductWidgetState();
}

class _EnhancedProductWidgetState extends State<EnhancedProductWidget> {
  @override
  Widget build(BuildContext context) {
    final productsViewModel = Provider.of<EnhancedProductsViewModel>(context);
    final viewedProdProvider = Provider.of<EnhancedViewedProductsProvider>(
      context,
    );
    Size size = MediaQuery.of(context).size;

    return FutureBuilder<Map<String, dynamic>?>(
      future: productsViewModel.getProductById(widget.productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final productData = snapshot.data!;

        return Container(
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
                viewedProdProvider.addViewedProduct(widget.productId);
                await Navigator.pushNamed(
                  context,
                  EnhancedProductDetailsScreen.routeName,
                  arguments: widget.productId,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: size.height * 0.22,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FancyShimmerImage(
                          imageUrl: productData['thumbnail'] ?? '',
                          height: size.height * 0.22,
                          width: double.infinity,
                          boxFit: BoxFit.contain,
                          errorWidget: Container(
                            height: size.height * 0.22,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.image_not_supported,
                              size: 42,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Row(
                      children: [
                        Flexible(
                          flex: 5,
                          child: TitlesTextWidget(
                            label: productData['name'] ?? '',
                            fontSize: 18,
                            maxLines: 2,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: HeartButtonWidget(productId: widget.productId),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "From ",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withOpacity(0.7),
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          "${_formatPrice(productData['price'] ?? 0)} VND",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if ((productData['marketPrice'] ?? 0) >
                                  (productData['price'] ?? 0)) ...[
                                const SizedBox(height: 4),
                                SubtitleTextWidget(
                                  label:
                                      "${_formatPrice(productData['marketPrice'] ?? 0)} VND",
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
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return "0";

    double priceValue = 0;
    if (price is int) {
      priceValue = price.toDouble();
    } else if (price is double) {
      priceValue = price;
    } else if (price is String) {
      priceValue = double.tryParse(price) ?? 0;
    }

    return priceValue
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
