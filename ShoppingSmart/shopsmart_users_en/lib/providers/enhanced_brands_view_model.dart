import 'package:flutter/foundation.dart';
import '../models/brand_model.dart';
import '../models/view_state.dart';
import '../repositories/brand_repository.dart';
import '../services/error_handling_service.dart';
import 'base_view_model.dart';

class EnhancedBrandsViewModel extends BaseViewModel<BrandsState> {
  final BrandRepository _brandRepository;
  EnhancedBrandsViewModel({BrandRepository? brandRepository})
    : _brandRepository = brandRepository ?? BrandRepository(),
      super(const BrandsState()) {
    debugPrint('EnhancedBrandsViewModel initialized');
  }

  // Getters
  List<BrandModel> get brands => state.brands.data ?? [];
  bool get isLoading => state.brands.isLoading;
  bool get hasError => state.brands.hasError;
  String? get errorMessage => state.brands.message;
  String? get selectedBrandId => state.selectedBrandId;

  // Load brands
  Future<void> loadBrands({bool refresh = false}) async {
    debugPrint('EnhancedBrandsViewModel: Loading brands');
    if (refresh) {
      updateState(state.copyWith(brands: ViewState.loading()));
    }

    try {
      final response = await _brandRepository.getBrands();

      debugPrint(
        'EnhancedBrandsViewModel: Brands response success=${response.success}',
      );

      if (response.success && response.data != null) {
        updateState(
          state.copyWith(brands: ViewState.loaded(response.data!.items)),
        );
        debugPrint(
          'EnhancedBrandsViewModel: Loaded ${response.data!.items.length} brands',
        );
      } else {
        updateState(
          state.copyWith(
            brands: ViewState.error(
              response.message ?? 'Failed to load brands',
              response.errors,
            ),
          ),
        );
        debugPrint(
          'EnhancedBrandsViewModel: Failed to load brands: ${response.message}',
        );
        debugPrint('EnhancedBrandsViewModel: Errors: ${response.errors}');
        handleError(
          response.message ?? 'Failed to load brands',
          source: 'loadBrands',
          severity: ErrorSeverity.medium,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('EnhancedBrandsViewModel: Error loading brands: $e');
      debugPrint(stackTrace.toString());
      handleError(e, source: 'loadBrands', severity: ErrorSeverity.high);
      updateState(
        state.copyWith(
          brands: ViewState.error('Failed to load brands: ${e.toString()}'),
        ),
      );
    }
  }

  // Select brand
  void selectBrand(String? brandId) {
    updateState(state.copyWith(selectedBrandId: brandId));
  }

  // Clear selection
  void clearSelection() {
    updateState(state.copyWith(selectedBrandId: null));
  }

  // Find brand by ID
  BrandModel? findBrandById(String id) {
    try {
      return brands.firstWhere((brand) => brand.id == id);
    } catch (e) {
      return null;
    }
  }
}

class BrandsState {
  final ViewState<List<BrandModel>> brands;
  final String? selectedBrandId;

  const BrandsState({
    this.brands = const ViewState<List<BrandModel>>(),
    this.selectedBrandId,
  });

  BrandsState copyWith({
    ViewState<List<BrandModel>>? brands,
    String? selectedBrandId,
  }) {
    return BrandsState(
      brands: brands ?? this.brands,
      selectedBrandId: selectedBrandId ?? this.selectedBrandId,
    );
  }
}
