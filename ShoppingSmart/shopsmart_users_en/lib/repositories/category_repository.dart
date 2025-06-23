import 'package:shopsmart_users_en/models/api_response_model.dart';
import 'package:shopsmart_users_en/models/category_model.dart';
import 'package:shopsmart_users_en/services/api_service.dart';

class CategoryRepository {
  // Get all categories with pagination
  Future<ApiResponse<PaginatedResponse<CategoryModel>>> getCategories({
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    return ApiService.getCategories(pageNumber: pageNumber, pageSize: pageSize);
  }
}
