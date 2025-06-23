import 'package:flutter/foundation.dart';
import '../models/skin_type_model.dart';
import '../models/view_state.dart';
import '../repositories/skin_type_repository.dart';
import '../services/error_handling_service.dart';
import 'base_view_model.dart';

class EnhancedSkinTypesViewModel extends BaseViewModel<SkinTypesState> {
  final SkinTypeRepository _skinTypeRepository;
  EnhancedSkinTypesViewModel({SkinTypeRepository? skinTypeRepository})
    : _skinTypeRepository = skinTypeRepository ?? SkinTypeRepository(),
      super(const SkinTypesState()) {
    debugPrint('EnhancedSkinTypesViewModel initialized');
  }

  // Getters
  List<SkinTypeModel> get skinTypes => state.skinTypes.data ?? [];
  bool get isLoading => state.skinTypes.isLoading;
  bool get hasError => state.skinTypes.hasError;
  String? get errorMessage => state.skinTypes.message;
  String? get selectedSkinTypeId => state.selectedSkinTypeId;

  // Load skin types
  Future<void> loadSkinTypes({bool refresh = false}) async {
    if (refresh) {
      updateState(state.copyWith(skinTypes: ViewState.loading()));
    }

    try {
      final response = await _skinTypeRepository.getSkinTypes();

      if (response.success && response.data != null) {
        updateState(
          state.copyWith(skinTypes: ViewState.loaded(response.data!.items)),
        );
      } else {
        updateState(
          state.copyWith(
            skinTypes: ViewState.error(
              response.message ?? 'Failed to load skin types',
              response.errors,
            ),
          ),
        );
        handleError(
          response.message ?? 'Failed to load skin types',
          source: 'loadSkinTypes',
          severity: ErrorSeverity.medium,
        );
      }
    } catch (e) {
      handleError(e, source: 'loadSkinTypes', severity: ErrorSeverity.high);
      updateState(
        state.copyWith(
          skinTypes: ViewState.error(
            'Failed to load skin types: ${e.toString()}',
          ),
        ),
      );
    }
  }

  // Select skin type
  void selectSkinType(String? skinTypeId) {
    updateState(state.copyWith(selectedSkinTypeId: skinTypeId));
  }

  // Clear selection
  void clearSelection() {
    updateState(state.copyWith(selectedSkinTypeId: null));
  }

  // Find skin type by ID
  SkinTypeModel? findSkinTypeById(String id) {
    try {
      return skinTypes.firstWhere((skinType) => skinType.id == id);
    } catch (e) {
      return null;
    }
  }
}

class SkinTypesState {
  final ViewState<List<SkinTypeModel>> skinTypes;
  final String? selectedSkinTypeId;

  const SkinTypesState({
    this.skinTypes = const ViewState<List<SkinTypeModel>>(),
    this.selectedSkinTypeId,
  });

  SkinTypesState copyWith({
    ViewState<List<SkinTypeModel>>? skinTypes,
    String? selectedSkinTypeId,
  }) {
    return SkinTypesState(
      skinTypes: skinTypes ?? this.skinTypes,
      selectedSkinTypeId: selectedSkinTypeId ?? this.selectedSkinTypeId,
    );
  }
}
