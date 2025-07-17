import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/view_state.dart';
import '../repositories/product_repository.dart';
import 'products_state.dart';

/// Enhanced ProductsProvider that uses ViewState to separate UI state from business logic
class EnhancedProductsProvider with ChangeNotifier {
  final ProductRepository _productRepository;
  ProductsState _state = const ProductsState();

  // Constructor with dependency injection for better testability
  EnhancedProductsProvider({ProductRepository? productRepository})
    : _productRepository = productRepository ?? ProductRepository();

  // Getter for the current state
  ProductsState get state => _state;

  // Getters for commonly used properties
  List<ProductModel> get products => _state.products.data ?? [];
  bool get isLoading => _state.products.isLoading;
  bool get isLoadingMore => _state.products.isLoadingMore;
  String? get errorMessage => _state.products.message;
  bool get hasError => _state.products.hasError;

  // Load initial products
  Future<void> loadProducts({bool refresh = false, String? sortBy}) async {
    if (refresh) {
      _updateState(
        _state.copyWith(
          products: ViewState.loading(),
          currentPage: 1,
          hasMoreData: true,
        ),
      );
    } else {
      _updateState(
        _state.copyWith(
          products: ViewState.loadingMore(_state.products.data ?? []),
        ),
      );
    }

    try {
      final response = await _productRepository.getProducts(
        pageNumber: refresh ? 1 : _state.currentPage,
        pageSize: _state.pageSize,
        sortBy: sortBy,
      );

      if (response.success && response.data != null) {
        final paginatedData = response.data!;
        final List<ProductModel> loadedProducts =
            refresh
                ? paginatedData.items
                : [...(_state.products.data ?? []), ...paginatedData.items];

        _updateState(
          _state.copyWith(
            products: ViewState.loaded(loadedProducts),
            currentPage: refresh ? 2 : _state.currentPage + 1,
            hasMoreData: loadedProducts.length < paginatedData.totalCount,
            sortOption: sortBy,
          ),
        );
      } else {
        _updateState(
          _state.copyWith(
            products: ViewState.error(
              response.message ?? 'Failed to load products',
            ),
          ),
        );
      }
    } catch (e) {
      _updateState(
        _state.copyWith(
          products: ViewState.error('Failed to load products: ${e.toString()}'),
        ),
      );
    }
  }

  // Load products by category
  Future<void> loadProductsByCategory({
    required String categoryId,
    bool refresh = false,
  }) async {
    if (refresh) {
      _updateState(
        _state.copyWith(
          products: ViewState.loading(),
          currentPage: 1,
          hasMoreData: true,
          selectedCategoryId: categoryId,
        ),
      );
    } else {
      _updateState(
        _state.copyWith(
          products: ViewState.loadingMore(_state.products.data ?? []),
        ),
      );
    }

    try {
      final response = await _productRepository.getProductsByCategory(
        categoryId: categoryId,
        pageNumber: refresh ? 1 : _state.currentPage,
        pageSize: _state.pageSize,
      );

      if (response.success && response.data != null) {
        final paginatedData = response.data!;
        final List<ProductModel> loadedProducts =
            refresh
                ? paginatedData.items
                : [...(_state.products.data ?? []), ...paginatedData.items];

        _updateState(
          _state.copyWith(
            products: ViewState.loaded(loadedProducts),
            currentPage: refresh ? 2 : _state.currentPage + 1,
            hasMoreData: loadedProducts.length < paginatedData.totalCount,
          ),
        );
      } else {
        _updateState(
          _state.copyWith(
            products: ViewState.error(
              response.message ?? 'Failed to load products for category',
            ),
          ),
        );
      }
    } catch (e) {
      _updateState(
        _state.copyWith(
          products: ViewState.error('Failed to load products: ${e.toString()}'),
        ),
      );
    }
  }

  // Load best sellers
  Future<void> loadBestSellers({bool refresh = false}) async {
    if (refresh) {
      _updateState(
        _state.copyWith(
          products: ViewState.loading(),
          currentPage: 1,
          hasMoreData: true,
        ),
      );
    } else {
      _updateState(
        _state.copyWith(
          products: ViewState.loadingMore(_state.products.data ?? []),
        ),
      );
    }

    try {
      final response = await _productRepository.getBestSellers(
        pageNumber: refresh ? 1 : _state.currentPage,
        pageSize: _state.pageSize,
      );

      if (response.success && response.data != null) {
        final paginatedData = response.data!;
        final List<ProductModel> loadedProducts =
            refresh
                ? paginatedData.items
                : [...(_state.products.data ?? []), ...paginatedData.items];

        _updateState(
          _state.copyWith(
            products: ViewState.loaded(loadedProducts),
            currentPage: refresh ? 2 : _state.currentPage + 1,
            hasMoreData: loadedProducts.length < paginatedData.totalCount,
          ),
        );
      } else {
        _updateState(
          _state.copyWith(
            products: ViewState.error(
              response.message ?? 'Failed to load best sellers',
            ),
          ),
        );
      }
    } catch (e) {
      _updateState(
        _state.copyWith(
          products: ViewState.error(
            'Failed to load best sellers: ${e.toString()}',
          ),
        ),
      );
    }
  }

  // Find product by ID
  ProductModel? findByProdId(String productId) {
    final products = _state.products.data;
    if (products == null) return null;

    try {
      return products.firstWhere((element) => element.productId == productId);
    } catch (e) {
      return null;
    }
  }

  // Search products
  Future<List<ProductModel>> searchProducts({
    required String searchText,
  }) async {
    if (searchText.trim().isEmpty) {
      return _state.products.data ?? [];
    }

    try {
      final response = await _productRepository.searchProducts(
        searchText: searchText,
        pageNumber: 1,
        pageSize: 20,
      );

      if (response.success && response.data != null) {
        return response.data!.items;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error searching products: ${e.toString()}');
      return [];
    }
  }

  // Clear error message
  void clearError() {
    if (_state.products.hasError) {
      _updateState(
        _state.copyWith(
          products: ViewState<List<ProductModel>>.loaded(
            _state.products.data ?? [],
          ),
        ),
      );
    }
  }

  // Update state and notify listeners
  void _updateState(ProductsState newState) {
    _state = newState;
    notifyListeners();
  }
}
