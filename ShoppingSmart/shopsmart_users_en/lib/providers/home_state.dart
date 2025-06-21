import '../models/blog_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/view_state.dart';

/// State cho màn hình Home
class HomeState {
  /// Danh sách sản phẩm mới nhất
  final ViewState<List<ProductModel>> latestProducts;

  /// Danh sách sản phẩm bán chạy
  final ViewState<List<ProductModel>> bestSellers;

  /// Danh sách danh mục
  final ViewState<List<CategoryModel>> categories;

  /// Danh sách bài viết blog
  final ViewState<List<BlogModel>> blogs;

  /// Chi tiết bài viết blog
  final ViewState<DetailedBlogModel?> detailedBlog;

  /// Đang tải banner
  final bool isLoadingBanner;

  /// Thông báo lỗi
  final String? errorMessage;

  /// Constructor
  const HomeState({
    this.latestProducts = const ViewState<List<ProductModel>>(),
    this.bestSellers = const ViewState<List<ProductModel>>(),
    this.categories = const ViewState<List<CategoryModel>>(),
    this.blogs = const ViewState<List<BlogModel>>(),
    this.detailedBlog = const ViewState<DetailedBlogModel?>(),
    this.isLoadingBanner = false,
    this.errorMessage,
  });

  /// Tạo bản sao với các giá trị mới
  HomeState copyWith({
    ViewState<List<ProductModel>>? latestProducts,
    ViewState<List<ProductModel>>? bestSellers,
    ViewState<List<CategoryModel>>? categories,
    ViewState<List<BlogModel>>? blogs,
    ViewState<DetailedBlogModel?>? detailedBlog,
    bool? isLoadingBanner,
    String? errorMessage,
  }) {
    return HomeState(
      latestProducts: latestProducts ?? this.latestProducts,
      bestSellers: bestSellers ?? this.bestSellers,
      categories: categories ?? this.categories,
      blogs: blogs ?? this.blogs,
      detailedBlog: detailedBlog ?? this.detailedBlog,
      isLoadingBanner: isLoadingBanner ?? this.isLoadingBanner,
      errorMessage: errorMessage,
    );
  }
}
