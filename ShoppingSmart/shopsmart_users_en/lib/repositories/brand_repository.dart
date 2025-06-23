import '../models/api_response_model.dart';
import '../models/brand_model.dart';
import '../services/api_service.dart';

class BrandRepository {
  // Get all brands with pagination
  Future<ApiResponse<PaginatedResponse<BrandModel>>> getBrands({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final response = await ApiService.getBrands(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    if (response.success && response.data != null) {
      final items =
          (response.data!.items)
              .map((item) => BrandModel.fromJson(item))
              .toList();

      return ApiResponse<PaginatedResponse<BrandModel>>(
        success: true,
        message: response.message,
        data: PaginatedResponse<BrandModel>(
          items: items,
          totalCount: response.data!.totalCount,
          pageNumber: response.data!.pageNumber,
          pageSize: response.data!.pageSize,
          totalPages: response.data!.totalPages,
        ),
      );
    }

    return ApiResponse<PaginatedResponse<BrandModel>>(
      success: false,
      message: response.message,
      errors: response.errors,
    );
  }
}
