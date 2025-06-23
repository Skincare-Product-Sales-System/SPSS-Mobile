import 'package:uuid/uuid.dart';
import '../models/view_state.dart';
import '../models/wishlist_model.dart';
import '../repositories/wishlist_repository.dart';
import '../services/error_handling_service.dart';
import '../services/service_locator.dart';
import 'base_view_model.dart';
import 'wishlist_state.dart';

/// ViewModel cải tiến cho Wishlist, kế thừa từ BaseViewModel
class EnhancedWishlistViewModel extends BaseViewModel<WishlistState> {
  final WishlistRepository _wishlistRepository;

  /// Constructor với dependency injection cho repository
  EnhancedWishlistViewModel({WishlistRepository? wishlistRepository})
    : _wishlistRepository = wishlistRepository ?? sl<WishlistRepository>(),
      super(const WishlistState());

  /// Getters tiện ích
  Map<String, WishlistModel> get wishlistItems =>
      state.wishlistItems.data ?? {};
  bool get isLoading => state.wishlistItems.isLoading;
  bool get isProcessing => state.isProcessing;
  String? get errorMessage => state.errorMessage;
  bool get hasError => state.errorMessage != null;
  int get count => state.count;
  bool get isEmpty => wishlistItems.isEmpty;

  /// Tải danh sách yêu thích từ server
  Future<void> fetchWishlistFromServer() async {
    updateState(
      state.copyWith(wishlistItems: ViewState.loading(), errorMessage: null),
    );

    try {
      final response = await _wishlistRepository.getWishlistItems();
      if (response.success && response.data != null) {
        final Map<String, WishlistModel> items = {};
        for (var item in response.data!) {
          items[item.productId] = item;
        }
        updateState(
          state.copyWith(
            wishlistItems: ViewState.loaded(items),
            errorMessage: null,
          ),
        );
      } else {
        updateState(
          state.copyWith(
            wishlistItems: ViewState.error(
              response.message ?? 'Failed to load wishlist',
              response.errors,
            ),
            errorMessage: response.message,
          ),
        );
        handleError(
          response.message ?? 'Failed to load wishlist',
          source: 'fetchWishlistFromServer',
          severity: ErrorSeverity.medium,
        );
      }
    } catch (e) {
      final errorMsg = 'Lỗi khi tải danh sách yêu thích: ${e.toString()}';
      updateState(
        state.copyWith(
          wishlistItems: ViewState.error(errorMsg),
          errorMessage: errorMsg,
        ),
      );
      handleError(
        e,
        source: 'fetchWishlistFromServer',
        severity: ErrorSeverity.medium,
      );
    }
  }

  /// Thêm hoặc xóa sản phẩm từ danh sách yêu thích
  Future<void> addOrRemoveFromWishlist({required String productId}) async {
    updateState(state.copyWith(isProcessing: true, errorMessage: null));

    try {
      if (state.hasProduct(productId)) {
        // Xóa khỏi danh sách yêu thích
        final response = await _wishlistRepository.removeFromWishlist(
          productId,
        );

        if (response.success) {
          final newItems = Map<String, WishlistModel>.from(wishlistItems);
          newItems.remove(productId);

          updateState(
            state.copyWith(
              wishlistItems: ViewState.loaded(newItems),
              isProcessing: false,
            ),
          );
        } else {
          updateState(
            state.copyWith(isProcessing: false, errorMessage: response.message),
          );
          handleError(
            response.message ?? 'Failed to remove from wishlist',
            source: 'removeFromWishlist',
            severity: ErrorSeverity.medium,
          );
        }
      } else {
        // Thêm vào danh sách yêu thích
        final response = await _wishlistRepository.addToWishlist(productId);

        if (response.success) {
          final newItems = Map<String, WishlistModel>.from(wishlistItems);
          newItems[productId] = WishlistModel(
            wishlistId: const Uuid().v4(),
            productId: productId,
          );

          updateState(
            state.copyWith(
              wishlistItems: ViewState.loaded(newItems),
              isProcessing: false,
            ),
          );
        } else {
          updateState(
            state.copyWith(isProcessing: false, errorMessage: response.message),
          );
          handleError(
            response.message ?? 'Failed to add to wishlist',
            source: 'addToWishlist',
            severity: ErrorSeverity.medium,
          );
        }
      }
    } catch (e) {
      final errorMsg = 'Lỗi khi cập nhật danh sách yêu thích: ${e.toString()}';
      updateState(state.copyWith(isProcessing: false, errorMessage: errorMsg));
      handleError(
        e,
        source: 'addOrRemoveFromWishlist',
        severity: ErrorSeverity.medium,
      );
    }
  }

  /// Kiểm tra xem sản phẩm có trong danh sách yêu thích không
  bool isInWishlist(String productId) {
    return state.hasProduct(productId);
  }

  /// Xóa lỗi
  void clearError() {
    if (state.errorMessage != null) {
      updateState(state.clearError());
    }
  }

  /// Xóa toàn bộ danh sách yêu thích
  void clearWishlist() {
    updateState(state.copyWith(wishlistItems: ViewState.loaded({})));
    // Trong thực tế, có thể thêm API để xóa toàn bộ danh sách yêu thích
  }
}
