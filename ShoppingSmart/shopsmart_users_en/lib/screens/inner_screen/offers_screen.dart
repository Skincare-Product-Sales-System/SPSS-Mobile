import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/providers/products_provider.dart';
import 'package:shopsmart_users_en/services/assets_manager.dart';
import 'package:shopsmart_users_en/widgets/empty_bag.dart';
import 'package:shopsmart_users_en/widgets/title_text.dart';
import '../../widgets/products/product_widget.dart';

class OffersScreen extends StatefulWidget {
  static const routeName = "/OffersScreen";
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  @override
  void initState() {
    super.initState();
    // Load products on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productsProvider = Provider.of<ProductsProvider>(
        context,
        listen: false,
      );
      // Load offers/discounted products (for now, we'll show all products)
      productsProvider.loadProducts(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsProvider>(
      builder: (context, productsProvider, child) {
        final offerProducts =
            productsProvider.getProducts
                .where(
                  (product) =>
                      // Filter for products with discount or special offers
                      // For now, showing all products as offers
                      product.productPrice != null &&
                      product.productPrice!.isNotEmpty,
                )
                .toList();

        return Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(AssetsManager.shoppingCart),
            ),
            title: const TitlesTextWidget(label: "🎉 Ưu đãi đặc biệt"),
            actions: [
              IconButton(
                onPressed: () {
                  // Refresh offers
                  productsProvider.loadProducts(refresh: true);
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body:
              productsProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : offerProducts.isEmpty
                  ? EmptyBagWidget(
                    imagePath: AssetsManager.bagWish,
                    title: "No offers available",
                    subtitle:
                        "Check back later for amazing deals and discounts",
                    buttonText: "Shop now",
                  )
                  : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0.1),
                                Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_offer,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Limited Time Offers",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    Text(
                                      "${offerProducts.length} amazing deals waiting for you",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: DynamicHeightGridView(
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            builder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ProductWidget(
                                  productId: offerProducts[index].productId,
                                ),
                              );
                            },
                            itemCount: offerProducts.length,
                            crossAxisCount: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
        );
      },
    );
  }
}
