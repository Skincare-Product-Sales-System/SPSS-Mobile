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
  String? selectedSortBy;
  bool showFilters = false;

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

      selectedCategoryId = category?.id;

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
      // Load basic products with pagination for "All" products
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final productsProvider = Provider.of<ProductsProvider>(
          context,
          listen: false,
        );
        final categoriesProvider = Provider.of<CategoriesProvider>(
          context,
          listen: false,
        );

        categoriesProvider.clearSelection();
        // Load products with pagination of 12 items for "All" products
        productsProvider.loadProducts(refresh: true);
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

  Future<void> _applyFilters() async {
    final productsProvider = Provider.of<ProductsProvider>(
      context,
      listen: false,
    );

    final categoriesProvider = Provider.of<CategoriesProvider>(
      context,
      listen: false,
    );

    setState(() {
      isSearching = true;
    });

    try {
      if (selectedCategoryId != null && selectedCategoryId!.isNotEmpty) {
        // Filter by category with optional sorting
        categoriesProvider.selectCategory(selectedCategoryId);
        await productsProvider.loadProductsByCategory(
          categoryId: selectedCategoryId!,
          sortBy: selectedSortBy,
          refresh: true,
        );

        // Update category name for display
        final category = categoriesProvider.getAllCategoriesFlat.firstWhere(
          (cat) => cat.id == selectedCategoryId,
          orElse: () => null as dynamic,
        );
        categoryName = category?.categoryName ?? 'Unknown Category';
      } else {
        // Show all products with optional sorting
        categoriesProvider.clearSelection();
        await productsProvider.loadProducts(
          sortBy: selectedSortBy,
          refresh: true,
        );
        categoryName = null;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to apply filters: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      isSearching = false;
    });
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    showFilters = !showFilters;
                  });
                },
                icon: Icon(
                  showFilters ? Icons.expand_less : Icons.expand_more,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),

          if (showFilters) ...[
            const SizedBox(height: 20),

            // Categories Section
            Consumer<CategoriesProvider>(
              builder: (context, categoriesProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Category Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // All Categories chip
                        _buildCategoryChip(
                          label: 'All Categories',
                          isSelected: selectedCategoryId == null,
                          onTap: () {
                            setState(() {
                              selectedCategoryId = null;
                            });
                          },
                        ),
                        // Individual category chips
                        ...categoriesProvider.getAllCategoriesFlat.map(
                          (category) => _buildCategoryChip(
                            label: category.categoryName,
                            isSelected: selectedCategoryId == category.id,
                            onTap: () {
                              setState(() {
                                selectedCategoryId = category.id;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Price Filter Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sort by Price',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 12),

                // Price Filter Options
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPriceFilterChip(
                      label: 'Default',
                      value: null,
                      icon: Icons.sort,
                    ),
                    _buildPriceFilterChip(
                      label: 'Low to High',
                      value: 'price_asc',
                      icon: Icons.trending_up,
                    ),
                    _buildPriceFilterChip(
                      label: 'High to Low',
                      value: 'price_desc',
                      icon: Icons.trending_down,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.filter_alt, size: 18),
                    label: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedCategoryId = null;
                        selectedSortBy = null;
                        categoryName = null;
                      });
                      _applyFilters();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      side: BorderSide(
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text(
                      'Clear All',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Active Filters Summary
            if (selectedCategoryId != null || selectedSortBy != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Filters:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (selectedCategoryId != null)
                          _buildActiveFilterChip(
                            (() {
                              final categoriesProvider =
                                  Provider.of<CategoriesProvider>(
                                    context,
                                    listen: false,
                                  );
                              final category = categoriesProvider
                                  .getAllCategoriesFlat
                                  .firstWhere(
                                    (cat) => cat.id == selectedCategoryId,
                                    orElse: () => null as dynamic,
                                  );
                              return category?.categoryName ?? 'Unknown';
                            })(),
                            () {
                              setState(() {
                                selectedCategoryId = null;
                              });
                            },
                          ),
                        if (selectedSortBy != null)
                          _buildActiveFilterChip(
                            selectedSortBy == 'price_asc'
                                ? 'Low to High'
                                : 'High to Low',
                            () {
                              setState(() {
                                selectedSortBy = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).dividerColor.withOpacity(0.4),
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check_circle, size: 16, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceFilterChip({
    required String label,
    required String? value,
    required IconData icon,
  }) {
    final isSelected = selectedSortBy == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSortBy = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).dividerColor.withOpacity(0.4),
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
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
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios, size: 20),
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
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1),
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
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
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
            ),

            // Filter Section
            _buildFilterSection(),

            // Show results count and category info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (searchTextController.text.isNotEmpty)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Results for "${searchTextController.text}"',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (categoryName != null && categoryName != "All")
                    Text(
                      'Category: $categoryName',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    )
                  else
                    Text(
                      'All products',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),

            // Content area
            Expanded(child: _buildContent(productList)),
          ],
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
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
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
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const TitlesTextWidget(label: "No products found"),
              const SizedBox(height: 8),
              Text(
                'No results for "${searchTextController.text}"',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching with different keywords',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  searchTextController.clear();
                  setState(() {
                    productListSearch = [];
                    isSearching = false;
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1),
                  foregroundColor: Theme.of(context).primaryColor,
                ),
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
