import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../repositories/category_repository.dart';

class CategoriesProvider with ChangeNotifier {
  final CategoryRepository _categoryRepository = CategoryRepository();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCategoryId;

  // Getters
  List<CategoryModel> get getCategories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCategoryId => _selectedCategoryId;

  // Get selected category
  CategoryModel? get selectedCategory {
    if (_selectedCategoryId == null) return null;
    return _findCategoryById(_selectedCategoryId!);
  }

  // Get selected category name
  String getSelectedCategoryName() {
    final category = selectedCategory;
    if (_selectedCategoryId == null) return 'All';
    return category?.categoryName ?? 'All';
  }

  // Find category by ID (including nested categories)
  CategoryModel? _findCategoryById(String categoryId) {
    for (var category in _categories) {
      var found = _searchInCategory(category, categoryId);
      if (found != null) return found;
    }
    return null;
  }

  CategoryModel? _searchInCategory(CategoryModel category, String categoryId) {
    if (category.id == categoryId) return category;

    for (var child in category.children) {
      var found = _searchInCategory(child, categoryId);
      if (found != null) return found;
    }
    return null;
  }

  // Load categories from API
  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _categoryRepository.getCategories(
        pageNumber: 1,
        pageSize: 50, // Get all categories
      );

      if (response.success && response.data != null) {
        _categories = response.data!.items;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'Failed to load categories: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select a category
  void selectCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  // Clear selected category
  void clearSelection() {
    _selectedCategoryId = null;
    notifyListeners();
  }

  // Get all main categories (level 0)
  List<CategoryModel> get getMainCategories {
    return _categories;
  }

  // Get flat list of all categories (including children)
  List<CategoryModel> get getAllCategoriesFlat {
    List<CategoryModel> allCategories = [];
    for (var category in _categories) {
      allCategories.addAll(category.getAllCategories());
    }
    return allCategories;
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh categories
  Future<void> refreshCategories() async {
    await loadCategories();
  }
}
