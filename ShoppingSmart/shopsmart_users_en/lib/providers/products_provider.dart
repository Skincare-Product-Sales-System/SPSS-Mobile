import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductsProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  // Pagination properties
  int _currentPage = 1;
  final int _pageSize = 10;
  int _totalPages = 0;
  int _totalCount = 0;
  bool _hasMoreData = true;

  // Getters
  List<ProductModel> get getProducts => _products;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalCount => _totalCount;
  bool get hasMoreData => _hasMoreData;

  // Load initial products
  Future<void> loadProducts({bool refresh = false, String? sortBy}) async {
    if (refresh) {
      _products.clear();
      _currentPage = 1;
      _hasMoreData = true;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.getProducts(
        pageNumber: _currentPage,
        pageSize: _pageSize,
        sortBy: sortBy,
      );

      if (response.success && response.data != null) {
        final paginatedData = response.data!;
        debugPrint(
          'Loading products - Total items: ${paginatedData.items.length}',
        );
        for (var product in paginatedData.items) {
          debugPrint(
            'Product ${product.id} - Items count: ${product.productItems.length}',
          );
        }

        if (refresh) {
          _products = paginatedData.items;
        } else {
          _products.addAll(paginatedData.items);
        }

        _totalPages = paginatedData.totalPages;
        _totalCount = paginatedData.totalCount;
        _hasMoreData = _currentPage < _totalPages;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'Failed to load products: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load latest products for arrival section
  Future<void> loadLatestProducts({bool refresh = false}) async {
    if (refresh) {
      _products.clear();
      _currentPage = 1;
      _hasMoreData = true;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.getBestSellers(
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      if (response.success && response.data != null) {
        final paginatedData = response.data!;

        if (refresh) {
          _products = paginatedData.items;
        } else {
          _products.addAll(paginatedData.items);
        }

        _totalPages = paginatedData.totalPages;
        _totalCount = paginatedData.totalCount;
        _hasMoreData = _currentPage < _totalPages;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'Failed to load best sellers: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load products by category
  Future<void> loadProductsByCategory({
    required String categoryId,
    bool refresh = false,
    String? sortBy,
  }) async {
    if (refresh) {
      _products.clear();
      _currentPage = 1;
      _hasMoreData = true;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.getProducts(
        categoryId: categoryId,
        pageNumber: _currentPage,
        pageSize: _pageSize,
        sortBy: sortBy,
      );

      if (response.success && response.data != null) {
        final paginatedData = response.data!;

        if (refresh) {
          _products = paginatedData.items;
        } else {
          _products.addAll(paginatedData.items);
        }

        _totalPages = paginatedData.totalPages;
        _totalCount = paginatedData.totalCount;
        _hasMoreData = _currentPage < _totalPages;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'Failed to load products by category: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more products for pagination
  Future<void> loadMoreProducts() async {
    if (_isLoadingMore || !_hasMoreData) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final response = await ApiService.getProducts(
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      if (response.success && response.data != null) {
        final paginatedData = response.data!;
        _products.addAll(paginatedData.items);
        _hasMoreData = _currentPage < paginatedData.totalPages;
      } else {
        _currentPage--; // Revert page number on error
        _errorMessage = response.message;
      }
    } catch (e) {
      _currentPage--; // Revert page number on error
      _errorMessage = 'Failed to load more products: ${e.toString()}';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Load more products by category for pagination
  Future<void> loadMoreProductsByCategory(String categoryId) async {
    if (_isLoadingMore || !_hasMoreData) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final response = await ApiService.getProducts(
        categoryId: categoryId,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      if (response.success && response.data != null) {
        final paginatedData = response.data!;
        _products.addAll(paginatedData.items);
        _hasMoreData = _currentPage < paginatedData.totalPages;
      } else {
        _currentPage--; // Revert page number on error
        _errorMessage = response.message;
      }
    } catch (e) {
      _currentPage--; // Revert page number on error
      _errorMessage =
          'Failed to load more products by category: ${e.toString()}';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Find product by ID
  ProductModel? findByProdId(String productId) {
    try {
      return _products.firstWhere((element) => element.productId == productId);
    } catch (e) {
      return null;
    }
  }

  // Search products
  Future<List<ProductModel>> searchProducts({
    required String searchText,
  }) async {
    if (searchText.trim().isEmpty) {
      return _products;
    }

    try {
      final response = await ApiService.searchProducts(
        searchQuery: searchText,
        pageNumber: 1,
        pageSize: 50, // Get more results for search
      );

      if (response.success && response.data != null) {
        return response.data!.items;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Search error: ${e.toString()}');
      return [];
    }
  }

  // Local search in loaded products (for offline search)
  List<ProductModel> searchQuery({
    required String searchText,
    required List<ProductModel> passedList,
  }) {
    if (searchText.trim().isEmpty) {
      return passedList;
    }

    List<ProductModel> searchList =
        passedList
            .where(
              (element) => element.productTitle.toLowerCase().contains(
                searchText.toLowerCase(),
              ),
            )
            .toList();
    return searchList;
  }

  // Find products by category (mock implementation since API doesn't have categories)
  List<ProductModel> findByCategory({required String categoryName}) {
    // Since the API doesn't have categories, we'll return all products
    // You can modify this when you add category support to your API
    return _products;
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh products
  Future<void> refreshProducts() async {
    await loadProducts(refresh: true);
  }

  // Load best seller products
  Future<void> loadBestSellers({bool refresh = false}) async {
    if (refresh) {
      _products.clear();
      _currentPage = 1;
      _hasMoreData = true;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.getBestSellers(
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      if (response.success && response.data != null) {
        final paginatedData = response.data!;

        if (refresh) {
          _products = paginatedData.items;
        } else {
          _products.addAll(paginatedData.items);
        }

        _totalPages = paginatedData.totalPages;
        _totalCount = paginatedData.totalCount;
        _hasMoreData = _currentPage < _totalPages;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'Failed to load best sellers: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
