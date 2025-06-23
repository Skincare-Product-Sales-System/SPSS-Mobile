import 'dart:io';
import '../models/api_response_model.dart';
import '../models/review_models.dart';
import '../services/api_service.dart';

class ReviewRepository {
  // Get user reviews
  Future<ApiResponse<ReviewResponse>> getUserReviews({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return ApiService.getUserReviews(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  // Delete a review
  Future<ApiResponse<bool>> deleteReview(String reviewId) async {
    return ApiService.deleteReview(reviewId);
  }

  // Update a review
  Future<ApiResponse<bool>> updateReview({
    required String reviewId,
    required List<String> reviewImages,
    required int ratingValue,
    required String comment,
  }) async {
    return ApiService.updateReview(
      reviewId: reviewId,
      reviewImages: reviewImages,
      ratingValue: ratingValue,
      comment: comment,
    );
  }

  // Upload review image
  Future<ApiResponse<String>> uploadReviewImage(File imageFile) async {
    final requestUrl = '${ApiService.baseUrl}/images';
    return ApiService.uploadImageWithUrl(imageFile, requestUrl, 'files');
  }

  // Delete review image
  Future<ApiResponse<bool>> deleteReviewImage(String imageUrl) async {
    final requestUrl = '${ApiService.baseUrl}/images';
    return ApiService.deleteImageWithQuery(imageUrl, requestUrl);
  }
}
