import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../consts/app_colors.dart';
import '../providers/enhanced_categories_view_model.dart';
import '../providers/enhanced_products_view_model.dart';
import '../providers/enhanced_brands_view_model.dart';
import '../providers/enhanced_skin_types_view_model.dart';
import '../widgets/products/enhanced_product_widget.dart';
import '../widgets/title_text.dart';

class SimpleSearchScreen extends StatefulWidget {
  static const routeName = '/simple-search';
  final String? categoryName;

  const SimpleSearchScreen({super.key, this.categoryName});

  @override
  State<SimpleSearchScreen> createState() => _SimpleSearchScreenState();
}

class _SimpleSearchScreenState extends State<SimpleSearchScreen> {
  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Filter state
  String? _selectedCategoryId;
  String? _selectedBrandId;
  String? _selectedSkinTypeId;
  String? _selectedSortBy;

  // UI state
  bool _isFilterVisible = false;

  @override
  void initState() {
    super.initState();

    // Add listener for infinite scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreProducts();
      }
    });
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _initializeData();
    }
  }

  Future<void> _initializeData() async {
    try {
      debugPrint("SimpleSearchScreen: Starting data initialization");

      // Get all view models
      final categoriesViewModel = Provider.of<EnhancedCategoriesViewModel>(
        context,
        listen: false,
      );
      final brandsViewModel = Provider.of<EnhancedBrandsViewModel>(
        context,
        listen: false,
      );
      final skinTypesViewModel = Provider.of<EnhancedSkinTypesViewModel>(
        context,
        listen: false,
      );
      final productsViewModel = Provider.of<EnhancedProductsViewModel>(
        context,
        listen: false,
      );

      // Check if data is already loaded to avoid unnecessary API calls
      final needsCategories = categoriesViewModel.categories.isEmpty;
      final needsBrands = brandsViewModel.brands.isEmpty;
      final needsSkinTypes = skinTypesViewModel.skinTypes.isEmpty;

      // Only load data if necessary
      if (needsCategories || needsBrands || needsSkinTypes) {
        debugPrint("SimpleSearchScreen: Loading missing data");

        // Load data in parallel
        await Future.wait([
          // Categories
          needsCategories
              ? categoriesViewModel.loadCategories()
              : Future.value(),

          // Brands
          needsBrands ? brandsViewModel.loadBrands() : Future.value(),

          // Skin types
          needsSkinTypes ? skinTypesViewModel.loadSkinTypes() : Future.value(),
        ]);
      }

      // Handle category selection if provided
      if (widget.categoryName != null &&
          widget.categoryName != "All" &&
          widget.categoryName != "Tất Cả") {
        final category = categoriesViewModel.findCategoryByName(
          widget.categoryName!,
        );
        if (category != null) {
          setState(() {
            _selectedCategoryId = category.id;
          });
          categoriesViewModel.selectCategory(_selectedCategoryId);

          // If we have a category, load products by that category
          await productsViewModel.loadProductsByCategory(
            categoryId: category.id,
            refresh: true,
          );
          debugPrint(
            "SimpleSearchScreen: Loaded products for category: ${category.categoryName}",
          );
          return; // Return early since we've loaded products for the category
        }
      }

      // Load initial products only if not already loaded
      if (productsViewModel.products.isEmpty) {
        await productsViewModel.loadProducts(refresh: true);
        debugPrint("SimpleSearchScreen: Loaded initial products");
      }

      debugPrint("SimpleSearchScreen: Data initialization completed");
    } catch (e, stackTrace) {
      debugPrint("SimpleSearchScreen: Error during initialization: $e");
      debugPrint(stackTrace.toString());
    }
  }

  // Add debounce for load more to prevent multiple calls
  DateTime _lastLoadMore = DateTime.now();

  void _loadMoreProducts() {
    // Add debounce to prevent multiple rapid calls
    final now = DateTime.now();
    if (now.difference(_lastLoadMore).inMilliseconds < 500) {
      // Ignore calls that are too close together
      return;
    }
    _lastLoadMore = now;

    final productsViewModel = Provider.of<EnhancedProductsViewModel>(
      context,
      listen: false,
    );

    if (productsViewModel.hasMoreData &&
        !productsViewModel.isLoading &&
        !productsViewModel.isLoadingMore) {
      debugPrint("SimpleSearchScreen: Loading more products");

      if (_selectedCategoryId != null) {
        productsViewModel.loadProductsByCategory(
          categoryId: _selectedCategoryId!,
          sortBy: _selectedSortBy,
          brandId: _selectedBrandId,
          skinTypeId: _selectedSkinTypeId,
        );
      } else {
        productsViewModel.loadProducts(
          sortBy: _selectedSortBy,
          brandId: _selectedBrandId,
          skinTypeId: _selectedSkinTypeId,
        );
      }
    }
  }

  void _performSearch(String searchText) {
    debugPrint("SimpleSearchScreen: Performing search for '$searchText'");

    // Close keyboard
    FocusScope.of(context).unfocus();

    if (searchText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập từ khóa tìm kiếm'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final productsViewModel = Provider.of<EnhancedProductsViewModel>(
      context,
      listen: false,
    );

    // Close filter panel if open
    if (_isFilterVisible) {
      setState(() {
        _isFilterVisible = false;
      });
    }

    // Debug existing filters
    debugPrint(
      "SimpleSearchScreen: Searching with filters - Category: $_selectedCategoryId, " +
          "Brand: $_selectedBrandId, SkinType: $_selectedSkinTypeId, SortBy: $_selectedSortBy",
    );

    // Perform search WITH all selected filters - ensure integration between search and filters    // Make a copy of search text to avoid any timing issues
    final finalSearchText = searchText.trim();

    // Reset the search state first to ensure we don't have any stale data
    productsViewModel.resetSearch();

    // Small delay to ensure search state is fully reset
    Future.delayed(const Duration(milliseconds: 50), () {
      productsViewModel.searchProducts(
        searchText: finalSearchText,
        sortBy: _selectedSortBy,
        brandId: _selectedBrandId,
        skinTypeId: _selectedSkinTypeId,
        refresh: true, // Always refresh when performing a new search
      );

      debugPrint(
        "SimpleSearchScreen: Search initiated for '$finalSearchText' with filters applied",
      );
    }); // Show notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Đang tìm kiếm: "$searchText"${_getFiltersDescription()}',
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Helper method to get a brief description of active filters for notifications
  String _getFiltersDescription() {
    List<String> activeFilters = [];

    if (_selectedCategoryId != null) {
      final category = Provider.of<EnhancedCategoriesViewModel>(
        context,
        listen: false,
      ).findCategoryById(_selectedCategoryId!);
      if (category != null) activeFilters.add(category.categoryName);
    }

    if (_selectedBrandId != null) {
      final brand = Provider.of<EnhancedBrandsViewModel>(
        context,
        listen: false,
      ).findBrandById(_selectedBrandId!);
      if (brand != null) activeFilters.add(brand.name);
    }

    if (activeFilters.isEmpty) return '';
    return ' với ${activeFilters.join(', ')}';
  }

  void _toggleFilter() {
    debugPrint("SimpleSearchScreen: Toggle filter");
    setState(() {
      _isFilterVisible = !_isFilterVisible;
    });
  }

  void _applyFilters() {
    debugPrint("SimpleSearchScreen: Applying filters");

    final productsViewModel = Provider.of<EnhancedProductsViewModel>(
      context,
      listen: false,
    );
    final categoriesViewModel = Provider.of<EnhancedCategoriesViewModel>(
      context,
      listen: false,
    );
    final brandsViewModel = Provider.of<EnhancedBrandsViewModel>(
      context,
      listen: false,
    );
    final skinTypesViewModel = Provider.of<EnhancedSkinTypesViewModel>(
      context,
      listen: false,
    );

    // Update selected items in view models
    if (_selectedCategoryId != null) {
      categoriesViewModel.selectCategory(_selectedCategoryId);
    } else {
      categoriesViewModel.clearSelection();
    }

    if (_selectedBrandId != null) {
      brandsViewModel.selectBrand(_selectedBrandId);
    } else {
      brandsViewModel.clearSelection();
    }

    if (_selectedSkinTypeId != null) {
      skinTypesViewModel.selectSkinType(_selectedSkinTypeId);
    } else {
      skinTypesViewModel.clearSelection();
    }

    // Get current search query if any
    final currentSearchQuery = productsViewModel.currentSearchQuery;
    debugPrint(
      "SimpleSearchScreen: Current search query when applying filters: $currentSearchQuery",
    );

    // Small delay to ensure view model state is updated
    Future.delayed(const Duration(milliseconds: 50), () {
      if (currentSearchQuery != null && currentSearchQuery.isNotEmpty) {
        // If we have a search query, apply filters to the search
        debugPrint(
          "SimpleSearchScreen: Applying filters to current search: $currentSearchQuery",
        );

        productsViewModel.searchProducts(
          searchText: currentSearchQuery,
          sortBy: _selectedSortBy,
          brandId: _selectedBrandId,
          skinTypeId: _selectedSkinTypeId,
          refresh: true, // Force refresh to clear any cached results
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã áp dụng bộ lọc cho "$currentSearchQuery"'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // No search query - just apply filters to product list
        debugPrint(
          "SimpleSearchScreen: Applying filters to product list without search",
        );

        if (_selectedCategoryId != null) {
          debugPrint(
            "SimpleSearchScreen: Loading products by category: $_selectedCategoryId",
          );
          productsViewModel.loadProductsByCategory(
            categoryId: _selectedCategoryId!,
            sortBy: _selectedSortBy,
            brandId: _selectedBrandId,
            skinTypeId: _selectedSkinTypeId,
            refresh: true,
          );
        } else {
          debugPrint("SimpleSearchScreen: Loading products with filters");
          productsViewModel.loadProducts(
            sortBy: _selectedSortBy,
            brandId: _selectedBrandId,
            skinTypeId: _selectedSkinTypeId,
            refresh: true,
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã áp dụng bộ lọc'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    // Close filter panel
    setState(() {
      _isFilterVisible = false;
    });
  }

  void _clearFilters() {
    debugPrint("SimpleSearchScreen: Clearing all filters");

    setState(() {
      _selectedCategoryId = null;
      _selectedBrandId = null;
      _selectedSkinTypeId = null;
      _selectedSortBy = null;
    });

    // Clear selections in view models
    Provider.of<EnhancedCategoriesViewModel>(
      context,
      listen: false,
    ).clearSelection();
    Provider.of<EnhancedBrandsViewModel>(
      context,
      listen: false,
    ).clearSelection();
    Provider.of<EnhancedSkinTypesViewModel>(
      context,
      listen: false,
    ).clearSelection();

    final productsViewModel = Provider.of<EnhancedProductsViewModel>(
      context,
      listen: false,
    );

    // Check if we have an active search query
    final currentSearchQuery = productsViewModel.currentSearchQuery;
    debugPrint("SimpleSearchScreen: Current search query: $currentSearchQuery");

    // Small delay to ensure view model state is updated
    Future.delayed(const Duration(milliseconds: 50), () {
      if (currentSearchQuery != null && currentSearchQuery.isNotEmpty) {
        // If we have a search query, re-run the search WITHOUT filters
        debugPrint("SimpleSearchScreen: Re-running search WITHOUT filters");
        productsViewModel.searchProducts(
          searchText: currentSearchQuery,
          // All filters are explicitly set to null
          brandId: null,
          skinTypeId: null,
          sortBy: null,
          refresh:
              true, // Critical - force a refresh to clear any cached results
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa bộ lọc, giữ từ khóa tìm kiếm'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // If no search query, reload all products without filters
        debugPrint(
          "SimpleSearchScreen: Reloading all products without filters",
        );
        productsViewModel.loadProducts(refresh: true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa bộ lọc'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    setState(() {
      _isFilterVisible = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(
        context,
        Provider.of<EnhancedProductsViewModel>(context, listen: false),
      ),
      body: Stack(
        children: [
          // Main content - Product list or search results
          Consumer<EnhancedProductsViewModel>(
            builder: (context, viewModel, child) {
              // Loading state
              if (viewModel.isLoading &&
                  viewModel.products.isEmpty &&
                  !viewModel.isSearching) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.lightAccent,
                    ),
                  ),
                );
              }

              // Search results view
              if (viewModel.isSearching ||
                  viewModel.currentSearchQuery != null) {
                return _buildSearchResults(context, viewModel);
              }

              // Regular products list view
              return _buildProductsList(context, viewModel);
            },
          ),

          // Filter panel overlay
          if (_isFilterVisible)
            Container(
              color: Colors.black.withOpacity(0.5),
              width: double.infinity,
              height: double.infinity,
              child: GestureDetector(
                onTap: _toggleFilter, // Close when tapping outside
                behavior: HitTestBehavior.opaque,
                child: GestureDetector(
                  onTap: () {}, // Prevent closing when tapping inside panel
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: _buildFilterPanel(),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    EnhancedProductsViewModel viewModel,
  ) {
    return AppBar(
      elevation: 0,
      title: const TitlesTextWidget(label: "Tìm kiếm"),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // Search box
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      fillColor: Theme.of(context).cardColor,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      hintText: 'Tìm kiếm sản phẩm...',
                      prefixIcon: const Icon(Icons.search),
                      // Clear button
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  debugPrint(
                                    "SimpleSearchScreen: Clearing search field",
                                  );

                                  // Clear the search text field
                                  setState(() {
                                    _searchController.clear();
                                  }); // Get the current view model
                                  final viewModel =
                                      Provider.of<EnhancedProductsViewModel>(
                                        context,
                                        listen: false,
                                      );

                                  // 1. First, fully reset search state to ensure no cached values remain
                                  viewModel.resetSearch();

                                  // Debug check to verify searchQuery is null
                                  debugPrint(
                                    "SimpleSearchScreen: After resetSearch, currentSearchQuery=${viewModel.currentSearchQuery}",
                                  );

                                  // 2. Add a small delay to ensure the reset is complete
                                  Future.delayed(const Duration(milliseconds: 50), () {
                                    // Check if we have any active filters
                                    bool hasFilters =
                                        _selectedCategoryId != null ||
                                        _selectedBrandId != null ||
                                        _selectedSkinTypeId != null ||
                                        _selectedSortBy != null;

                                    debugPrint(
                                      "SimpleSearchScreen: Has active filters: $hasFilters",
                                    ); // The key fix: explicitly pass searchText as empty string to ensure
                                    // the API is called with name=null while preserving any active filters
                                    if (_selectedCategoryId != null) {
                                      // Case 1: We have a category filter
                                      // Call loadProductsByCategory with the category and other filters
                                      viewModel.loadProductsByCategory(
                                        categoryId: _selectedCategoryId!,
                                        refresh: true, // Force refresh
                                        sortBy: _selectedSortBy,
                                        brandId: _selectedBrandId,
                                        skinTypeId: _selectedSkinTypeId,
                                      );

                                      debugPrint(
                                        "SimpleSearchScreen: Reloaded products with category filter: $_selectedCategoryId",
                                      );
                                    } else {
                                      // Case 2: No category, but might have other filters
                                      // We use loadProducts instead of searchProducts to ensure we're not in search mode
                                      // This will call the API with name=null
                                      viewModel.loadProducts(
                                        refresh: true, // Force refresh
                                        sortBy: _selectedSortBy,
                                        brandId: _selectedBrandId,
                                        skinTypeId: _selectedSkinTypeId,
                                      );

                                      debugPrint(
                                        "SimpleSearchScreen: Reloaded all products with filters but no search query",
                                      );
                                    }

                                    // Show appropriate notification based on filter state
                                    if (hasFilters) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Đã xóa tìm kiếm, giữ các bộ lọc',
                                          ),
                                          duration: Duration(seconds: 1),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Đã xóa tìm kiếm'),
                                          duration: Duration(seconds: 1),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  });
                                },
                              )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {}); // Update UI for clear button visibility
                    },
                    onSubmitted: _performSearch,
                    textInputAction: TextInputAction.search,
                  ),
                ),
              ),

              // Filter button
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color:
                      _isFilterVisible
                          ? AppColors.lightAccent.withOpacity(0.2)
                          : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _toggleFilter,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.filter_list,
                        color: _isFilterVisible ? AppColors.lightAccent : null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPanel() {
    final categoriesViewModel = Provider.of<EnhancedCategoriesViewModel>(
      context,
      listen: false,
    );
    final brandsViewModel = Provider.of<EnhancedBrandsViewModel>(
      context,
      listen: false,
    );
    final skinTypesViewModel = Provider.of<EnhancedSkinTypesViewModel>(
      context,
      listen: false,
    ); // Disable debug prints for better performance
    // debugPrint("SimpleSearchScreen: Building filter panel with:");
    // debugPrint("Categories: ${categoriesViewModel.categories.length}");
    // debugPrint("Brands: ${brandsViewModel.brands.length}");
    // debugPrint("Skin Types: ${skinTypesViewModel.skinTypes.length}");

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          minHeight: MediaQuery.of(context).size.height * 0.3,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.lightAccent.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    "Bộ lọc tìm kiếm",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _toggleFilter,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Filter content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categories
                    const Text(
                      "Danh mục sản phẩm",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(
                          "Tất cả",
                          isSelected: _selectedCategoryId == null,
                          onTap:
                              () => setState(() => _selectedCategoryId = null),
                        ),
                        ...categoriesViewModel.categories.map(
                          (category) => _buildChip(
                            category.categoryName,
                            isSelected: _selectedCategoryId == category.id,
                            onTap:
                                () => setState(
                                  () => _selectedCategoryId = category.id,
                                ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Brands
                    const Text(
                      "Thương hiệu",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(
                          "Tất cả",
                          isSelected: _selectedBrandId == null,
                          onTap: () => setState(() => _selectedBrandId = null),
                        ),
                        ...brandsViewModel.brands.map(
                          (brand) => _buildChip(
                            brand.name,
                            isSelected: _selectedBrandId == brand.id,
                            onTap:
                                () =>
                                    setState(() => _selectedBrandId = brand.id),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Skin types
                    const Text(
                      "Loại da",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(
                          "Tất cả",
                          isSelected: _selectedSkinTypeId == null,
                          onTap:
                              () => setState(() => _selectedSkinTypeId = null),
                        ),
                        ...skinTypesViewModel.skinTypes.map(
                          (skinType) => _buildChip(
                            skinType.name,
                            isSelected: _selectedSkinTypeId == skinType.id,
                            onTap:
                                () => setState(
                                  () => _selectedSkinTypeId = skinType.id,
                                ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Sort options
                    const Text(
                      "Sắp xếp theo",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(
                          "Mới nhất",
                          isSelected: _selectedSortBy == "createdAt_desc",
                          onTap:
                              () => setState(
                                () => _selectedSortBy = "createdAt_desc",
                              ),
                        ),
                        _buildChip(
                          "Giá thấp đến cao",
                          isSelected: _selectedSortBy == "price_asc",
                          onTap:
                              () =>
                                  setState(() => _selectedSortBy = "price_asc"),
                        ),
                        _buildChip(
                          "Giá cao đến thấp",
                          isSelected: _selectedSortBy == "price_desc",
                          onTap:
                              () => setState(
                                () => _selectedSortBy = "price_desc",
                              ),
                        ),
                        _buildChip(
                          "Phổ biến nhất",
                          isSelected: _selectedSortBy == "popularity_desc",
                          onTap:
                              () => setState(
                                () => _selectedSortBy = "popularity_desc",
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _clearFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Xóa bộ lọc"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Áp dụng"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(
    String label, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightAccent : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Helper method to get a description of active filters for UI
  String _getActiveFiltersText() {
    List<String> filterTexts = [];

    // Add category if selected
    if (_selectedCategoryId != null) {
      final categoriesViewModel = Provider.of<EnhancedCategoriesViewModel>(
        context,
        listen: false,
      );
      final category = categoriesViewModel.findCategoryById(
        _selectedCategoryId!,
      );
      if (category != null) {
        filterTexts.add("Danh mục: ${category.categoryName}");
      }
    }

    // Add brand if selected
    if (_selectedBrandId != null) {
      final brandsViewModel = Provider.of<EnhancedBrandsViewModel>(
        context,
        listen: false,
      );
      final brand = brandsViewModel.findBrandById(_selectedBrandId!);
      if (brand != null) {
        filterTexts.add("Thương hiệu: ${brand.name}");
      }
    }

    // Add skin type if selected
    if (_selectedSkinTypeId != null) {
      final skinTypesViewModel = Provider.of<EnhancedSkinTypesViewModel>(
        context,
        listen: false,
      );
      final skinType = skinTypesViewModel.findSkinTypeById(
        _selectedSkinTypeId!,
      );
      if (skinType != null) {
        filterTexts.add("Loại da: ${skinType.name}");
      }
    }

    // Add sort by if selected
    if (_selectedSortBy != null) {
      String sortText = '';
      switch (_selectedSortBy) {
        case 'createdAt_desc':
          sortText = 'Mới nhất';
          break;
        case 'price_asc':
          sortText = 'Giá thấp đến cao';
          break;
        case 'price_desc':
          sortText = 'Giá cao đến thấp';
          break;
        case 'popularity_desc':
          sortText = 'Phổ biến nhất';
          break;
      }

      if (sortText.isNotEmpty) {
        filterTexts.add("Sắp xếp: $sortText");
      }
    }

    if (filterTexts.isEmpty) {
      return '';
    }

    return filterTexts.join(' • ');
  }

  Widget _buildSearchResults(
    BuildContext context,
    EnhancedProductsViewModel viewModel,
  ) {
    final hasActiveFilters =
        _selectedCategoryId != null ||
        _selectedBrandId != null ||
        _selectedSkinTypeId != null ||
        _selectedSortBy != null;

    final activeFiltersText = _getActiveFiltersText();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search result header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.lightAccent.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.search,
                    size: 16,
                    color: AppColors.lightAccent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Kết quả cho "${viewModel.currentSearchQuery}"',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Tìm thấy ${viewModel.searchResults.length} sản phẩm',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),

              // Show active filters if any
              if (hasActiveFilters) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      size: 14,
                      color: AppColors.lightAccent.withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        activeFiltersText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: _toggleFilter,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Text(
                          'Chỉnh sửa',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.lightAccent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Product grid
        Expanded(
          child:
              viewModel.isSearching
                  ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.lightAccent,
                      ),
                    ),
                  )
                  : viewModel.searchResults.isEmpty
                  ? _buildEmptyResults(context)
                  : Padding(
                    padding: const EdgeInsets.all(12),
                    child: DynamicHeightGridView(
                      itemCount: viewModel.searchResults.length,
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      builder: (context, index) {
                        return EnhancedProductWidget(
                          productId: viewModel.searchResults[index].productId,
                        );
                      },
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildProductsList(
    BuildContext context,
    EnhancedProductsViewModel viewModel,
  ) {
    // Loading state
    if (viewModel.isLoading && viewModel.products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.lightAccent),
        ),
      );
    }

    return Column(
      children: [
        // Active filters bar
        if (_selectedCategoryId != null ||
            _selectedBrandId != null ||
            _selectedSkinTypeId != null ||
            _selectedSortBy != null)
          _buildActiveFiltersBar(),

        // Products grid
        Expanded(
          child:
              viewModel.products.isEmpty
                  ? Center(
                    child: Text(
                      'Không tìm thấy sản phẩm nào',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  )
                  : Padding(
                    padding: const EdgeInsets.all(12),
                    child: DynamicHeightGridView(
                      controller: _scrollController,
                      itemCount: viewModel.products.length,
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      builder: (context, index) {
                        final product = viewModel.products[index];
                        return EnhancedProductWidget(
                          productId: product.productId,
                        );
                      },
                    ),
                  ),
        ),

        // Loading more indicator
        if (viewModel.isLoadingMore)
          Container(
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.lightAccent,
                ),
                strokeWidth: 3,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActiveFiltersBar() {
    final categoriesViewModel = Provider.of<EnhancedCategoriesViewModel>(
      context,
      listen: false,
    );
    final brandsViewModel = Provider.of<EnhancedBrandsViewModel>(
      context,
      listen: false,
    );
    final skinTypesViewModel = Provider.of<EnhancedSkinTypesViewModel>(
      context,
      listen: false,
    );

    // Get selected entities
    final selectedCategory =
        _selectedCategoryId != null
            ? categoriesViewModel.findCategoryById(_selectedCategoryId!)
            : null;

    final selectedBrand =
        _selectedBrandId != null
            ? brandsViewModel.findBrandById(_selectedBrandId!)
            : null;

    final selectedSkinType =
        _selectedSkinTypeId != null
            ? skinTypesViewModel.findSkinTypeById(_selectedSkinTypeId!)
            : null;

    // Get sort text
    String sortByText = '';
    if (_selectedSortBy == 'createdAt_desc') sortByText = 'Mới nhất';
    if (_selectedSortBy == 'price_asc') sortByText = 'Giá thấp đến cao';
    if (_selectedSortBy == 'price_desc') sortByText = 'Giá cao đến thấp';
    if (_selectedSortBy == 'popularity_desc') sortByText = 'Phổ biến nhất';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // Filter information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      size: 16,
                      color: AppColors.lightAccent,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Đang lọc:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (selectedCategory != null)
                      _buildFilterTag(selectedCategory.categoryName),
                    if (selectedBrand != null)
                      _buildFilterTag(selectedBrand.name),
                    if (selectedSkinType != null)
                      _buildFilterTag(selectedSkinType.name),
                    if (sortByText.isNotEmpty) _buildFilterTag(sortByText),
                  ],
                ),
              ],
            ),
          ),

          // Edit button
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.lightAccent),
            onPressed: _toggleFilter,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
      ),
    );
  }

  Widget _buildEmptyResults(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty_search.png',
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 24),
          Text(
            'Không tìm thấy sản phẩm nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Hãy thử tìm kiếm với từ khóa khác hoặc thay đổi bộ lọc',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _toggleFilter,
            icon: const Icon(Icons.filter_list),
            label: const Text('Thay đổi bộ lọc'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
