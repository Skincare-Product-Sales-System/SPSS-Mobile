import '../models/view_state.dart';
import '../models/viewed_product.dart';
import '../repositories/viewed_products_repository.dart';
import '../services/service_locator.dart';
import 'base_view_model.dart';

/// State class for viewed products
class ViewedProductsState {
  final ViewState<List<ViewedProdModel>> viewedProducts;

  const ViewedProductsState({
    this.viewedProducts = const ViewState<List<ViewedProdModel>>(),
  });

  ViewedProductsState copyWith({
    ViewState<List<ViewedProdModel>>? viewedProducts,
  }) {
    return ViewedProductsState(
      viewedProducts: viewedProducts ?? this.viewedProducts,
    );
  }
}

/// ViewModel for viewed products, following MVVM pattern
class EnhancedViewedProductsProvider
    extends BaseViewModel<ViewedProductsState> {
  final ViewedProductsRepository _viewedProductsRepository;

  EnhancedViewedProductsProvider({
    ViewedProductsRepository? viewedProductsRepository,
  }) : _viewedProductsRepository =
           viewedProductsRepository ?? sl<ViewedProductsRepository>(),
       super(const ViewedProductsState());

  /// Getters
  List<ViewedProdModel> get viewedProducts => state.viewedProducts.data ?? [];
  bool get isLoading => state.viewedProducts.isLoading;
  bool get hasError => state.viewedProducts.hasError;
  String? get errorMessage => state.viewedProducts.message;

  /// Load viewed products
  Future<void> loadViewedProducts() async {
    updateState(state.copyWith(viewedProducts: ViewState.loading()));

    try {
      final response = await _viewedProductsRepository.getViewedProducts();
      if (response.success && response.data != null) {
        updateState(
          state.copyWith(viewedProducts: ViewState.loaded(response.data!)),
        );
      } else {
        updateState(
          state.copyWith(
            viewedProducts: ViewState.error(
              response.message ?? 'Failed to load viewed products',
            ),
          ),
        );
      }
    } catch (e) {
      handleError(e, source: 'loadViewedProducts');
      updateState(
        state.copyWith(
          viewedProducts: ViewState.error(
            'An error occurred while loading viewed products: ${e.toString()}',
          ),
        ),
      );
    }
  }

  /// Add product to viewed products
  Future<void> addViewedProduct(String productId) async {
    try {
      final response = await _viewedProductsRepository.addViewedProduct(
        productId,
      );
      if (response.success) {
        loadViewedProducts(); // Reload the list after adding
      }
    } catch (e) {
      handleError(e, source: 'addViewedProduct');
    }
  }

  /// Clear all viewed products
  Future<void> clearViewedProducts() async {
    try {
      final response = await _viewedProductsRepository.clearViewedProducts();
      if (response.success) {
        updateState(state.copyWith(viewedProducts: ViewState.loaded([])));
      }
    } catch (e) {
      handleError(e, source: 'clearViewedProducts');
    }
  }
}
