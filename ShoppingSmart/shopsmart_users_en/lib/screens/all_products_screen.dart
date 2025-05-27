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
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
        if (productsProvider.hasMoreData && !productsProvider.isLoadingMore) {
          productsProvider.loadMoreProducts();
        }
      }
    });

    // Load initial products if empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
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
            return TitlesTextWidget(
              label: "All Products (${productsProvider.totalCount})",
            );
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
          if (productsProvider.isLoading && productsProvider.getProducts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (productsProvider.errorMessage != null && productsProvider.getProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
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
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  TitlesTextWidget(label: "No products available"),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => productsProvider.refreshProducts(),
            child: Column(
              children: [
                // Progress indicator for pagination info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Page ${productsProvider.currentPage} of ${productsProvider.totalPages}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      if (productsProvider.hasMoreData)
                        Text(
                          'Scroll down for more',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Products grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DynamicHeightGridView(
                      controller: _scrollController,
                      itemCount: productsProvider.getProducts.length + 
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
                          productId: productsProvider.getProducts[index].productId,
                        );
                      },
                    ),
                  ),
                ),

                // Load more button (alternative to infinite scroll)
                if (productsProvider.hasMoreData && !productsProvider.isLoadingMore)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () => productsProvider.loadMoreProducts(),
                      child: const Text('Load More Products'),
                    ),
                  ),

                // End of list indicator
                if (!productsProvider.hasMoreData && productsProvider.getProducts.isNotEmpty)
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