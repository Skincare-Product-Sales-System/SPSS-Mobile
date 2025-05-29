import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import '../providers/products_provider.dart';
import '../services/assets_manager.dart';
import '../widgets/products/product_widget.dart';
import '../widgets/title_text.dart';

class AllProductsScreen extends StatefulWidget {
  static const routeName = '/AllProductsScreen';
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Add listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        final productsProvider = Provider.of<ProductsProvider>(
          context,
          listen: false,
        );
        if (productsProvider.hasMoreData && !productsProvider.isLoadingMore) {
          productsProvider.loadMoreProducts();
        }
      }
    });

    // Load initial products if empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productsProvider = Provider.of<ProductsProvider>(
        context,
        listen: false,
      );
      if (productsProvider.getProducts.isEmpty) {
        productsProvider.loadProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetsManager.shoppingCart),
        ),
        title: Consumer<ProductsProvider>(
          builder: (context, productsProvider, child) {
            return TitlesTextWidget(label: "All Products");
          },
        ),
        actions: [
          Consumer<ProductsProvider>(
            builder: (context, productsProvider, child) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => productsProvider.refreshProducts(),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProductsProvider>(
        builder: (context, productsProvider, child) {
          if (productsProvider.isLoading &&
              productsProvider.getProducts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productsProvider.errorMessage != null &&
              productsProvider.getProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${productsProvider.errorMessage}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => productsProvider.refreshProducts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (productsProvider.getProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const TitlesTextWidget(label: "No products available"),
                  const SizedBox(height: 16),
                  const Text("Pull to refresh or try again later"),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => productsProvider.refreshProducts(),
            child: Column(
              children: [
                // Products grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DynamicHeightGridView(
                      controller: _scrollController,
                      itemCount:
                          productsProvider.getProducts.length +
                          (productsProvider.isLoadingMore ? 1 : 0),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      builder: (context, index) {
                        // Show loading indicator at the end while loading more
                        if (index == productsProvider.getProducts.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        return ProductWidget(
                          productId:
                              productsProvider.getProducts[index].productId,
                        );
                      },
                    ),
                  ),
                ),

                // Load more button (alternative to infinite scroll)
                if (productsProvider.hasMoreData &&
                    !productsProvider.isLoadingMore)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () => productsProvider.loadMoreProducts(),
                      child: const Text('Load More Products'),
                    ),
                  ),

                // End of list indicator
                if (!productsProvider.hasMoreData &&
                    productsProvider.getProducts.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'You\'ve reached the end!',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
