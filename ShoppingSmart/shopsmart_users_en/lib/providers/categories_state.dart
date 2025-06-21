import '../models/category_model.dart';
import '../models/view_state.dart';

/// Lớp quản lý state cho danh mục sản phẩm
class CategoriesState {
  /// Trạng thái danh sách danh mục với ViewState để kiểm soát quá trình loading
  final ViewState<List<CategoryModel>> categories;

  /// ID của danh mục được chọn
  final String? selectedCategoryId;

  /// Thông báo lỗi khi thực hiện các thao tác trên danh mục
  final String? errorMessage;

  /// Constructor với giá trị mặc định
  const CategoriesState({
    this.categories = const ViewState<List<CategoryModel>>(),
    this.selectedCategoryId,
    this.errorMessage,
  });

  /// Phương thức tạo state mới với một số thuộc tính được thay đổi
  CategoriesState copyWith({
    ViewState<List<CategoryModel>>? categories,
    String? selectedCategoryId,
    String? errorMessage,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Phương thức xóa thông báo lỗi
  CategoriesState clearError() {
    return copyWith(errorMessage: null);
  }

  /// Phương thức xóa danh mục được chọn
  CategoriesState clearSelection() {
    return copyWith(selectedCategoryId: null);
  }

  /// Lấy danh mục được chọn
  CategoryModel? get selectedCategory {
    if (selectedCategoryId == null || categories.data == null) return null;

    // Tìm danh mục theo ID (bao gồm cả danh mục con)
    for (var category in categories.data!) {
      final found = _searchInCategory(category, selectedCategoryId!);
      if (found != null) return found;
    }

    return null;
  }

  /// Lấy tên danh mục được chọn
  String getSelectedCategoryName() {
    final category = selectedCategory;
    if (selectedCategoryId == null) return 'All';
    return category?.categoryName ?? 'All';
  }

  /// Tìm danh mục theo ID (bao gồm cả danh mục con)
  CategoryModel? _searchInCategory(CategoryModel category, String categoryId) {
    if (category.id == categoryId) return category;

    for (var child in category.children) {
      final found = _searchInCategory(child, categoryId);
      if (found != null) return found;
    }

    return null;
  }

  /// Lấy danh sách các danh mục chính (cấp 0)
  List<CategoryModel> get mainCategories => categories.data ?? [];

  /// Lấy danh sách phẳng của tất cả các danh mục (bao gồm cả danh mục con)
  List<CategoryModel> get allCategoriesFlat {
    final List<CategoryModel> allCategories = [];
    final List<CategoryModel>? data = categories.data;

    if (data != null) {
      for (var category in data) {
        allCategories.addAll(category.getAllCategories());
      }
    }

    return allCategories;
  }
}
