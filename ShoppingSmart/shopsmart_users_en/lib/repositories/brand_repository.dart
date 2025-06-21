import '../models/api_response_model.dart';
import '../services/api_service.dart';

class BrandRepository {
  // Get all brands with pagination
  Future<ApiResponse<PaginatedResponse<dynamic>>> getBrands({
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    return ApiService.getBrands(pageNumber: pageNumber, pageSize: pageSize);
  }
}
