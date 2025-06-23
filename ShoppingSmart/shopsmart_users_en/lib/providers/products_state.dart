import '../models/detailed_product_model.dart';
import '../models/product_model.dart';
import '../models/review_models.dart';
import '../models/view_state.dart';

/// State class for Products screen
class ProductsState {
  final ViewState<List<ProductModel>> products;
  final ViewState<List<ProductModel>> searchResults;
  final ViewState<DetailedProductModel?> detailedProduct;
  final ViewState<List<ReviewModel>> productReviews;
  final String? selectedCategoryId;
  final String? selectedBrandId;
  final String? selectedSkinTypeId;
  final String? sortOption;
  final String? searchQuery;
  final bool isSearching;
  final int currentPage;
  final int pageSize;
  final int totalPages;
  final int totalCount;
  final bool hasMoreData;
  final int? selectedRatingFilter;

  const ProductsState({
    this.products = const ViewState<List<ProductModel>>(),
    this.searchResults = const ViewState<List<ProductModel>>(),
    this.detailedProduct = const ViewState<DetailedProductModel?>(),
    this.productReviews = const ViewState<List<ReviewModel>>(),
    this.selectedCategoryId,
    this.selectedBrandId,
    this.selectedSkinTypeId,
    this.sortOption,
    this.searchQuery,
    this.isSearching = false,
    this.currentPage = 1,
    this.pageSize = 10,
    this.totalPages = 1,
    this.totalCount = 0,
    this.hasMoreData = false,
    this.selectedRatingFilter,
  });

  /// Create a copy of this state with some properties changed
  ProductsState copyWith({
    ViewState<List<ProductModel>>? products,
    ViewState<List<ProductModel>>? searchResults,
    ViewState<DetailedProductModel?>? detailedProduct,
    ViewState<List<ReviewModel>>? productReviews,
    String? selectedCategoryId,
    String? selectedBrandId,
    String? selectedSkinTypeId,
    String? sortOption,
    String? searchQuery,
    bool? isSearching,
    int? currentPage,
    int? pageSize,
    int? totalPages,
    int? totalCount,
    bool? hasMoreData,
    int? selectedRatingFilter,
  }) {
    return ProductsState(
      products: products ?? this.products,
      searchResults: searchResults ?? this.searchResults,
      detailedProduct: detailedProduct ?? this.detailedProduct,
      productReviews: productReviews ?? this.productReviews,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedBrandId: selectedBrandId ?? this.selectedBrandId,
      selectedSkinTypeId: selectedSkinTypeId ?? this.selectedSkinTypeId,
      sortOption: sortOption ?? this.sortOption,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      selectedRatingFilter: selectedRatingFilter ?? this.selectedRatingFilter,
    );
  }
}
