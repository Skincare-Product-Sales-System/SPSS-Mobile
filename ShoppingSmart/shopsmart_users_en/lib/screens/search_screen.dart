import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/models/product_model.dart';
import 'package:shopsmart_users_en/providers/products_provider.dart';
import 'package:shopsmart_users_en/providers/categories_provider.dart';

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
  late ScrollController _scrollController;
  List<ProductModel> productListSearch = [];
  bool isSearching = false;
  String? selectedCategoryId;
  String? categoryName;
  String? selectedSortBy;
  bool showFilters = false;

  @override
  void initState() {
    searchTextController = TextEditingController();
    _scrollController = ScrollController();

    // Add pagination listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreProducts();
      }
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize categories if not loaded
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final categoriesProvider = Provider.of<CategoriesProvider>(
        context,
        listen: false,
      );

      // Load categories if empty
      if (categoriesProvider.getCategories.isEmpty) {
        debugPrint('SearchScreen - Loading categories...');
        await categoriesProvider.loadCategories();
      }

      // Get the passed category name from route arguments
      final arguments = ModalRoute.of(context)?.settings.arguments;
      debugPrint('SearchScreen - Route arguments: $arguments');

      if (arguments is String && arguments.isNotEmpty && arguments != "All") {
        categoryName = arguments;

        // Find the category ID from the categories provider
        final allCategories = categoriesProvider.getAllCategoriesFlat;
        debugPrint(
          'SearchScreen - Looking for category: $categoryName in ${allCategories.length} categories',
        );

        final category = allCategories.firstWhere(
          (cat) => cat.categoryName == categoryName,
          orElse: () => null as dynamic,
        );

        selectedCategoryId = category.id;
        debugPrint('SearchScreen - Found category ID: $selectedCategoryId');

        // Set category selection but DON'T auto-load products
        categoriesProvider.selectCategory(selectedCategoryId);

        setState(() {
          // Update UI to show the category is selected
        });
      } else {
        debugPrint('SearchScreen - Set to show all products');
        // Clear selection but DON'T auto-load products
        categoriesProvider.clearSelection();
        setState(() {
          categoryName = null;
          selectedCategoryId = null;
        });
      }
    });
  }

  @override
  void dispose() {
    searchTextController.dispose();
    _scrollController.dispose();
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
      debugPrint(
        'Applying filters - selectedCategoryId: $selectedCategoryId, sortBy: $selectedSortBy',
      );

      if (selectedCategoryId != null && selectedCategoryId!.isNotEmpty) {
        // Filter by category with optional sorting
        debugPrint('Loading products by category: $selectedCategoryId');
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
        categoryName = category.categoryName ?? 'Unknown Category';

        debugPrint(
          'Products loaded for category $categoryName: ${productsProvider.getProducts.length}',
        );
      } else {
        // Show all products with optional sorting
        debugPrint('Loading all products with sortBy: $selectedSortBy');
        categoriesProvider.clearSelection();
        await productsProvider.loadProducts(
          sortBy: selectedSortBy,
          refresh: true,
        );
        categoryName = null;

        debugPrint(
          'All products loaded: ${productsProvider.getProducts.length}',
        );
      }

      // Force UI refresh after loading products
      setState(() {
        // This will trigger rebuild and show correct products
      });

      // Show success message
      if (mounted) {
        final productCount = productsProvider.getProducts.length;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              selectedCategoryId != null
                  ? 'Tìm thấy $productCount sản phẩm trong danh mục ${categoryName ?? "đã chọn"}'
                  : 'Tìm thấy $productCount sản phẩm',
            ),
            backgroundColor: productCount > 0 ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error applying filters: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi áp dụng bộ lọc: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    setState(() {
      isSearching = false;
    });
  }

  Future<void> _loadMoreProducts() async {
    final productsProvider = Provider.of<ProductsProvider>(
      context,
      listen: false,
    );

    // Only load more if not already loading and has more data
    if (productsProvider.isLoadingMore || !productsProvider.hasMoreData) {
      return;
    }

    try {
      if (selectedCategoryId != null && selectedCategoryId!.isNotEmpty) {
        await productsProvider.loadMoreProductsByCategory(selectedCategoryId!);
      } else {
        await productsProvider.loadMoreProducts();
      }
    } catch (e) {
      debugPrint('Error loading more products: $e');
    }
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
                      'Danh mục',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Category Chips - Fixed overflow issue with SingleChildScrollView
                    SizedBox(
                      height: 120, // Fixed height to prevent overflow
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            // All Categories chip
                            _buildCategoryChip(
                              label: 'Tất cả danh mục',
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
                      ),
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

                // Price Filter Options - Fixed overflow
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildPriceFilterChip(
                        label: 'Mặc định',
                        value: null,
                        icon: Icons.sort,
                      ),
                      const SizedBox(width: 8),
                      _buildPriceFilterChip(
                        label: 'Thấp đến cao',
                        value: 'price_asc',
                        icon: Icons.trending_up,
                      ),
                      const SizedBox(width: 8),
                      _buildPriceFilterChip(
                        label: 'Cao đến thấp',
                        value: 'price_desc',
                        icon: Icons.trending_down,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _applyFilters();
                      // Close filters after applying
                      setState(() {
                        showFilters = false;
                      });
                    },
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
                              return category.categoryName ?? 'Unknown';
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
                                ? 'Thấp đến cao'
                                : 'Cao đến thấp',
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(right: 4, bottom: 4),
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
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color:
                      isSelected
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    return Consumer<ProductsProvider>(
      builder: (context, productsProvider, child) {
        // Use products based on whether we're filtering by category or showing all
        List<ProductModel> productList = productsProvider.getProducts;

        debugPrint(
          'SearchScreen build - Products count: ${productList.length}',
        );
        debugPrint(
          'SearchScreen build - Selected category: $selectedCategoryId',
        );
        debugPrint('SearchScreen build - Category name: $categoryName');

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
                        ? "Sản phẩm - $categoryName"
                        : "Tìm sản phẩm",
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
                        final categoriesProvider =
                            Provider.of<CategoriesProvider>(
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
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchTextController,
                          decoration: InputDecoration(
                            hintText:
                                categoryName != null
                                    ? "Tìm trong $categoryName..."
                                    : "Tìm sản phẩm...",
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
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
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
                                  child: const Icon(
                                    Icons.clear,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) {
                            // DON'T auto-search, only clear results if empty
                            if (value.trim().isEmpty) {
                              setState(() {
                                productListSearch = [];
                                isSearching = false;
                              });
                            }
                          },
                          onSubmitted: (value) {
                            _performSearch(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (searchTextController.text.trim().isNotEmpty) {
                            _performSearch(searchTextController.text);
                          }
                        },
                        icon: const Icon(Icons.search, size: 18),
                        label: const Text('Tìm'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
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
                                    'Kết quả cho "${searchTextController.text}"',
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
                      else
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (categoryName != null && categoryName != "All")
                                Text(
                                  'Category: $categoryName',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                )
                              else
                                Text(
                                  'Tất cả sản phẩm',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              // Pagination info
                              if (productList.isNotEmpty)
                                Text(
                                  'Hiển thị ${productList.length}${productsProvider.hasMoreData ? '+' : ''} trong ${productsProvider.totalCount} sản phẩm',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Content area
                Expanded(child: _buildContent(productList, productsProvider)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
    List<ProductModel> productList,
    ProductsProvider productsProvider,
  ) {
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
              Icons.filter_list_outlined,
              size: 64,
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            TitlesTextWidget(label: "Chọn danh mục và bấm Apply Filter"),
            const SizedBox(height: 8),
            Text(
              selectedCategoryId != null
                  ? "Bấm Apply Filter để xem sản phẩm trong danh mục đã chọn"
                  : "Chọn danh mục hoặc bấm Apply Filter để xem tất cả sản phẩm",
              style: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _applyFilters();
              },
              icon: const Icon(Icons.filter_alt),
              label: Text(
                selectedCategoryId != null
                    ? 'Apply Filter'
                    : 'Xem tất cả sản phẩm',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
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
              Text('Đang tìm kiếm sản phẩm...'),
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
              const TitlesTextWidget(label: "Không tìm thấy sản phẩm"),
              const SizedBox(height: 8),
              Text(
                'Không có kết quả cho "${searchTextController.text}"',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Thử tìm kiếm với từ khóa khác',
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
                label: const Text('Xóa tìm kiếm'),
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

      return _buildProductGrid(productListSearch, productsProvider);
    }

    return _buildProductGrid(productList, productsProvider);
  }

  Widget _buildProductGrid(
    List<ProductModel> products,
    ProductsProvider productsProvider,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: DynamicHeightGridView(
          controller: _scrollController,
          itemCount: products.length + (productsProvider.isLoadingMore ? 1 : 0),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 8,
          builder: (context, index) {
            // Show loading indicator at the end if loading more
            if (index == products.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text(
                        'Đang tải thêm sản phẩm...',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360, minHeight: 280),
              child: ProductWidget(productId: products[index].productId),
            );
          },
        ),
      ),
    );
  }
}
