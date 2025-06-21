import '../models/api_response_model.dart';
import '../models/skin_type_model.dart';
import '../services/api_service.dart';

class SkinTypeRepository {
  Future<ApiResponse<PaginatedResponse<SkinTypeModel>>> getSkinTypes({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final response = await ApiService.getSkinTypes(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    if (response.success && response.data != null) {
      final items =
          (response.data!.items)
              .map((item) => SkinTypeModel.fromJson(item))
              .toList();

      return ApiResponse<PaginatedResponse<SkinTypeModel>>(
        success: true,
        message: response.message,
        data: PaginatedResponse<SkinTypeModel>(
          items: items,
          totalCount: response.data!.totalCount,
          pageNumber: response.data!.pageNumber,
          pageSize: response.data!.pageSize,
          totalPages: response.data!.totalPages,
        ),
      );
    }

    return ApiResponse<PaginatedResponse<SkinTypeModel>>(
      success: false,
      message: response.message,
      errors: response.errors,
    );
  }
}
