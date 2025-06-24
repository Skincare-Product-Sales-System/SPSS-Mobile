import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/review_model.dart';
import '../models/view_state.dart';
import '../repositories/review_repository.dart';
import '../services/error_handling_service.dart';
import 'base_view_model.dart';
import 'user_reviews_state.dart';

class EnhancedUserReviewsViewModel extends BaseViewModel<UserReviewsState> {
  final ReviewRepository _reviewRepository;

  EnhancedUserReviewsViewModel({ReviewRepository? reviewRepository})
    : _reviewRepository = reviewRepository ?? ReviewRepository(),
      super(const UserReviewsState());

  // Getters
  List<UserReviewModel> get reviews => state.reviews.data ?? [];
  bool get isLoading => state.reviews.isLoading;
  bool get isLoadingMore => state.reviews.isLoadingMore;
  String? get errorMessage => state.reviews.message;
  bool get hasError => state.reviews.hasError;
  bool get hasMoreData => state.hasMoreData;

  // Review edit getters
  List<String> get editReviewImages => state.editReviewImages;
  bool get isSubmittingReview => state.isSubmittingReview;
  bool get isUploadingImage => state.isUploadingImage;
  bool get isDeletingImage => state.isDeletingImage;
  bool get isDeleting => state.isDeleting;
  String? get reviewError => state.reviewError;
  bool get reviewUpdated => state.reviewUpdated;
  String? get selectedReviewId => state.selectedReviewId;

  // Load user reviews
  Future<void> loadUserReviews({bool refresh = false}) async {
    if (refresh) {
      updateState(
        state.copyWith(
          reviews: ViewState.loading(),
          currentPage: 1,
          hasMoreData: true,
        ),
      );
    } else {
      updateState(state.copyWith(reviews: ViewState.loadingMore(reviews)));
    }

    try {
      final response = await _reviewRepository.getUserReviews(
        pageNumber: refresh ? 1 : state.currentPage,
        pageSize: state.pageSize,
      );
      if (response.success && response.data != null) {
        final reviewsData = response.data!;
        // Convert ReviewResponse to a list of UserReviewModel
        final List<UserReviewModel> userReviews = [];

        // Log the number of items for debugging
        debugPrint('API response: ${reviewsData.items.length} reviews found');

        for (final item in reviewsData.items) {
          try {
            // Create UserReviewModel directly
            var userReview = UserReviewModel(
              id: item.id,
              userName: item.userName,
              avatarUrl: item.avatarUrl,
              reviewImages: item.reviewImages,
              variationOptionValues: item.variationOptionValues,
              ratingValue: item.ratingValue,
              comment: item.comment,
              lastUpdatedTime: item.lastUpdatedTime,
              reply: item.reply,
              // Extract product details directly from the ReviewModel which now has these fields
              productImage: item.productImage ?? '',
              productId: item.productId ?? '',
              productName: item.productName ?? '',
              isEditble: item.isEditble ?? false,
            );

            userReviews.add(userReview);

            // Log product details for debugging
            debugPrint(
              'Added review: ${userReview.id}, Product: ${userReview.productNameSafe}',
            );
            debugPrint('Product image: ${userReview.productImageSafe}');
            debugPrint('Product ID: ${userReview.productIdSafe}');
          } catch (e) {
            debugPrint('Error converting ReviewModel to UserReviewModel: $e');
            // Skip this item if there's an error
          }
        }

        final List<UserReviewModel> loadedReviews =
            refresh ? userReviews : [...reviews, ...userReviews];

        updateState(
          state.copyWith(
            reviews: ViewState.loaded(loadedReviews),
            currentPage: refresh ? 2 : state.currentPage + 1,
            hasMoreData: loadedReviews.length < reviewsData.totalCount,
          ),
        );
      } else {
        updateState(
          state.copyWith(
            reviews: ViewState.error(
              response.message ?? 'Failed to load user reviews',
              response.errors,
            ),
          ),
        );
      }
    } catch (e) {
      handleError(e, source: 'loadUserReviews');
      updateState(
        state.copyWith(
          reviews: ViewState.error(
            'Failed to load user reviews: ${e.toString()}',
          ),
        ),
      );
    }
  }

  // Delete review
  // Future<bool> deleteReview(String reviewId) async {
  //   updateState(state.copyWith(isDeleting: true, reviewError: null));

  //   try {
  //     final response = await _reviewRepository.deleteReview(reviewId);

  //     if (response.success && response.data != null && response.data!) {
  //       // Remove the deleted review from the state
  //       final updatedReviews = reviews.where((r) => r.id != reviewId).toList();

  //       updateState(
  //         state.copyWith(
  //           reviews: ViewState.loaded(updatedReviews),
  //           isDeleting: false,
  //         ),
  //       );
  //       return true;
  //     } else {
  //       updateState(
  //         state.copyWith(
  //           isDeleting: false,
  //           reviewError: response.message ?? 'Failed to delete review',
  //         ),
  //       );
  //       return false;
  //     }
  //   } catch (e) {
  //     handleError(e, source: 'deleteReview');
  //     updateState(
  //       state.copyWith(
  //         isDeleting: false,
  //         reviewError: 'Failed to delete review: ${e.toString()}',
  //       ),
  //     );
  //     return false;
  //   }
  // }
  // Prepare for updating review
  void prepareForEdit(UserReviewModel review) {
    // Lưu ảnh ban đầu và ảnh hiện tại giống nhau khi bắt đầu chỉnh sửa
    updateState(
      state.copyWith(
        selectedReviewId: review.id,
        editReviewImages: List<String>.from(review.reviewImages),
        originalReviewImages: List<String>.from(review.reviewImages),
        newlyAddedImages: [], // Không có ảnh mới thêm vào khi bắt đầu
      ),
    );
  }

  // Update review
  Future<bool> updateReview({
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    updateState(state.copyWith(isSubmittingReview: true, reviewError: null));

    try {
      // Get the current images
      final reviewImages = List<String>.from(state.editReviewImages);

      // Lưu lại danh sách ảnh gốc đã bị xóa để xử lý sau khi cập nhật thành công
      final originalImages = List<String>.from(state.originalReviewImages);
      final removedOriginalImages =
          originalImages
              .where((originalImg) => !reviewImages.contains(originalImg))
              .toList();

      final response = await _reviewRepository.updateReview(
        reviewId: reviewId,
        reviewImages: reviewImages,
        ratingValue: rating,
        comment: comment,
      );

      // Reset review edit state regardless of result
      final resetState = state.resetReviewState();

      // Kiểm tra response.success thay vì kiểm tra cả response.data
      if (response.success) {
        // Nếu cập nhật thành công, xóa ảnh gốc đã bị loại bỏ khỏi server
        for (final imageUrl in removedOriginalImages) {
          try {
            debugPrint('Đang xóa ảnh gốc đã bị loại bỏ sau khi lưu: $imageUrl');
            await _reviewRepository.deleteReviewImage(imageUrl);
          } catch (e) {
            debugPrint('Lỗi khi xóa ảnh gốc đã bị loại bỏ: $e');
            // Tiếp tục với ảnh tiếp theo ngay cả khi có lỗi
          }
        }

        // Find and update the review in the state
        final reviewIndex = reviews.indexWhere((r) => r.id == reviewId);
        if (reviewIndex >= 0) {
          final updatedReview = UserReviewModel(
            id: reviewId,
            userName: reviews[reviewIndex].userName,
            avatarUrl: reviews[reviewIndex].avatarUrl,
            reviewImages: reviewImages,
            variationOptionValues: reviews[reviewIndex].variationOptionValues,
            ratingValue: rating,
            comment: comment,
            lastUpdatedTime: DateTime.now(),
            reply: reviews[reviewIndex].reply,
            productImage: reviews[reviewIndex].productImage,
            productId: reviews[reviewIndex].productId,
            productName: reviews[reviewIndex].productName,
            isEditble: reviews[reviewIndex].isEditble,
          );

          final updatedReviews = List<UserReviewModel>.from(reviews);
          updatedReviews[reviewIndex] = updatedReview;

          updateState(
            resetState.copyWith(
              reviews: ViewState.loaded(updatedReviews),
              reviewUpdated: true,
            ),
          );
        } else {
          // If review not found, refresh the list
          loadUserReviews(refresh: true);
          updateState(resetState.copyWith(reviewUpdated: true));
        }
        return true;
      } else {
        updateState(
          resetState.copyWith(
            reviewError: response.message ?? 'Failed to update review',
          ),
        );
        return false;
      }
    } catch (e) {
      handleError(e, source: 'updateReview');

      // Reset review edit state on error
      final resetState = state.resetReviewState();
      updateState(
        resetState.copyWith(
          reviewError: 'Failed to update review: ${e.toString()}',
        ),
      );
      return false;
    }
  }

  // Upload review image
  Future<String?> uploadReviewImage(XFile imageFile) async {
    updateState(state.copyWith(isUploadingImage: true, reviewError: null));

    try {
      final file = File(imageFile.path);
      final response = await _reviewRepository.uploadReviewImage(file);

      if (response.success && response.data != null) {
        final imageUrl = response.data!;

        // Add image to state
        final updatedState = state.addReviewImage(imageUrl);
        updateState(updatedState.copyWith(isUploadingImage: false));
        return imageUrl;
      } else {
        updateState(
          state.copyWith(
            isUploadingImage: false,
            reviewError: response.message ?? 'Failed to upload image',
          ),
        );
        return null;
      }
    } catch (e) {
      handleError(e, source: 'uploadReviewImage');
      updateState(
        state.copyWith(
          isUploadingImage: false,
          reviewError: 'Failed to upload image: ${e.toString()}',
        ),
      );
      return null;
    }
  }

  // Delete review image
  Future<bool> deleteReviewImage(String imageUrl) async {
    updateState(state.copyWith(isDeletingImage: true, reviewError: null));

    try {
      // Kiểm tra xem ảnh này có phải là ảnh mới thêm vào không
      final isNewlyAdded = state.newlyAddedImages.contains(imageUrl);

      // Nếu là ảnh mới thêm vào, xóa ngay khỏi server
      bool success = true;
      if (isNewlyAdded) {
        final response = await _reviewRepository.deleteReviewImage(imageUrl);
        success = response.success && response.data != null && response.data!;

        if (!success) {
          updateState(
            state.copyWith(
              isDeletingImage: false,
              reviewError: response.message ?? 'Failed to delete image',
            ),
          );
          return false;
        }
      }

      // Trong mọi trường hợp, luôn xóa khỏi UI state
      final updatedState = state.removeReviewImage(imageUrl);

      // Nếu là ảnh gốc (không phải ảnh mới thêm), chỉ xóa khỏi UI, không xóa khỏi server
      if (!isNewlyAdded) {
        debugPrint(
          'Ảnh gốc đã được xóa khỏi UI, sẽ chỉ xóa khỏi server nếu người dùng lưu thay đổi',
        );
      }

      updateState(updatedState.copyWith(isDeletingImage: false));
      return true;
    } catch (e) {
      handleError(e, source: 'deleteReviewImage');
      updateState(
        state.copyWith(
          isDeletingImage: false,
          reviewError: 'Failed to delete image: ${e.toString()}',
        ),
      );
      return false;
    }
  }

  // Clean up review images - deletes any images that were uploaded during the edit session
  Future<void> cleanupReviewImages() async {
    // Lấy danh sách ảnh mới thêm vào trước khi reset state
    final imagesToDelete = List<String>.from(state.newlyAddedImages);

    debugPrint(
      'CLEANUP - Danh sách ảnh mới thêm vào cần xóa: ${imagesToDelete.join(", ")}',
    );
    debugPrint('CLEANUP - Tổng số ảnh mới cần xóa: ${imagesToDelete.length}');

    // Reset review state để cập nhật UI ngay lập tức
    final newState = state.resetReviewState();
    updateState(newState);

    // Xóa các ảnh mới thêm vào từ server
    for (final imageUrl in imagesToDelete) {
      try {
        debugPrint('CLEANUP - Đang xóa ảnh mới đã tải lên khi hủy: $imageUrl');
        await _reviewRepository.deleteReviewImage(imageUrl);
      } catch (e) {
        debugPrint('CLEANUP - Lỗi khi xóa ảnh: $e');
        // Tiếp tục với ảnh tiếp theo ngay cả khi có lỗi
      }
    }

    // Ghi log để xác nhận dọn dẹp
    debugPrint(
      'CLEANUP - ĐÃ XÓA ẢNH KHI HỦY: Đã xóa ${imagesToDelete.length} ảnh mới thêm vào',
    );
  }

  @override
  void handleError(
    dynamic error, {
    String? source,
    ErrorSeverity severity = ErrorSeverity.medium,
  }) {
    debugPrint(
      'Error in EnhancedUserReviewsViewModel (${source ?? 'unknown'}): $error',
    );
    // Call parent method to use centralized error handling
    super.handleError(error, source: source, severity: severity);
  }
}
