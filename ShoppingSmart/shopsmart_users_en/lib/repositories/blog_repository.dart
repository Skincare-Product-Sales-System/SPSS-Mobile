import 'package:shopsmart_users_en/models/api_response_model.dart';
import 'package:shopsmart_users_en/models/blog_model.dart';
import 'package:shopsmart_users_en/services/api_service.dart';

class BlogRepository {
  // Get all blogs with pagination
  Future<ApiResponse<PaginatedResponse<BlogModel>>> getBlogs({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return ApiService.getBlogs(pageNumber: pageNumber, pageSize: pageSize);
  }

  // Get blog by ID
  Future<ApiResponse<DetailedBlogModel>> getBlogById(String blogId) async {
    return ApiService.getBlogById(blogId);
  }
}
