import 'package:shopsmart_users_en/models/address_model.dart';
import 'package:shopsmart_users_en/models/api_response_model.dart';
import 'package:shopsmart_users_en/models/auth_models.dart';
import 'package:shopsmart_users_en/models/payment_method_model.dart';
import 'package:shopsmart_users_en/models/user_profile_model.dart';
import 'package:shopsmart_users_en/models/view_state.dart';
import 'package:shopsmart_users_en/repositories/user_repository.dart';
import 'package:shopsmart_users_en/services/error_handling_service.dart';
import 'package:shopsmart_users_en/services/jwt_service.dart';
import 'package:shopsmart_users_en/services/service_locator.dart';
import 'base_view_model.dart';
import 'enhanced_cart_view_model.dart';
import 'profile_state.dart';

/// ViewModel cải tiến cho Profile, kế thừa từ BaseViewModel
class EnhancedProfileViewModel extends BaseViewModel<ProfileState> {
  final UserRepository _userRepository;

  /// Constructor với dependency injection
  EnhancedProfileViewModel({UserRepository? userRepository})
    : _userRepository = userRepository ?? sl<UserRepository>(),
      super(const ProfileState());

  /// Getters tiện ích
  bool get isLoggedIn => state.isLoggedIn;
  UserInfo? get userInfo => state.userInfo;
  UserProfileModel? get userProfile => state.userProfile.data;
  bool get isLoading => state.isLoading;
  bool get isUpdating => state.isUpdating;
  String? get errorMessage => state.errorMessage;

  // Getters for checkout functionality
  List<AddressModel> get addresses => state.addresses.data?.items ?? [];
  List<PaymentMethodModel> get paymentMethods =>
      state.paymentMethods.data?.items ?? [];

  /// Khởi tạo dữ liệu
  Future<void> initialize() async {
    // Kiểm tra đăng nhập
    await checkAuthentication();

    // Nếu đã đăng nhập, tải thông tin profile
    if (isLoggedIn) {
      await fetchUserProfile();
      await fetchAddresses();
      await fetchPaymentMethods();
    }
  }

  /// Kiểm tra trạng thái đăng nhập
  Future<void> checkAuthentication() async {
    updateState(state.copyWith(isLoading: true));

    try {
      final isAuth = await JwtService.isAuthenticated();
      if (isAuth) {
        final token = await JwtService.getStoredToken();
        if (token != null) {
          final tokenData = JwtService.getUserFromToken(token);
          if (tokenData != null) {
            final userInfo = UserInfo.fromTokenData(tokenData);
            updateState(
              state.copyWith(
                isLoggedIn: true,
                userInfo: userInfo,
                isLoading: false,
              ),
            );
            return;
          }
        }
      }

      // Nếu không có token hoặc token không hợp lệ
      updateState(
        state.copyWith(
          isLoggedIn: false,
          userInfo: null,
          userProfile: const ViewState<UserProfileModel>(),
          isLoading: false,
        ),
      );
    } catch (e) {
      updateState(
        state.copyWith(
          isLoggedIn: false,
          userInfo: null,
          userProfile: const ViewState<UserProfileModel>(),
          isLoading: false,
          errorMessage: 'Lỗi khi kiểm tra đăng nhập: ${e.toString()}',
        ),
      );
      handleError(e, source: 'checkAuthentication');
    }
  }

  /// Tải thông tin profile người dùng
  Future<void> fetchUserProfile() async {
    if (!isLoggedIn) {
      updateState(
        state.copyWith(
          errorMessage: 'Bạn cần đăng nhập để xem thông tin profile',
        ),
      );
      return;
    }

    updateState(
      state.copyWith(
        userProfile: ViewState<UserProfileModel>.loading(),
        errorMessage: null,
      ),
    );

    try {
      final response = await _userRepository.getUserProfile();
      if (response.success && response.data != null) {
        updateState(
          state.copyWith(
            userProfile: ViewState<UserProfileModel>.loaded(response.data!),
            errorMessage: null,
          ),
        );
      } else {
        updateState(
          state.copyWith(
            userProfile: ViewState<UserProfileModel>.error(
              response.message ?? 'Không thể tải thông tin profile',
            ),
            errorMessage: response.message,
          ),
        );
        handleError(
          response.message ?? 'Không thể tải thông tin profile',
          source: 'fetchUserProfile',
          severity: ErrorSeverity.medium,
        );
      }
    } catch (e) {
      String errorMessage;
      if (e is FormatException) {
        errorMessage = 'Lỗi định dạng dữ liệu: ${e.message}';
      } else {
        errorMessage = 'Lỗi khi tải thông tin profile: ${e.toString()}';
      }

      updateState(
        state.copyWith(
          userProfile: ViewState<UserProfileModel>.error(errorMessage),
          errorMessage: errorMessage,
        ),
      );
      handleError(e, source: 'fetchUserProfile');
    }
  }

  /// Cập nhật thông tin profile
  Future<void> updateProfile(UpdateProfileRequest request) async {
    if (!isLoggedIn) {
      updateState(
        state.copyWith(
          errorMessage: 'Bạn cần đăng nhập để cập nhật thông tin profile',
        ),
      );
      return;
    }

    updateState(state.copyWith(isUpdating: true, errorMessage: null));

    try {
      final response = await _userRepository.updateUserProfile(request);
      if (response.success && response.data != null) {
        updateState(
          state.copyWith(
            userProfile: ViewState<UserProfileModel>.loaded(response.data!),
            isUpdating: false,
            errorMessage: null,
          ),
        );
      } else {
        updateState(
          state.copyWith(
            isUpdating: false,
            errorMessage:
                response.message ?? 'Không thể cập nhật thông tin profile',
          ),
        );
        handleError(
          response.message ?? 'Không thể cập nhật thông tin profile',
          source: 'updateProfile',
          severity: ErrorSeverity.medium,
        );
      }
    } catch (e) {
      updateState(
        state.copyWith(
          isUpdating: false,
          errorMessage: 'Lỗi khi cập nhật thông tin profile: ${e.toString()}',
        ),
      );
      handleError(e, source: 'updateProfile');
    }
  }

  /// Cập nhật ảnh đại diện
  Future<void> updateAvatar(String imagePath) async {
    updateState(state.copyWith(isUpdating: true, errorMessage: null));

    try {
      final response = await _userRepository.updateAvatar(imagePath);
      if (response.success && response.data != null) {
        // Sau khi cập nhật ảnh đại diện, lấy lại thông tin profile
        await fetchUserProfile();
      } else {
        updateState(
          state.copyWith(
            isUpdating: false,
            errorMessage: response.message ?? 'Không thể cập nhật ảnh đại diện',
          ),
        );
      }
    } catch (error) {
      handleError(error, source: 'updateAvatar');
      updateState(
        state.copyWith(
          isUpdating: false,
          errorMessage: 'Không thể cập nhật ảnh đại diện',
        ),
      );
    }
  }

  /// Đổi mật khẩu
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    updateState(state.copyWith(isUpdating: true, errorMessage: null));

    try {
      final response = await _userRepository.changePassword(
        currentPassword,
        newPassword,
        confirmNewPassword,
      );

      updateState(state.copyWith(isUpdating: false));

      if (!response.success) {
        updateState(state.copyWith(errorMessage: response.message));
      }

      return response.success;
    } catch (error) {
      handleError(error, source: 'changePassword');
      updateState(
        state.copyWith(
          isUpdating: false,
          errorMessage: 'Không thể đổi mật khẩu',
        ),
      );
      return false;
    }
  }

  /// Xử lý chuyển đổi theme
  void toggleTheme() {
    // Xử lý chuyển đổi chế độ tối/sáng ở đây nếu cần
  }

  /// Đăng xuất
  Future<void> logout() async {
    await JwtService.clearTokens();
    updateState(
      state.copyWith(
        isLoggedIn: false,
        userInfo: null,
        userProfile: const ViewState<UserProfileModel>(),
        addresses: const ViewState<PaginatedResponse<AddressModel>>(),
        paymentMethods:
            const ViewState<PaginatedResponse<PaymentMethodModel>>(),
      ),
    );

    // Clear cart data only locally - get the CartViewModel instance
    final cartViewModel = sl<EnhancedCartViewModel>();
    await cartViewModel.clearLocalCart();
  }

  /// Fetch user addresses
  Future<void> fetchAddresses() async {
    updateState(
      state.copyWith(
        addresses: ViewState<PaginatedResponse<AddressModel>>.loading(),
      ),
    );

    try {
      final response = await _userRepository.getAddresses();

      if (response.success && response.data != null) {
        updateState(
          state.copyWith(
            addresses: ViewState<PaginatedResponse<AddressModel>>.loaded(
              response.data!,
            ),
            errorMessage: null,
          ),
        );
      } else {
        updateState(
          state.copyWith(
            addresses: ViewState<PaginatedResponse<AddressModel>>.error(
              response.message ?? 'Failed to load addresses',
            ),
            errorMessage: response.message,
          ),
        );
      }
    } catch (e) {
      final errorMsg = 'Error fetching addresses: ${e.toString()}';
      updateState(
        state.copyWith(
          addresses: ViewState<PaginatedResponse<AddressModel>>.error(errorMsg),
          errorMessage: errorMsg,
        ),
      );
    }
  }

  /// Fetch payment methods
  Future<void> fetchPaymentMethods() async {
    updateState(
      state.copyWith(
        paymentMethods:
            ViewState<PaginatedResponse<PaymentMethodModel>>.loading(),
      ),
    );

    try {
      final response = await _userRepository.getPaymentMethods();

      if (response.success && response.data != null) {
        updateState(
          state.copyWith(
            paymentMethods:
                ViewState<PaginatedResponse<PaymentMethodModel>>.loaded(
                  response.data!,
                ),
            errorMessage: null,
          ),
        );
      } else {
        updateState(
          state.copyWith(
            paymentMethods:
                ViewState<PaginatedResponse<PaymentMethodModel>>.error(
                  response.message ?? 'Failed to load payment methods',
                ),
            errorMessage: response.message,
          ),
        );
      }
    } catch (e) {
      final errorMsg = 'Error fetching payment methods: ${e.toString()}';
      updateState(
        state.copyWith(
          paymentMethods:
              ViewState<PaginatedResponse<PaymentMethodModel>>.error(errorMsg),
          errorMessage: errorMsg,
        ),
      );
    }
  }

  /// Kiểm tra và cập nhật lại trạng thái đăng nhập
  Future<void> checkLoginStatus() async {
    await checkAuthentication();
    if (isLoggedIn) {
      await fetchUserProfile();
    }
  }
}
