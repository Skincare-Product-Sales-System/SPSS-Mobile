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
import 'mvvm_screen_template.dart';

class EnhancedSearchScreen extends StatefulWidget {
  static const routeName = '/enhanced-search';
  final String? categoryName;

  const EnhancedSearchScreen({super.key, this.categoryName});

  @override
  State<EnhancedSearchScreen> createState() => _EnhancedSearchScreenState();
}

class _EnhancedSearchScreenState extends State<EnhancedSearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategoryId;
  String? _selectedBrandId;
  String? _selectedSkinTypeId;
  String? _selectedSortBy;
  bool _showFilters = false;
  late AnimationController _animationController;
  late Animation<double> _filterAnimation;

  @override
  void initState() {
    super.initState();

    // Khởi tạo animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _filterAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Thêm listener cho pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreProducts();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Khởi tạo dữ liệu ban đầu
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      debugPrint("EnhancedSearchScreen: Starting data initialization");

      // Loading categories, brands, and skin types in parallel
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

      // Using Future.wait to load data in parallel instead of sequentially
      await Future.wait([
        // Load categories if needed
        categoriesViewModel.categories.isEmpty
            ? Future(() async {
              debugPrint("EnhancedSearchScreen: Loading categories");
              await categoriesViewModel.loadCategories();
              debugPrint(
                "EnhancedSearchScreen: Categories loaded: ${categoriesViewModel.categories.length}",
              );
            })
            : Future.value(),

        // Load brands if needed
        brandsViewModel.brands.isEmpty
            ? Future(() async {
              debugPrint("EnhancedSearchScreen: Loading brands");
              await brandsViewModel.loadBrands();
              debugPrint(
                "EnhancedSearchScreen: Brands loaded: ${brandsViewModel.brands.length}",
              );
            })
            : Future.value(),

        // Load skin types if needed
        skinTypesViewModel.skinTypes.isEmpty
            ? Future(() async {
              debugPrint("EnhancedSearchScreen: Loading skin types");
              await skinTypesViewModel.loadSkinTypes();
              debugPrint(
                "EnhancedSearchScreen: Skin types loaded: ${skinTypesViewModel.skinTypes.length}",
              );
            })
            : Future.value(),
      ]);

      // Process category parameter if provided
      if (widget.categoryName != null && widget.categoryName != "All") {
        debugPrint(
          "EnhancedSearchScreen: Processing category param: ${widget.categoryName}",
        );
        final category = categoriesViewModel.findCategoryByName(
          widget.categoryName!,
        );
        if (category != null) {
          setState(() {
            _selectedCategoryId = category.id;
          });
          categoriesViewModel.selectCategory(_selectedCategoryId);
          debugPrint(
            "EnhancedSearchScreen: Selected category: ${category.categoryName} (${category.id})",
          );
        }
      }

      // Load initial products
      debugPrint("EnhancedSearchScreen: Loading initial products");
      await productsViewModel.loadProducts(refresh: true);
      debugPrint(
        "EnhancedSearchScreen: Initial products loaded: ${productsViewModel.products.length}",
      );

      debugPrint("EnhancedSearchScreen: Data initialization completed");
    } catch (e, stackTrace) {
      debugPrint("EnhancedSearchScreen: Error during initialization: $e");
      debugPrint(stackTrace.toString());
    }
  }

  void _loadMoreProducts() {
    final productsViewModel = Provider.of<EnhancedProductsViewModel>(
      context,
      listen: false,
    );

    if (productsViewModel.hasMoreData &&
        !productsViewModel.isLoading &&
        !productsViewModel.isLoadingMore) {
      debugPrint("EnhancedSearchScreen: Loading more products");

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
    // Đóng bàn phím khi tìm kiếm
    FocusScope.of(context).unfocus();

    if (searchText.trim().isEmpty) {
      // Hiển thị thông báo nếu không có từ khóa tìm kiếm
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

    // Đóng bộ lọc nếu đang mở
    if (_showFilters) {
      _toggleFilters();
    }

    debugPrint("EnhancedSearchScreen: Searching for: '$searchText'");

    // Thực hiện tìm kiếm
    productsViewModel.searchProducts(
      searchText: searchText,
      sortBy: _selectedSortBy,
      brandId: _selectedBrandId,
      skinTypeId: _selectedSkinTypeId,
    );

    // Hiển thị thông báo đang tìm kiếm
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
            Text('Đang tìm kiếm: "$searchText"'),
          ],
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleFilters() {
    debugPrint(
      "EnhancedSearchScreen: Toggling filters, current state: $_showFilters",
    );

    _debugPrintAllFilters();

    setState(() {
      _showFilters = !_showFilters;
      if (_showFilters) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _debugPrintAllFilters() {
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

    debugPrint("======= DEBUG FILTERS =======");
    debugPrint("Categories (${categoriesViewModel.categories.length}):");
    for (var category in categoriesViewModel.categories) {
      debugPrint(" - ${category.categoryName} (${category.id})");
    }

    debugPrint("Brands (${brandsViewModel.brands.length}):");
    for (var brand in brandsViewModel.brands) {
      debugPrint(" - ${brand.name} (${brand.id})");
    }

    debugPrint("Skin Types (${skinTypesViewModel.skinTypes.length}):");
    for (var skinType in skinTypesViewModel.skinTypes) {
      debugPrint(" - ${skinType.name} (${skinType.id})");
    }

    debugPrint("Currently Selected Filters:");
    debugPrint(" - Category ID: $_selectedCategoryId");
    debugPrint(" - Brand ID: $_selectedBrandId");
    debugPrint(" - Skin Type ID: $_selectedSkinTypeId");
    debugPrint(" - Sort By: $_selectedSortBy");
    debugPrint("============================");
  }

  void _applyFilters() {
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

    // Update the selected category in the view model
    if (_selectedCategoryId != null) {
      categoriesViewModel.selectCategory(_selectedCategoryId);
    } else {
      categoriesViewModel.clearSelection();
    }

    // Update the selected brand in the view model
    if (_selectedBrandId != null) {
      brandsViewModel.selectBrand(_selectedBrandId);
    } else {
      brandsViewModel.clearSelection();
    }

    // Update the selected skin type in the view model
    if (_selectedSkinTypeId != null) {
      skinTypesViewModel.selectSkinType(_selectedSkinTypeId);
    } else {
      skinTypesViewModel.clearSelection();
    }

    // Load products with the selected filters
    if (_selectedCategoryId != null) {
      productsViewModel.loadProductsByCategory(
        categoryId: _selectedCategoryId!,
        sortBy: _selectedSortBy,
        brandId: _selectedBrandId,
        skinTypeId: _selectedSkinTypeId,
        refresh: true,
      );
    } else {
      productsViewModel.loadProducts(
        sortBy: _selectedSortBy,
        brandId: _selectedBrandId,
        skinTypeId: _selectedSkinTypeId,
        refresh: true,
      );
    }

    _toggleFilters();
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoryId = null;
      _selectedBrandId = null;
      _selectedSkinTypeId = null;
      _selectedSortBy = null;
    });

    final categoriesViewModel = Provider.of<EnhancedCategoriesViewModel>(
      context,
      listen: false,
    );
    categoriesViewModel.clearSelection();

    final brandsViewModel = Provider.of<EnhancedBrandsViewModel>(
      context,
      listen: false,
    );
    brandsViewModel.clearSelection();

    final skinTypesViewModel = Provider.of<EnhancedSkinTypesViewModel>(
      context,
      listen: false,
    );
    skinTypesViewModel.clearSelection();

    final productsViewModel = Provider.of<EnhancedProductsViewModel>(
      context,
      listen: false,
    );
    productsViewModel.loadProducts(refresh: true);

    _toggleFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MvvmScreenTemplate<EnhancedProductsViewModel, dynamic>(
      title: 'Tìm kiếm',
      buildAppBar: (context, viewModel) => _buildAppBar(context, viewModel),
      buildContent: (context, viewModel) => _buildContent(context, viewModel),
      isLoading:
          (viewModel) =>
              viewModel.isSearching && viewModel.searchResults.isEmpty,
      isEmpty:
          (viewModel) =>
              !viewModel.isSearching &&
              viewModel.searchResults.isEmpty &&
              viewModel.currentSearchQuery != null,
      getErrorMessage:
          (viewModel) =>
              viewModel.hasSearchError ? viewModel.searchErrorMessage : null,
      buildEmpty: (context, viewModel) => _buildEmptyResults(context),
      onRefresh: (viewModel) async {
        if (viewModel.currentSearchQuery != null) {
          await viewModel.searchProducts(
            searchText: viewModel.currentSearchQuery!,
          );
        }
      },
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
                      // Thêm nút xóa text khi có nội dung
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                  });

                                  // Reset search and load all products with name=null
                                  final productsViewModel =
                                      Provider.of<EnhancedProductsViewModel>(
                                        context,
                                        listen: false,
                                      );
                                  debugPrint(
                                    "EnhancedSearchScreen: Clearing search and reloading products with name=null",
                                  );

                                  // Luôn reset search state để đảm bảo trạng thái tìm kiếm được xóa hoàn toàn
                                  productsViewModel.resetSearch();

                                  // Gọi API với các tham số lọc hiện tại nhưng không có từ khóa tìm kiếm
                                  productsViewModel.loadProducts(
                                    refresh: true,
                                    sortBy: _selectedSortBy,
                                    brandId: _selectedBrandId,
                                    skinTypeId: _selectedSkinTypeId,
                                  );
                                },
                              )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      // Cập nhật UI khi text thay đổi để hiển thị nút xóa
                      setState(() {});
                    },
                    onSubmitted: _performSearch,
                    textInputAction: TextInputAction.search,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Nút bộ lọc với animation
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
                      _showFilters
                          ? AppColors.lightAccent.withOpacity(0.2)
                          : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _toggleFilters,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: AnimatedRotation(
                        turns: _showFilters ? 0.25 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(Icons.filter_list),
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

  Widget _buildContent(
    BuildContext context,
    EnhancedProductsViewModel viewModel,
  ) {
    return Stack(
      children: [
        // Hiển thị kết quả tìm kiếm hoặc danh sách sản phẩm
        _showFilters
            ? const SizedBox() // Khi hiển thị bộ lọc, ẩn nội dung phía sau
            : viewModel.currentSearchQuery != null &&
                viewModel.searchResults.isNotEmpty
            ? _buildSearchResults(context, viewModel)
            : _buildProductsList(context, viewModel),

        // Bộ lọc với animation
        AnimatedBuilder(
          animation: _filterAnimation,
          builder: (context, child) {
            debugPrint(
              "EnhancedSearchScreen: Filter animation value: ${_filterAnimation.value}",
            );

            return PositionedDirectional(
              top: _showFilters ? 0 : -MediaQuery.of(context).size.height,
              start: 0,
              end: 0,
              height: MediaQuery.of(context).size.height,
              child: FadeTransition(
                opacity: _filterAnimation,
                child: Material(
                  color:
                      Colors
                          .white, // Thay đổi màu nền sang trắng cho filter panel
                  child: SafeArea(child: _buildFiltersView(context)),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFiltersView(BuildContext context) {
    debugPrint("EnhancedSearchScreen: Building filters view");

    // Thêm một widget debug để kiểm tra xem container có được hiển thị không
    return Container(
      color: Colors.white,
      child: Consumer3<
        EnhancedCategoriesViewModel,
        EnhancedBrandsViewModel,
        EnhancedSkinTypesViewModel
      >(
        builder: (
          context,
          categoriesViewModel,
          brandsViewModel,
          skinTypesViewModel,
          child,
        ) {
          debugPrint("EnhancedSearchScreen: Consumer3 builder called");
          debugPrint(
            "EnhancedSearchScreen: Categories count: ${categoriesViewModel.categories.length}",
          );
          debugPrint(
            "EnhancedSearchScreen: Brands count: ${brandsViewModel.brands.length}",
          );
          debugPrint(
            "EnhancedSearchScreen: SkinTypes count: ${skinTypesViewModel.skinTypes.length}",
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề bộ lọc
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const TitlesTextWidget(
                      label: "Bộ lọc tìm kiếm",
                      fontSize: 20,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _toggleFilters,
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),

                // Phần danh mục
                const TitlesTextWidget(
                  label: "Danh mục sản phẩm",
                  fontSize: 16,
                ),
                const SizedBox(height: 12),

                // Danh sách danh mục với thiết kế mới
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildCategoryChip('Tất cả', null),
                    ...categoriesViewModel.categories.map((category) {
                      return _buildCategoryChip(
                        category.categoryName,
                        category.id,
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 24),
                const TitlesTextWidget(label: "Thương hiệu", fontSize: 16),
                const SizedBox(height: 12),

                // Danh sách thương hiệu
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildBrandChip('Tất cả', null),
                    ...brandsViewModel.brands.map((brand) {
                      return _buildBrandChip(brand.name, brand.id);
                    }),
                  ],
                ),

                const SizedBox(height: 24),
                const TitlesTextWidget(label: "Loại da", fontSize: 16),
                const SizedBox(height: 12),

                // Danh sách loại da
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildSkinTypeChip('Tất cả', null),
                    ...skinTypesViewModel.skinTypes.map((skinType) {
                      return _buildSkinTypeChip(skinType.name, skinType.id);
                    }),
                  ],
                ),

                const SizedBox(height: 24),
                const TitlesTextWidget(label: "Sắp xếp theo", fontSize: 16),
                const SizedBox(height: 12),

                // Các tùy chọn sắp xếp với thiết kế mới
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildSortOptionChip('Mới nhất', 'createdAt_desc'),
                    _buildSortOptionChip('Giá thấp đến cao', 'price_asc'),
                    _buildSortOptionChip('Giá cao đến thấp', 'price_desc'),
                    _buildSortOptionChip('Phổ biến nhất', 'popularity_desc'),
                  ],
                ),

                const SizedBox(height: 40),

                // Các nút áp dụng và xóa bộ lọc
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Đặt lại'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _applyFilters,
                        icon: const Icon(Icons.check),
                        label: const Text('Áp dụng'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? categoryId) {
    final isSelected = _selectedCategoryId == categoryId;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedCategoryId = categoryId;
            });
          }
        },
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.grey.shade200,
        selectedColor: AppColors.lightAccent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: isSelected ? 2 : 0,
      ),
    );
  }

  Widget _buildBrandChip(String label, String? brandId) {
    final isSelected = _selectedBrandId == brandId;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedBrandId = brandId;
            });
          }
        },
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.grey.shade200,
        selectedColor: AppColors.lightAccent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: isSelected ? 2 : 0,
      ),
    );
  }

  Widget _buildSkinTypeChip(String label, String? skinTypeId) {
    final isSelected = _selectedSkinTypeId == skinTypeId;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedSkinTypeId = skinTypeId;
            });
          }
        },
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.grey.shade200,
        selectedColor: AppColors.lightAccent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: isSelected ? 2 : 0,
      ),
    );
  }

  Widget _buildSortOptionChip(String label, String sortOption) {
    final isSelected = _selectedSortBy == sortOption;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedSortBy = sortOption;
            });
          }
        },
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.grey.shade200,
        selectedColor: AppColors.lightAccent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: isSelected ? 2 : 0,
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    EnhancedProductsViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner kết quả tìm kiếm
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.lightAccent.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.search,
                    size: 20,
                    color: AppColors.lightAccent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Kết quả cho "${viewModel.currentSearchQuery}"',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Tìm thấy ${viewModel.searchResults.length} sản phẩm',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
        // Lưới sản phẩm
        Expanded(
          child:
              viewModel.searchResults.isEmpty
                  ? _buildEmptyResults(context)
                  : Padding(
                    padding: const EdgeInsets.all(12.0),
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
    if (viewModel.isLoading && viewModel.products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.lightAccent),
        ),
      );
    }

    return Column(
      children: [
        // Hiển thị thông tin về danh mục đang chọn nếu có
        if (_selectedCategoryId != null ||
            _selectedBrandId != null ||
            _selectedSkinTypeId != null ||
            _selectedSortBy != null)
          _buildActiveFiltersBar(context),

        // Lưới sản phẩm
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
                    padding: const EdgeInsets.all(12.0),
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

        // Hiển thị loading khi tải thêm sản phẩm
        if (viewModel.isLoadingMore)
          Container(
            padding: const EdgeInsets.all(16.0),
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

  Widget _buildActiveFiltersBar(BuildContext context) {
    final categoriesViewModel = Provider.of<EnhancedCategoriesViewModel>(
      context,
    );
    final brandsViewModel = Provider.of<EnhancedBrandsViewModel>(context);
    final skinTypesViewModel = Provider.of<EnhancedSkinTypesViewModel>(context);

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

    String sortByText = '';
    if (_selectedSortBy == 'createdAt_desc') sortByText = 'Mới nhất';
    if (_selectedSortBy == 'price_asc') sortByText = 'Giá thấp đến cao';
    if (_selectedSortBy == 'price_desc') sortByText = 'Giá cao đến thấp';
    if (_selectedSortBy == 'popularity_desc') sortByText = 'Phổ biến nhất';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Hiển thị thông tin về bộ lọc đang dùng
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.filter_list,
                      size: 18,
                      color: AppColors.lightAccent,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Bộ lọc:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (selectedCategory != null)
                      _buildFilterChip(selectedCategory.categoryName),
                    if (selectedBrand != null)
                      _buildFilterChip(selectedBrand.name),
                    if (selectedSkinType != null)
                      _buildFilterChip(selectedSkinType.name),
                    if (sortByText.isNotEmpty) _buildFilterChip(sortByText),
                  ],
                ),
              ],
            ),
          ),
          // Nút chỉnh sửa bộ lọc
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.lightAccent),
            onPressed: _toggleFilters,
            tooltip: 'Chỉnh sửa bộ lọc',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
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
            width: 180,
            height: 180,
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
          Text(
            'Hãy thử tìm kiếm với từ khóa khác hoặc thay đổi bộ lọc',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _toggleFilters,
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
