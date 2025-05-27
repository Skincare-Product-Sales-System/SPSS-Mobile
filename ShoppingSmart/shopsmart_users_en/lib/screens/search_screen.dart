import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/models/product_model.dart';
import 'package:shopsmart_users_en/providers/products_provider.dart';
import 'package:shopsmart_users_en/providers/categories_provider.dart';

import '../services/assets_manager.dart';
import '../widgets/products/product_widget.dart';
import '../widgets/title_text.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/SearchScreen';
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController searchTextController;
  List<ProductModel> productListSearch = [];
  bool isSearching = false;
  String? selectedCategoryId;
  String? categoryName;

  @override
  void initState() {
    searchTextController = TextEditingController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get the passed category name from route arguments
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is String && arguments.isNotEmpty && arguments != "All") {
      categoryName = arguments;

      // Find the category ID from the categories provider
      final categoriesProvider = Provider.of<CategoriesProvider>(
        context,
        listen: false,
      );
      final category = categoriesProvider.getAllCategoriesFlat.firstWhere(
        (cat) => cat.categoryName == categoryName,
        orElse: () => null as dynamic,
      );

      selectedCategoryId = category.id;

      // Load products for this category if not already loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final productsProvider = Provider.of<ProductsProvider>(
          context,
          listen: false,
        );
        if (productsProvider.getProducts.isEmpty ||
            categoriesProvider.selectedCategoryId != selectedCategoryId) {
          categoriesProvider.selectCategory(selectedCategoryId);
          productsProvider.loadProductsByCategory(
            categoryId: selectedCategoryId!,
            refresh: true,
          );
        }
      });
        } else {
      // Load all products if no specific category
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final productsProvider = Provider.of<ProductsProvider>(
          context,
          listen: false,
        );
        final categoriesProvider = Provider.of<CategoriesProvider>(
          context,
          listen: false,
        );

        if (productsProvider.getProducts.isEmpty) {
          categoriesProvider.clearSelection();
          productsProvider.loadProducts(refresh: true);
        }
      });
    }
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String searchText) async {
    if (searchText.trim().isEmpty) {
      setState(() {
        productListSearch = [];
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      final productsProvider = Provider.of<ProductsProvider>(
        context,
        listen: false,
      );
      final searchResults = await productsProvider.searchProducts(
        searchText: searchText,
      );

      setState(() {
        productListSearch = searchResults;
        isSearching = false;
      });
    } catch (e) {
      setState(() {
        productListSearch = [];
        isSearching = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);

    // Use products based on whether we're filtering by category or showing all
    List<ProductModel> productList = productsProvider.getProducts;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(AssetsManager.shoppingCart),
          ),
          title: TitlesTextWidget(
            label:
                categoryName != null
                    ? "Products - $categoryName"
                    : "Search products",
          ),
          actions: [
            // Show category indicator if filtering by category
            if (categoryName != null && categoryName != "All")
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Chip(
                  label: Text(
                    categoryName!,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.blue[50],
                  onDeleted: () {
                    // Clear category filter
                    final categoriesProvider = Provider.of<CategoriesProvider>(
                      context,
                      listen: false,
                    );
                    categoriesProvider.clearSelection();
                    productsProvider.loadProducts(refresh: true);
                    setState(() {
                      categoryName = null;
                      selectedCategoryId = null;
                    });
                  },
                ),
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 15.0),
              TextField(
                controller: searchTextController,
                decoration: InputDecoration(
                  hintText:
                      categoryName != null
                          ? "Search in $categoryName..."
                          : "Search products...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSearching)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          searchTextController.clear();
                          setState(() {
                            productListSearch = [];
                            isSearching = false;
                          });
                        },
                        child: const Icon(Icons.clear, color: Colors.red),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  // Debounce search
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (searchTextController.text == value) {
                      _performSearch(value);
                    }
                  });
                },
                onSubmitted: (value) {
                  _performSearch(value);
                },
              ),
              const SizedBox(height: 15.0),

              // Show results count and category info
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    if (searchTextController.text.isNotEmpty)
                      Text(
                        'Search results: ${productListSearch.length} products found',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      )
                    else if (categoryName != null && categoryName != "All")
                      Text(
                        'Category: $categoryName (${productList.length} products)',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      )
                    else
                      Text(
                        'All products (${productList.length} items)',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                  ],
                ),
              ),

              // Content area
              Expanded(child: _buildContent(productList)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<ProductModel> productList) {
    // Show loading indicator when loading initial products
    if (productsProvider.isLoading && productList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error if no products loaded initially
    if (productList.isEmpty && searchTextController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            TitlesTextWidget(
              label:
                  categoryName != null
                      ? "No products in $categoryName"
                      : "No products available",
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (selectedCategoryId != null) {
                  productsProvider.loadProductsByCategory(
                    categoryId: selectedCategoryId!,
                    refresh: true,
                  );
                } else {
                  productsProvider.loadProducts(refresh: true);
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show search results or all products
    if (searchTextController.text.isNotEmpty) {
      if (isSearching) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Searching products...'),
            ],
          ),
        );
      }

      if (productListSearch.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              TitlesTextWidget(label: "No products found"),
              SizedBox(height: 8),
              Text(
                'Try searching with different keywords',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return _buildProductGrid(productListSearch);
    }

    return _buildProductGrid(productList);
  }

  Widget _buildProductGrid(List<ProductModel> products) {
    return DynamicHeightGridView(
      itemCount: products.length,
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      builder: (context, index) {
        return ProductWidget(productId: products[index].productId);
      },
    );
  }

  ProductsProvider get productsProvider =>
      Provider.of<ProductsProvider>(context, listen: false);
}
