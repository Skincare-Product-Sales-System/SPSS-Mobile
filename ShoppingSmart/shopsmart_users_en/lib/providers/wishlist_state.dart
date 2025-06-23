import '../models/view_state.dart';
import '../models/wishlist_model.dart';

/// Lớp quản lý state cho danh sách yêu thích
class WishlistState {
  /// Trạng thái danh sách sản phẩm yêu thích với ViewState để kiểm soát quá trình loading
  final ViewState<Map<String, WishlistModel>> wishlistItems;

  /// Chỉ báo hoạt động đang thực hiện
  final bool isProcessing;

  /// Thông báo lỗi khi thực hiện các thao tác trên danh sách yêu thích
  final String? errorMessage;

  /// Constructor với giá trị mặc định
  const WishlistState({
    this.wishlistItems = const ViewState<Map<String, WishlistModel>>(),
    this.isProcessing = false,
    this.errorMessage,
  });

  /// Phương thức tạo state mới với một số thuộc tính được thay đổi
  WishlistState copyWith({
    ViewState<Map<String, WishlistModel>>? wishlistItems,
    bool? isProcessing,
    String? errorMessage,
  }) {
    return WishlistState(
      wishlistItems: wishlistItems ?? this.wishlistItems,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Phương thức xóa thông báo lỗi
  WishlistState clearError() {
    return copyWith(errorMessage: null);
  }

  /// Tổng số sản phẩm yêu thích
  int get count => wishlistItems.data?.length ?? 0;

  /// Kiểm tra xem một sản phẩm có trong danh sách yêu thích hay không
  bool hasProduct(String productId) {
    return wishlistItems.data?.containsKey(productId) ?? false;
  }
}
