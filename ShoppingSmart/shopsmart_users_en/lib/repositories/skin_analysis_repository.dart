import 'dart:io';
import 'package:shopsmart_users_en/models/api_response_model.dart';
import 'package:shopsmart_users_en/models/skin_analysis_models.dart';
import 'package:shopsmart_users_en/services/api_service.dart';

class SkinAnalysisRepository {
  // Analyze skin from image
  Future<ApiResponse<SkinAnalysisResult>> analyzeSkin(File imageFile) async {
    return ApiService.analyzeSkin(imageFile);
  }

  // Get skin analysis history
  Future<ApiResponse<List<SkinAnalysisResult>>> getSkinAnalysisHistory({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final response = await ApiService.getSkinAnalysisHistory(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    // Đảm bảo data không null
    if (response.success && response.data == null) {
      return ApiResponse<List<SkinAnalysisResult>>(
        success: response.success,
        data: [],
        message: response.message,
        errors: response.errors,
      );
    }

    return response;
  }

  // Get skin analysis detail by ID
  Future<ApiResponse<SkinAnalysisResult>> getSkinAnalysisById(String id) async {
    return ApiService.getSkinAnalysisById(id);
  }

  // Analyze skin with payment
  Future<ApiResponse<SkinAnalysisResult>> analyzeSkinWithPayment(
    File imageFile,
  ) async {
    return ApiService.analyzeSkinWithPayment(imageFile);
  }
}
