import 'package:flutter/foundation.dart';
import '../models/detailed_product_model.dart';
import '../models/product_model.dart';
import '../models/review_models.dart';
import '../models/view_state.dart';
import '../repositories/product_repository.dart';
import '../services/error_handling_service.dart';
import '../services/service_locator.dart';
import 'base_view_model.dart';
import 'products_state.dart';

/// ViewModel cải tiến cho Products, kế thừa từ BaseViewModel
class EnhancedProductsViewModel extends BaseViewModel<ProductsState> {
  final ProductRepository _productRepository;

  /// Constructor với dependency injection cho repository
  EnhancedProductsViewModel({ProductRepository? productRepository})
    : _productRepository = productRepository ?? sl<ProductRepository>(),
      super(const ProductsState());

  /// Getters tiện ích
  List<ProductModel> get products => state.products.data ?? [];
  List<ProductModel> get searchResults => state.searchResults.data ?? [];
  DetailedProductModel? get detailedProduct => state.detailedProduct.data;
  List<ReviewModel> get productReviews => state.productReviews.data ?? [];
  bool get isLoading => state.products.isLoading;
  bool get isLoadingMore => state.products.isLoadingMore;
  bool get isDetailLoading => state.detailedProduct.isLoading;
  bool get isReviewsLoading => state.productReviews.isLoading;
  bool get isSearching => state.isSearching;
  bool get isSearchResultsLoading => state.searchResults.isLoading;
  String? get errorMessage => state.products.message;
  String? get detailErrorMessage => state.detailedProduct.message;
  String? get reviewsErrorMessage => state.productReviews.message;
  String? get searchErrorMessage => state.searchResults.message;
  bool get hasError => state.products.hasError;
  bool get hasDetailError => state.detailedProduct.hasError;
  bool get hasReviewsError => state.productReviews.hasError;
  bool get hasSearchError => state.searchResults.hasError;
  bool get hasMoreData => state.hasMoreData;
  String? get currentSearchQuery => state.searchQuery;
  int? get selectedRatingFilter => state.selectedRatingFilter;
  String? get selectedBrandId => state.selectedBrandId;
  String? get selectedSkinTypeId => state.selectedSkinTypeId;

  /// Get product by ID for QuizProductCard
  Future<Map<String, dynamic>?> getProductById(String productId) async {
    try {
      final response = await _productRepository.getProductById(productId);

      if (response.success && response.data != null) {
        final product = response.data!;
        // Convert DetailedProductModel to Map for compatibility with QuizProductCard
        return {
          'id': product.id,
          'name': product.name,
          'thumbnail': product.thumbnail,
          'description': product.description,
          'price': product.price,
          'discountPercentage': product.discountPercentage,
        };
      } else {
        handleError(
          response.message ?? 'Failed to load product details',
          source: 'getProductById',
          severity: ErrorSeverity.medium,
        );
        return null;
      }
    } catch (e) {
      handleError(e, source: 'getProductById', severity: ErrorSeverity.medium);
      return null;
    }
  }

  /// Load initial products
  Future<void> loadProducts({
    bool refresh = false,
    String? sortBy,
    String? brandId,
    String? skinTypeId,
  }) async {
    if (refresh) {
      updateState(
        state.copyWith(
          products: ViewState.loading(),
          currentPage: 1,
          hasMoreData: true,
          selectedBrandId: brandId,
          selectedSkinTypeId: skinTypeId,
        ),
      );
    } else {
      updateState(
        state.copyWith(
          products: ViewState.loadingMore(state.products.data ?? []),
        ),
      );
    }

    try {
      final response = await _productRepository.getProducts(
        pageNumber: refresh ? 1 : state.currentPage,
        pageSize: state.pageSize,
        sortBy: sortBy,
        brandId: brandId ?? state.selectedBrandId,
        skinTypeId: skinTypeId ?? state.selectedSkinTypeId,
      );

      if (response.success && response.data != null) {
        final paginatedData = response.data!;
        final List<ProductModel> loadedProducts =
            refresh
                ? paginatedData.items
                : [...(state.products.data ?? []), ...paginatedData.items];

        updateState(
          state.copyWith(
            products: ViewState.loaded(loadedProducts),
            currentPage: refresh ? 2 : state.currentPage + 1,
            totalPages: paginatedData.totalPages,
            totalCount: paginatedData.totalCount,
            hasMoreData: loadedProducts.length < paginatedData.totalCount,
            sortOption: sortBy ?? state.sortOption,
          ),
        );
      } else {
        updateState(
          state.copyWith(
            products: ViewState.error(
              response.message ?? 'Failed to load products',
              response.errors,
            ),
          ),
        );

        handleError(
          response.message ?? 'Failed to load products',
          source: 'loadProducts',
          severity: ErrorSeverity.medium,
        );
      }
    } catch (e) {
      handleError(e, source: 'loadProducts', severity: ErrorSeverity.high);
      updateState(
        state.copyWith(
          products: ViewState.error('Failed to load products: ${e.toString()}'),
        ),
      );
    }
  }

  /// Load products by category
  Future<void> loadProductsByCategory({
    required String categoryId,
    bool refresh = false,
    String? sortBy,
    String? brandId,
    String? skinTypeId,
  }) async {
    if (refresh) {
      updateState(
        state.copyWith(
          products: ViewState.loading(),
          currentPage: 1,
          hasMoreData: true,
          selectedCategoryId: categoryId,
          selectedBrandId: brandId,
          selectedSkinTypeId: skinTypeId,
        ),
      );
    } else {
      updateState(
        state.copyWith(
          products: ViewState.loadingMore(state.products.data ?? []),
        ),
      );
    }

    try {
      final response = await _productRepository.getProducts(
        categoryId: categoryId,
        pageNumber: refresh ? 1 : state.currentPage,
        pageSize: state.pageSize,
        sortBy: sortBy,
        brandId: brandId ?? state.selectedBrandId,
        skinTypeId: skinTypeId ?? state.selectedSkinTypeId,
      );

      if (response.success && response.data != null) {
        final paginatedData = response.data!;
        final List<ProductModel> loadedProducts =
            refresh
                ? paginatedData.items
                : [...(state.products.data ?? []), ...paginatedData.items];

        updateState(
          state.copyWith(
            products: ViewState.loaded(loadedProducts),
            currentPage: refresh ? 2 : state.currentPage + 1,
            totalPages: paginatedData.totalPages,
            totalCount: paginatedData.totalCount,
            hasMoreData: loadedProducts.length < paginatedData.totalCount,
            sortOption: sortBy ?? state.sortOption,
          ),
        );
      } else {
        updateState(
          state.copyWith(
            products: ViewState.error(
              response.message ?? 'Failed to load products for category',
              response.errors,
            ),
          ),
        );

        handleError(
          response.message ?? 'Failed to load products for category',
          source: 'loadProductsByCategory',
          severity: ErrorSeverity.medium,
        );
      }
    } catch (e) {
      handleError(
        e,
        source: 'loadProductsByCategory',
        severity: ErrorSeverity.high,
      );
      updateState(
        state.copyWith(
          products: ViewState.error('Failed to load products: ${e.toString()}'),
        ),
      );
    }
  }

  /// Load best sellers
  Future<void> loadBestSellers({bool refresh = false}) async {
    if (refresh) {
      updateState(
        state.copyWith(
          products: ViewState.loading(),
          currentPage: 1,
          hasMoreData: true,
        ),
      );
    } else {
      updateState(
        state.copyWith(
          products: ViewState.loadingMore(state.products.data ?? []),
        ),
      );
    }

    try {
      final response = await _productRepository.getBestSellers(
        pageNumber: refresh ? 1 : state.currentPage,
        pageSize: state.pageSize,
      );

      if (response.success && response.data != null) {
        final paginatedData = response.data!;
        final List<ProductModel> loadedProducts =
            refresh
                ? paginatedData.items
                : [...(state.products.data ?? []), ...paginatedData.items];

        updateState(
          state.copyWith(
            products: ViewState.loaded(loadedProducts),
            currentPage: refresh ? 2 : state.currentPage + 1,
            totalPages: paginatedData.totalPages,
            totalCount: paginatedData.totalCount,
            hasMoreData: loadedProducts.length < paginatedData.totalCount,
          ),
        );
      } else {
        updateState(
          state.copyWith(
            products: ViewState.error(
              response.message ?? 'Failed to load best sellers',
              response.errors,
            ),
          ),
        );

        handleError(
          response.message ?? 'Failed to load best sellers',
          source: 'loadBestSellers',
          severity: ErrorSeverity.medium,
        );
      }
    } catch (e) {
      handleError(e, source: 'loadBestSellers', severity: ErrorSeverity.high);
      updateState(
        state.copyWith(
          products: ViewState.error(
            'Failed to load best sellers: ${e.toString()}',
          ),
        ),
      );
    }
  }

  /// Find product by ID
  ProductModel? findByProdId(String productId) {
    final products = state.products.data;
    if (products == null) return null;

    try {
      return products.firstWhere((element) => element.productId == productId);
    } catch (e) {
      handleError(e, source: 'findByProdId', severity: ErrorSeverity.low);
      return null;
    }
  }

  /// Tìm kiếm sản phẩm theo từ khóa
  Future<void> searchProducts({
    required String searchText,
    String? sortBy,
    String? brandId,
    String? skinTypeId,
    int pageNumber = 1,
    int pageSize = 10,
    bool refresh = false,
  }) async {
    // Nếu đang tìm kiếm, không thực hiện tìm kiếm mới
    if (state.isSearching && !refresh) return;

    // Nếu searchText rỗng, load lại danh sách sản phẩm
    if (searchText.trim().isEmpty) {
      updateState(state.copyWith(searchQuery: null));
      return loadProducts(
        sortBy: sortBy,
        brandId: brandId,
        skinTypeId: skinTypeId,
        refresh: true,
      );
    }

    // Cập nhật trạng thái tìm kiếm
    updateState(
      state.copyWith(
        isSearching: true,
        searchQuery: searchText,
        selectedBrandId: brandId,
        selectedSkinTypeId: skinTypeId,
        searchResults: refresh ? ViewState.loading() : state.searchResults,
      ),
    );

    try {
      // Gọi API tìm kiếm
      final response = await _productRepository.searchProducts(
        searchText: searchText,
        sortBy: sortBy,
        brandId: brandId,
        skinTypeId: skinTypeId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      if (response.success && response.data != null) {
        updateState(
          state.copyWith(
            isSearching: false,
            searchResults: ViewState.loaded(response.data!.items),
            hasMoreData: pageNumber < response.data!.totalPages,
          ),
        );
      } else {
        updateState(
          state.copyWith(
            isSearching: false,
            searchResults: ViewState.error(
              response.message ?? 'Không thể tìm kiếm sản phẩm',
            ),
          ),
        );
        handleError(
          response.message ?? 'Không thể tìm kiếm sản phẩm',
          source: 'searchProducts',
        );
      }
    } catch (e) {
      final errorMsg = 'Lỗi khi tìm kiếm sản phẩm: ${e.toString()}';
      updateState(
        state.copyWith(
          isSearching: false,
          searchResults: ViewState.error(errorMsg),
        ),
      );
      handleError(e, source: 'searchProducts');
    }
  }

  /// Clear search results and reset search state
  void clearSearchResults() {
    updateState(
      state.copyWith(
        searchResults: const ViewState<List<ProductModel>>(),
        searchQuery: null,
        isSearching: false,
      ),
    );
  }

  /// Clear error message
  void clearError() {
    if (state.products.hasError) {
      updateState(
        state.copyWith(
          products: ViewState<List<ProductModel>>.loaded(
            state.products.data ?? [],
          ),
        ),
      );
    }
  }

  /// Clear search error message
  void clearSearchError() {
    if (state.searchResults.hasError) {
      updateState(
        state.copyWith(
          searchResults: ViewState<List<ProductModel>>.loaded(
            state.searchResults.data ?? [],
          ),
        ),
      );
    }
  }

  /// Lấy chi tiết sản phẩm theo ID
  Future<void> getProductDetails(String productId) async {
    updateState(state.copyWith(detailedProduct: ViewState.loading()));

    try {
      final response = await _productRepository.getProductById(productId);

      if (response.success && response.data != null) {
        updateState(
          state.copyWith(detailedProduct: ViewState.loaded(response.data)),
        );
      } else {
        updateState(
          state.copyWith(
            detailedProduct: ViewState.error(
              response.message ?? 'Failed to load product details',
              response.errors,
            ),
          ),
        );

        handleError(
          response.message ?? 'Failed to load product details',
          source: 'getProductDetails',
          severity: ErrorSeverity.medium,
        );
      }
    } catch (e) {
      handleError(e, source: 'getProductDetails', severity: ErrorSeverity.high);
      updateState(
        state.copyWith(
          detailedProduct: ViewState.error(
            'Failed to load product details: ${e.toString()}',
          ),
        ),
      );
    }
  }

  /// Lấy đánh giá sản phẩm
  Future<void> getProductReviews(String productId, {int? ratingFilter}) async {
    updateState(
      state.copyWith(
        productReviews: ViewState.loading(),
        selectedRatingFilter: ratingFilter,
      ),
    );

    try {
      final response = await _productRepository.getProductReviews(
        productId,
        ratingFilter: ratingFilter,
        pageSize: 20,
      );

      if (response.success && response.data != null) {
        updateState(
          state.copyWith(
            productReviews: ViewState.loaded(response.data!.items),
          ),
        );
      } else {
        updateState(
          state.copyWith(
            productReviews: ViewState.error(
              response.message ?? 'Failed to load product reviews',
              response.errors,
            ),
          ),
        );

        handleError(
          response.message ?? 'Failed to load product reviews',
          source: 'getProductReviews',
          severity: ErrorSeverity.medium,
        );
      }
    } catch (e) {
      handleError(e, source: 'getProductReviews', severity: ErrorSeverity.high);
      updateState(
        state.copyWith(
          productReviews: ViewState.error(
            'Failed to load product reviews: ${e.toString()}',
          ),
        ),
      );
    }
  }

  /// Gửi đánh giá sản phẩm
  Future<bool> submitProductReview({
    required String productId,
    required int rating,
    required String comment,
    String? title,
    List<String>? imageUrls,
  }) async {
    try {
      final response = await _productRepository.submitProductReview(
        productId: productId,
        rating: rating,
        comment: comment,
        title: title,
        imageUrls: imageUrls,
      );

      if (response.success) {
        // Refresh reviews after submission
        await getProductReviews(
          productId,
          ratingFilter: state.selectedRatingFilter,
        );
        return true;
      } else {
        handleError(
          response.message ?? 'Failed to submit review',
          source: 'submitProductReview',
          severity: ErrorSeverity.medium,
        );
        return false;
      }
    } catch (e) {
      handleError(
        e,
        source: 'submitProductReview',
        severity: ErrorSeverity.high,
      );
      return false;
    }
  }

  /// Reset trạng thái tìm kiếm về mặc định
  void resetSearch() {
    // Đảm bảo xóa triệt để searchQuery và kết quả tìm kiếm
    updateState(
      state.copyWith(
        isSearching: false,
        searchQuery: null,
        searchResults: ViewState.loaded([]),
        // Ensure search results are fully reset but keep other filters
        // selected in the UI
      ),
    );

    // Double check if the searchQuery is actually null
    if (state.searchQuery != null) {
      // Force another update to ensure searchQuery is null
      updateState(
        ProductsState(
          // Preserve other state properties
          products: state.products,
          detailedProduct: state.detailedProduct,
          productReviews: state.productReviews,
          selectedCategoryId: state.selectedCategoryId,
          selectedBrandId: state.selectedBrandId,
          selectedSkinTypeId: state.selectedSkinTypeId,
          sortOption: state.sortOption,
          currentPage: state.currentPage,
          pageSize: state.pageSize,
          totalPages: state.totalPages,
          totalCount: state.totalCount,
          hasMoreData: state.hasMoreData,
          selectedRatingFilter: state.selectedRatingFilter,
          // Explicitly set search properties to initial values
          searchQuery: null,
          searchResults: ViewState.loaded([]),
          isSearching: false,
        ),
      );
    }

    // Log để debug
    debugPrint(
      "EnhancedProductsViewModel: Search state has been reset completely. currentSearchQuery=${state.searchQuery}",
    );
  }
}
