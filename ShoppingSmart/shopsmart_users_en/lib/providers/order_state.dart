import '../models/order_models.dart';
import '../models/view_state.dart';
import '../models/voucher_model.dart';

class OrderState {
  final ViewState<List<OrderModel>> orders;
  final ViewState<OrderDetailModel> selectedOrder;
  final ViewState<List<VoucherModel>> vouchers;
  final VoucherModel? selectedVoucher;
  final int currentPage;
  final int pageSize;
  final bool hasMoreData;
  final String? selectedOrderStatus;
  final bool isCreatingOrder;
  final String? creatingOrderError;

  // Review-related state
  final List<String> reviewImages;
  final bool isSubmittingReview;
  final bool isUploadingImage;
  final bool isDeletingImage;
  final String? reviewError;
  final bool reviewSubmitted;

  const OrderState({
    this.orders = const ViewState<List<OrderModel>>(),
    this.selectedOrder = const ViewState<OrderDetailModel>(),
    this.vouchers = const ViewState<List<VoucherModel>>(),
    this.selectedVoucher,
    this.currentPage = 1,
    this.pageSize = 10,
    this.hasMoreData = true,
    this.selectedOrderStatus,
    this.isCreatingOrder = false,
    this.creatingOrderError,

    // Initialize review-related state
    this.reviewImages = const [],
    this.isSubmittingReview = false,
    this.isUploadingImage = false,
    this.isDeletingImage = false,
    this.reviewError,
    this.reviewSubmitted = false,
  });

  OrderState copyWith({
    ViewState<List<OrderModel>>? orders,
    ViewState<OrderDetailModel>? selectedOrder,
    ViewState<List<VoucherModel>>? vouchers,
    VoucherModel? selectedVoucher,
    int? currentPage,
    int? pageSize,
    bool? hasMoreData,
    String? selectedOrderStatus,
    bool? isCreatingOrder,
    String? creatingOrderError,

    // Review-related state
    List<String>? reviewImages,
    bool? isSubmittingReview,
    bool? isUploadingImage,
    bool? isDeletingImage,
    String? reviewError,
    bool? reviewSubmitted,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      vouchers: vouchers ?? this.vouchers,
      selectedVoucher: selectedVoucher ?? this.selectedVoucher,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      selectedOrderStatus: selectedOrderStatus ?? this.selectedOrderStatus,
      isCreatingOrder: isCreatingOrder ?? this.isCreatingOrder,
      creatingOrderError: creatingOrderError ?? this.creatingOrderError,

      // Review-related state
      reviewImages: reviewImages ?? this.reviewImages,
      isSubmittingReview: isSubmittingReview ?? this.isSubmittingReview,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      isDeletingImage: isDeletingImage ?? this.isDeletingImage,
      reviewError: reviewError ?? this.reviewError,
      reviewSubmitted: reviewSubmitted ?? this.reviewSubmitted,
    );
  }

  // Phương thức tiện ích để xóa mã giảm giá đã chọn
  OrderState clearSelectedVoucher() {
    return copyWith(selectedVoucher: null);
  }

  // Phương thức tiện ích để xóa lỗi tạo đơn hàng
  OrderState clearCreatingOrderError() {
    return copyWith(creatingOrderError: null);
  }

  // Phương thức tiện ích để đặt lại trạng thái phân trang
  OrderState resetPagination() {
    return copyWith(currentPage: 1, hasMoreData: true);
  }

  // Phương thức tiện ích để đặt lại trạng thái đánh giá
  OrderState resetReviewState() {
    return copyWith(
      reviewImages: [],
      isSubmittingReview: false,
      isUploadingImage: false,
      isDeletingImage: false,
      reviewError: null,
      reviewSubmitted: false,
    );
  }

  // Phương thức tiện ích để thêm URL hình ảnh đánh giá
  OrderState addReviewImage(String url) {
    final updatedImages = List<String>.from(reviewImages)..add(url);
    return copyWith(reviewImages: updatedImages);
  }

  // Phương thức tiện ích để xóa URL hình ảnh đánh giá
  OrderState removeReviewImage(String url) {
    final updatedImages = List<String>.from(reviewImages)..remove(url);
    return copyWith(reviewImages: updatedImages);
  }
}
