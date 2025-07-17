import '../models/detailed_product_model.dart';
import '../models/product_model.dart';
import '../models/review_models.dart';
import '../models/view_state.dart';
import '../models/product_image_model.dart';

/// State class for Products screen
class ProductsState {
  final ViewState<List<ProductModel>> products;
  final ViewState<DetailedProductModel> detailedProduct;
  final ViewState<List<ReviewModel>> productReviews;
  final ViewState<List<ProductModel>> searchResults;
  final ViewState<List<ProductImage>> productImages;
  final bool isSearching;
  final int currentPage;
  final int pageSize;
  final int totalPages;
  final int totalCount;
  final bool hasMoreData;
  final String? searchQuery;
  final int? selectedRatingFilter;
  final String? selectedBrandId;
  final String? selectedSkinTypeId;
  final String? selectedCategoryId;
  final String? sortOption;

  const ProductsState({
    this.products = const ViewState<List<ProductModel>>(),
    this.detailedProduct = const ViewState<DetailedProductModel>(),
    this.productReviews = const ViewState<List<ReviewModel>>(),
    this.searchResults = const ViewState<List<ProductModel>>(),
    this.productImages = const ViewState<List<ProductImage>>(),
    this.isSearching = false,
    this.currentPage = 1,
    this.pageSize = 10,
    this.totalPages = 0,
    this.totalCount = 0,
    this.hasMoreData = true,
    this.searchQuery,
    this.selectedRatingFilter,
    this.selectedBrandId,
    this.selectedSkinTypeId,
    this.selectedCategoryId,
    this.sortOption,
  });

  /// Create a copy of this state with some properties changed
  ProductsState copyWith({
    ViewState<List<ProductModel>>? products,
    ViewState<DetailedProductModel>? detailedProduct,
    ViewState<List<ReviewModel>>? productReviews,
    ViewState<List<ProductModel>>? searchResults,
    ViewState<List<ProductImage>>? productImages,
    bool? isSearching,
    int? currentPage,
    int? pageSize,
    int? totalPages,
    int? totalCount,
    bool? hasMoreData,
    String? searchQuery,
    int? selectedRatingFilter,
    String? selectedBrandId,
    String? selectedSkinTypeId,
    String? selectedCategoryId,
    String? sortOption,
  }) {
    return ProductsState(
      products: products ?? this.products,
      detailedProduct: detailedProduct ?? this.detailedProduct,
      productReviews: productReviews ?? this.productReviews,
      searchResults: searchResults ?? this.searchResults,
      productImages: productImages ?? this.productImages,
      isSearching: isSearching ?? this.isSearching,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedRatingFilter: selectedRatingFilter ?? this.selectedRatingFilter,
      selectedBrandId: selectedBrandId ?? this.selectedBrandId,
      selectedSkinTypeId: selectedSkinTypeId ?? this.selectedSkinTypeId,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}
