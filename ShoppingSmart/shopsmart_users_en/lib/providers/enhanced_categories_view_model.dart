import '../models/category_model.dart';
import '../models/view_state.dart';
import '../repositories/category_repository.dart';
import '../services/error_handling_service.dart';
import '../services/service_locator.dart';
import 'base_view_model.dart';
import 'categories_state.dart';

/// ViewModel cải tiến cho Categories, kế thừa từ BaseViewModel
class EnhancedCategoriesViewModel extends BaseViewModel<CategoriesState> {
  final CategoryRepository _categoryRepository;

  /// Constructor với dependency injection cho repository
  EnhancedCategoriesViewModel({CategoryRepository? categoryRepository})
    : _categoryRepository = categoryRepository ?? sl<CategoryRepository>(),
      super(const CategoriesState());

  /// Getters tiện ích
  List<CategoryModel> get categories => state.categories.data ?? [];
  bool get isLoading => state.categories.isLoading;
  String? get errorMessage => state.errorMessage;
  bool get hasError => state.errorMessage != null;
  String? get selectedCategoryId => state.selectedCategoryId;
  CategoryModel? get selectedCategory => state.selectedCategory;
  List<CategoryModel> get mainCategories => state.mainCategories;
  List<CategoryModel> get allCategoriesFlat => state.allCategoriesFlat;
  bool get isEmpty => categories.isEmpty;

  /// Tải danh mục từ server
  Future<void> loadCategories() async {
    updateState(
      state.copyWith(categories: ViewState.loading(), errorMessage: null),
    );

    try {
      final response = await _categoryRepository.getCategories(
        pageNumber: 1,
        pageSize: 50, // Lấy tất cả danh mục
      );

      if (response.success && response.data != null) {
        updateState(
          state.copyWith(
            categories: ViewState.loaded(response.data!.items),
            errorMessage: null,
          ),
        );
      } else {
        updateState(
          state.copyWith(
            categories: ViewState.error(
              response.message ?? 'Failed to load categories',
              response.errors,
            ),
            errorMessage: response.message,
          ),
        );
        handleError(
          response.message ?? 'Failed to load categories',
          source: 'loadCategories',
          severity: ErrorSeverity.medium,
        );
      }
    } catch (e) {
      final errorMsg = 'Lỗi khi tải danh mục: ${e.toString()}';
      updateState(
        state.copyWith(
          categories: ViewState.error(errorMsg),
          errorMessage: errorMsg,
        ),
      );
      handleError(e, source: 'loadCategories', severity: ErrorSeverity.medium);
    }
  }

  /// Chọn một danh mục
  void selectCategory(String? categoryId) {
    updateState(state.copyWith(selectedCategoryId: categoryId));
  }

  /// Xóa danh mục được chọn
  void clearSelection() {
    updateState(state.clearSelection());
  }

  /// Xóa lỗi
  void clearError() {
    if (state.errorMessage != null) {
      updateState(state.clearError());
    }
  }

  /// Làm mới danh mục
  Future<void> refreshCategories() async {
    await loadCategories();
  }

  /// Lấy tên danh mục được chọn
  String getSelectedCategoryName() {
    return state.getSelectedCategoryName();
  }

  /// Tìm danh mục theo tên
  CategoryModel? findCategoryByName(String categoryName) {
    try {
      return categories.firstWhere(
        (category) =>
            category.categoryName.toLowerCase() == categoryName.toLowerCase(),
        orElse:
            () => allCategoriesFlat.firstWhere(
              (category) =>
                  category.categoryName.toLowerCase() ==
                  categoryName.toLowerCase(),
              orElse: () => throw Exception('Category not found'),
            ),
      );
    } catch (e) {
      handleError(e, source: 'findCategoryByName', severity: ErrorSeverity.low);
      return null;
    }
  }

  /// Tìm danh mục theo ID
  CategoryModel? findCategoryById(String categoryId) {
    try {
      return categories.firstWhere(
        (category) => category.id == categoryId,
        orElse: () => throw Exception('Category not found'),
      );
    } catch (e) {
      handleError(e, source: 'findCategoryById', severity: ErrorSeverity.low);
      return null;
    }
  }
}
