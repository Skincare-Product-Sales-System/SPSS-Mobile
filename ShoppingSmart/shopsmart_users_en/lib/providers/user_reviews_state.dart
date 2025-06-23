import '../models/review_model.dart';
import '../models/view_state.dart';

class UserReviewsState {
  // Main state properties
  final ViewState<List<UserReviewModel>> reviews;
  final int currentPage;
  final int pageSize;
  final bool hasMoreData;

  // Edit review properties
  final String? selectedReviewId;
  final List<String> editReviewImages;
  final List<String> originalReviewImages; // Danh sách ảnh ban đầu
  final List<String> newlyAddedImages; // Danh sách ảnh mới thêm vào
  final bool isSubmittingReview;
  final bool isUploadingImage;
  final bool isDeletingImage;
  final bool isDeleting;
  final String? reviewError;
  final bool reviewUpdated;

  // Constructor
  const UserReviewsState({
    this.reviews = const ViewState<List<UserReviewModel>>(),
    this.currentPage = 1,
    this.pageSize = 10,
    this.hasMoreData = true,

    // Edit review properties
    this.selectedReviewId,
    this.editReviewImages = const [],
    this.originalReviewImages = const [],
    this.newlyAddedImages = const [],
    this.isSubmittingReview = false,
    this.isUploadingImage = false,
    this.isDeletingImage = false,
    this.isDeleting = false,
    this.reviewError,
    this.reviewUpdated = false,
  });

  // Copy with method for immutable state updates
  UserReviewsState copyWith({
    ViewState<List<UserReviewModel>>? reviews,
    int? currentPage,
    int? pageSize,
    bool? hasMoreData,

    // For edits to set or clear
    String? selectedReviewId,
    bool clearSelectedReview = false,
    List<String>? editReviewImages,
    List<String>? originalReviewImages,
    List<String>? newlyAddedImages,
    bool? isSubmittingReview,
    bool? isUploadingImage,
    bool? isDeletingImage,
    bool? isDeleting,
    String? reviewError,
    bool clearReviewError = false,
    bool? reviewUpdated,
  }) {
    return UserReviewsState(
      reviews: reviews ?? this.reviews,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      hasMoreData: hasMoreData ?? this.hasMoreData,

      selectedReviewId:
          clearSelectedReview
              ? null
              : (selectedReviewId ?? this.selectedReviewId),
      editReviewImages: editReviewImages ?? this.editReviewImages,
      originalReviewImages: originalReviewImages ?? this.originalReviewImages,
      newlyAddedImages: newlyAddedImages ?? this.newlyAddedImages,
      isSubmittingReview: isSubmittingReview ?? this.isSubmittingReview,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      isDeletingImage: isDeletingImage ?? this.isDeletingImage,
      isDeleting: isDeleting ?? this.isDeleting,
      reviewError: clearReviewError ? null : (reviewError ?? this.reviewError),
      reviewUpdated: reviewUpdated ?? this.reviewUpdated,
    );
  }

  // Add review image
  UserReviewsState addReviewImage(String imageUrl) {
    final updatedImages = List<String>.from(editReviewImages)..add(imageUrl);
    final updatedNewImages = List<String>.from(newlyAddedImages)..add(imageUrl);
    return copyWith(
      editReviewImages: updatedImages,
      newlyAddedImages: updatedNewImages,
    );
  }

  // Remove review image
  UserReviewsState removeReviewImage(String imageUrl) {
    final updatedImages = List<String>.from(editReviewImages)..remove(imageUrl);
    // Chỉ xóa khỏi danh sách newlyAddedImages nếu nó là ảnh mới thêm
    final updatedNewImages = List<String>.from(newlyAddedImages);
    if (newlyAddedImages.contains(imageUrl)) {
      updatedNewImages.remove(imageUrl);
    }
    return copyWith(
      editReviewImages: updatedImages,
      newlyAddedImages: updatedNewImages,
    );
  }

  // Reset review state
  UserReviewsState resetReviewState() {
    return copyWith(
      selectedReviewId: null,
      clearSelectedReview: true,
      editReviewImages: [],
      originalReviewImages: [],
      newlyAddedImages: [],
      isSubmittingReview: false,
      isUploadingImage: false,
      isDeletingImage: false,
      isDeleting: false,
      reviewError: null,
      clearReviewError: true,
      reviewUpdated: false,
    );
  }
}
