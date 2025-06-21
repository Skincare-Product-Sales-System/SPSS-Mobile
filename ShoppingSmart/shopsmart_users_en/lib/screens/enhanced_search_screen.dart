import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../consts/app_colors.dart';
import '../providers/enhanced_categories_view_model.dart';
import '../providers/enhanced_products_view_model.dart';
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
    final categoriesViewModel = Provider.of<EnhancedCategoriesViewModel>(
      context,
      listen: false,
    );

    // Tải danh mục nếu chưa có
    if (categoriesViewModel.categories.isEmpty) {
      await categoriesViewModel.loadCategories();
    }

    // Tải danh sách thương hiệu nếu cần
    // final brandsViewModel = Provider.of<EnhancedBrandsViewModel>(
    //   context,
    //   listen: false,
    // );
    // if (brandsViewModel.brands.isEmpty) {
    //   await brandsViewModel.loadBrands();
    // }

    // Xử lý tham số danh mục nếu có
    if (widget.categoryName != null && widget.categoryName != "All") {
      final category = categoriesViewModel.findCategoryByName(
        widget.categoryName!,
      );
      if (category != null) {
        setState(() {
          _selectedCategoryId = category.id;
        });
        categoriesViewModel.selectCategory(_selectedCategoryId);
      }
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
      if (_selectedCategoryId != null) {
        productsViewModel.loadProductsByCategory(
          categoryId: _selectedCategoryId!,
          sortBy: _selectedSortBy,
        );
      } else {
        productsViewModel.loadProducts(sortBy: _selectedSortBy);
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

    // Thực hiện tìm kiếm
    productsViewModel.searchProducts(searchText: searchText);

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
    setState(() {
      _showFilters = !_showFilters;
      if (_showFilters) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
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

    if (_selectedCategoryId != null) {
      categoriesViewModel.selectCategory(_selectedCategoryId);
      productsViewModel.loadProductsByCategory(
        categoryId: _selectedCategoryId!,
        sortBy: _selectedSortBy,
        refresh: true,
      );
    } else {
      categoriesViewModel.clearSelection();
      productsViewModel.loadProducts(sortBy: _selectedSortBy, refresh: true);
    }

    _toggleFilters();
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoryId = null;
      _selectedSortBy = null;
    });

    final categoriesViewModel = Provider.of<EnhancedCategoriesViewModel>(
      context,
      listen: false,
    );
    categoriesViewModel.clearSelection();

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
                      hintText: 'Tìm kiếm sản phẩm...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.lightAccent,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      // Thêm nút xóa text khi có nội dung
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                  // Clear search results and reset to initial state
                                  final productsViewModel =
                                      Provider.of<EnhancedProductsViewModel>(
                                        context,
                                        listen: false,
                                      );
                                  productsViewModel.clearSearchResults();
                                  // Load products to show initial product list
                                  productsViewModel.loadProducts(refresh: true);
                                },
                              )
                              : null,
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
                        child: Icon(
                          Icons.filter_list,
                          color:
                              _showFilters
                                  ? AppColors.lightAccent
                                  : Colors.grey,
                        ),
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
            return PositionedDirectional(
              top: _showFilters ? 0 : -MediaQuery.of(context).size.height,
              start: 0,
              end: 0,
              height: MediaQuery.of(context).size.height,
              child: FadeTransition(
                opacity: _filterAnimation,
                child: Material(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: _buildFiltersView(context),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFiltersView(BuildContext context) {
    final categoriesViewModel = Provider.of<EnhancedCategoriesViewModel>(
      context,
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
              const TitlesTextWidget(label: "Bộ lọc tìm kiếm", fontSize: 20),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _toggleFilters,
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),

          // Phần danh mục
          const TitlesTextWidget(label: "Danh mục sản phẩm", fontSize: 16),
          const SizedBox(height: 12),

          // Danh sách danh mục với thiết kế mới
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildCategoryChip('Tất cả', null),
              ...categoriesViewModel.categories.map((category) {
                return _buildCategoryChip(
                  category.categoryName ?? '',
                  category.id,
                );
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
                          productId:
                              viewModel.searchResults[index].productId ?? '',
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
        if (_selectedCategoryId != null || _selectedSortBy != null)
          _buildActiveFiltersBar(context),

        // Lưới sản phẩm
        Expanded(
          child: Padding(
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
                  productId: product.productId ?? '',
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
    final selectedCategory =
        _selectedCategoryId != null
            ? categoriesViewModel.findCategoryById(_selectedCategoryId!)
            : null;

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
          const Icon(Icons.filter_list, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Lọc: ${selectedCategory?.categoryName ?? 'Tất cả'}'
              '${sortByText.isNotEmpty ? ' • $sortByText' : ''}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          GestureDetector(
            onTap: _toggleFilters,
            child: const Text(
              'Thay đổi',
              style: TextStyle(
                color: AppColors.lightAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResults(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off, size: 64, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Text(
              'Không tìm thấy sản phẩm nào',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Hãy thử tìm kiếm với từ khóa khác hoặc sử dụng bộ lọc để tìm sản phẩm phù hợp',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _toggleFilters,
              icon: const Icon(Icons.filter_alt),
              label: const Text('Mở bộ lọc'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
