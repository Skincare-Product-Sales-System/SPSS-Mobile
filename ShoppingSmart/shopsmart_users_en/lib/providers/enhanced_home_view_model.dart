import '../models/blog_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/view_state.dart';
import '../repositories/blog_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/product_repository.dart';
import '../services/service_locator.dart';
import 'base_view_model.dart';
import 'home_state.dart';

/// ViewModel cải tiến cho Home, kế thừa từ BaseViewModel
class EnhancedHomeViewModel extends BaseViewModel<HomeState> {
  // Repositories
  final ProductRepository _productRepository;
  final CategoryRepository _categoryRepository;
  final BlogRepository _blogRepository;

  /// Constructor với dependency injection cho repositories
  EnhancedHomeViewModel({
    ProductRepository? productRepository,
    CategoryRepository? categoryRepository,
    BlogRepository? blogRepository,
  }) : _productRepository = productRepository ?? sl<ProductRepository>(),
       _categoryRepository = categoryRepository ?? sl<CategoryRepository>(),
       _blogRepository = blogRepository ?? sl<BlogRepository>(),
       super(const HomeState());

  /// Getters tiện ích
  List<ProductModel> get latestProducts => state.latestProducts.data ?? [];
  List<ProductModel> get bestSellers => state.bestSellers.data ?? [];
  List<CategoryModel> get categories => state.categories.data ?? [];
  List<BlogModel> get blogs => state.blogs.data ?? [];
  DetailedBlogModel? get detailedBlog => state.detailedBlog.data;

  bool get isLoadingLatestProducts => state.latestProducts.isLoading;
  bool get isLoadingBestSellers => state.bestSellers.isLoading;
  bool get isLoadingCategories => state.categories.isLoading;
  bool get isLoadingBlogs => state.blogs.isLoading;
  bool get isBlogDetailLoading => state.detailedBlog.isLoading;
  bool get isLoadingBanner => state.isLoadingBanner;

  bool get hasError => state.errorMessage != null;
  String? get errorMessage => state.errorMessage;
  String? get blogDetailError =>
      state.detailedBlog.hasError ? state.detailedBlog.message : null;

  bool get isLoading =>
      isLoadingLatestProducts ||
      isLoadingBestSellers ||
      isLoadingCategories ||
      isLoadingBlogs;

  /// Khởi tạo dữ liệu cho màn hình Home
  Future<void> initializeHomeData() async {
    await Future.wait([
      loadCategories(),
      loadBestSellers(),
      loadLatestProducts(),
      loadBlogs(),
    ]);
  }

  /// Làm mới toàn bộ dữ liệu
  Future<void> refreshAllData() async {
    await Future.wait([
      loadCategories(refresh: true),
      loadBestSellers(refresh: true),
      loadLatestProducts(refresh: true),
      loadBlogs(refresh: true),
    ]);
  }

  /// Tải danh sách danh mục
  Future<void> loadCategories({bool refresh = false}) async {
    if (refresh) {
      updateState(
        state.copyWith(categories: ViewState.loading(), errorMessage: null),
      );
    } else if (state.categories.data != null &&
        state.categories.data!.isNotEmpty) {
      return; // Đã có dữ liệu, không cần tải lại
    } else {
      updateState(
        state.copyWith(categories: ViewState.loading(), errorMessage: null),
      );
    }

    try {
      final response = await _categoryRepository.getCategories(
        pageNumber: 1,
        pageSize: 50,
      );

      if (response.success && response.data != null) {
        updateState(
          state.copyWith(categories: ViewState.loaded(response.data!.items)),
        );
      } else {
        updateState(
          state.copyWith(
            categories: ViewState.error(
              response.message ?? 'Không thể tải danh mục',
            ),
          ),
        );
      }
    } catch (error) {
      handleError(error, source: 'loadCategories');
      updateState(
        state.copyWith(
          categories: ViewState.error('Đã xảy ra lỗi khi tải danh mục'),
        ),
      );
    }
  }

  /// Tải danh sách sản phẩm bán chạy
  Future<void> loadBestSellers({bool refresh = false}) async {
    if (refresh) {
      updateState(
        state.copyWith(bestSellers: ViewState.loading(), errorMessage: null),
      );
    } else if (state.bestSellers.data != null &&
        state.bestSellers.data!.isNotEmpty) {
      return; // Đã có dữ liệu, không cần tải lại
    } else {
      updateState(
        state.copyWith(bestSellers: ViewState.loading(), errorMessage: null),
      );
    }

    try {
      final response = await _productRepository.getBestSellers(
        pageNumber: 1,
        pageSize: 10,
      );

      if (response.success && response.data != null) {
        updateState(
          state.copyWith(bestSellers: ViewState.loaded(response.data!.items)),
        );
      } else {
        updateState(
          state.copyWith(
            bestSellers: ViewState.error(
              response.message ?? 'Không thể tải sản phẩm bán chạy',
            ),
            errorMessage: response.message,
          ),
        );
      }
    } catch (error) {
      handleError(error, source: 'loadBestSellers');
      updateState(
        state.copyWith(
          bestSellers: ViewState.error(
            'Đã xảy ra lỗi khi tải sản phẩm bán chạy',
          ),
          errorMessage: 'Đã xảy ra lỗi khi tải sản phẩm bán chạy',
        ),
      );
    }
  }

  /// Tải danh sách sản phẩm mới nhất
  Future<void> loadLatestProducts({bool refresh = false}) async {
    if (refresh) {
      updateState(
        state.copyWith(latestProducts: ViewState.loading(), errorMessage: null),
      );
    } else if (state.latestProducts.data != null &&
        state.latestProducts.data!.isNotEmpty) {
      return; // Đã có dữ liệu, không cần tải lại
    } else {
      updateState(
        state.copyWith(latestProducts: ViewState.loading(), errorMessage: null),
      );
    }

    try {
      final response = await _productRepository.getLatestProducts(
        pageNumber: 1,
        pageSize: 10,
      );

      if (response.success && response.data != null) {
        updateState(
          state.copyWith(
            latestProducts: ViewState.loaded(response.data!.items),
          ),
        );
      } else {
        updateState(
          state.copyWith(
            latestProducts: ViewState.error(
              response.message ?? 'Không thể tải sản phẩm mới nhất',
            ),
          ),
        );
      }
    } catch (error) {
      handleError(error, source: 'loadLatestProducts');
      updateState(
        state.copyWith(
          latestProducts: ViewState.error(
            'Đã xảy ra lỗi khi tải sản phẩm mới nhất',
          ),
        ),
      );
    }
  }

  /// Tải danh sách bài viết blog
  Future<void> loadBlogs({bool refresh = false}) async {
    if (refresh) {
      updateState(
        state.copyWith(blogs: ViewState.loading(), errorMessage: null),
      );
    } else if (state.blogs.data != null && state.blogs.data!.isNotEmpty) {
      return; // Đã có dữ liệu, không cần tải lại
    } else {
      updateState(
        state.copyWith(blogs: ViewState.loading(), errorMessage: null),
      );
    }

    try {
      final response = await _blogRepository.getBlogs(
        pageNumber: 1,
        pageSize: 10,
      );

      if (response.success && response.data != null) {
        updateState(
          state.copyWith(blogs: ViewState.loaded(response.data!.items)),
        );
      } else {
        updateState(
          state.copyWith(
            blogs: ViewState.error(
              response.message ?? 'Không thể tải bài viết blog',
            ),
          ),
        );
      }
    } catch (error) {
      handleError(error, source: 'loadBlogs');
      updateState(
        state.copyWith(
          blogs: ViewState.error('Đã xảy ra lỗi khi tải bài viết blog'),
        ),
      );
    }
  }

  /// Tải chi tiết bài viết blog
  Future<void> loadBlogDetails(String blogId) async {
    updateState(state.copyWith(detailedBlog: ViewState.loading()));

    try {
      final response = await _blogRepository.getBlogById(blogId);

      if (response.success && response.data != null) {
        updateState(
          state.copyWith(detailedBlog: ViewState.loaded(response.data)),
        );
      } else {
        updateState(
          state.copyWith(
            detailedBlog: ViewState.error(
              response.message ?? 'Không thể tải chi tiết bài viết',
            ),
          ),
        );
      }
    } catch (error) {
      handleError(error, source: 'loadBlogDetails');
      updateState(
        state.copyWith(
          detailedBlog: ViewState.error(
            'Đã xảy ra lỗi khi tải chi tiết bài viết',
          ),
        ),
      );
    }
  }

  /// Kiểm tra kết nối API
  Future<bool> testApiConnection() async {
    try {
      final response = await _productRepository.getProducts(
        pageNumber: 1,
        pageSize: 1,
      );
      return response.success;
    } catch (error) {
      handleError(error, source: 'testApiConnection');
      return false;
    }
  }
}
