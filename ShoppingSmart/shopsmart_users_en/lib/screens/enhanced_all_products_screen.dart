import 'package:flutter/material.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import '../providers/enhanced_products_view_model.dart';
import '../services/assets_manager.dart';
import '../widgets/products/product_widget.dart';
import '../widgets/title_text.dart';

class EnhancedAllProductsScreen extends StatefulWidget {
  static const routeName = '/enhanced-all-products';

  const EnhancedAllProductsScreen({super.key});

  @override
  State<EnhancedAllProductsScreen> createState() =>
      _EnhancedAllProductsScreenState();
}

class _EnhancedAllProductsScreenState extends State<EnhancedAllProductsScreen> {
  late EnhancedProductsViewModel _viewModel;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _viewModel = EnhancedProductsViewModel();
    _scrollController = ScrollController();

    // Add listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (_viewModel.hasMoreData && !_viewModel.isLoadingMore) {
          _loadMoreProducts();
        }
      }
    });

    // Load initial products
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    await _viewModel.loadProducts(refresh: true);
  }

  Future<void> _loadMoreProducts() async {
    await _viewModel.loadProducts(refresh: false);
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
        title: const TitlesTextWidget(label: "Tất cả sản phẩm"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadProducts),
        ],
      ),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading && _viewModel.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_viewModel.hasError && _viewModel.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${_viewModel.errorMessage}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProducts,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (_viewModel.products.isEmpty) {
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
                  const TitlesTextWidget(label: "Không có sản phẩm nào"),
                  const SizedBox(height: 16),
                  const Text("Kéo để làm mới hoặc thử lại sau"),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadProducts,
            child: Column(
              children: [
                // Products grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DynamicHeightGridView(
                      controller: _scrollController,
                      itemCount:
                          _viewModel.products.length +
                          (_viewModel.isLoadingMore ? 1 : 0),
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 12,
                      builder: (context, index) {
                        // Show loading indicator at the end while loading more
                        if (index == _viewModel.products.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        return SizedBox(
                          height: 360,
                          child: ProductWidget(
                            productId: _viewModel.products[index].productId,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Load more button (alternative to infinite scroll)
                if (_viewModel.hasMoreData && !_viewModel.isLoadingMore)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: _loadMoreProducts,
                      child: const Text('Tải thêm sản phẩm'),
                    ),
                  ),

                // End of list indicator
                if (!_viewModel.hasMoreData && _viewModel.products.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Bạn đã xem hết danh sách sản phẩm!',
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
